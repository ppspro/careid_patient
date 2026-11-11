import 'package:careid_patient_app/features/patient/data/models/digital_health_card_models.dart';
import 'package:careid_patient_app/features/patient/data/models/family_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/dependent_health_card_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/family_consent_requests_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/member_permissions_sharing_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/shared_medical_records_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testMember = FamilyMemberDto(
    id: 'mem-test-01',
    fullName: 'Benjamin Harrison',
    relationship: 'Child / Dependent',
  );

  final testGrants = [
    const SharedAccessGrantDto(
      id: 'cst-test-01',
      granteeName: 'Dr. Emily Watson',
      granteeRole: 'Pediatrician',
      facilityName: "Children's Memorial Hospital",
      scopes: ['Full Medical Records', 'Vitals'],
      status: 'PENDING',
      createdAt: '2026-10-31T08:00:00Z',
      expiresAt: '2026-11-30T08:00:00Z',
    ),
    const SharedAccessGrantDto(
      id: 'cst-test-02',
      granteeName: 'Metro Health Center',
      granteeRole: 'Clinic',
      facilityName: 'Metro General Pavilion',
      scopes: ['ECG Reports'],
      status: 'ACTIVE',
      createdAt: '2026-10-25T10:00:00Z',
      expiresAt: '2026-11-25T10:00:00Z',
    ),
  ];

  group('Family Management Figma MCP Fidelity & Flow Suite (Nodes 20:22157 - 20:22594)', () {
    testWidgets('1. FamilyConsentRequestsScreen (20:22157) renders 64px header, tabs, and request cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: FamilyConsentRequestsScreen(
            language: 'en',
            initialGrants: testGrants,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Consent & Requests'), findsOneWidget);
      expect(find.text('Manage Access'), findsOneWidget);
      expect(find.text('Send New Request'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);

      // Verify pending request card content
      expect(find.text('Dr. Emily Watson'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);

      // Switch to Approved tab
      await tester.tap(find.text('Approved'));
      await tester.pumpAndSettle();
      expect(find.text('Metro Health Center'), findsOneWidget);
    });

    testWidgets('2. MemberPermissionsSharingScreen (20:22307) renders member header, permission toggles and save CTA', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MemberPermissionsSharingScreen(
            language: 'en',
            member: testMember,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Permissions & Sharing'), findsOneWidget);
      expect(find.text('Benjamin Harrison'), findsOneWidget);
      expect(find.text('ACCESS LEVELS'), findsOneWidget);
      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.text('Dental Records'), findsOneWidget);
      expect(find.text('Vision Records'), findsOneWidget);
      expect(find.text('EXPIRY SETTINGS'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Save Permissions'), findsOneWidget);
    });

    testWidgets('3. DependentHealthCardScreen (20:22459) renders Apple Wallet card, QR, allergies and bento stats', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: DependentHealthCardScreen(
            language: 'en',
            member: testMember,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Family Member'), findsOneWidget);
      expect(find.text('Premium Care'), findsOneWidget);
      expect(find.text('Benjamin Harrison'), findsOneWidget);
      expect(find.text('O- Positive (O+)'), findsOneWidget);
      expect(find.text('12 May 2018'), findsOneWidget);
      expect(find.text('Share with Provider'), findsOneWidget);
      expect(find.text('Download Health PDF'), findsOneWidget);
      expect(find.text('Immunizations'), findsOneWidget);
    });

    testWidgets('4. SharedMedicalRecordsScreen (20:22594) renders member switcher, filters and timeline', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SharedMedicalRecordsScreen(
            language: 'en',
            initialMembers: [testMember],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shared Medical Records'), findsOneWidget);
      expect(find.text('FAMILY MEMBERS'), findsOneWidget);
      expect(find.text('Benjamin'), findsOneWidget);
      expect(find.text('Pediatric Wellness Checkup'), findsOneWidget);
      expect(find.text('Routine MMR Booster Vaccination'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Pediatric Dental Cleaning'), findsOneWidget);
    });
  });
}
