import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/digital_health_card_models.dart';

/// CareID Digital Health Card Repository
/// Grounded in `07. Digital Health Cards & Passes`
class DigitalHealthCardRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DigitalHealthCardRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? apiClient?.tokenStorage ?? AppTokenStorage();

  /// Retrieves active Health Card details for current patient
  /// GET /api/v1/health-cards
  Future<ApiResult<HealthCardDto>> getActiveHealthCard() async {
    _isLoading = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure(
          message: 'Authentication session required. Please sign in.',
          statusCode: 401,
        );
      }

      final result = await _apiClient.get<HealthCardDto>(
        ApiEndpoints.healthCards,
        requiresAuth: true,
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            return HealthCardDto.fromJson(json);
          } else if (json is List && json.isNotEmpty && json.first is Map) {
            return HealthCardDto.fromJson(json.first as Map<String, dynamic>);
          }
          return const HealthCardDto();
        },
      );
      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Issues a new Health Card if none exists
  /// POST /api/v1/health-cards
  Future<ApiResult<HealthCardDto>> issueHealthCard({String reason = 'Initial patient issuance'}) async {
    return _apiClient.post<HealthCardDto>(
      ApiEndpoints.healthCards,
      requiresAuth: true,
      body: {'reason': reason},
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return HealthCardDto.fromJson(json);
        }
        return const HealthCardDto();
      },
    );
  }

  /// Verifies a digital Health Card QR payload
  /// POST /api/v1/health-cards/verify-qr
  Future<ApiResult<VerifyQrResponseDto>> verifyQrPayload(String qrPayload) async {
    return _apiClient.post<VerifyQrResponseDto>(
      ApiEndpoints.healthCardsVerifyQr,
      requiresAuth: true,
      body: {'qrPayload': qrPayload},
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return VerifyQrResponseDto.fromJson(json);
        }
        return const VerifyQrResponseDto(isValid: false, message: 'Invalid QR payload format');
      },
    );
  }

  /// Retrieves status audit history for a specific card
  /// GET /api/v1/health-cards/:id/history
  Future<ApiResult<List<HealthCardHistoryItemDto>>> getCardHistory(String cardId) async {
    return _apiClient.get<List<HealthCardHistoryItemDto>>(
      '${ApiEndpoints.healthCards}/$cardId/history',
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => HealthCardHistoryItemDto.fromJson(
                  e is Map<String, dynamic> ? e : <String, dynamic>{}))
              .toList();
        }
        return [];
      },
    );
  }

  /// Activates card
  /// POST /api/v1/health-cards/:id/activate
  Future<ApiResult<Map<String, dynamic>>> activateCard(String cardId) async {
    return _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.healthCards}/$cardId/activate',
      requiresAuth: true,
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }

  /// Retrieves active and recent clinical access sharing grants
  /// GET /api/v1/family/consents
  Future<ApiResult<List<SharedAccessGrantDto>>> getSharedAccessGrants() async {
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

  /// Revokes an active clinical access sharing grant
  /// PATCH /api/v1/family/consents/:id
  Future<ApiResult<Map<String, dynamic>>> revokeSharedAccessGrant(String grantId) async {
    return _apiClient.patch<Map<String, dynamic>>(
      '${ApiEndpoints.familyConsents}/$grantId',
      requiresAuth: true,
      body: {'status': 'REVOKED'},
      fromJson: (json) => json is Map<String, dynamic> ? json : {'status': 'REVOKED'},
    );
  }

  /// Creates a clinical access sharing grant
  /// POST /api/v1/family/consents
  Future<ApiResult<Map<String, dynamic>>> createSharedAccessGrant({
    required String familyMemberId,
    required String category,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.familyConsents,
      requiresAuth: true,
      body: {
        'familyMemberId': familyMemberId,
        'category': category,
      },
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }

  /// Deactivates card
  /// POST /api/v1/health-cards/:id/deactivate
  Future<ApiResult<Map<String, dynamic>>> deactivateCard(String cardId) async {
    return _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.healthCards}/$cardId/deactivate',
      requiresAuth: true,
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }
  /// Blocks Health Card for security, fraud, or lost card reasons
  /// POST /api/v1/health-cards/:id/block
  Future<ApiResult<HealthCardDto>> blockHealthCard(
    String cardId, {
    String reason = 'Compromised or lost card',
  }) async {
    return _apiClient.post<HealthCardDto>(
      '${ApiEndpoints.healthCards}/$cardId/block',
      requiresAuth: true,
      body: {'reason': reason},
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return HealthCardDto.fromJson(json);
        }
        return const HealthCardDto();
      },
    );
  }

  /// Unblocks a previously BLOCKED Health Card
  /// POST /api/v1/health-cards/:id/unblock
  Future<ApiResult<HealthCardDto>> unblockHealthCard(String cardId) async {
    return _apiClient.post<HealthCardDto>(
      '${ApiEndpoints.healthCards}/$cardId/unblock',
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return HealthCardDto.fromJson(json);
        }
        return const HealthCardDto();
      },
    );
  }
}
