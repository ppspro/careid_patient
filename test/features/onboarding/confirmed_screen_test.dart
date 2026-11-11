import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/auth/data/models/registration_context.dart';
import 'package:careid_patient_app/features/onboarding/data/models/health_card_models.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/confirmed_screen.dart';

void main() {
  group('Step 6 Models & Context Tests', () {
    test('HealthCardDto serialization and deserialization', () {
      final json = {
        'id': 'hc-12345',
        'patientProfileId': 'pat-67890',
        'cardNumber': 'CI-920512',
        'status': 'ISSUED',
        'qrPayload': 'HV360-1234-5678-9012',
        'issuedAt': '2026-10-27T10:00:00Z',
        'expiresAt': '2027-10-27T10:00:00Z',
        'emergencyFlag': false,
      };

      final dto = HealthCardDto.fromJson(json);
      expect(dto.id, 'hc-12345');
      expect(dto.cardNumber, 'CI-920512');
      expect(dto.status, 'ISSUED');
      expect(dto.qrPayload, 'HV360-1234-5678-9012');

      final serialized = dto.toJson();
      expect(serialized['id'], 'hc-12345');
      expect(serialized['cardNumber'], 'CI-920512');
      expect(serialized['emergencyFlag'], false);
    });

    test('RegistrationContext displayCareId returns assigned or fallback', () {
      const defaultCtx = RegistrationContext(
        fullName: 'Sarah Jenkins',
        phone: '+14155552671',
        email: 'sarah.j@email.com',
      );
      expect(defaultCtx.displayCareId, '#CI-920512');

      final customCardCtx = defaultCtx.copyWith(careIdNumber: 'CI-112233');
      expect(customCardCtx.displayCareId, '#CI-112233');

      final hashCardCtx = defaultCtx.copyWith(careIdNumber: '#CI-445566');
      expect(hashCardCtx.displayCareId, '#CI-445566');
    });
  });

  group('ConfirmedScreen Widget Tests (Figma 20:31401)', () {
    const testContext = RegistrationContext(
      fullName: 'Sarah Jenkins',
      phone: '+14155552671',
      email: 'sarah.j@email.com',
      bloodGroup: 'O Positive (O+)',
      dateOfBirth: '12/05/1992',
      onboardingStep: 6,
      termsAccepted: true,
      privacyPolicyAccepted: true,
      insuranceProvider: 'Blue Cross Blue Shield',
      insuranceMemberId: 'XEH88910293',
    );

    testWidgets('Renders all core sections from Figma frame 20:31401',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmedScreen(
            registrationContext: testContext,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Stepper & Badges
      expect(find.text('Step 6 of 6'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
      expect(find.text('Care ID Cryptographic Vault Active'), findsOneWidget);

      // Hero Header
      expect(find.text('Your Care ID Vault is ready'), findsOneWidget);

      // Digital Credential Card
      expect(find.text('Care ID Digital Credential'), findsOneWidget);
      expect(find.text('HIPAA Secured'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('#CI-920512'), findsOneWidget);
      expect(find.text('O Positive (O+)'), findsOneWidget);
      expect(find.text('12/05/1992'), findsOneWidget);

      // Vault Disciplines
      expect(find.text('Your Care ID Vault'), findsOneWidget);
      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.text('Dental Records'), findsOneWidget);
      expect(find.text('Vision Records'), findsOneWidget);
      expect(find.text('Pet Records'), findsOneWidget);
      expect(find.text('Insurance Records'), findsOneWidget);

      // Profile Strength & Check Items
      expect(find.textContaining('Profile Strength: 90%'), findsOneWidget);
      expect(find.text('Personal Info'), findsOneWidget);
      expect(find.text('Phone Verified'), findsOneWidget);
      expect(find.text('Medical Summary'), findsOneWidget);

      // Privacy & Security Badges
      expect(find.text('You own your health data'), findsOneWidget);
      expect(find.text('End-to-End Cryptographic Security'), findsOneWidget);

      // Primary and Secondary CTAs
      expect(find.text('Enter Care ID'), findsOneWidget);
      expect(find.text('Share Digital Health Card'), findsOneWidget);
    });

    testWidgets('Tapping Share Digital Health Card opens bottom sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmedScreen(
            registrationContext: testContext,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final shareBtn = find.text('Share Digital Health Card');
      expect(shareBtn, findsOneWidget);

      await tester.ensureVisible(shareBtn);
      await tester.tap(shareBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Modal content should now be visible
      expect(find.text('Present your Care ID credential to healthcare providers:'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('Language toggle changes strings to Spanish',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmedScreen(
            registrationContext: testContext,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Initially in English
      expect(find.text('Step 6 of 6'), findsOneWidget);

      // Switch to Spanish
      final espBtn = find.text('ESP');
      expect(espBtn, findsOneWidget);
      await tester.tap(espBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check Spanish translations
      expect(find.text('Paso 6 de 6'), findsOneWidget);
      expect(find.text('Tu bóveda Care ID está lista'), findsOneWidget);
      expect(find.text('Entrar a Care ID'), findsOneWidget);
    });
  });
}
