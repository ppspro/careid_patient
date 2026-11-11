import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/health_card_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/patient_main_navigation_shell.dart';
import 'package:careid_patient_app/shared/widgets/careid_bottom_navigation_bar.dart';

void main() {
  group(
      'Empirical Challenge: CareIdBottomNavigationBar & PatientMainNavigationShell',
      () {
    testWidgets(
        'CareIdBottomNavigationBar standalone: short tap triggers onCenterAction, long press triggers onCenterLongPress',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      int selectedIndex = 0;
      bool actionTriggered = false;
      bool longPressTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CareIdBottomNavigationBar(
              currentIndex: selectedIndex,
              onTabSelected: (idx) => selectedIndex = idx,
              onCenterAction: () => actionTriggered = true,
              onCenterLongPress: () => longPressTriggered = true,
              showCenterButton: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find center button using QR icon
      final centerButtonFinder = find.byIcon(Icons.qr_code_scanner_rounded);
      expect(centerButtonFinder, findsOneWidget);

      // 1. Short tap
      await tester.tap(centerButtonFinder);
      await tester.pump();
      expect(actionTriggered, isTrue);
      expect(longPressTriggered, isFalse);

      // Reset
      actionTriggered = false;

      // 2. Long press
      await tester.longPress(centerButtonFinder);
      await tester.pump();
      expect(longPressTriggered, isTrue);
      expect(actionTriggered, isFalse);
    });

    testWidgets(
        'PatientMainNavigationShell: Short tap toggles expandable action bubbles',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Initially action bubbles must NOT exist in the widget tree
      expect(find.text('Scan Health Card'), findsNothing);
      expect(find.text('Scan Medical Document (OCR)'), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      // Short tap center QR button to expand
      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Bubbles are now visible
      expect(find.text('Scan Health Card'), findsOneWidget);
      expect(find.text('Verify Patient CareID Credentials'), findsOneWidget);
      expect(find.text('Scan Medical Document (OCR)'), findsOneWidget);
      expect(find.text('Prescriptions, Lab Slips, X-Rays'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Short tap close button to collapse
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Bubbles are dismissed
      expect(find.text('Scan Health Card'), findsNothing);
      expect(find.text('Scan Medical Document (OCR)'), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets(
        'PatientMainNavigationShell: Long press invokes _openHealthCard and pushes HealthCardScreen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PatientMainNavigationShell), findsOneWidget);
      expect(find.byType(HealthCardScreen), findsNothing);

      // Long press on center elevated QR button
      await tester.longPress(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify HealthCardScreen was navigated to
      expect(find.byType(HealthCardScreen), findsOneWidget);
      expect(find.text('Digital Health Card'), findsOneWidget);
      expect(find.text('Verifiable Clinical Identity'), findsOneWidget);
    });

    testWidgets(
        'PatientMainNavigationShell: Long press while expanded collapses menu and navigates to HealthCardScreen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Expand bubbles
      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Scan Health Card'), findsOneWidget);

      // Long press while menu is expanded (tapping on close icon)
      await tester.longPress(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Must navigate to HealthCardScreen
      expect(find.byType(HealthCardScreen), findsOneWidget);
      expect(find.text('Digital Health Card'), findsOneWidget);

      // Clean up navigation
      Navigator.of(tester.element(find.byType(HealthCardScreen))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets(
        'PatientMainNavigationShell: Tab tap collapses expanded QR menu',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Expand bubbles
      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Scan Health Card'), findsOneWidget);

      // Tap Home tab
      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Menu must be collapsed
      expect(find.text('Scan Health Card'), findsNothing);
    });

    testWidgets(
        'PatientMainNavigationShell: Scrim tap collapses expanded QR menu',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Expand bubbles
      await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Scan Health Card'), findsOneWidget);

      // Tap outside on scrim
      await tester.tapAt(const Offset(200, 150));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Menu must be collapsed
      expect(find.text('Scan Health Card'), findsNothing);
    });
  });
}
