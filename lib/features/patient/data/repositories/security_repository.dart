import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/security_session_models.dart';

/// CareID Security & Session Repository
/// Grounded in Postman folder `03. User Profile & Account` and `18. Security & Sessions`
class SecurityRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SecurityRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? apiClient?.tokenStorage ?? AppTokenStorage();

  /// Retrieves list of active sessions for authenticated patient
  /// GET /api/v1/auth/sessions
  Future<ApiResult<List<UserSessionDto>>> getActiveSessions() async {
    _isLoading = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure(
          message: 'Authentication session required. Please sign in.',
          statusCode: 401,
        );
      }

      final result = await _apiClient.get<List<UserSessionDto>>(
        ApiEndpoints.sessions,
        requiresAuth: true,
        fromJson: (json) {
          final list = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => UserSessionDto.fromJson(e))
                .toList();
          }
          return <UserSessionDto>[];
        },
      );
      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Terminates all other active sessions (remote device logout)
  /// DELETE /api/v1/auth/sessions
  Future<ApiResult<bool>> terminateAllOtherSessions() async {
    _isLoading = true;
    try {
      final result = await _apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.sessions,
        requiresAuth: true,
        fromJson: (dynamic json) =>
            json is Map<String, dynamic> ? json : <String, dynamic>{},
      );

      if (result is ApiSuccess) {
        return const ApiSuccess(data: true, message: 'All other sessions terminated successfully');
      } else {
        final failure = result as ApiFailure;
        return ApiFailure(
          message: failure.message,
          statusCode: failure.statusCode,
        );
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Terminates a specific active session
  /// DELETE /api/v1/auth/sessions/:sessionId
  Future<ApiResult<bool>> terminateSession(String sessionId) async {
    try {
      final result = await _apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.sessionById(sessionId),
        requiresAuth: true,
        fromJson: (dynamic json) =>
            json is Map<String, dynamic> ? json : <String, dynamic>{},
      );

      if (result is ApiSuccess) {
        return const ApiSuccess(data: true, message: 'Session revoked successfully');
      } else {
        final failure = result as ApiFailure;
        return ApiFailure(
          message: failure.message,
          statusCode: failure.statusCode,
        );
      }
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  /// Retrieves consent access audit history
  /// GET /api/v1/family/consents/history
  Future<ApiResult<List<ConsentAuditItemDto>>> getConsentAuditHistory() async {
    try {
      final result = await _apiClient.get<List<ConsentAuditItemDto>>(
        ApiEndpoints.consentHistory,
        requiresAuth: true,
        fromJson: (json) {
          final list = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => ConsentAuditItemDto.fromJson(e))
                .toList();
          }
          return <ConsentAuditItemDto>[];
        },
      );
      return result;
    } catch (_) {
      return const ApiSuccess(data: []);
    }
  }
}
