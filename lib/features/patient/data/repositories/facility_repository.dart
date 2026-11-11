import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/facility_models.dart';

/// CareID Facility & Clinic Directory Repository
/// Grounded in Postman folder `09. Facilities & Branches`
class FacilityRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FacilityRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? apiClient?.tokenStorage ?? AppTokenStorage();

  /// Retrieves all registered facilities (hospitals, diagnostic centers, clinics)
  /// GET /api/v1/facilities
  Future<ApiResult<List<FacilityDto>>> getFacilities({int? page, int? limit}) async {
    _isLoading = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure(
          message: 'Authentication session required. Please sign in.',
          statusCode: 401,
        );
      }

      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final result = await _apiClient.get<List<FacilityDto>>(
        ApiEndpoints.facilities,
        requiresAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (dynamic json) {
          final list = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => FacilityDto.fromJson(e))
                .toList();
          }
          return <FacilityDto>[];
        },
      );
      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Searches facilities by keyword, hospital name, city, or specialty
  /// GET /api/v1/facilities/search?q={query}
  Future<ApiResult<List<FacilityDto>>> searchFacilities(String query) async {
    if (query.trim().isEmpty) {
      return getFacilities();
    }

    return _apiClient.get<List<FacilityDto>>(
      ApiEndpoints.facilitiesSearch,
      requiresAuth: true,
      queryParams: {'q': query.trim()},
      fromJson: (dynamic json) {
        final list = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data']
            : json;
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => FacilityDto.fromJson(e))
              .toList();
        }
        return <FacilityDto>[];
      },
    );
  }

  /// Retrieves detailed profile for a specific facility by ID
  /// GET /api/v1/facilities/:id
  Future<ApiResult<FacilityDto>> getFacilityById(String id) async {
    return _apiClient.get<FacilityDto>(
      ApiEndpoints.facilityById(id),
      requiresAuth: true,
      fromJson: (dynamic json) {
        final source = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data'] as Map<String, dynamic>
            : (json is Map<String, dynamic> ? json : <String, dynamic>{});
        return FacilityDto.fromJson(source);
      },
    );
  }
}

