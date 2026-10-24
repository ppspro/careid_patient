import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/otp_models.dart';
import '../models/patient_registration.dart';

/// CareID Patient App — Auth & OTP Repository
/// Handles OTP challenge dispatch, verification, token persistence, and session management.
class AuthRepository {
  final ApiClient? _apiClient;
  final TokenStorage _tokenStorage;

  bool _isRequestInFlight = false;
  bool _isVerifyInFlight = false;
  bool _isResendInFlight = false;

  AuthRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient,
      _tokenStorage = tokenStorage ?? InMemoryTokenStorage();

  bool get isRequestInFlight => _isRequestInFlight;
  bool get isVerifyInFlight => _isVerifyInFlight;
  bool get isResendInFlight => _isResendInFlight;
  TokenStorage get tokenStorage => _tokenStorage;

  /// Requests a 6-digit OTP code for a phone number.
  /// Endpoint: POST /api/v1/auth/otp/request
  Future<ApiResult<RequestOtpResponseDto>> requestOtp(String phone) async {
    if (!RequestOtpDto.isValidPhone(phone)) {
      return const ApiFailure(
        message: 'Invalid phone number. Please enter a valid international or 10-digit number.',
        statusCode: 422,
      );
    }

    if (_isRequestInFlight) {
      return const ApiFailure(
        message: 'An OTP request is already in progress. Please wait.',
      );
    }

    _isRequestInFlight = true;

    try {
      final client = _apiClient ?? ApiClient(tokenStorage: _tokenStorage);
      final result = await client.post<RequestOtpResponseDto>(
        ApiEndpoints.otpRequest,
        body: RequestOtpDto(phone: phone).toJson(),
        fromJson: (json) => RequestOtpResponseDto.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );

      _isRequestInFlight = false;

      if (result.isSuccess) {
        return ApiSuccess(
          data: result.dataOrNull!,
          message: result.messageOrNull,
        );
      } else {
        final failure = result as ApiFailure<RequestOtpResponseDto>;
        final mapped = _mapServerError(failure.message);
        return ApiFailure(
          message: mapped,
          statusCode: failure.statusCode,
          error: failure.error,
        );
      }
    } catch (e) {
      _isRequestInFlight = false;
      return ApiFailure(message: 'Network error requesting OTP: $e');
    }
  }

  /// Verifies a 6-digit OTP code against the active challenge identifier.
  /// Endpoint: POST /api/v1/auth/otp/verify
  /// Upon successful verification, securely stores the returned JWT access & refresh tokens.
  Future<ApiResult<VerifyOtpResponseDto>> verifyOtp({
    required String challengeId,
    required String otpCode,
  }) async {
    if (!VerifyOtpDto.isValidOtpCode(otpCode)) {
      return const ApiFailure(
        message: 'Verification code must be exactly 6 digits.',
        statusCode: 422,
      );
    }

    if (challengeId.isEmpty) {
      return const ApiFailure(
        message:
            'Challenge session identifier missing. Please request a new code.',
        statusCode: 400,
      );
    }

    if (_isVerifyInFlight) {
      return const ApiFailure(
        message: 'Verification is currently in progress. Please wait.',
      );
    }

    _isVerifyInFlight = true;

    try {
      final client = _apiClient ?? ApiClient(tokenStorage: _tokenStorage);
      final result = await client.post<VerifyOtpResponseDto>(
        ApiEndpoints.otpVerify,
        body: VerifyOtpDto(challengeId: challengeId, otpCode: otpCode).toJson(),
        fromJson: (json) => VerifyOtpResponseDto.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );

      _isVerifyInFlight = false;

      if (result.isSuccess) {
        final data = result.dataOrNull!;
        if (data.accessToken.isNotEmpty) {
          await _tokenStorage.saveTokens(
            accessToken: data.accessToken,
            refreshToken: data.refreshToken,
          );
        }
        return ApiSuccess(
          data: data,
          message: result.messageOrNull ?? 'Verification successful',
        );
      } else {
        final failure = result as ApiFailure<VerifyOtpResponseDto>;
        final mapped = _mapServerError(failure.message);
        return ApiFailure(
          message: mapped,
          statusCode: failure.statusCode,
          error: failure.error,
        );
      }
    } catch (e) {
      _isVerifyInFlight = false;
      return ApiFailure(message: 'Network error verifying OTP: $e');
    }
  }

  /// Resends an OTP for an existing challenge session.
  /// Endpoint: POST /api/v1/auth/otp/resend
  Future<ApiResult<ResendOtpResponseDto>> resendOtp(String challengeId) async {
    if (challengeId.isEmpty) {
      return const ApiFailure(
        message: 'Active challenge identifier required to resend OTP.',
        statusCode: 400,
      );
    }

    if (_isResendInFlight) {
      return const ApiFailure(
        message: 'Resend request already in progress. Please wait.',
      );
    }

    _isResendInFlight = true;

    try {
      final client = _apiClient ?? ApiClient(tokenStorage: _tokenStorage);
      final result = await client.post<ResendOtpResponseDto>(
        ApiEndpoints.otpResend,
        body: ResendOtpDto(challengeId: challengeId).toJson(),
        fromJson: (json) => ResendOtpResponseDto.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );

      _isResendInFlight = false;

      if (result.isSuccess) {
        return ApiSuccess(
          data: result.dataOrNull!,
          message: result.messageOrNull,
        );
      } else {
        final failure = result as ApiFailure<ResendOtpResponseDto>;
        final mapped = _mapServerError(failure.message);
        return ApiFailure(
          message: mapped,
          statusCode: failure.statusCode,
          error: failure.error,
        );
      }
    } catch (e) {
      _isResendInFlight = false;
      return ApiFailure(message: 'Network error resending OTP: $e');
    }
  }

  /// Initializes patient draft profile using the newly established JWT Bearer session.
  /// Endpoint: POST /api/v1/patients/register
  Future<ApiResult<PatientRegistrationDraft>> initializePatientDraft() async {
    try {
      final client = _apiClient ?? ApiClient(tokenStorage: _tokenStorage);
      final result = await client.post<PatientRegistrationDraft>(
        ApiEndpoints.patientRegisterDraft,
        requiresAuth: true,
        fromJson: (json) => PatientRegistrationDraft.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );
      return result;
    } catch (e) {
      return ApiFailure(
        message: 'Error initializing draft patient profile: $e',
      );
    }
  }

  /// Maps known backend errors (such as missing database tables) to clear messages.
  String _mapServerError(String raw) {
    if (raw.contains('public.users') || raw.contains('DatabaseError(P2021)')) {
      return 'Live Backend Blocker: The users table (public.users) does not exist in the database. Client OTP challenge blocked until backend database migrations are applied.';
    }
    if (raw.contains('challengeId must be a valid UUIDv4')) {
      return 'Invalid challenge session identifier. Please request a new verification code.';
    }
    if (raw.contains('otpCode must be a 6-digit')) {
      return 'Verification code must be 6 digits.';
    }
    return raw;
  }
}
