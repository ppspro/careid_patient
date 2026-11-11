import 'package:test/test.dart';

import 'package:careid_patient_app/core/constants/api_endpoints.dart';

void main() {
  group('ApiEndpoints Configuration', () {
    test('all endpoints must start with /api/v1/', () {
      final endpoints = [
        ApiEndpoints.health,
        ApiEndpoints.otpRequest,
        ApiEndpoints.otpVerify,
        ApiEndpoints.otpResend,
        ApiEndpoints.tokenRefresh,
        ApiEndpoints.authMe,
        ApiEndpoints.logout,
        ApiEndpoints.logoutAll,
        ApiEndpoints.sessions,
        ApiEndpoints.patientRegisterDraft,
        ApiEndpoints.patientRegisterStatus,
        ApiEndpoints.patientRegisterResume,
        ApiEndpoints.onboardingProgress,
        ApiEndpoints.onboardingDemographics,
        ApiEndpoints.onboardingEmergencyContact,
        ApiEndpoints.onboardingInsurance,
        ApiEndpoints.onboardingHealthCard,
        ApiEndpoints.onboardingFamilyInvite,
        ApiEndpoints.onboardingComplete,
        ApiEndpoints.patientProfileMe,
        ApiEndpoints.patientProfileFull,
        ApiEndpoints.patientHealthCards,
      ];

      for (final endpoint in endpoints) {
        expect(
          endpoint,
          startsWith('/api/v1/'),
          reason: 'Endpoint $endpoint must start with /api/v1/',
        );
      }
    });

    test('health endpoint matches /api/v1/health', () {
      expect(ApiEndpoints.health, equals('/api/v1/health'));
    });

    test('registration draft endpoint matches /api/v1/patients/register', () {
      expect(
        ApiEndpoints.patientRegisterDraft,
        equals('/api/v1/patients/register'),
      );
    });
  });
}
