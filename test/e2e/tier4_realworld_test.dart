import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/core/constants/api_endpoints.dart';
import 'package:careid_patient_app/features/patient/data/models/appointment_models.dart';
import 'package:careid_patient_app/features/patient/data/models/medical_record_models.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'e2e_test_harness.dart';

void main() {
  group('E2E Tier 4: Real-World Workflows (Full User Journey Tests)', () {
    late E2ETestHarness harness;

    setUp(() {
      harness = E2ETestHarness.create();
    });

    // =========================================================================
    // Workflow 1: End-to-End Patient Onboarding & Health Card Generation
    // =========================================================================
    test('4.1 Journey 1: Complete Patient Onboarding to Digital Health Card Issuance', () async {
      const patientPhone = '+16505550004';

      // Step 1: Request Phone OTP
      final otpRes = await harness.authRepo.requestOtp(patientPhone);
      expect(otpRes.isSuccess, isTrue);
      final challengeId = otpRes.dataOrNull!.challengeId;

      // Step 2: Verify OTP and acquire JWT session
      final verifyRes = await harness.authRepo.verifyOtp(
        challengeId: challengeId,
        otpCode: '123456',
      );
      expect(verifyRes.isSuccess, isTrue);
      expect(await harness.tokenStorage.getAccessToken(), isNotNull);

      // Step 3: Initialize Draft Profile
      final draftRes = await harness.onboardingRepo.initializeDraft();
      expect(draftRes.isSuccess, isTrue);
      expect(draftRes.dataOrNull?['status'], equals('DRAFT'));

      // Step 4: Register Demographics
      final demoRes = await harness.apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.onboardingDemographics,
        requiresAuth: true,
        body: {
          'firstName': 'John',
          'lastName': 'Doe',
          'dateOfBirth': '1990-01-01',
          'gender': 'Male',
          'bloodGroup': 'O+',
        },
        fromJson: (j) => j as Map<String, dynamic>,
      );
      expect(demoRes.isSuccess, isTrue);

      // Step 5: Save Emergency Contact
      final emergRes = await harness.apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.onboardingEmergencyContact,
        requiresAuth: true,
        body: {
          'name': 'Jane Doe',
          'relationship': 'Spouse',
          'phone': '+14155552671',
        },
        fromJson: (j) => j as Map<String, dynamic>,
      );
      expect(emergRes.isSuccess, isTrue);

      // Step 6: Link Health Insurance
      final insRes = await harness.apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.onboardingInsurance,
        requiresAuth: true,
        body: {
          'providerName': 'Blue Cross Blue Shield',
          'policyNumber': 'POL-998877',
        },
        fromJson: (j) => j as Map<String, dynamic>,
      );
      expect(insRes.isSuccess, isTrue);

      // Step 7: Finalize Onboarding
      final completeRes = await harness.apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.onboardingComplete,
        requiresAuth: true,
        fromJson: (j) => j as Map<String, dynamic>,
      );
      expect(completeRes.isSuccess, isTrue);

      // Step 8: Fetch Generated Digital Health Card
      final cardRes = await harness.healthCardRepo.getActiveHealthCard();
      expect(cardRes.isSuccess, isTrue);
      final card = cardRes.dataOrNull!;
      expect(card.cardNumber, startsWith('HC-CAREID-'));
      expect(card.status, equals('ACTIVE'));
      expect(card.qrPayload, isNotNull);

      // Step 9: Verify Profile Completion is 100%
      final completionRes = await harness.patientRepo.getProfileCompletion();
      expect(completionRes.isSuccess, isTrue);
      expect(completionRes.dataOrNull?.percentage, equals(100));
    });

    // =========================================================================
    // Workflow 2: Doctor Discovery, Slot Reservation, Consultation Lifecycle
    // =========================================================================
    test('4.2 Journey 2: Doctor Discovery, Appointment Booking, Rescheduling & Cancellation', () async {
      await harness.loginAsSeededPatient();

      // Step 1: Patient searches for Cardiology specialists
      final doctorListRes = await harness.doctorRepo.getDoctors(specialty: 'Cardiology');
      expect(doctorListRes.isSuccess, isTrue);
      final doctors = doctorListRes.dataOrNull!;
      expect(doctors.isNotEmpty, isTrue);

      final drChen = doctors.firstWhere((d) => d.fullName.contains('Robert Chen'));
      expect(drChen.rating, greaterThanOrEqualTo(4.8));

      // Step 2: Retrieve available schedule slots for Dr. Chen
      final slotsRes = await harness.doctorRepo.getDoctorSlots(drChen.id);
      expect(slotsRes.isSuccess, isTrue);
      final slots = slotsRes.dataOrNull!;
      expect(slots.isNotEmpty, isTrue);
      expect(slots.any((s) => s.isAvailable), isTrue);

      // Step 3: Book consultation
      final newAppointment = AppointmentModel(
        id: 'apt-lifecycle-001',
        doctorId: drChen.id,
        doctorName: drChen.fullName,
        specialization: drChen.primarySpecialization,
        facility: drChen.facilityName,
        dateTime: DateTime(2026, 11, 25, 9, 0),
        consultationType: 'In-Person Consultation',
        reasonForVisit: 'Annual cardiovascular risk screening',
        durationMinutes: 30,
      );

      final bookRes = await harness.doctorRepo.bookAppointment(newAppointment);
      expect(bookRes.isSuccess, isTrue);
      final bookedId = bookRes.dataOrNull!.id;

      // Step 4: Confirm appointment is indexed in patient schedule
      final myAptsRes = await harness.doctorRepo.getMyAppointments();
      expect(myAptsRes.isSuccess, isTrue);
      expect(myAptsRes.dataOrNull?.any((a) => a.id == bookedId || a.doctorId == drChen.id), isTrue);

      // Step 5: Reschedule appointment to a different time
      final rescheduleRes = await harness.doctorRepo.rescheduleAppointment(
        bookedId,
        newDate: DateTime(2026, 11, 26),
        startTime: '14:00',
        endTime: '14:30',
      );
      expect(rescheduleRes.isSuccess, isTrue);

      // Step 6: Patient cancels appointment
      final cancelRes = await harness.doctorRepo.cancelAppointment(
        bookedId,
        reason: 'Work travel conflict',
      );
      expect(cancelRes.isSuccess, isTrue);
    });

    // =========================================================================
    // Workflow 3: Clinical Record Ingestion & Doctor QR Verification
    // =========================================================================
    test('4.3 Journey 3: Clinical Record Ingestion, Search & Doctor QR Scanning', () async {
      await harness.loginAsSeededPatient();

      // Step 1: Patient receives and adds a new clinical lab record
      const labRecord = MedicalRecordDto(
        id: '',
        title: 'Comprehensive Metabolic Panel (CMP)',
        category: 'GENERAL',
        chiefComplaint: 'Routine annual metabolic profiling',
        clinicalNotes: 'Glucose 92 mg/dL, BUN 14, Creatinine 0.9, eGFR > 60 mL/min.',
        treatmentPlan: 'Maintain current hydration and exercise regimen.',
        status: 'FINAL',
      );

      final createRes = await harness.recordsRepo.createRecord(labRecord);
      expect(createRes.isSuccess, isTrue);

      // Step 2: Patient searches records vault for metabolic results
      final searchRes = await harness.recordsRepo.searchRecords('Metabolic');
      expect(searchRes.isSuccess, isTrue);
      expect(searchRes.dataOrNull?.any((r) => r.title.contains('Metabolic')), isTrue);

      // Step 3: Patient checks medical records across all departments (General, Dental, Vision)
      final allRecordsRes = await harness.recordsRepo.getMedicalRecords();
      expect(allRecordsRes.isSuccess, isTrue);
      final records = allRecordsRes.dataOrNull!;
      expect(records.any((r) => r.category == 'GENERAL'), isTrue);
      expect(records.any((r) => r.category == 'DENTAL'), isTrue);
      expect(records.any((r) => r.category == 'VISION'), isTrue);

      // Step 4: Patient arrives at clinic, doctor scans patient health card QR
      final cardRes = await harness.healthCardRepo.getActiveHealthCard();
      expect(cardRes.isSuccess, isTrue);
      final qrString = cardRes.dataOrNull!.qrPayload!;

      final doctorScanRes = await harness.healthCardRepo.verifyQrPayload(qrString);
      expect(doctorScanRes.isSuccess, isTrue);
      final verifiedData = doctorScanRes.dataOrNull!;
      expect(verifiedData.isValid, isTrue);
      expect(verifiedData.patientName, equals('John Doe'));
      expect(verifiedData.patientNumber, equals('PT-2026-0004'));
      expect(verifiedData.bloodGroup, equals('O+'));
    });

    // =========================================================================
    // Workflow 4: Insurance Coverage & Orthodontic Treatment Financing
    // =========================================================================
    test('4.4 Journey 4: Insurance Policy Audit, Treatment Offer Review & 0% APR Financing', () async {
      await harness.loginAsSeededPatient();

      // Step 1: Patient audits current active insurance policies
      final policiesRes = await harness.insuranceRepo.getPolicies();
      expect(policiesRes.isSuccess, isTrue);
      final policies = policiesRes.dataOrNull!;
      expect(policies.isNotEmpty, isTrue);
      final activePolicy = policies.first;
      expect(activePolicy.providerName, equals('Blue Cross Blue Shield'));
      expect(activePolicy.status, equals('ACTIVE'));

      // Step 2: Patient inspects clinical treatment offers
      final offersRes = await harness.treatmentOfferRepo.getTreatmentOffers();
      expect(offersRes.isSuccess, isTrue);
      final offers = offersRes.dataOrNull!;
      expect(offers.isNotEmpty, isTrue);

      final orthoOffer = offers.first;
      expect(orthoOffer.clinicalIndication, contains('Orthodontic'));

      // Step 3: Detailed treatment offer financial inspection
      final offerDetailRes = await harness.treatmentOfferRepo.getTreatmentOfferById(orthoOffer.id);
      expect(offerDetailRes.isSuccess, isTrue);
      final detail = offerDetailRes.dataOrNull!;

      // Step 4: Verify transparent financial terms
      expect(detail.totalProceduresCost, equals(2400.0));
      expect(detail.discountAmount, equals(600.0));
      expect(detail.netPayableCost, equals(1800.0));
      expect(detail.financingEligible, isTrue);
      expect(detail.recommendedTenureMonths, equals(12));

      // Step 5: Verify status is ACTIVE
      expect(detail.status, equals('ACTIVE'));
    });

    // =========================================================================
    // Workflow 5: Multi-Device Session Lifecycle, Token Refresh & Total Logout
    // =========================================================================
    test('4.5 Journey 5: Session Audit, Automatic Token Refresh & Complete Vault Teardown', () async {
      // Step 1: Clean login
      await harness.loginAsSeededPatient();
      final initialAccessToken = await harness.tokenStorage.getAccessToken();
      final initialRefreshToken = await harness.tokenStorage.getRefreshToken();
      expect(initialAccessToken, isNotNull);
      expect(initialRefreshToken, isNotNull);

      // Step 2: List active user sessions
      final sessionsRes = await harness.apiClient.get<List<dynamic>>(
        ApiEndpoints.sessions,
        requiresAuth: true,
        fromJson: (j) => j as List<dynamic>,
      );
      expect(sessionsRes.isSuccess, isTrue);
      expect(sessionsRes.dataOrNull?.isNotEmpty, isTrue);

      // Step 3: Rotate token via refresh endpoint
      final refreshRes = await harness.apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.tokenRefresh,
        body: {'refreshToken': initialRefreshToken!},
        fromJson: (j) => j as Map<String, dynamic>,
      );
      expect(refreshRes.isSuccess, isTrue);
      final newAccessToken = refreshRes.dataOrNull?['accessToken'] as String?;
      expect(newAccessToken, isNotNull);
      expect(newAccessToken, contains('refreshed'));

      // Save refreshed tokens
      await harness.tokenStorage.saveTokens(
        accessToken: newAccessToken!,
        refreshToken: refreshRes.dataOrNull!['refreshToken'] as String,
      );
      expect(await harness.tokenStorage.getAccessToken(), equals(newAccessToken));

      // Step 4: Terminate all sessions across all devices
      final logoutAllRes = await harness.apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.logoutAll,
        requiresAuth: true,
        fromJson: (j) => j as Map<String, dynamic>,
      );
      expect(logoutAllRes.isSuccess, isTrue);

      // Step 5: Clear local vault storage
      await harness.tokenStorage.clear();
      expect(await harness.tokenStorage.getAccessToken(), isNull);
      expect(await harness.tokenStorage.getRefreshToken(), isNull);

      // Step 6: Verify protected resource access is completely blocked
      final blockedRes = await harness.patientRepo.getPatientProfile();
      expect(blockedRes.isFailure, isTrue);
      expect((blockedRes as ApiFailure).statusCode, equals(401));
    });
  });
}
