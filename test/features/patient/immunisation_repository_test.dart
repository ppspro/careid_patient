import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/patient/data/repositories/immunisation_repository.dart';

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
    if (endpoint.contains('/immunisation/vaccines')) {
      final json = [
        {
          'id': 'vac-01',
          'name': 'COVID-19 mRNA Vaccine',
          'code': 'COVID-19',
          'manufacturer': 'Pfizer-BioNTech',
          'targetGroup': 'Adults 18+',
          'totalDosesRequired': 2.0,
          'minIntervalDays': 21.0,
          'description': 'mRNA vaccine against SARS-CoV-2 spike protein',
          'contraindications': ['Severe allergic reaction to polyethylene glycol'],
          'isActive': true,
        },
        {
          'id': 'vac-02',
          'name': 'Hepatitis B Recombinant',
          'code': 'HEP-B',
          'manufacturer': 'GlaxoSmithKline',
          'targetGroup': 'All ages',
          'totalDosesRequired': 3.0,
          'minIntervalDays': 30.0,
          'description': 'Recombinant hepatitis B vaccine',
          'contraindications': <String>[],
          'isActive': true,
        }
      ];
      return ApiSuccess(data: fromJson!(json));
    } else if (endpoint.contains('/immunisation/records')) {
      final json = [
        {
          'id': 'rec-vac-01',
          'patientProfileId': 'pat-123',
          'vaccineId': 'vac-01',
          'doseNumber': 1.0,
          'status': 'ADMINISTERED',
          'administeredDate': '2023-05-15',
          'administeredBy': 'Nurse Ratched, RN',
          'facilityName': 'Metro General Hospital',
          'batchNumber': 'PF-98421',
          'vaccine': {
            'id': 'vac-01',
            'name': 'COVID-19 mRNA Vaccine',
            'code': 'COVID-19',
            'manufacturer': 'Pfizer-BioNTech',
            'totalDosesRequired': 2.0,
          }
        }
      ];
      return ApiSuccess(data: fromJson!(json));
    }

    return const ApiFailure(message: 'Not found', statusCode: 404);
  }
}

void main() {
  group('ImmunisationRepository & Models Tests', () {
    late ImmunisationRepository repository;

    setUp(() {
      repository = ImmunisationRepository(
        apiClient: _FakeApiClient(),
        tokenStorage: _FakeTokenStorage(),
      );
    });

    test('getVaccines parses available vaccines correctly', () async {
      final result = await repository.getVaccines();
      expect(result.isSuccess, isTrue);
      final list = result.dataOrNull!;
      expect(list.length, 2);
      expect(list[0].name, 'COVID-19 mRNA Vaccine');
      expect(list[0].code, 'COVID-19');
      expect(list[0].requiredDoses, 2);
      expect(list[0].contraindications.length, 1);
      expect(list[1].name, 'Hepatitis B Recombinant');
      expect(list[1].requiredDoses, 3);
    });

    test('getPatientRecords parses patient vaccination records', () async {
      final result = await repository.getPatientRecords();
      expect(result.isSuccess, isTrue);
      final records = result.dataOrNull!;
      expect(records.length, 1);
      expect(records[0].id, 'rec-vac-01');
      expect(records[0].currentDose, 1);
      expect(records[0].facilityName, 'Metro General Hospital');
      expect(records[0].displayName, 'COVID-19 mRNA Vaccine');
    });
  });
}

