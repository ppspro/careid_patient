import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';
import 'api_result.dart';

/// Central HTTP Client for CareID Backend Integration.
/// Pointed strictly at https://360api.vnvision.in.
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final TokenStorage? _tokenStorage;
  final void Function()? onSessionExpired;

  bool _isRefreshing = false;

  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
    TokenStorage? tokenStorage,
    this.onSessionExpired,
  }) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
       _httpClient = httpClient ?? http.Client(),
       _tokenStorage = tokenStorage;

  TokenStorage? get tokenStorage => _tokenStorage;

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath')
        .replace(queryParameters: queryParams);
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'CareID-PatientApp/1.0.0',
    };

    final storage = _tokenStorage;
    if (requiresAuth && storage != null) {
      final token = await storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Perform a GET request
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, String>? queryParams,
    bool requiresAuth = false,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _httpClient
          .get(uri, headers: headers)
          .timeout(AppConfig.connectTimeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final newHeaders = await _getHeaders(requiresAuth: true);
          final retryResponse = await _httpClient
              .get(uri, headers: newHeaders)
              .timeout(AppConfig.connectTimeout);
          return _handleResponse<T>(retryResponse, fromJson);
        } else {
          _handleUnauthorized();
        }
      }

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiFailure<T>(
        message: 'Connection timed out. Please check your network connection.',
        statusCode: 408,
      );
    } on SocketException catch (e) {
      return ApiFailure<T>(
        message: 'Network error: Unable to reach CareID server.',
        error: e,
      );
    } catch (e) {
      return ApiFailure<T>(message: 'Unexpected network error: $e', error: e);
    }
  }

  /// Perform a POST request
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic body,
    bool requiresAuth = false,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _httpClient
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.connectTimeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final newHeaders = await _getHeaders(requiresAuth: true);
          final retryResponse = await _httpClient
              .post(
                uri,
                headers: newHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.connectTimeout);
          return _handleResponse<T>(retryResponse, fromJson);
        } else {
          _handleUnauthorized();
        }
      }

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiFailure<T>(
        message: 'Connection timed out. Please check your network connection.',
        statusCode: 408,
      );
    } on SocketException catch (e) {
      return ApiFailure<T>(
        message: 'Network error: Unable to reach CareID server.',
        error: e,
      );
    } catch (e) {
      return ApiFailure<T>(message: 'Unexpected network error: $e', error: e);
    }
  }

  /// Perform a PUT request
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic body,
    bool requiresAuth = false,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _httpClient
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.connectTimeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final newHeaders = await _getHeaders(requiresAuth: true);
          final retryResponse = await _httpClient
              .put(
                uri,
                headers: newHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.connectTimeout);
          return _handleResponse<T>(retryResponse, fromJson);
        } else {
          _handleUnauthorized();
        }
      }

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiFailure<T>(
        message: 'Connection timed out. Please check your network connection.',
        statusCode: 408,
      );
    } on SocketException catch (e) {
      return ApiFailure<T>(
        message: 'Network error: Unable to reach CareID server.',
        error: e,
      );
    } catch (e) {
      return ApiFailure<T>(message: 'Unexpected network error: $e', error: e);
    }
  }

  /// Perform a PATCH request
  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic body,
    bool requiresAuth = false,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _httpClient
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.connectTimeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final newHeaders = await _getHeaders(requiresAuth: true);
          final retryResponse = await _httpClient
              .patch(
                uri,
                headers: newHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.connectTimeout);
          return _handleResponse<T>(retryResponse, fromJson);
        } else {
          _handleUnauthorized();
        }
      }

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiFailure<T>(
        message: 'Connection timed out. Please check your network connection.',
        statusCode: 408,
      );
    } on SocketException catch (e) {
      return ApiFailure<T>(
        message: 'Network error: Unable to reach CareID server.',
        error: e,
      );
    } catch (e) {
      return ApiFailure<T>(message: 'Unexpected network error: $e', error: e);
    }
  }

  /// Perform a DELETE request
  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic body,
    bool requiresAuth = false,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _httpClient
          .delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.connectTimeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final newHeaders = await _getHeaders(requiresAuth: true);
          final retryResponse = await _httpClient
              .delete(
                uri,
                headers: newHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.connectTimeout);
          return _handleResponse<T>(retryResponse, fromJson);
        } else {
          _handleUnauthorized();
        }
      }

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiFailure<T>(
        message: 'Connection timed out. Please check your network connection.',
        statusCode: 408,
      );
    } on SocketException catch (e) {
      return ApiFailure<T>(
        message: 'Network error: Unable to reach CareID server.',
        error: e,
      );
    } catch (e) {
      return ApiFailure<T>(message: 'Unexpected network error: $e', error: e);
    }
  }

  /// Sends a multipart/form-data POST request with form fields and/or files.
  /// Automatically sets the proper Content-Type boundary header.
  Future<ApiResult<T>> postMultipart<T>(
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool requiresAuth = false,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final request = http.MultipartRequest('POST', uri);

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      headers.remove('Content-Type'); // Allow MultipartRequest to generate boundary
      request.headers.addAll(headers);

      if (fields != null) {
        request.fields.addAll(fields);
      }
      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse =
          await request.send().timeout(AppConfig.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final retryRequest = http.MultipartRequest('POST', uri);
          final newHeaders = await _getHeaders(requiresAuth: true);
          newHeaders.remove('Content-Type');
          retryRequest.headers.addAll(newHeaders);
          if (fields != null) retryRequest.fields.addAll(fields);
          if (files != null) retryRequest.files.addAll(files);

          final retryStreamed =
              await retryRequest.send().timeout(AppConfig.connectTimeout);
          final retryResponse = await http.Response.fromStream(retryStreamed);
          return _handleResponse<T>(retryResponse, fromJson);
        } else {
          _handleUnauthorized();
        }
      }

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiFailure<T>(
        message: 'Connection timed out. Please check your network connection.',
        statusCode: 408,
      );
    } on SocketException catch (e) {
      return ApiFailure<T>(
        message: 'Network error: Unable to reach CareID server.',
        error: e,
      );
    } catch (e) {
      return ApiFailure<T>(message: 'Unexpected network error: $e', error: e);
    }
  }

  /// Attempts to refresh access token using refresh token
  Future<bool> _attemptTokenRefresh() async {
    final storage = _tokenStorage;
    if (storage == null || _isRefreshing) return false;

    _isRefreshing = true;
    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final uri = _buildUri(ApiEndpoints.tokenRefresh);
      final response = await _httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(AppConfig.connectTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payload = data is Map<String, dynamic> && data.containsKey('data')
            ? data['data']
            : data;

        final newAccess = payload['accessToken'] as String?;
        final newRefresh = payload['refreshToken'] as String? ?? refreshToken;

        if (newAccess != null) {
          await storage.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void _handleUnauthorized() {
    _tokenStorage?.clear();
    onSessionExpired?.call();
  }

  /// Safe Health Check Probe
  Future<ApiResult<Map<String, dynamic>>> checkHealth() async {
    return get<Map<String, dynamic>>(
      ApiEndpoints.health,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }
        return <String, dynamic>{'status': 'unknown'};
      },
    );
  }

  ApiResult<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json)? fromJson,
  ) {
    final statusCode = response.statusCode;
    dynamic decodedBody;

    try {
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      }
    } catch (_) {
      decodedBody = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      final dataField =
          (decodedBody is Map<String, dynamic> &&
              decodedBody.containsKey('data'))
          ? decodedBody['data']
          : decodedBody;

      final message = (decodedBody is Map<String, dynamic>)
          ? decodedBody['message'] as String?
          : null;

      final parsed = fromJson != null ? fromJson(dataField) : (dataField as T);

      return ApiSuccess<T>(
        data: parsed,
        message: message,
        statusCode: statusCode,
      );
    } else {
      String errorMessage = 'Server error ($statusCode)';
      if (decodedBody is Map<String, dynamic>) {
        errorMessage =
            decodedBody['message']?.toString() ??
            decodedBody['error']?.toString() ??
            errorMessage;
      }

      return ApiFailure<T>(
        message: errorMessage,
        statusCode: statusCode,
        error: decodedBody,
      );
    }
  }

  void close() {
    _httpClient.close();
  }
}
