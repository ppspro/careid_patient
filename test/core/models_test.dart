import 'package:test/test.dart';

import 'package:careid_patient_app/features/auth/data/models/auth_tokens.dart';
import 'package:careid_patient_app/features/auth/data/models/patient_registration.dart';

void main() {
  group('CareID Domain Models Deserialization', () {
    test('AuthTokens parses standard JSON payload', () {
      final json = {
        'accessToken': 'jwt.token.access',
        'refreshToken': 'jwt.token.refresh',
        'expiresIn': 3600,
        'tokenType': 'Bearer',
      };

      final tokens = AuthTokens.fromJson(json);
      expect(tokens.accessToken, equals('jwt.token.access'));
      expect(tokens.refreshToken, equals('jwt.token.refresh'));
      expect(tokens.expiresIn, equals(3600));
      expect(tokens.tokenType, equals('Bearer'));
    });

    test('PatientRegistrationDraft parses RegisterPatientResponseDto', () {
      final json = {
        'profileId': '01925a62-7935-7c18-9ce0-f7c87c2b04f1',
        'patientNumber': 'PT-2026-00042',
        'status': 'DRAFT',
        'onboardingStep': 1,
      };

      final draft = PatientRegistrationDraft.fromJson(json);
      expect(draft.profileId, equals('01925a62-7935-7c18-9ce0-f7c87c2b04f1'));
      expect(draft.patientNumber, equals('PT-2026-00042'));
      expect(draft.status, equals('DRAFT'));
      expect(draft.onboardingStep, equals(1));
    });
  });
}
