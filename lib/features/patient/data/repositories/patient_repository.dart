import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/patient_profile_models.dart';

/// CareID Patient Profile Repository
/// Grounded strictly in OpenAPI 3.0.0 and `06. Patient App` API catalog
class PatientRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PatientRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? apiClient?.tokenStorage ?? AppTokenStorage();

  TokenStorage get tokenStorage => _tokenStorage;

  /// Retrieves current patient profile summary
  /// Attempts GET /api/v1/patients/me/full first for comprehensive clinical fields,
  /// falling back to GET /api/v1/patients/me if needed.
  Future<ApiResult<PatientProfileDto>> getPatientProfile() async {
    _isLoading = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure(
          message: 'Authentication required. Please sign in.',
          statusCode: 401,
        );
      }

      final fullResult = await getFullProfile();
      if (fullResult.isSuccess && fullResult.dataOrNull != null) {
        return fullResult;
      }

      final result = await _apiClient.get<PatientProfileDto>(
        ApiEndpoints.patientProfileMe,
        requiresAuth: true,
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            return PatientProfileDto.fromJson(json);
          }
          return const PatientProfileDto(id: '', firstName: '', lastName: '');
        },
      );

      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Retrieves full extended patient profile
  /// GET /api/v1/patients/me/full
  Future<ApiResult<PatientProfileDto>> getFullProfile() async {
    _isLoading = true;
    try {
      final result = await _apiClient.get<PatientProfileDto>(
        ApiEndpoints.patientProfileFull,
        requiresAuth: true,
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            return PatientProfileDto.fromJson(json);
          }
          return const PatientProfileDto(id: '', firstName: '', lastName: '');
        },
      );
      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Retrieves profile completion breakdown
  /// GET /api/v1/patients/profile/completion
  Future<ApiResult<ProfileCompletionDto>> getProfileCompletion() async {
    return _apiClient.get<ProfileCompletionDto>(
      ApiEndpoints.patientProfileCompletion,
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return ProfileCompletionDto.fromJson(json);
        }
        return const ProfileCompletionDto(percentage: 100);
      },
    );
  }

  /// Updates basic patient demographic fields (name, DOB, gender)
  /// PATCH /api/v1/patients/me/basic
  Future<ApiResult<Map<String, dynamic>>> updateBasicInfo({
    required String firstName,
    required String lastName,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
  }) async {
    return _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.patientBasic,
      requiresAuth: true,
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (gender != null) 'gender': gender,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
      },
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }

  /// Updates medical summary (blood group, allergies, conditions)
  /// PATCH /api/v1/patients/me/medical-summary
  Future<ApiResult<Map<String, dynamic>>> updateMedicalSummary({
    String? bloodGroup,
    List<String>? allergies,
    List<String>? conditions,
  }) async {
    return _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.patientMedicalSummary,
      requiresAuth: true,
      body: {
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        if (allergies != null) 'knownAllergies': allergies,
        if (conditions != null) 'chronicConditions': conditions,
      },
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }

  /// Updates current address
  /// PATCH /api/v1/patients/me/address
  Future<ApiResult<Map<String, dynamic>>> updateAddress(String addressLine) async {
    return _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.patientAddress,
      requiresAuth: true,
      body: {
        'currentAddress': {'line1': addressLine.trim()},
      },
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }
  /// Uploads or replaces current patient profile photo.
  /// Supports direct image file/bytes upload via multipart ('file' field)
  /// as well as JSON/form-field photoUrl & photoKey contracts.
  /// POST /api/v1/patients/me/photo
  Future<ApiResult<Map<String, dynamic>>> updateProfilePhoto({
    String? photoUrl,
    String? photoKey,
    List<int>? bytes,
    String? filePath,
    String? fileName,
  }) async {
    // 1. If physical image file or bytes provided, perform multipart file upload
    if ((bytes != null && bytes.isNotEmpty) || (filePath != null && filePath.isNotEmpty)) {
      return uploadProfilePhotoFile(
        bytes: bytes,
        filePath: filePath,
        fileName: fileName,
      );
    }

    // 2. Fallback to URL/key field update
    final fields = <String, String>{};
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      fields['photoUrl'] = photoUrl.trim();
    }
    if (photoKey != null && photoKey.trim().isNotEmpty) {
      fields['photoKey'] = photoKey.trim();
    }

    try {
      final res = await _apiClient.postMultipart<Map<String, dynamic>>(
        ApiEndpoints.patientPhoto,
        requiresAuth: true,
        fields: fields,
        fromJson: (json) => json is Map<String, dynamic> ? json : {},
      );
      if (res.isSuccess) return res;
    } catch (_) {}

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.patientPhoto,
      requiresAuth: true,
      body: fields,
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }

  /// Direct multipart file upload to backend: POST /api/v1/patients/me/photo
  /// Attaches multipart field 'file' as required by NestJS FileInterceptor('file')
  Future<ApiResult<Map<String, dynamic>>> uploadProfilePhotoFile({
    List<int>? bytes,
    String? filePath,
    String? fileName,
  }) async {
    try {
      http.MultipartFile? multipartFile;

      if (filePath != null && filePath.isNotEmpty) {
        multipartFile = await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: fileName,
        );
      } else if (bytes != null && bytes.isNotEmpty) {
        multipartFile = http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName ?? 'profile_photo.jpg',
        );
      }

      if (multipartFile == null) {
        return const ApiFailure(message: 'No image file or bytes provided');
      }

      return await _apiClient.postMultipart<Map<String, dynamic>>(
        ApiEndpoints.patientPhoto,
        requiresAuth: true,
        files: [multipartFile],
        fromJson: (json) => json is Map<String, dynamic> ? json : {},
      );
    } catch (e) {
      return ApiFailure(message: 'Failed to upload image file: $e', error: e);
    }
  }

  /// Deletes current patient profile photo
  /// DELETE /api/v1/patients/me/photo
  Future<ApiResult<bool>> deleteProfilePhoto() async {
    return _apiClient.delete<bool>(
      ApiEndpoints.patientPhoto,
      requiresAuth: true,
      fromJson: (json) => true,
    );
  }

  /// Retrieves profile change timeline
  /// GET /api/v1/patients/profile/timeline
  Future<ApiResult<List<Map<String, dynamic>>>> getProfileTimeline() async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.patientProfileTimeline,
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

  /// Retrieves profile activity summary
  /// GET /api/v1/patients/profile/activity
  Future<ApiResult<Map<String, dynamic>>> getProfileActivity() async {
    return _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.patientProfileActivity,
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return (json['data'] is Map<String, dynamic>)
              ? json['data'] as Map<String, dynamic>
              : json;
        }
        return <String, dynamic>{};
      },
    );
  }
}
