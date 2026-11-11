import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/features/patient/data/models/insurance_policy_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_qr_screen.dart';

void main() {
  group('Insurance QR Screen Widget Tests (Figma 20:21019)', () {
    const samplePolicy = InsurancePolicyDto(
      id: 'pol-test-1',
      providerName: 'BlueCross Platinum Plus',
      policyNumber: '44829-01',
      groupNumber: '99281',
      planName: 'Comprehensive Medical & Rx',
      status: 'ACTIVE',
      validThru: '2026-12-31',
    );

    testWidgets('renders top app bar, hero QR pass, action buttons, and disclaimer', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: InsuranceQrScreen(
            policy: samplePolicy,
            language: 'en',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top app bar
      expect(find.text('Insurance QR'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Hero Card Member & Plan summary
      expect(find.text('MEMBER'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('PLAN ID'), findsOneWidget);

      // Verification Badge
      expect(find.text('VERIFIED ACTIVE COVERAGE'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);

      // Insurance Details Summary
      expect(find.text(samplePolicy.providerName), findsOneWidget);
      expect(find.textContaining('Policy #'), findsOneWidget);

      // Action buttons
      expect(find.text('Share QR Pass'), findsOneWidget);
      expect(find.text('Add to Digital Wallet'), findsOneWidget);

      // Security Disclaimer
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.textContaining('HIPAA-compliant encryption'), findsOneWidget);

      // Scroll and Tap Share QR Pass
      await tester.ensureVisible(find.text('Share QR Pass'));
      await tester.tap(find.text('Share QR Pass'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(find.textContaining('shared successfully'), findsOneWidget);
    });

    testWidgets('renders Spanish localization correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: InsuranceQrScreen(
            policy: samplePolicy,
            language: 'es',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('QR de Seguro'), findsOneWidget);
      expect(find.text('MIEMBRO'), findsOneWidget);
      expect(find.text('ID DE PLAN'), findsOneWidget);
      expect(find.text('Compartir Pase QR'), findsOneWidget);
      expect(find.text('Añadir a Cartera Digital'), findsOneWidget);
    });
  });
}
