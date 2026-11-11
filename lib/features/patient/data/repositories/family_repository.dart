import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/digital_health_card_models.dart';
import '../models/family_models.dart';

/// CareID Family Members & Invitations Repository
/// Grounded in `12. Family Members & Relationships`
class FamilyRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FamilyRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? apiClient?.tokenStorage ?? AppTokenStorage();

  TokenStorage get tokenStorage => _tokenStorage;

  /// Retrieves list of family invitations
  /// GET /api/v1/family/invitations
  Future<ApiResult<List<FamilyInvitationDto>>> getInvitations() async {
    _isLoading = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure(
          message: 'Authentication session required. Please sign in.',
          statusCode: 401,
        );
      }

      final result = await _apiClient.get<List<FamilyInvitationDto>>(
        ApiEndpoints.familyInvitations,
        requiresAuth: true,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((e) => FamilyInvitationDto.fromJson(
                    e is Map<String, dynamic> ? e : <String, dynamic>{}))
                .toList();
          }
          return [];
        },
      );
      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Sends a new family linkage invitation
  /// POST /api/v1/family/invitations
  Future<ApiResult<FamilyInvitationDto>> sendInvitation(FamilyInvitationDto dto) async {
    return _apiClient.post<FamilyInvitationDto>(
      ApiEndpoints.familyInvitations,
      requiresAuth: true,
      body: dto.toJson(),
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return FamilyInvitationDto.fromJson(json);
        }
        return dto;
      },
    );
  }

  /// Retrieves linked family members
  /// GET /api/v1/family/members
  Future<ApiResult<List<FamilyMemberDto>>> getMembers() async {
    return _apiClient.get<List<FamilyMemberDto>>(
      ApiEndpoints.familyMembers,
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => FamilyMemberDto.fromJson(
                  e is Map<String, dynamic> ? e : <String, dynamic>{}))
              .toList();
        }
        return [];
      },
    );
  }

  /// Retrieves family consents & data sharing requests
  /// GET /api/v1/family/consents
  Future<ApiResult<List<SharedAccessGrantDto>>> getConsents() async {
    return _apiClient.get<List<SharedAccessGrantDto>>(
      ApiEndpoints.familyConsents,
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => SharedAccessGrantDto.fromJson(
                  e is Map<String, dynamic> ? e : <String, dynamic>{}))
              .toList();
        }
        return [];
      },
    );
  }

  /// Updates family linkage consent status (ACCEPTED / REJECTED)
  /// PATCH /api/v1/family/consents/:id
  Future<ApiResult<Map<String, dynamic>>> updateConsent({
    required String consentId,
    required String status,
  }) async {
    return _apiClient.patch<Map<String, dynamic>>(
      '${ApiEndpoints.familyConsents}/$consentId',
      requiresAuth: true,
      body: {'status': status},
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }

  /// Retrieves list of guardians assigned to the patient
  /// GET /api/v1/family/guardians
  Future<ApiResult<List<Map<String, dynamic>>>> getGuardians() async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.familyGuardians,
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

  /// Assigns a guardian to the patient
  /// POST /api/v1/family/guardians
  Future<ApiResult<Map<String, dynamic>>> assignGuardian(Map<String, dynamic> data) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.familyGuardians,
      requiresAuth: true,
      body: data,
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }

  /// Retrieves list of dependents registered under the patient
  /// GET /api/v1/family/dependents
  Future<ApiResult<List<Map<String, dynamic>>>> getDependents() async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.familyDependents,
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

  /// Registers a dependent (minor, senior, or care patient)
  /// POST /api/v1/family/dependents
  Future<ApiResult<Map<String, dynamic>>> registerDependent(Map<String, dynamic> data) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.familyDependents,
      requiresAuth: true,
      body: data,
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }
}

