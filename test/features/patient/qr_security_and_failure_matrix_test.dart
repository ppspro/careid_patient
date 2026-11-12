import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/patient/data/repositories/digital_health_card_repository.dart';

class MockSecurityFailureApiClient extends ApiClient {
  MockSecurityFailureApiClient({required this.isAuthorized})
      : super(tokenStorage: InMemoryTokenStorage());

  final bool isAuthorized;
  int scanLogCount = 0;

  @override
  Future<ApiResult<T>> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic json)? fromJson,
  }) async {
    if (!isAuthorized) {
      return const ApiFailure(
        message: 'UnauthorizedException: Missing or invalid doctor credentials',
        statusCode: 401,
      );
    }

    if (endpoint == '/api/v1/qr/verify') {
      scanLogCount++;
      final token = (body as Map?)?['token']?.toString() ?? '';

      if (token == 'HVQR-VALID-ACTIVE-001') {
        final json = {
          'isValid': true,
          'status': 'VALID',
          'entityType': 'HEALTH_CARD',
          'entityId': 'HC-CAREID-2026-0004',
          'ownerId': '787e5187-7859-4320-bb1a-465a57dd086a',
        };
        return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
      }

      if (token == 'HVQR-EXPIRED-TOKEN') {
        final json = {
          'isValid': false,
          'status': 'EXPIRED',
          'failureReason': 'This QR code has expired.',
        };
        return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
      }

      if (token == 'HVQR-REVOKED-TOKEN') {
        final json = {
          'isValid': false,
          'status': 'REVOKED',
          'failureReason': 'This QR code has been revoked.',
        };
        return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
      }

      if (token == 'HVQR-OLD-ROTATED-TOKEN') {
        final json = {
          'isValid': false,
          'status': 'ROTATED',
          'failureReason': 'This QR token has been rotated and is no longer valid.',
        };
        return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
      }

      if (token == 'HVQR-NEW-ROTATED-TOKEN') {
        final json = {
          'isValid': true,
          'status': 'VALID',
          'entityType': 'HEALTH_CARD',
          'entityId': 'HC-CAREID-2026-0004',
          'ownerId': '787e5187-7859-4320-bb1a-465a57dd086a',
        };
        return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
      }

      if (token == 'HVQR-NETWORK-TIMEOUT') {
        return const ApiFailure(message: 'Connection timeout', statusCode: 504);
      }

      return const ApiFailure(
        message: 'Invalid or non-existing QR token',
        statusCode: 404,
      );
    }

    if (endpoint == '/api/v1/health-cards/verify-qr') {
      final payload = (body as Map?)?['qrPayload']?.toString() ?? '';
      if (payload.contains('HC-CAREID-2026-0004')) {
        final json = {
          'isValid': true,
          'status': 'VERIFIED',
          'patientDetails': {
            'patientNumber': 'PT-1004',
            'firstName': 'Marcus',
            'lastName': 'Doe',
            'dateOfBirth': '1988-06-14',
            'bloodGroup': 'O+',
          },
        };
        return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
      }
      return const ApiFailure(message: 'Invalid card number', statusCode: 404);
    }

    return const ApiFailure(message: 'Not found', statusCode: 404);
  }
}

void main() {
  group('Phase 15.1: QR Security & Failure Matrix Test Suite', () {
    late MockSecurityFailureApiClient authorizedClient;
    late MockSecurityFailureApiClient unauthorizedClient;
    late DigitalHealthCardRepository repo;
    late DigitalHealthCardRepository unauthorizedRepo;

    setUp(() async {
      authorizedClient = MockSecurityFailureApiClient(isAuthorized: true);
      await authorizedClient.tokenStorage!.saveTokens(
        accessToken: 'mock_doc_jwt',
        refreshToken: 'mock_doc_refresh',
      );
      repo = DigitalHealthCardRepository(apiClient: authorizedClient);

      unauthorizedClient = MockSecurityFailureApiClient(isAuthorized: false);
      unauthorizedRepo = DigitalHealthCardRepository(apiClient: unauthorizedClient);
    });

    test('1. Valid QR returns status VALID and isValid = true', () async {
      final res = await repo.verifyQrPayload('HVQR-VALID-ACTIVE-001');
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.isValid, isTrue);
      expect(res.dataOrNull?.verificationStatus, equals('VALID'));
    });

    test('2. Malformed QR (empty string, corrupt json) fails gracefully', () async {
      final resEmpty = await repo.verifyQrPayload('');
      expect(resEmpty.dataOrNull?.isValid != true, isTrue);

      final resCorruptJson = await repo.verifyQrPayload('{"bad_json: true');
      expect(resCorruptJson.dataOrNull?.isValid != true, isTrue);
    });

    test('3. Invalid enterprise token (HVQR-NON-EXISTING) is rejected', () async {
      final res = await repo.verifyQrPayload('HVQR-NON-EXISTING');
      expect(res.dataOrNull?.isValid != true, isTrue);
    });

    test('4. Expired QR token returns status EXPIRED', () async {
      final res = await repo.verifyQrPayload('HVQR-EXPIRED-TOKEN');
      expect(res.dataOrNull?.isValid, isFalse);
      expect(res.dataOrNull?.verificationStatus, equals('EXPIRED'));
    });

    test('5. Revoked QR token returns status REVOKED', () async {
      final res = await repo.verifyQrPayload('HVQR-REVOKED-TOKEN');
      expect(res.dataOrNull?.isValid, isFalse);
      expect(res.dataOrNull?.verificationStatus, equals('REVOKED'));
    });

    test('6. Old QR after rotation returns status ROTATED and is rejected', () async {
      final res = await repo.verifyQrPayload('HVQR-OLD-ROTATED-TOKEN');
      expect(res.dataOrNull?.isValid, isFalse);
      expect(res.dataOrNull?.verificationStatus, equals('ROTATED'));
    });

    test('7. New QR after rotation is accepted', () async {
      final res = await repo.verifyQrPayload('HVQR-NEW-ROTATED-TOKEN');
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.isValid, isTrue);
      expect(res.dataOrNull?.verificationStatus, equals('VALID'));
    });

    test('8. Duplicate scan is logged and verified idempotently', () async {
      final scan1 = await repo.verifyQrPayload('HVQR-VALID-ACTIVE-001');
      final scan2 = await repo.verifyQrPayload('HVQR-VALID-ACTIVE-001');
      expect(scan1.dataOrNull?.isValid, isTrue);
      expect(scan2.dataOrNull?.isValid, isTrue);
      expect(authorizedClient.scanLogCount, equals(2));
    });

    test('9. Network failure returns ApiFailure without crashing', () async {
      final res = await repo.verifyQrPayload('HVQR-NETWORK-TIMEOUT');
      expect(res.isFailure, isTrue);
      expect(res.messageOrNull, contains('timeout'));
    });

    test('10. Unauthorized doctor is rejected with 401', () async {
      final res = await unauthorizedRepo.verifyQrPayload('HVQR-VALID-ACTIVE-001');
      expect(res.isFailure, isTrue);
      expect((res as ApiFailure).statusCode, equals(401));
    });

    test('11. Unsupported QR version in canonical payload handles safely', () async {
      final unsupportedVersionJson = jsonEncode({
        'v': '99.0',
        'type': 'CAREID_HEALTH_CARD',
        'token': 'HVQR-VALID-ACTIVE-001',
        'cardNumber': 'HC-CAREID-2026-0004',
      });

      final res = await repo.verifyQrPayload(unsupportedVersionJson);
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.isValid, isTrue);
    });
  });
}
