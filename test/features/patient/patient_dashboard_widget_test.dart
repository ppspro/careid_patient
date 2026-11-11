import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/auth/data/models/registration_context.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/home_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/patient_main_navigation_shell.dart';
import 'package:careid_patient_app/shared/widgets/careid_bottom_navigation_bar.dart';

void main() {
  group('HomeScreen & Navigation Shell Tests (Figma 20:19552 - Home Option 6)', () {
    const testContext = RegistrationContext(
      fullName: 'Sarah Jenkins',
      phone: '+14155552671',
      email: 'sarah.j@email.com',
      bloodGroup: 'O+',
      careIdNumber: 'CID-8472-9102-4821',
      chronicConditions: ['Asthma'],
      knownAllergies: ['Penicillin'],
    );

    testWidgets('renders Hero Health Card, Bento Grid, Quick Actions, and Upcoming Appointments', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(
            registrationContext: testContext,
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Hero Health Card (Figma 20:19554)
      expect(find.text('DIGITAL HEALTH ID'), findsOneWidget);
      expect(find.text('Sarah\nJenkins'), findsOneWidget);
      expect(find.text('ICE Active'), findsOneWidget);
      expect(find.text('DOB'), findsOneWidget);
      expect(find.text('BLOOD GROUP'), findsOneWidget);
      expect(find.text('Add to Wallet'), findsOneWidget);

      // Section: Health Records Bento Grid (Figma 20:19631)
      expect(find.text('Health Records'), findsOneWidget);
      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Dental'), findsOneWidget);
      expect(find.text('Vision'), findsOneWidget);
      expect(find.text('Pets'), findsOneWidget);

      // Section: Quick Actions (Figma 20:19687)
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Insurance Card'), findsOneWidget);
      expect(find.text('Add Family Member'), findsOneWidget);
      expect(find.text('Book Appointment'), findsOneWidget);
      expect(find.text('Emergency'), findsOneWidget);

      // Section: Upcoming Appointments (Figma 20:19598)
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.text('Dental Appointment'), findsOneWidget);
      expect(find.text('Prescription Collection'), findsOneWidget);
    });

    testWidgets('PatientMainNavigationShell renders CareIdBottomNavigationBar and switches tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMainNavigationShell(
            registrationContext: testContext,
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // CareIdBottomNavigationBar (Figma 20:19764)
      expect(find.byType(CareIdBottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('Doctor'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Switch to Records tab -> opens Care ID - Family Records (Figma 20:30521)
      await tester.tap(find.text('Records'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('My Health Records'), findsOneWidget);
      expect(find.text('Family Health Records'), findsOneWidget);
      expect(find.text('Pet Records'), findsOneWidget);

      // Verify category navigation: tap Continue on My Health Records opens MedicalRecordsScreen
      await tester.tap(find.text('Continue').first);
      await tester.pumpAndSettle();
      expect(find.text('All Records'), findsOneWidget);

      // Verify back navigation: pop returns to Family Records hub, preserving Records tab
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.text('My Health Records'), findsOneWidget);

      // Switch to Doctor tab
      await tester.tap(find.text('Doctor'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Doctors/ Providers'), findsOneWidget);

      // Switch to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      // Switch back to Home tab
      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('DIGITAL HEALTH ID'), findsOneWidget);
    });
  });
}
