import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/patient_main_navigation_shell.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/scan_health_card_qr_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/scan_medical_document_ocr_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_bottom_navigation_bar.dart';

void main() {
  group('CareID Floating QR Action Menu Suite (Figma 20:19764 & 20:19790)', () {
    testWidgets('CareIdBottomNavigationBar renders all 4 tabs and center elevated QR button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      int selectedIndex = 0;
      bool qrTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CareIdBottomNavigationBar(
              currentIndex: selectedIndex,
              onTabSelected: (idx) => selectedIndex = idx,
              onCenterAction: () => qrTapped = true,
              showCenterButton: true,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify all 4 primary navigation labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('Doctor'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify central QR scanner icon
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

      // Tap central QR button
      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      expect(qrTapped, isTrue);
    });

    testWidgets('Tapping center QR button in PatientMainNavigationShell expands two action bubbles', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Initially action bubbles are not displayed
      expect(find.text('Scan Health Card'), findsNothing);
      expect(find.text('Scan Medical Document (OCR)'), findsNothing);

      // Tap central QR button to expand menu
      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Both action bubbles must now be visible with their respective subtitles
      expect(find.text('Scan Health Card'), findsOneWidget);
      expect(find.text('Verify Patient CareID Credentials'), findsOneWidget);

      expect(find.text('Scan Medical Document (OCR)'), findsOneWidget);
      expect(find.text('Prescriptions, Lab Slips, X-Rays'), findsOneWidget);

      // Central button transforms to close icon
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap close button to collapse menu
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Scan Health Card'), findsNothing);
      expect(find.text('Scan Medical Document (OCR)'), findsNothing);
    });

    testWidgets('Tapping backdrop scrim collapses expanded QR action menu', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Expand
      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Scan Health Card'), findsOneWidget);

      // Tap outside (on scrim area, e.g. top of screen)
      await tester.tapAt(const Offset(200, 150));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Scan Health Card'), findsNothing);
    });

    testWidgets('Selecting Scan Health Card bubble navigates to ScanHealthCardQrScreen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Expand
      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Tap Action 1: Scan Health Card
      await tester.tap(find.text('Scan Health Card'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ScanHealthCardQrScreen), findsOneWidget);
      expect(find.text('Align the CareID QR code within the viewfinder frame'), findsOneWidget);
      expect(find.text('Auto Test'), findsOneWidget);

      // Test simulate scan
      await tester.tap(find.text('Auto Test'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Valid Health Card Credential'), findsOneWidget);
    });

    testWidgets('Selecting Scan Medical Document bubble navigates to ScanMedicalDocumentOcrScreen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Expand
      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Tap Action 2: Scan Medical Document (OCR)
      await tester.tap(find.text('Scan Medical Document (OCR)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ScanMedicalDocumentOcrScreen), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose File'), findsOneWidget);

      // Trigger demo extraction
      await tester.tap(find.byTooltip('Auto Sample'));
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Extracted Clinical Fields (Editable)'), findsOneWidget);
      expect(find.text('Save to CareID Vault'), findsOneWidget);
    });
  });
}
