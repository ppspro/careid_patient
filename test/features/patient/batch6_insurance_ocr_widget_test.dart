import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/patient/data/models/insurance_policy_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/add_insurance_select_method_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_card_camera_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_ocr_processing_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_ocr_results_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_card_details_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('Batch 6: Insurance Ingestion & OCR Card Capture Suite (Figma 20:20311 - 20:20890)', () {
    testWidgets('1. AddInsuranceSelectMethodScreen (20:20311) renders methods, security banner and header logo', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          const AddInsuranceSelectMethodScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.text('Add Insurance'), findsOneWidget);

      // Verify Intro banner
      expect(find.text('Add Insurance Card'), findsOneWidget);

      // Verify Ingestion Options
      expect(find.text('Live Camera Scan'), findsOneWidget);
      expect(find.text('Upload from Gallery'), findsOneWidget);
      expect(find.text('RECOMMENDED'), findsOneWidget);

      // Verify Compliance Footer
      expect(find.textContaining('HIPAA Compliant'), findsOneWidget);
    });

    testWidgets('2. InsuranceCardCameraScreen (20:20258) renders viewfinder, card cutout brackets and shutter', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          const InsuranceCardCameraScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Top Header controls
      expect(find.text('Scan Card'), findsOneWidget);
      expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);

      // Verify Card Viewport & Guidance
      expect(find.text('Card Front'), findsOneWidget);
      expect(find.text('Card Back'), findsOneWidget);
      expect(find.text('Align card within the guide brackets'), findsOneWidget);

      // Verify Controls bar
      expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    });

    testWidgets('3. InsuranceOcrProcessingScreen (20:20415) renders progress indicators and scanning checklist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          const InsuranceOcrProcessingScreen(
            cardImageUrl: 'https://example.com/card.jpg',
            cardImageBytes: null,
            autoStart: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.text('OCR Processing'), findsOneWidget);

      // Verify Scan Title
      expect(find.text('Analyzing Insurance Card'), findsOneWidget);

      // Verify 3 Pipeline Steps
      expect(find.text('Boundary & Contour Alignment'), findsOneWidget);
      expect(find.text('Optical Character Recognition'), findsOneWidget);
      expect(find.text('Field Extraction & Validation'), findsOneWidget);
    });

    testWidgets('4. InsuranceOcrResultsScreen (20:20517) renders confidence banner, extracted fields and edits', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          const InsuranceOcrResultsScreen(
            ocrId: 'ocr-test-123',
            confidence: 0.95,
            extractedData: {
              'providerName': 'Aetna Health Inc.',
              'planName': 'Open Choice PPO',
              'policyNumber': 'AET-9901428',
              'groupNumber': 'GRP-4412',
              'payerId': '60054',
              'member': 'David Miller',
              'rxBin': '003858',
              'rxPcn': 'A4',
              'rxGroup': 'RXAETNA',
              'copayPrimary': '\$30',
              'copaySpecialist': '\$60',
              'deductible': '\$2,000',
              'outOfPocketMax': '\$5,000',
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.text('Verify Card Details'), findsOneWidget);

      // Verify Confidence Banner
      expect(find.text('95% OCR Match • Please Verify'), findsOneWidget);

      // Verify Field Section Headers & Labels
      expect(find.text('Policy & Member Information'), findsOneWidget);
      expect(find.text('Insurance Carrier / Provider'), findsOneWidget);
      expect(find.text('Member / Policy ID'), findsOneWidget);
      expect(find.text('Prescription / Rx Benefits'), findsOneWidget);
      expect(find.text('Copays & Deductible'), findsOneWidget);

      // Verify Badges initially OCR
      expect(find.text('OCR'), findsWidgets);

      // Edit first field and verify badge switches to USER EDITED
      final formFields = find.byType(TextFormField);
      expect(formFields, findsWidgets);
      await tester.enterText(formFields.first, 'Aetna Global PPO');
      await tester.pump();

      expect(find.text('USER EDITED'), findsOneWidget);

      // Scroll and Verify Confirm Action Buttons
      await tester.scrollUntilVisible(
        find.text('Confirm & Save Policy'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Confirm & Save Policy'), findsOneWidget);
      expect(find.text('Retake Card Photo'), findsOneWidget);
    });

    testWidgets('5. InsuranceCardDetailsScreen (20:20890) renders digital card, masked ID toggle and bento items', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      const testPolicy = InsurancePolicyDto(
        id: 'pol-test-8899',
        providerName: 'Blue Cross Blue Shield',
        planName: 'Premier Choice PPO',
        policyNumber: 'BCBS-88421903',
        groupNumber: 'GRP-772109',
        status: 'ACTIVE',
        validThru: '12/2026',
      );

      await tester.pumpWidget(
        createTestWidget(
          const InsuranceCardDetailsScreen(
            policy: testPolicy,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.text('Insurance Card Details'), findsOneWidget);

      // Verify Card View
      expect(find.text('BLUE CROSS BLUE SHIELD'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('•••• •••• •••• 1903'), findsOneWidget);
      expect(find.text('GRP-772109'), findsWidgets);
      expect(find.text('12/2026'), findsOneWidget);

      // Toggle unmask policy number
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.text('BCBS-88421903'), findsWidgets);

      // Verify Quick Action Buttons
      expect(find.text('Verify'), findsOneWidget);
      expect(find.text('Share Pass'), findsOneWidget);
      expect(find.text('Download PDF'), findsOneWidget);
      expect(find.text('New Claim'), findsOneWidget);

      // Verify Copay Bento
      expect(find.text('Copays & Deductibles'), findsOneWidget);
      expect(find.text('\$25'), findsOneWidget);
      expect(find.text('\$50'), findsOneWidget);
      expect(find.text('\$1,500'), findsOneWidget);

      // Verify Rx Section
      expect(find.text('Prescription (Rx) Routing'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Done / Back to Policies'), 300);
      expect(find.text('Done / Back to Policies'), findsOneWidget);
    });
  });
}
