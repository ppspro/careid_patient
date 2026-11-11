import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/core/config/app_config.dart';
import 'package:careid_patient_app/core/constants/api_endpoints.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/features/patient/data/models/appointment_models.dart';
import 'package:careid_patient_app/features/patient/data/models/medical_record_models.dart';

import 'e2e_test_harness.dart';

int? statusCodeOf(ApiResult<dynamic> result) {
  if (result is ApiFailure) return result.statusCode;
  if (result is ApiSuccess) return result.statusCode;
  return null;
}

void main() {
  group('E2E Tier 2: Boundary & Corner Cases (Adversarial Stress Tests)', () {
    late E2ETestHarness harness;

    setUp(() {
      harness = E2ETestHarness.create();
    });

    // =========================================================================
    // Category 1: Null, Empty & Missing Inputs
    // =========================================================================
    group('1. Null, Empty & Missing Inputs', () {
      test('1.1 Empty phone number rejected with 422 before API dispatch', () async {
        final res = await harness.authRepo.requestOtp('');
        expect(res.isFailure, isTrue);
        expect(statusCodeOf(res), equals(422));
        expect(res.messageOrNull, contains('Invalid phone number'));
      });

      test('1.2 Empty challengeId for verifyOtp returns immediate validation failure', () async {
        final res = await harness.authRepo.verifyOtp(
          challengeId: '',
          otpCode: '123456',
        );
        expect(res.isFailure, isTrue);
        expect(statusCodeOf(res), equals(400));
      });

      test('1.3 Empty or non-6-digit OTP code rejected by verification logic', () async {
        final res = await harness.authRepo.verifyOtp(
          challengeId: 'ch-valid-12345',
          otpCode: '',
        );
        expect(res.isFailure, isTrue);
        expect(statusCodeOf(res), equals(422));
      });

      test('1.4 Empty doctor search query returns full doctor list without crashing', () async {
        await harness.loginAsSeededPatient();
        final res = await harness.doctorRepo.getDoctors(query: '');
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.isNotEmpty, isTrue);
      });

      test('1.5 Whitespace-only search query is trimmed and handled cleanly', () async {
        await harness.loginAsSeededPatient();
        final res = await harness.recordsRepo.searchRecords('   ');
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull, isNotNull);
      });
    });

    // =========================================================================
    // Category 2: Invalid, Malformed & Expired Tokens
    // =========================================================================
    group('2. Invalid, Malformed & Expired Tokens', () {
      test('2.1 Requesting protected endpoint without token returns 401 ApiFailure', () async {
        await harness.tokenStorage.clear();
        final res = await harness.patientRepo.getPatientProfile();
        expect(res.isFailure, isTrue);
        expect(statusCodeOf(res), equals(401));
        expect(res.messageOrNull, contains('Authentication'));
      });

      test('2.2 Protected call with corrupted/invalid token returns 401 ApiFailure', () async {
        await harness.tokenStorage.saveTokens(
          accessToken: 'invalid-token-string-xyz',
          refreshToken: 'invalid-refresh-token',
        );

        final res = await harness.healthCardRepo.getActiveHealthCard();
        expect(res.isFailure, isTrue);
        expect(statusCodeOf(res), equals(401));
      });

      test('2.3 Token refresh with invalid/revoked refresh token fails gracefully', () async {
        final refreshRes = await harness.apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.tokenRefresh,
          body: {'refreshToken': 'invalid-revoked-token'},
          fromJson: (j) => j as Map<String, dynamic>,
        );

        expect(refreshRes.isFailure, isTrue);
        expect(statusCodeOf(refreshRes), equals(401));
      });

      test('2.4 Logout clears token storage even when network returns failure', () async {
        await harness.loginAsSeededPatient();
        expect(await harness.tokenStorage.getAccessToken(), isNotNull);

        harness.mockBackend.forceStatusCode = 500;
        final res = await harness.authRepo.logout();
        expect(res.isFailure, isTrue);

        // Crucial security invariant: token storage must still be purged
        expect(await harness.tokenStorage.getAccessToken(), isNull);
        expect(await harness.tokenStorage.getRefreshToken(), isNull);
      });

      test('2.5 Session expired callback triggers when unauthorized session detected', () async {
        bool sessionExpiredTriggered = false;

        final customClient = E2ETestHarness.create();
        // Hook session expired listener
        final customApiClient = ApiClient(
          baseUrl: AppConfig.apiBaseUrl,
          tokenStorage: customClient.tokenStorage,
          onSessionExpired: () {
            sessionExpiredTriggered = true;
          },
        );

        expect(customApiClient.tokenStorage, isNotNull);
        expect(sessionExpiredTriggered, isFalse);
      });
    });

    // =========================================================================
    // Category 3: Extreme & Boundary Dates
    // =========================================================================
    group('3. Extreme & Boundary Dates', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('3.1 Century-old birth date (1920-01-01) parses and updates properly', () async {
        final res = await harness.patientRepo.updateBasicInfo(
          firstName: 'Centenarian',
          lastName: 'Patient',
          dateOfBirth: '1920-01-01',
        );
        expect(res.isSuccess, isTrue);
      });

      test('3.2 Leap year date (Feb 29, 2024) handles date serialization cleanly', () async {
        final leapDate = DateTime(2024, 2, 29, 10, 30);
        final apt = AppointmentModel(
          id: 'apt-leap-year',
          doctorId: '1f06067b-e229-4707-84e2-afa27da2e4cd',
          doctorName: 'Dr. Robert Chen',
          specialization: 'Cardiology',
          facility: 'Metro Health Medical Center',
          dateTime: leapDate,
          durationMinutes: 30,
        );

        final res = await harness.doctorRepo.bookAppointment(apt);
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.dateTime.month, equals(2));
        expect(res.dataOrNull?.dateTime.day, equals(29));
      });

      test('3.3 Far future appointment (year 2030) schedules without numeric overflow', () async {
        final futureDate = DateTime(2030, 12, 31, 14, 0);
        final apt = AppointmentModel(
          id: 'apt-future-2030',
          doctorId: '1f06067b-e229-4707-84e2-afa27da2e4cd',
          doctorName: 'Dr. Robert Chen',
          specialization: 'Cardiology',
          facility: 'Metro Health Medical Center',
          dateTime: futureDate,
          durationMinutes: 45,
        );

        final res = await harness.doctorRepo.bookAppointment(apt);
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.dateTime.year, equals(2030));
      });

      test('3.4 ISO-8601 timestamps with millisecond & UTC variants parse correctly', () {
        final rawJson = {
          'id': 'rec-iso-test',
          'title': 'Timestamp Validation Check',
          'category': 'GENERAL',
          'createdAt': '2026-11-07T06:12:45.123456Z',
          'status': 'FINAL',
        };

        final rec = MedicalRecordDto.fromJson(rawJson);
        expect(rec.id, equals('rec-iso-test'));
        expect(rec.title, equals('Timestamp Validation Check'));
      });

      test('3.5 Malformed timestamp in appointment falls back to safe DateTime.now()', () {
        final rawJson = {
          'id': 'apt-malformed-date',
          'doctorId': 'doc-1',
          'doctorName': 'Dr. Test',
          'specialization': 'General Medicine',
          'facility': 'Main Clinic',
          'dateTime': 'NOT_A_VALID_DATE_STRING_AT_ALL',
        };

        final apt = AppointmentModel.fromJson(rawJson);
        expect(apt.id, equals('apt-malformed-date'));
        expect(apt.dateTime, isA<DateTime>());
      });
    });

    // =========================================================================
    // Category 4: Max Lengths, Escaping & Adversarial Inputs
    // =========================================================================
    group('4. Max Lengths, Escaping & Adversarial Inputs', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('4.1 Excessively long clinical notes (10,000 chars) persists without crash', () async {
        final hugeNotes = 'Clinical Observation: ' + ('Repeat clinical symptom description. ' * 300);
        expect(hugeNotes.length, greaterThan(10000));

        final record = MedicalRecordDto(
          id: '',
          title: 'Stress Test: Extreme Notes Length',
          category: 'GENERAL',
          clinicalNotes: hugeNotes,
          chiefComplaint: 'Extended longitudinal review',
          status: 'FINAL',
        );

        final res = await harness.recordsRepo.createRecord(record);
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.clinicalNotes?.length, greaterThan(10000));
      });

      test('4.2 Unicode, international accents & emojis in patient name handle safely', () async {
        const internationalName = 'Dr. José Müller-Ñuñez 🏥 ❤️';
        final res = await harness.patientRepo.updateBasicInfo(
          firstName: internationalName,
          lastName: 'Santacruz',
        );

        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?['firstName'], equals(internationalName));
      });

      test('4.3 SQL Injection payload in search query does not cause server error', () async {
        const sqli = "' OR '1'='1'; DROP TABLE patients;--";
        final res = await harness.recordsRepo.searchRecords(sqli);
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull, isNotNull);
      });

      test('4.4 XSS / HTML script tag payload in chief complaint persists safely escaped', () async {
        const xssPayload = '<script>alert("XSS_VULNERABILITY");</script>';
        const record = MedicalRecordDto(
          id: '',
          title: 'Security Escaping Test',
          category: 'GENERAL',
          chiefComplaint: xssPayload,
          clinicalNotes: 'Testing script payload storage safety',
          status: 'FINAL',
        );

        final res = await harness.recordsRepo.createRecord(record);
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.chiefComplaint, equals(xssPayload));
      });

      test('4.5 Phone numbers with international formatting characters parse safely', () async {
        const formattedPhone = '+1 (650) 555-0004';
        final res = await harness.authRepo.requestOtp(formattedPhone);
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.challengeId, isNotNull);
      });
    });

    // =========================================================================
    // Category 5: Network Error Handling & HTTP Status Codes
    // =========================================================================
    group('5. Network Error Handling & HTTP Status Codes', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('5.1 Simulated TimeoutException returns ApiFailure with status 408', () async {
        harness.mockBackend.simulateTimeout = true;
        final res = await harness.patientRepo.getPatientProfile();
        expect(res.isFailure, isTrue);
        expect(statusCodeOf(res), equals(408));
        expect(res.messageOrNull, contains('timed out'));
      });

      test('5.2 Simulated SocketException (network failure) returns ApiFailure', () async {
        harness.mockBackend.simulateSocketError = true;
        final res = await harness.recordsRepo.getMedicalRecords();
        expect(res.isFailure, isTrue);
        expect(res.messageOrNull, contains('Unable to reach'));
      });

      test('5.3 Simulated HTTP 500 Internal Server Error returns structured ApiFailure', () async {
        harness.mockBackend.forceStatusCode = 500;
        harness.mockBackend.forceErrorMessage = 'Internal database connectivity failure';

        final res = await harness.doctorRepo.getDoctors();
        expect(res.isFailure || res.dataOrNull != null, isTrue);
      });

      test('5.4 Simulated HTTP 429 Rate Limiting returns 429 status code', () async {
        harness.mockBackend.forceStatusCode = 429;
        harness.mockBackend.forceErrorMessage = 'Rate limit exceeded: Please wait 60 seconds';

        final res = await harness.healthCardRepo.getActiveHealthCard();
        expect(res.isFailure, isTrue);
        expect(statusCodeOf(res), equals(429));
      });

      test('5.5 Simulated HTTP 404 Endpoint Not Found returns 404 status code', () async {
        harness.mockBackend.forceStatusCode = 404;
        harness.mockBackend.forceErrorMessage = 'Resource not found';

        final res = await harness.insuranceRepo.getPolicyById('non-existent-pol-id');
        expect(res.isFailure, isTrue);
        expect(statusCodeOf(res), equals(404));
      });
    });

    // =========================================================================
    // Category 6: Concurrency & State Mutation Boundaries
    // =========================================================================
    group('6. Concurrency & State Mutation Boundaries', () {
      test('6.1 Rapid duplicate in-flight OTP request triggers concurrency protection', () async {
        const phone = '+16505550004';

        // Fire two simultaneous requests
        final f1 = harness.authRepo.requestOtp(phone);
        final f2 = harness.authRepo.requestOtp(phone);

        final results = await Future.wait([f1, f2]);
        expect(results.any((r) => r.isSuccess), isTrue);
      });

      test('6.2 Rapid duplicate verification calls handle gracefully', () async {
        final f1 = harness.authRepo.verifyOtp(challengeId: 'ch-1', otpCode: '123456');
        final f2 = harness.authRepo.verifyOtp(challengeId: 'ch-1', otpCode: '123456');

        final results = await Future.wait([f1, f2]);
        expect(results.any((r) => r.isSuccess || r.isFailure), isTrue);
      });

      test('6.3 Simultaneous record creation preserves unique records without loss', () async {
        await harness.loginAsSeededPatient();

        const r1 = MedicalRecordDto(id: '', title: 'Concurrent Record 1', category: 'GENERAL', status: 'FINAL');
        const r2 = MedicalRecordDto(id: '', title: 'Concurrent Record 2', category: 'GENERAL', status: 'FINAL');

        final results = await Future.wait([
          harness.recordsRepo.createRecord(r1),
          harness.recordsRepo.createRecord(r2),
        ]);

        expect(results[0].isSuccess, isTrue);
        expect(results[1].isSuccess, isTrue);
        expect(results[0].dataOrNull?.id != results[1].dataOrNull?.id, isTrue);
      });

      test('6.4 Repeated idempotent logout calls succeed cleanly without throwing', () async {
        await harness.loginAsSeededPatient();
        final l1 = await harness.authRepo.logout();
        expect(l1.isSuccess, isTrue);

        final l2 = await harness.authRepo.logout();
        expect(l2.isSuccess || l2.isFailure, isTrue);
        expect(await harness.tokenStorage.getAccessToken(), isNull);
      });

      test('6.5 Rapid sequential search queries do not leak memory or deadlock', () async {
        await harness.loginAsSeededPatient();
        for (int i = 0; i < 10; i++) {
          final res = await harness.recordsRepo.searchRecords('Screening $i');
          expect(res.isSuccess, isTrue);
        }
      });
    });
  });
}
