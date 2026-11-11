import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/core/theme/app_theme.dart';
import 'package:careid_patient_app/features/auth/data/models/registration_context.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/access_verification_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/document_viewer_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/family_records_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/home_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_card_camera_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_ocr_processing_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/personal_details_identity_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/record_details_hub_screen.dart';

void main() {
  const testRegistrationContext = RegistrationContext(
    fullName: 'Sarah Jenkins',
    phone: '+14155552671',
    email: 'sarah.j@email.com',
    bloodGroup: 'O+',
    careIdNumber: 'CID-8472-9102-4821',
    chronicConditions: ['Asthma'],
    knownAllergies: ['Penicillin'],
  );

  Widget buildTestApp(Widget child, {TextScaler? textScaler}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: textScaler ?? const TextScaler.linear(1.0),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void attachDiagnosticErrorHandler() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // ignore: avoid_print
      print('=== RENDERFLEX ERROR CAUGHT ===');
      // ignore: avoid_print
      print(details.exceptionAsString());
      // ignore: avoid_print
      print('CONTEXT: ${details.context}');
      if (details.informationCollector != null) {
        // ignore: avoid_print
        print(details.informationCollector!().map((e) => e.toString()).join('\n'));
      }
    };
  }

  group('Milestone 2 Viewport & Overflow Empirical Stress Suite', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      attachDiagnosticErrorHandler();
    });

    // ------------------------------------------------------------------------
    // Group 1: Target Xiaomi Redmi 8A Dual (720x1520 physical, DPR 2.0 -> 360x760 dp)
    // ------------------------------------------------------------------------
    group('Target Viewport: Xiaomi Redmi 8A Dual (360x760 dp logical)', () {
      void configureTargetViewport(WidgetTester tester) {
        tester.view.physicalSize = const Size(720, 1520);
        tester.view.devicePixelRatio = 2.0;
      }

      testWidgets('Hotspot 1: InsuranceCardCameraScreen cutout guide renders without RenderFlex overflow', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const InsuranceCardCameraScreen(language: 'en')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'RenderFlex overflow occurred in InsuranceCardCameraScreen: $ex');
      });

      testWidgets('Hotspots 2-5: AccessVerificationScreen glow, app bar, session row & footer render without overflow', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const AccessVerificationScreen(
          doctorName: 'Dr. Marcus Thorne',
          sessionId: 'HV-90210-X',
        )));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'RenderFlex overflow occurred in AccessVerificationScreen: $ex');
      });

      testWidgets('Hotspots 6-7: FamilyRecordsScreen status strip & vault badges render without overflow (EN & ES)', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // English test
        await tester.pumpWidget(buildTestApp(const FamilyRecordsScreen(language: 'en')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final exEn = tester.takeException();
        expect(exEn, isNull, reason: 'RenderFlex overflow occurred in FamilyRecordsScreen (EN): $exEn');

        // Spanish test
        await tester.pumpWidget(buildTestApp(const FamilyRecordsScreen(language: 'es')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final exEs = tester.takeException();
        expect(exEs, isNull, reason: 'RenderFlex overflow occurred in FamilyRecordsScreen (ES): $exEs');
      });

      testWidgets('Hotspot 8: RecordDetailsHubScreen vault card badges with Wrap render without overflow', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const RecordDetailsHubScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'RenderFlex overflow occurred in RecordDetailsHubScreen: $ex');
      });

      testWidgets('Hotspot 9: InsuranceOcrProcessingScreen responsive laser scanner renders without overflow', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const InsuranceOcrProcessingScreen(
          cardImageUrl: 'test_card.jpg',
          autoStart: false,
          language: 'en',
        )));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'RenderFlex overflow occurred in InsuranceOcrProcessingScreen: $ex');
      });

      testWidgets('Hotspot 10: HomeScreen hero health card & lower shelf render cleanly on 360x760 dp', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const HomeScreen(
          registrationContext: testRegistrationContext,
          language: 'en',
        )));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'RenderFlex overflow occurred in HomeScreen: $ex');
      });

      testWidgets('Hotspot 11: DocumentViewerScreen title ellipsis & bottom toolbar render without overflow', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const DocumentViewerScreen(
          title: 'Comprehensive Blood Chemistry Panel & Metabolic Profile',
          fileName: 'comprehensive_lab_report_q4_2026_unabridged_encrypted.pdf',
          verifiedDate: 'May 14, 2024',
        )));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'RenderFlex overflow occurred in DocumentViewerScreen: $ex');
      });
    });

    // ------------------------------------------------------------------------
    // Group 2: Ultra-Tight Viewport Stress Test: 320x568 dp logical (iPhone SE 1st / Ultra-compact)
    // ------------------------------------------------------------------------
    group('Ultra-Tight Viewport Stress (320x568 dp logical)', () {
      void configureCompactViewport(WidgetTester tester) {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
      }

      testWidgets('Hotspot 1: InsuranceCardCameraScreen adapts safely to 320x568 dp', (tester) async {
        configureCompactViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const InsuranceCardCameraScreen(language: 'en')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: '320x568 overflow in InsuranceCardCameraScreen: $ex');
      });

      testWidgets('Hotspots 2-5: AccessVerificationScreen adapts safely to 320x568 dp', (tester) async {
        configureCompactViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const AccessVerificationScreen(
          doctorName: 'Dr. Marcus Thorne',
          sessionId: 'HV-90210-X',
        )));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: '320x568 overflow in AccessVerificationScreen: $ex');
      });

      testWidgets('Hotspots 6-7: FamilyRecordsScreen adapts safely to 320x568 dp in Spanish', (tester) async {
        configureCompactViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const FamilyRecordsScreen(language: 'es')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: '320x568 overflow in FamilyRecordsScreen (ES): $ex');
      });

      testWidgets('Hotspot 8: RecordDetailsHubScreen adapts safely to 320x568 dp', (tester) async {
        configureCompactViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const RecordDetailsHubScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: '320x568 overflow in RecordDetailsHubScreen: $ex');
      });

      testWidgets('Hotspot 9: InsuranceOcrProcessingScreen adapts safely to 320x568 dp', (tester) async {
        configureCompactViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const InsuranceOcrProcessingScreen(
          cardImageUrl: 'test_card.jpg',
          autoStart: false,
          language: 'en',
        )));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: '320x568 overflow in InsuranceOcrProcessingScreen: $ex');
      });

      testWidgets('Hotspot 10: HomeScreen adapts safely to 320x568 dp', (tester) async {
        configureCompactViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const HomeScreen(
          registrationContext: testRegistrationContext,
          language: 'en',
        )));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        final ex = tester.takeException();
        expect(ex, isNull, reason: '320x568 overflow in HomeScreen: $ex');
      });

      testWidgets('Hotspot 11: DocumentViewerScreen adapts safely to 320x568 dp', (tester) async {
        configureCompactViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const DocumentViewerScreen(
          title: 'Laboratory Diagnostic Report',
          fileName: 'lab_report_q4.pdf',
          verifiedDate: 'May 14, 2024',
        )));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: '320x568 overflow in DocumentViewerScreen: $ex');
      });
    });

    // ------------------------------------------------------------------------
    // Group 3: Text Scaler 1.5x & Adversarial Text Length Stress (360x760 dp)
    // ------------------------------------------------------------------------
    group('Accessibility Text Scaler 1.5x & Adversarial Text Expansion', () {
      void configureTargetViewport(WidgetTester tester) {
        tester.view.physicalSize = const Size(720, 1520);
        tester.view.devicePixelRatio = 2.0;
      }

      testWidgets('AccessVerificationScreen withstands 1.5x textScaler & 64-character encrypted session ID', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(
          const AccessVerificationScreen(
            doctorName: 'Dr. Alexander Bartholomew Montgomery-Fitzgerald III',
            sessionId: 'HV-90210-X-SECURE-ENCRYPTED-SESSION-TOKEN-2026-LONG-STRING-ALPHA-BETA-GAMMA',
          ),
          textScaler: const TextScaler.linear(1.5),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'Adversarial overflow in AccessVerificationScreen with 1.5x text scaler: $ex');
      });

      testWidgets('FamilyRecordsScreen withstands 1.5x textScaler & Spanish translations', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(
          const FamilyRecordsScreen(language: 'es'),
          textScaler: const TextScaler.linear(1.5),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'Adversarial overflow in FamilyRecordsScreen with 1.5x text scaler in Spanish: $ex');
      });

      testWidgets('RecordDetailsHubScreen withstands 1.5x textScaler on badges and card content', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(
          const RecordDetailsHubScreen(),
          textScaler: const TextScaler.linear(1.5),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'Adversarial overflow in RecordDetailsHubScreen with 1.5x text scaler: $ex');
      });

      testWidgets('DocumentViewerScreen withstands 1.5x textScaler & extreme title/filename lengths', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(
          const DocumentViewerScreen(
            title: 'Very Long Title For A Comprehensive Medical Report From St Jude Hospital And Associated Laboratories Panel',
            fileName: 'very_long_file_name_for_medical_report_dated_2026_11_07_final_signed_off_by_chief_physician.pdf',
            verifiedDate: 'May 14, 2024',
          ),
          textScaler: const TextScaler.linear(1.5),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'Adversarial overflow in DocumentViewerScreen with 1.5x text scaler: $ex');
      });

      testWidgets('PersonalDetailsIdentityScreen withstands 1.5x textScaler and small viewport', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(
          const PersonalDetailsIdentityScreen(language: 'en'),
          textScaler: const TextScaler.linear(1.5),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'Adversarial overflow in PersonalDetailsIdentityScreen with 1.5x text scaler: $ex');
      });
    });

    // ------------------------------------------------------------------------
    // Group 4: Bottom Navigation Bar Clearance & Scrollability Verification
    // ------------------------------------------------------------------------
    group('Bottom Navigation Bar Clearance (120dp clearance verification)', () {
      void configureTargetViewport(WidgetTester tester) {
        tester.view.physicalSize = const Size(720, 1520);
        tester.view.devicePixelRatio = 2.0;
      }

      testWidgets('HomeScreen scrollview has 120dp bottom clearance and scrolls to bottom without overflow', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const HomeScreen(
          registrationContext: testRegistrationContext,
          language: 'en',
        )));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        final scrollViewFinder = find.byType(SingleChildScrollView);
        expect(scrollViewFinder, findsOneWidget);

        final SingleChildScrollView scrollView = tester.widget(scrollViewFinder);
        expect(scrollView.padding, isNotNull);
        final EdgeInsets padding = scrollView.padding as EdgeInsets;
        expect(padding.bottom, greaterThanOrEqualTo(120.0), reason: 'HomeScreen must have at least 120dp bottom clearance for floating nav bar');

        // Scroll down 600 pixels to exercise scroll physics
        await tester.drag(scrollViewFinder, const Offset(0, -600));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'RenderFlex overflow occurred during scroll on HomeScreen: $ex');
      });

      testWidgets('FamilyRecordsScreen scrollview has 120dp bottom clearance and scrolls to bottom without overflow', (tester) async {
        configureTargetViewport(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp(const FamilyRecordsScreen(language: 'en')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final scrollViewFinder = find.byType(SingleChildScrollView);
        expect(scrollViewFinder, findsOneWidget);

        final SingleChildScrollView scrollView = tester.widget(scrollViewFinder);
        expect(scrollView.padding, isNotNull);
        final EdgeInsets padding = scrollView.padding as EdgeInsets;
        expect(padding.bottom, greaterThanOrEqualTo(120.0), reason: 'FamilyRecordsScreen must have at least 120dp bottom clearance for floating nav bar');

        // Scroll down 400 pixels to exercise scroll physics
        await tester.drag(scrollViewFinder, const Offset(0, -400));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final ex = tester.takeException();
        expect(ex, isNull, reason: 'RenderFlex overflow occurred during scroll on FamilyRecordsScreen: $ex');
      });
    });
  });
}
