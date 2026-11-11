import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/patient/data/repositories/facility_repository.dart';

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
  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    if (endpoint.contains('/facilities/search')) {
      final json = [
        {
          'id': 'fac-002',
          'name': 'Metro General Hospital',
          'facilityType': 'HOSPITAL',
          'streetAddress': '100 Medical Blvd',
          'city': 'Metro City',
          'state': 'CA',
          'emergencyPhone': '+1 (555) 911-0000',
          'departments': [
            {'id': 'dept-01', 'name': 'Emergency', 'departmentHead': 'Dr. Jenkins'}
          ]
        }
      ];
      return ApiSuccess(data: fromJson!(json));
    } else if (endpoint.contains('/facilities/fac-001')) {
      final json = {
        'id': 'fac-001',
        'name': 'CareID Apex Diagnostic Center',
        'facilityType': 'DIAGNOSTIC_CENTER',
        'streetAddress': '450 Clinical Park',
        'city': 'Springfield',
        'state': 'OR',
        'phone': '+1 (555) 123-4567',
        'departments': <Map<String, dynamic>>[]
      };
      return ApiSuccess(data: fromJson!(json));
    } else if (endpoint.endsWith('/facilities')) {
      final json = [
        {
          'id': 'fac-001',
          'name': 'CareID Apex Diagnostic Center',
          'facilityType': 'DIAGNOSTIC_CENTER',
          'streetAddress': '450 Clinical Park',
          'city': 'Springfield',
          'state': 'OR',
          'phone': '+1 (555) 123-4567',
          'departments': <Map<String, dynamic>>[]
        },
        {
          'id': 'fac-002',
          'name': 'Metro General Hospital',
          'facilityType': 'HOSPITAL',
          'streetAddress': '100 Medical Blvd',
          'city': 'Metro City',
          'state': 'CA',
          'emergencyPhone': '+1 (555) 911-0000',
          'departments': [
            {'id': 'dept-01', 'name': 'Emergency', 'departmentHead': 'Dr. Jenkins'}
          ]
        }
      ];
      return ApiSuccess(data: fromJson!(json));
    }

    return const ApiFailure(message: 'Not found', statusCode: 404);
  }
}

void main() {
  group('FacilityRepository & FacilityDto Tests', () {
    late FacilityRepository repository;

    setUp(() {
      repository = FacilityRepository(
        apiClient: _FakeApiClient(),
        tokenStorage: _FakeTokenStorage(),
      );
    });

    test('getFacilities parses list of facilities correctly', () async {
      final result = await repository.getFacilities();
      expect(result.isSuccess, isTrue);
      final facilities = result.dataOrNull!;
      expect(facilities.length, 2);
      expect(facilities[0].name, 'CareID Apex Diagnostic Center');
      expect(facilities[0].isDiagnosticCenter, isTrue);
      expect(facilities[1].name, 'Metro General Hospital');
      expect(facilities[1].isHospital, isTrue);
      expect(facilities[1].departments.length, 1);
      expect(facilities[1].departments[0].name, 'Emergency');
    });

    test('searchFacilities returns matched facilities', () async {
      final result = await repository.searchFacilities('hospital');
      expect(result.isSuccess, isTrue);
      final list = result.dataOrNull!;
      expect(list.length, 1);
      expect(list.first.name, 'Metro General Hospital');
    });

    test('getFacilityById returns single facility profile', () async {
      final result = await repository.getFacilityById('fac-001');
      expect(result.isSuccess, isTrue);
      final fac = result.dataOrNull!;
      expect(fac.id, 'fac-001');
      expect(fac.fullAddress, contains('Springfield, OR'));
    });
  });
}
