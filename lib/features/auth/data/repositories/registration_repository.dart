import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../models/patient_registration.dart';
import '../models/register_patient_request.dart';
import '../models/registration_context.dart';

/// CareID Patient App — Registration Repository
/// Encapsulates all data access and integration logic for patient registration.
class RegistrationRepository {
  final ApiClient? _apiClient;
  bool _isInFlight = false;

  RegistrationRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  /// Whether a registration submission is currently in flight.
  bool get isInFlight => _isInFlight;

  /// Registers a new patient draft profile.
  /// Calls POST /api/v1/patients/register.
  /// If the backend requires OTP authentication before profile creation (HTTP 401),
  /// it gracefully initiates OTP challenge via POST /api/v1/auth/otp/request.
  Future<ApiResult<RegistrationContext>> registerPatient(
    RegisterPatientRequest request,
  ) async {
    if (_isInFlight) {
      return const ApiFailure(
        message: 'A registration request is already in progress. Please wait.',
      );
    }

    _isInFlight = true;

    try {
      final client = _apiClient ?? ApiClient();

      // Step 1: Attempt direct draft patient profile registration
      final registerResult = await client.post<PatientRegistrationDraft>(
        ApiEndpoints.patientRegisterDraft,
        body: request.toJson(),
        fromJson: (json) => PatientRegistrationDraft.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );

      // If successful (HTTP 201 Created), construct RegistrationContext and return
      if (registerResult.isSuccess) {
        final draft = registerResult.dataOrNull;
        _isInFlight = false;
        return ApiSuccess(
          data: RegistrationContext(
            fullName: request.fullName,
            phone: request.phone,
            email: request.email,
            profileId: draft?.profileId,
            patientNumber: draft?.patientNumber,
            status: draft?.status ?? 'DRAFT',
            onboardingStep: draft?.onboardingStep ?? 1,
          ),
          message: registerResult.messageOrNull,
        );
      }

      // Step 2: Handle HTTP 401 Unauthorized
      // Per OpenAPI and backend analysis, /api/v1/patients/register requires a Bearer JWT
      // if user authentication precedes profile creation.
      // In this flow, we initiate mobile OTP verification challenge.
      final failure = registerResult as ApiFailure<PatientRegistrationDraft>;
      if (failure.statusCode == 401) {
        final otpResult = await client.post<Map<String, dynamic>>(
          ApiEndpoints.otpRequest,
          body: {'phone': request.phone},
        );

        _isInFlight = false;

        if (otpResult.isSuccess) {
          final otpData = otpResult.dataOrNull ?? <String, dynamic>{};
          final challengeId = otpData['challengeId']?.toString();
          return ApiSuccess(
            data: RegistrationContext(
              fullName: request.fullName,
              phone: request.phone,
              email: request.email,
              status: 'OTP_PENDING',
              onboardingStep: 2,
              challengeId: challengeId,
            ),
            message:
                otpResult.messageOrNull ??
                'Verification code dispatched to your mobile number.',
          );
        } else {
          final otpFailure = otpResult as ApiFailure<Map<String, dynamic>>;
          return ApiFailure(
            message:
                'Authentication session required. OTP service error: ${otpFailure.message}',
            statusCode: otpFailure.statusCode,
            error: otpFailure.error,
          );
        }
      }

      _isInFlight = false;
      return ApiFailure(
        message: failure.message,
        statusCode: failure.statusCode,
        error: failure.error,
      );
    } catch (e) {
      _isInFlight = false;
      return ApiFailure(
        message: 'Network or communication failure: ${e.toString()}',
      );
    }
  }
}
