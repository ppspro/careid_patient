import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/patient/data/repositories/financing_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/treatment_offer_repository.dart';

void main() {
  group('TreatmentOfferRepository Tests (Section 45)', () {
    test('getTreatmentOffers parses active offers successfully', () async {
      final tokenStorage = InMemoryTokenStorage();
      await tokenStorage.saveTokens(accessToken: 'test-token', refreshToken: 'test-refresh');

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/patients/treatment-offers'));
        expect(request.headers['Authorization'], contains('Bearer test-token'));
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': [
              {
                'id': 'to-uuid-1',
                'offerNumber': 'TO-2026-00001',
                'patientProfileId': 'pat-uuid-1',
                'doctorId': 'doc-uuid-1',
                'facilityId': 'fac-uuid-1',
                'clinicalIndication': 'Surgical Restoration Plan',
                'totalProceduresCost': 150000.0,
                'discountAmount': 15000.0,
                'netPayableCost': 135000.0,
                'financingEligible': true,
                'recommendedTenureMonths': 12,
                'status': 'DISPATCHED',
                'validUntil': '2026-12-31T23:59:59Z',
                'version': 1,
                'procedures': [
                  {
                    'id': 'proc-1',
                    'procedureCode': 'SURG-001',
                    'procedureName': 'Cardiac Angioplasty',
                    'category': 'SURGICAL',
                    'quantity': 1,
                    'unitCost': 150000.0,
                    'totalCost': 150000.0,
                  }
                ],
                'doctor': {'fullName': 'Dr. Julian Vance', 'primarySpecialization': 'Cardiology'},
                'facility': {'name': 'CareID Central Hospital'},
              }
            ],
            'meta': {'total': 1}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, tokenStorage: tokenStorage);
      final repo = TreatmentOfferRepository(apiClient: apiClient);
      final res = await repo.getTreatmentOffers();

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull!.length, equals(1));
      final offer = res.dataOrNull!.first;
      expect(offer.offerNumber, equals('TO-2026-00001'));
      expect(offer.netPayableCost, equals(135000.0));
      expect(offer.doctorName, equals('Dr. Julian Vance'));
      expect(offer.procedures.first.procedureCode, equals('SURG-001'));
    });

    test('acceptTreatmentOffer posts signatureConsent and expectedVersion', () async {
      final tokenStorage = InMemoryTokenStorage();
      await tokenStorage.saveTokens(accessToken: 'test-token', refreshToken: 'test-refresh');

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/patients/treatment-offers/to-uuid-1/accept'));
        expect(request.method, equals('POST'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['signatureConsent'], isTrue);
        expect(body['expectedVersion'], equals(1));
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': {'status': 'ACCEPTED', 'offerNumber': 'TO-2026-00001', 'version': 2}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, tokenStorage: tokenStorage);
      final repo = TreatmentOfferRepository(apiClient: apiClient);
      final res = await repo.acceptTreatmentOffer(
        offerId: 'to-uuid-1',
        signatureConsent: true,
        patientResponseNotes: 'Consent signed',
        expectedVersion: 1,
      );

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull!['status'], equals('ACCEPTED'));
    });

    test('rejectTreatmentOffer posts declineReason and expectedVersion', () async {
      final tokenStorage = InMemoryTokenStorage();
      await tokenStorage.saveTokens(accessToken: 'test-token', refreshToken: 'test-refresh');

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/patients/treatment-offers/to-uuid-1/reject'));
        expect(request.method, equals('POST'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['declineReason'], equals('Second opinion required'));
        expect(body['expectedVersion'], equals(1));
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': {'status': 'REJECTED', 'offerNumber': 'TO-2026-00001', 'version': 2}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, tokenStorage: tokenStorage);
      final repo = TreatmentOfferRepository(apiClient: apiClient);
      final res = await repo.rejectTreatmentOffer(
        offerId: 'to-uuid-1',
        declineReason: 'Second opinion required',
        expectedVersion: 1,
      );

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull!['status'], equals('REJECTED'));
    });
  });

  group('FinancingRepository Extended Tests (Section 27)', () {
    test('acceptFinancingOffer calls /api/v1/financing/offers/:id/accept', () async {
      final tokenStorage = InMemoryTokenStorage();
      await tokenStorage.saveTokens(accessToken: 'test-token', refreshToken: 'test-refresh');

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/financing/offers/fin-1/accept'));
        expect(request.method, equals('POST'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['signatureConsent'], isTrue);
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': {'status': 'ACCEPTED', 'id': 'fin-1'}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, tokenStorage: tokenStorage);
      final repo = FinancingRepository(apiClient: apiClient);
      final res = await repo.acceptFinancingOffer('fin-1');

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull!['status'], equals('ACCEPTED'));
    });

    test('rejectFinancingOffer calls /api/v1/financing/offers/:id/reject', () async {
      final tokenStorage = InMemoryTokenStorage();
      await tokenStorage.saveTokens(accessToken: 'test-token', refreshToken: 'test-refresh');

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/financing/offers/fin-1/reject'));
        expect(request.method, equals('POST'));
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': {'status': 'REJECTED', 'id': 'fin-1'}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, tokenStorage: tokenStorage);
      final repo = FinancingRepository(apiClient: apiClient);
      final res = await repo.rejectFinancingOffer('fin-1', reason: 'Self pay');

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull!['status'], equals('REJECTED'));
    });

    test('getFinancingApplications retrieves list from /api/v1/financing/applications', () async {
      final tokenStorage = InMemoryTokenStorage();
      await tokenStorage.saveTokens(accessToken: 'test-token', refreshToken: 'test-refresh');

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/financing/applications'));
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': [
              {
                'id': 'app-1',
                'applicationNumber': 'FIN-2026-00001',
                'status': 'APPROVED',
                'requestedAmount': 5000.0,
                'tenureMonths': 12,
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, tokenStorage: tokenStorage);
      final repo = FinancingRepository(apiClient: apiClient);
      final res = await repo.getFinancingApplications();

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull!.length, equals(1));
      expect(res.dataOrNull!.first['applicationNumber'], equals('FIN-2026-00001'));
    });
  });
}
