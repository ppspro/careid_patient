import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/immunisation_models.dart';

/// CareID Immunisation & Vaccine Directory Repository
/// Grounded in Postman folder `11. Immunisation Management`
class ImmunisationRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ImmunisationRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? apiClient?.tokenStorage ?? AppTokenStorage();

  /// Retrieves list of all vaccines available in the clinical directory
  /// GET /api/v1/immunisation/vaccines
  Future<ApiResult<List<VaccineDto>>> getVaccines() async {
    _isLoading = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure(
          message: 'Authentication session required. Please sign in.',
          statusCode: 401,
        );
      }

      return await _apiClient.get<List<VaccineDto>>(
        ApiEndpoints.vaccines,
        requiresAuth: true,
        fromJson: (dynamic json) {
          final list = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => VaccineDto.fromJson(e))
                .toList();
          }
          return <VaccineDto>[];
        },
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Retrieves all scheduled or administered vaccination records for the patient
  /// GET /api/v1/immunisation/records
  Future<ApiResult<List<PatientVaccinationRecordDto>>> getPatientRecords() async {
    _isLoading = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure(
          message: 'Authentication session required. Please sign in.',
          statusCode: 401,
        );
      }

      return await _apiClient.get<List<PatientVaccinationRecordDto>>(
        ApiEndpoints.immunisationRecords,
        requiresAuth: true,
        fromJson: (dynamic json) {
          final list = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => PatientVaccinationRecordDto.fromJson(e))
                .toList();
          }
          return <PatientVaccinationRecordDto>[];
        },
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Lists vaccination schedules (supports optional vaccineId filter)
  /// GET /api/v1/immunisation/schedules
  Future<ApiResult<List<Map<String, dynamic>>>> getSchedules({String? vaccineId}) async {
    final query = vaccineId != null && vaccineId.isNotEmpty
        ? {'vaccineId': vaccineId}
        : null;
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.immunisationSchedules,
      queryParams: query,
      requiresAuth: true,
      fromJson: (json) {
        final list = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data']
            : json;
        if (list is List) {
          return list.whereType<Map<String, dynamic>>().toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  /// Lists all digital vaccine certificates for current patient
  /// GET /api/v1/immunisation/certificates
  Future<ApiResult<List<Map<String, dynamic>>>> getCertificates() async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.immunisationCertificates,
      requiresAuth: true,
      fromJson: (json) {
        final list = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data']
            : json;
        if (list is List) {
          return list.whereType<Map<String, dynamic>>().toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }
}

