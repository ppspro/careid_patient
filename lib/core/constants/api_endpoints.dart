/// CareID Backend API Endpoints
/// Grounded strictly in the OpenAPI 3.0.0 specification from https://360api.vnvision.in/docs.
class ApiEndpoints {
  ApiEndpoints._();

  // Health Check
  static const String health = '/api/v1/health';

  // Authentication & Session
  static const String otpRequest = '/api/v1/auth/otp/request';
  static const String otpVerify = '/api/v1/auth/otp/verify';
  static const String otpResend = '/api/v1/auth/otp/resend';
  static const String tokenRefresh = '/api/v1/auth/token/refresh';
  static const String authMe = '/api/v1/auth/me';
  static const String logout = '/api/v1/auth/logout';
  static const String logoutAll = '/api/v1/auth/logout-all';
  static const String sessions = '/api/v1/auth/sessions';

  // Patient Registration & Onboarding Lifecycle
  static const String patientRegisterDraft = '/api/v1/patients/register';
  static const String patientRegisterStatus =
      '/api/v1/patients/register/status';
  static const String patientRegisterResume =
      '/api/v1/patients/register/resume';

  // Step-by-Step Onboarding
  static const String onboardingProgress =
      '/api/v1/patients/onboarding/progress';
  static const String onboardingDemographics =
      '/api/v1/patients/onboarding/demographics';
  static const String onboardingEmergencyContact =
      '/api/v1/patients/onboarding/emergency-contact';
  static const String onboardingInsurance =
      '/api/v1/patients/onboarding/insurance';
  static const String onboardingHealthCard =
      '/api/v1/patients/onboarding/health-card';
  static const String onboardingFamilyInvite =
      '/api/v1/patients/onboarding/family-invite';
  static const String onboardingComplete =
      '/api/v1/patients/onboarding/complete';

  // Patient Profile
  static const String patientProfileMe = '/api/v1/patients/me';
  static const String patientProfileFull = '/api/v1/patients/me/full';
  static const String patientMedicalSummary =
      '/api/v1/patients/me/medical-summary';
  static const String patientAddress = '/api/v1/patients/me/address';
  static const String patientBasic = '/api/v1/patients/me/basic';

  // Insurance & OCR
  static const String insuranceOnboard = '/api/v1/insurance/onboard';
  static const String insurancePolicies = '/api/v1/insurance/policies';
  static const String insuranceOcrScan = '/api/v1/insurance/ocr/scan';
  static const String insuranceOcrConfirm = '/api/v1/insurance/ocr/confirm';
}
