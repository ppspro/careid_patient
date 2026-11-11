import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/patient/data/repositories/digital_health_card_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/patient_repository.dart';

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<String?> getAccessToken() async => 'fake-jwt-token';
  @override
  Future<String?> getRefreshToken() async => 'fake-refresh-token';
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}
  @override
  Future<void> clear() async {}
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(baseUrl: 'https://360api.vnvision.in');

  @override
  Future<ApiResult<T>> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    if (endpoint.contains('/patients/me/photo')) {
      final json = {
        'message': 'Profile photo updated successfully',
        'photoUrl': (body as Map)['photoUrl'],
        'photoKey': body['photoKey'],
      };
      return ApiSuccess(data: fromJson!(json));
    } else if (endpoint.contains('/health-cards/card-001/block')) {
      final json = {
        'id': 'card-001',
        'cardNumber': 'CID-8472-9102-4821',
        'status': 'BLOCKED',
        'history': [
          {
            'id': 'hist-01',
            'healthCardId': 'card-001',
            'action': 'STATUS_CHANGE',
            'previousStatus': 'ACTIVE',
            'newStatus': 'BLOCKED',
            'reason': (body as Map)['reason'] ?? 'Security freeze',
          }
        ]
      };
      return ApiSuccess(data: fromJson!(json));
    } else if (endpoint.contains('/health-cards/card-001/unblock')) {
      final json = {
        'id': 'card-001',
        'cardNumber': 'CID-8472-9102-4821',
        'status': 'ACTIVE',
      };
      return ApiSuccess(data: fromJson!(json));
    }

    return const ApiFailure(message: 'Endpoint error', statusCode: 400);
  }

  @override
  Future<ApiResult<T>> delete<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    if (endpoint.contains('/patients/me/photo')) {
      return ApiSuccess(data: fromJson!(true));
    }
    return const ApiFailure(message: 'Endpoint error', statusCode: 400);
  }

  @override
  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    if (endpoint.contains('/health-cards/card-001/history')) {
      final json = [
        {
          'id': 'hist-01',
          'healthCardId': 'card-001',
          'action': 'ISSUED',
          'newStatus': 'ACTIVE',
          'reason': 'Initial issuance',
        }
      ];
      return ApiSuccess(data: fromJson!(json));
    }
    return const ApiFailure(message: 'Not found', statusCode: 404);
  }
}

void main() {
  group('Photo Management & Health Card Security Freeze Tests', () {
    late PatientRepository patientRepo;
    late DigitalHealthCardRepository cardRepo;

    setUp(() {
      final fakeApi = _FakeApiClient();
      final fakeStorage = _FakeTokenStorage();
      patientRepo = PatientRepository(apiClient: fakeApi, tokenStorage: fakeStorage);
      cardRepo = DigitalHealthCardRepository(apiClient: fakeApi, tokenStorage: fakeStorage);
    });

    test('updateProfilePhoto sends JSON contract and receives success', () async {
      final res = await patientRepo.updateProfilePhoto(
        photoUrl: 'https://images.unsplash.com/test-photo.jpg',
        photoKey: 'avatars/test-patient.jpg',
      );
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?['photoUrl'], contains('test-photo.jpg'));
    });

    test('deleteProfilePhoto invokes DELETE endpoint successfully', () async {
      final res = await patientRepo.deleteProfilePhoto();
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull, isTrue);
    });

    test('blockHealthCard changes status to BLOCKED with reason', () async {
      final res = await cardRepo.blockHealthCard('card-001', reason: 'Lost card reported');
      expect(res.isSuccess, isTrue);
      final card = res.dataOrNull!;
      expect(card.id, 'card-001');
      expect(card.status, 'BLOCKED');
    });

    test('unblockHealthCard restores status to ACTIVE', () async {
      final res = await cardRepo.unblockHealthCard('card-001');
      expect(res.isSuccess, isTrue);
      final card = res.dataOrNull!;
      expect(card.status, 'ACTIVE');
    });

    test('getCardHistory retrieves audit trail events', () async {
      final res = await cardRepo.getCardHistory('card-001');
      expect(res.isSuccess, isTrue);
      final history = res.dataOrNull!;
      expect(history.length, 1);
      expect(history.first.action, 'ISSUED');
      expect(history.first.newStatus, 'ACTIVE');
    });
  });
}

