import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/health_info_models.dart';
import '../models/insurance_models.dart';

/// Repository coordinating Step 3 Health Information, Demographics, and Step 4 Insurance.
/// Grounded strictly in OpenAPI 3.0.0 (https://360api.vnvision.in/docs).
class OnboardingRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  bool _isSavingMedicalSummary = false;
  bool _isSavingDemographics = false;
  bool _isSavingEmergencyContact = false;
  bool _isSavingHealthInfo = false;
  bool _isSavingInsurance = false;

  OnboardingRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? InMemoryTokenStorage();

  bool get isSaving =>
      _isSavingMedicalSummary ||
      _isSavingDemographics ||
      _isSavingEmergencyContact ||
      _isSavingHealthInfo ||
      _isSavingInsurance;

  /// Updates Patient Medical Summary (Blood Group, Allergies, Chronic Conditions)
  /// PATCH /api/v1/patients/me/medical-summary
  Future<ApiResult<Map<String, dynamic>>> saveMedicalSummary(
    MedicalSummaryDto dto,
  ) async {
    if (_isSavingMedicalSummary) {
      return const ApiFailure<Map<String, dynamic>>(
        message: 'A medical summary save operation is already in progress.',
        statusCode: 429,
      );
    }

    _isSavingMedicalSummary = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure<Map<String, dynamic>>(
          message: 'Authentication session required. Please verify OTP first.',
          statusCode: 401,
        );
      }

      final result = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.patientMedicalSummary,
        body: dto.toJson(),
        requiresAuth: true,
        fromJson: (json) {
          if (json is Map<String, dynamic>) return json;
          return <String, dynamic>{'status': 'updated'};
        },
      );

      return result;
    } finally {
      _isSavingMedicalSummary = false;
    }
  }

  /// Saves Step 2 Demographics Details
  /// POST /api/v1/patients/onboarding/demographics
  Future<ApiResult<Map<String, dynamic>>> saveDemographics(
    DemographicsDto dto,
  ) async {
    if (_isSavingDemographics) {
      return const ApiFailure<Map<String, dynamic>>(
        message: 'A demographics save operation is already in progress.',
        statusCode: 429,
      );
    }

    _isSavingDemographics = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure<Map<String, dynamic>>(
          message: 'Authentication session required. Please verify OTP first.',
          statusCode: 401,
        );
      }

      final result = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.onboardingDemographics,
        body: dto.toJson(),
        requiresAuth: true,
        fromJson: (json) {
          if (json is Map<String, dynamic>) return json;
          return <String, dynamic>{'status': 'saved'};
        },
      );

      return result;
    } finally {
      _isSavingDemographics = false;
    }
  }

  /// Saves Step 3 Emergency Contact
  /// POST /api/v1/patients/onboarding/emergency-contact
  Future<ApiResult<Map<String, dynamic>>> saveEmergencyContact(
    EmergencyContactDto dto,
  ) async {
    if (_isSavingEmergencyContact) {
      return const ApiFailure<Map<String, dynamic>>(
        message: 'An emergency contact save operation is already in progress.',
        statusCode: 429,
      );
    }

    _isSavingEmergencyContact = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure<Map<String, dynamic>>(
          message: 'Authentication session required. Please verify OTP first.',
          statusCode: 401,
        );
      }

      final result = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.onboardingEmergencyContact,
        body: dto.toJson(),
        requiresAuth: true,
        fromJson: (json) {
          if (json is Map<String, dynamic>) return json;
          return <String, dynamic>{'status': 'saved'};
        },
      );

      return result;
    } finally {
      _isSavingEmergencyContact = false;
    }
  }

  /// Coordinated submission of Health Info.
  /// Executes required and optional medical and demographic records in sequence.
  /// Handles partial failures and preserves user input.
  Future<ApiResult<Map<String, dynamic>>> submitHealthInformation({
    required MedicalSummaryDto medicalSummary,
    DemographicsDto? demographics,
    EmergencyContactDto? emergencyContact,
  }) async {
    if (_isSavingHealthInfo) {
      return const ApiFailure<Map<String, dynamic>>(
        message: 'A submission is currently in flight. Please wait.',
        statusCode: 429,
      );
    }

    _isSavingHealthInfo = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure<Map<String, dynamic>>(
          message: 'Authentication session expired or missing. Please verify your mobile number via OTP.',
          statusCode: 401,
        );
      }

      // 1. Submit Demographics if provided
      if (demographics != null) {
        final demoResult = await saveDemographics(demographics);
        if (demoResult.isFailure) {
          return demoResult;
        }
      }

      // 2. Submit Medical Summary (Blood group, allergies, conditions)
      final medResult = await saveMedicalSummary(medicalSummary);
      if (medResult.isFailure) {
        return medResult;
      }

      // 3. Submit Emergency Contact if provided
      if (emergencyContact != null) {
        final ecResult = await saveEmergencyContact(emergencyContact);
        if (ecResult.isFailure) {
          return ecResult;
        }
      }

      return const ApiSuccess<Map<String, dynamic>>(
        data: {'status': 'completed', 'step': 3},
        message: 'Health information saved successfully.',
        statusCode: 200,
      );
    } finally {
      _isSavingHealthInfo = false;
    }
  }

  /// Saves Step 4 Insurance details
  /// POST /api/v1/patients/onboarding/insurance
  /// Alias: POST /api/v1/insurance/onboard
  Future<ApiResult<Map<String, dynamic>>> saveInsurance(
    OnboardInsuranceDto dto,
  ) async {
    if (_isSavingInsurance) {
      return const ApiFailure<Map<String, dynamic>>(
        message: 'An insurance save operation is already in progress.',
        statusCode: 429,
      );
    }

    // Client-side field validation before network transmission
    final validationError = dto.validate();
    if (validationError != null) {
      return ApiFailure<Map<String, dynamic>>(
        message: validationError,
        statusCode: 400,
      );
    }

    _isSavingInsurance = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure<Map<String, dynamic>>(
          message: 'Authentication session required. Please verify OTP first.',
          statusCode: 401,
        );
      }

      final result = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.onboardingInsurance,
        body: dto.toJson(),
        requiresAuth: true,
        fromJson: (json) {
          if (json is Map<String, dynamic>) return json;
          return <String, dynamic>{'status': 'saved', 'step': 4};
        },
      );

      return result;
    } finally {
      _isSavingInsurance = false;
    }
  }

  /// Optional: Submits insurance card image for OCR scanning
  /// POST /api/v1/insurance/ocr/scan
  Future<ApiResult<Map<String, dynamic>>> scanInsuranceCard(
    InsuranceOcrScanDto dto,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return const ApiFailure<Map<String, dynamic>>(
        message: 'Authentication session required for OCR scanning.',
        statusCode: 401,
      );
    }

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.insuranceOcrScan,
      body: dto.toJson(),
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) return json;
        return <String, dynamic>{'status': 'scanned'};
      },
    );
  }

  /// Retrieves step-by-step onboarding checklist progress
  /// GET /api/v1/patients/onboarding/progress
  Future<ApiResult<OnboardingProgressDto>> getOnboardingProgress() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return const ApiFailure<OnboardingProgressDto>(
        message: 'Authentication session required.',
        statusCode: 401,
      );
    }

    return _apiClient.get<OnboardingProgressDto>(
      ApiEndpoints.onboardingProgress,
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return OnboardingProgressDto.fromJson(json);
        }
        return const OnboardingProgressDto();
      },
    );
  }
}
