import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/patient/data/models/patient_profile_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/qr_dashboard_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/share_options_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/qr_preview_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/manage_shared_access_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('Batch 7: QR Clinical Sharing, Pass Preview & Access Management Suite (Figma 20:22771 - 20:23597)', () {
    testWidgets('1. QrDashboardScreen (20:22771) renders header, active pass badge, QR card, bento actions & privacy guard', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          const QrDashboardScreen(
            initialProfile: PatientProfileDto(
              id: 'p1',
              firstName: 'John',
              lastName: 'Doe',
              patientNumber: '9928-8829',
              bloodGroup: 'O+',
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.text('QR Dashboard'), findsOneWidget);

      // Verify Active Status Badge
      expect(find.text('ACTIVE QR PASS • 24H REFRESH'), findsOneWidget);

      // Verify Central QR & Identity
      expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.textContaining('CID-'), findsOneWidget);

      // Verify Bento Quick Actions
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Share Options'), findsOneWidget);
      expect(find.text('QR Preview'), findsOneWidget);
      expect(find.text('Download PDF'), findsOneWidget);
      expect(find.text('Manage Access'), findsOneWidget);

      // Verify Data Privacy Guard Banner
      expect(find.text('Data Privacy Guard'), findsOneWidget);
      expect(find.textContaining('expires automatically every 24 hours'), findsOneWidget);
    });

    testWidgets('2. ShareOptionsScreen (20:23195) renders module choices, duration pills, PIN toggle and action button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          const ShareOptionsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.text('Share Options'), findsOneWidget);

      // Verify Copy Headline
      expect(find.text('What would you like to share?'), findsOneWidget);

      // Verify Data Modules
      expect(find.text('Entire Health Card'), findsOneWidget);
      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.text('Dental Records'), findsOneWidget);
      expect(find.text('Vision Records'), findsOneWidget);
      expect(find.text('Insurance Information'), findsOneWidget);
      expect(find.text('Family Member Access'), findsOneWidget);
      expect(find.text('Pet Records'), findsOneWidget);

      // Scroll to Duration section
      await tester.scrollUntilVisible(
        find.text('ACCESS DURATION'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      // Verify Duration Pills
      expect(find.text('ACCESS DURATION'), findsOneWidget);
      expect(find.text('15 Minutes'), findsOneWidget);
      expect(find.text('1 Hour'), findsOneWidget);
      expect(find.text('24 Hours'), findsOneWidget);
      expect(find.text('Single-Use'), findsOneWidget);

      // Verify PIN switch
      await tester.scrollUntilVisible(
        find.text('Require 4-digit PIN'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Require 4-digit PIN'), findsOneWidget);

      // Verify Primary Generate Action
      await tester.scrollUntilVisible(
        find.text('Generate Secure QR Pass'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Generate Secure QR Pass'), findsOneWidget);
    });

    testWidgets('3. QrPreviewScreen (20:23338) renders high-contrast QR pass, countdown timer, scopes & share action', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          const QrPreviewScreen(
            patientName: 'Sarah Jenkins',
            careId: '8829-X',
            sharedModules: ['health_card', 'medical_records', 'insurance_info'],
            duration: '15_min',
            requirePin: true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.text('QR Preview'), findsOneWidget);

      // Verify Ribbon Content
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('CareID: #CID-8829-X'), findsOneWidget);
      expect(find.text('PIN LOCKED'), findsOneWidget);

      // Verify High-Density QR Viewport
      expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);

      // Verify Countdown Timer
      expect(find.textContaining('Valid for'), findsOneWidget);

      // Verify Scope Badges
      expect(find.text('Health Card'), findsOneWidget);
      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.text('Insurance'), findsOneWidget);

      // Verify Security Seal
      expect(find.textContaining('SHA-256 Validated Credential'), findsOneWidget);

      // Verify Action Buttons
      expect(find.text('Share Pass Link'), findsOneWidget);
      expect(find.text('Save Image'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Verify Security & Compliance Footer
      expect(find.textContaining('HIPAA Compliant'), findsOneWidget);
    });

    testWidgets('4. ManageSharedAccessScreen (20:23597) renders sharing hub, active clinical grants, pending requests & sessions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          const ManageSharedAccessScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.text('Manage Shared Access'), findsOneWidget);

      // Verify Visualization Card
      expect(find.text('Secure Sharing Hub'), findsOneWidget);

      // Verify Section: CURRENTLY SHARED
      expect(find.text('CURRENTLY SHARED'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins, MD'), findsOneWidget);
      expect(find.text('Mount Sinai Medical Center'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Revoke Access'), findsOneWidget);

      // Verify Section: PENDING REQUESTS
      expect(find.text('PENDING REQUESTS'), findsOneWidget);
      expect(find.text('St. Jude Diagnostic Imaging Center'), findsOneWidget);
      expect(find.text('Accept Request'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);

      // Scroll to Recent Sessions
      await tester.scrollUntilVisible(
        find.text('RECENT SESSIONS'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      // Verify Section: RECENT SESSIONS
      expect(find.text('RECENT SESSIONS'), findsOneWidget);
      expect(find.text('Metropolitan ER Trauma Center'), findsOneWidget);
      expect(find.text('Dr. Robert Chen (Dental Care)'), findsOneWidget);
      expect(find.text('Jane Doe (Family Guardian)'), findsOneWidget);
    });
  });
}
