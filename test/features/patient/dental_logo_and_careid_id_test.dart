import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/patient/data/models/insurance_policy_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_qr_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/medical_records_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_dental_logo.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';
import 'package:careid_patient_app/shared/widgets/service_feature_card.dart';

void main() {
  group('CareIdDentalLogo Tests', () {
    testWidgets('renders CareIdDentalLogo with custom size and color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CareIdDentalLogo(
                size: 32,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CareIdDentalLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      final dentalLogoFinder = find.byType(CareIdDentalLogo);
      final dentalLogo = tester.widget<CareIdDentalLogo>(dentalLogoFinder);
      expect(dentalLogo.size, equals(32));
      expect(dentalLogo.color, equals(const Color(0xFF0284C7)));
    });

    testWidgets('renders CareIdDentalLogo with badge background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CareIdDentalLogo.badge(
                size: 20,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CareIdDentalLogo), findsOneWidget);
      final dentalLogo = tester.widget<CareIdDentalLogo>(find.byType(CareIdDentalLogo));
      expect(dentalLogo.hasBackground, isTrue);
    });

    testWidgets('DentalToothPainter paints without error', (tester) async {
      const painter = DentalToothPainter(color: Color(0xFF0284C7));
      final recorder = TestPaintingContext();
      // Verify paint executes cleanly across various canvas bounds
      painter.paint(recorder.canvas, const Size(24, 24));
      painter.paint(recorder.canvas, const Size(100, 100));
      expect(painter.shouldRepaint(const DentalToothPainter(color: Color(0xFF0284C7))), isFalse);
      expect(painter.shouldRepaint(const DentalToothPainter(color: Colors.red)), isTrue);
    });
  });

  group('CareIdLogo.onlyId Tests', () {
    testWidgets('renders CareIdLogo.onlyId with assets/images/careid_only_id.png', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CareIdLogo.onlyId(height: 18),
            ),
          ),
        ),
      );

      expect(find.byType(CareIdLogo), findsOneWidget);
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.image, isA<AssetImage>());
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/images/careid_only_id.png'));
    });

    testWidgets('CareIdLogo.emblem delegates to onlyId variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CareIdLogo.emblem(height: 17),
            ),
          ),
        ),
      );

      expect(find.byType(CareIdLogo), findsOneWidget);
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<AssetImage>());
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/images/careid_only_id.png'));
    });
  });

  group('ServiceFeatureCard Dental Logo Integration Tests', () {
    testWidgets('renders CareIdDentalLogo for ServiceType.dental', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceFeatureCard(
              type: ServiceType.dental,
              title: 'Dental Health Vault',
              description: 'Routine checkups, cleanings, and x-rays.',
            ),
          ),
        ),
      );

      expect(find.byType(ServiceFeatureCard), findsOneWidget);
      expect(find.byType(CareIdDentalLogo), findsOneWidget);
      expect(find.text('Dental Health Vault'), findsOneWidget);
    });

    testWidgets('renders standard Icons for ServiceType.medical', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceFeatureCard(
              type: ServiceType.medical,
              title: 'Medical Health Vault',
              description: 'General doctor notes, labs, and vitals.',
            ),
          ),
        ),
      );

      expect(find.byType(ServiceFeatureCard), findsOneWidget);
      expect(find.byType(CareIdDentalLogo), findsNothing);
      expect(find.byIcon(Icons.medical_services_rounded), findsOneWidget);
    });
  });

  group('InsuranceQrScreen Logo Integration Tests', () {
    testWidgets('renders CareIdLogo.onlyId in header and QR center', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const samplePolicy = InsurancePolicyDto(
        id: 'test-policy-1',
        providerName: 'BlueCross Platinum Plus',
        policyNumber: '44829-01',
        groupNumber: 'GRP-9902',
        status: 'ACTIVE',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: InsuranceQrScreen(policy: samplePolicy),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InsuranceQrScreen), findsOneWidget);
      // Both header action and center of the QR matrix use CareIdLogo.onlyId
      final logoFinders = find.byType(CareIdLogo);
      expect(logoFinders, findsNWidgets(2));
    });
  });

  group('MedicalRecordsScreen Dental Logo Integration Tests', () {
    testWidgets('renders CareIdDentalLogo inside Dental Vault chip', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: MedicalRecordsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(MedicalRecordsScreen), findsOneWidget);
      expect(find.text('Dental Vault'), findsOneWidget);
      expect(find.byType(CareIdDentalLogo), findsOneWidget);
    });
  });
}

class TestPaintingContext {
  final Canvas canvas = _MockCanvas();
}

class _MockCanvas implements Canvas {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
