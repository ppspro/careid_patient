import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/auth/data/models/registration_context.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/family_members_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/health_card_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/medical_records_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/patient_profile_screen.dart';

void main() {
  const testContext = RegistrationContext(
    fullName: 'Sarah Jenkins',
    phone: '+14155552671',
    email: 'sarah.j@email.com',
    bloodGroup: 'O+',
    careIdNumber: 'CID-8472-9102-4821',
    chronicConditions: ['Asthma'],
    knownAllergies: ['Penicillin'],
  );

  group('Patient Feature Screens Widget Tests', () {
    testWidgets('MedicalRecordsScreen renders search, filter chips, and add record button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MedicalRecordsScreen(language: 'en'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextField), findsOneWidget); // search input
      expect(find.text('All Records'), findsOneWidget);
      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('DENTAL'), findsOneWidget);
      expect(find.text('VISION'), findsOneWidget);
      expect(find.text('Add Record'), findsOneWidget);
    });

    testWidgets('HealthCardScreen renders title, flip toggle, and action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HealthCardScreen(
            registrationContext: testContext,
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Digital Health Card'), findsOneWidget);
      expect(find.text('Verifiable Clinical Identity'), findsOneWidget);
      expect(find.byIcon(Icons.flip_to_back_rounded), findsOneWidget);
      expect(find.text('Verify Pass'), findsOneWidget);
    });

    testWidgets('InsuranceScreen renders platform title, tabs, and add policy button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InsuranceScreen(
            registrationContext: testContext,
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Insurance Platform'), findsOneWidget);
      expect(find.text('Policies'), findsOneWidget);
      expect(find.text('Claims'), findsOneWidget);
      expect(find.text('Add Policy'), findsOneWidget);
    });

    testWidgets('FamilyMembersScreen renders family title and add icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FamilyMembersScreen(language: 'en'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Family Management'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_alt_1_rounded), findsOneWidget);
    });

    testWidgets('PatientProfileScreen renders patient name, demographics, and logout button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientProfileScreen(
            registrationContext: testContext,
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sarah Jenkins'), findsWidgets);
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.text('Health Profiles'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
