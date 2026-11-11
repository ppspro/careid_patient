import 'package:test/test.dart';

import 'package:careid_patient_app/features/auth/data/models/registration_context.dart';
import 'package:careid_patient_app/features/onboarding/data/models/consent_models.dart';

void main() {
  group('Step 5: Privacy & Consents Models & Validation Tests', () {
    test('PrivacyConsentsDto defaults match HIPAA & CareID standards', () {
      const dto = PrivacyConsentsDto(
        termsOfServiceAccepted: false,
        privacyPolicyAccepted: false,
      );

      expect(dto.termsOfServiceAccepted, isFalse);
      expect(dto.privacyPolicyAccepted, isFalse);
      expect(dto.healthVaultStorageEnabled, isTrue);
      expect(dto.shareWithHealthcareProviders, isTrue);
      expect(dto.productUpdatesMarketing, isFalse);
      expect(dto.clinicalAppointmentReminders, isTrue);
      expect(dto.securityAlertsAcknowledged, isTrue);
      expect(dto.isValid, isFalse);
      expect(dto.mandatoryAcceptedCount, equals(0));
    });

    test('Validation enforces both Terms of Service and Privacy Policy', () {
      const unacceptedDto = PrivacyConsentsDto(
        termsOfServiceAccepted: false,
        privacyPolicyAccepted: false,
      );
      expect(
        unacceptedDto.validate(isEn: true),
        equals(
          'Please review and accept both the Terms of Service and Privacy Policy.',
        ),
      );
      expect(
        unacceptedDto.validate(isEn: false),
        equals(
          'Por favor revisa y acepta tanto los Términos del Servicio como la Política de Privacidad.',
        ),
      );

      const termsOnlyDto = PrivacyConsentsDto(
        termsOfServiceAccepted: true,
        privacyPolicyAccepted: false,
      );
      expect(termsOnlyDto.isValid, isFalse);
      expect(termsOnlyDto.mandatoryAcceptedCount, equals(1));
      expect(
        termsOnlyDto.validate(isEn: true),
        equals('You must accept the Privacy Policy to continue.'),
      );

      const privacyOnlyDto = PrivacyConsentsDto(
        termsOfServiceAccepted: false,
        privacyPolicyAccepted: true,
      );
      expect(privacyOnlyDto.isValid, isFalse);
      expect(privacyOnlyDto.mandatoryAcceptedCount, equals(1));
      expect(
        privacyOnlyDto.validate(isEn: true),
        equals('You must accept the Terms of Service to continue.'),
      );

      const fullyAcceptedDto = PrivacyConsentsDto(
        termsOfServiceAccepted: true,
        privacyPolicyAccepted: true,
      );
      expect(fullyAcceptedDto.isValid, isTrue);
      expect(fullyAcceptedDto.mandatoryAcceptedCount, equals(2));
      expect(fullyAcceptedDto.validate(), isNull);
    });

    test('PrivacyConsentsDto serializes and deserializes correctly', () {
      const dto = PrivacyConsentsDto(
        termsOfServiceAccepted: true,
        privacyPolicyAccepted: true,
        healthVaultStorageEnabled: true,
        shareWithHealthcareProviders: false,
        productUpdatesMarketing: true,
        clinicalAppointmentReminders: true,
        securityAlertsAcknowledged: true,
        consentTimestamp: '2026-10-27T10:00:00Z',
      );

      final json = dto.toJson();
      expect(json['termsOfServiceAccepted'], isTrue);
      expect(json['privacyPolicyAccepted'], isTrue);
      expect(json['healthVaultStorageEnabled'], isTrue);
      expect(json['shareWithHealthcareProviders'], isFalse);
      expect(json['productUpdatesMarketing'], isTrue);
      expect(json['clinicalAppointmentReminders'], isTrue);
      expect(json['securityAlertsAcknowledged'], isTrue);
      expect(json['consentTimestamp'], equals('2026-10-27T10:00:00Z'));

      final fromJsonDto = PrivacyConsentsDto.fromJson(json);
      expect(fromJsonDto.termsOfServiceAccepted, isTrue);
      expect(fromJsonDto.privacyPolicyAccepted, isTrue);
      expect(fromJsonDto.shareWithHealthcareProviders, isFalse);
      expect(fromJsonDto.productUpdatesMarketing, isTrue);
    });

    test('RegistrationContext preserves Step 5 consents across transitions', () {
      const initial = RegistrationContext(
        fullName: 'Jane Doe',
        phone: '+14155552671',
        email: 'jane.doe@example.com',
        onboardingStep: 4,
      );

      expect(initial.hasConsentsAccepted, isFalse);
      expect(initial.termsAccepted, isFalse);
      expect(initial.privacyPolicyAccepted, isFalse);

      final updated = initial.copyWith(
        onboardingStep: 5,
        termsAccepted: true,
        privacyPolicyAccepted: true,
        healthStorageConsent: true,
        shareWithProvidersConsent: true,
      );

      expect(updated.onboardingStep, equals(5));
      expect(updated.hasConsentsAccepted, isTrue);
      expect(updated.termsAccepted, isTrue);
      expect(updated.privacyPolicyAccepted, isTrue);
      expect(updated.fullName, equals('Jane Doe'));
    });
  });
}
