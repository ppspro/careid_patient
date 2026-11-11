import 'package:careid_patient_app/features/patient/data/models/patient_profile_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/medical_info_summary_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/medication_reminder_detail_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/patient_profile_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/personal_details_identity_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testProfile = PatientProfileDto(
    id: 'test-patient-001',
    patientNumber: '8829-X',
    firstName: 'Sarah',
    lastName: 'Jenkins',
    phone: '+1 (555) 234-5678',
    email: 'sarah.j@email.com',
    dateOfBirth: '1992-05-12',
    gender: 'Female',
    bloodGroup: 'O+',
    address: '425 Clinical Way, Suite 200',
    emergencyContactName: 'Arthur Thompson',
    emergencyContactPhone: '+1 (555) 987-6543',
    allergies: ['Penicillin', 'Peanuts'],
    conditions: ['Type 1 Diabetes', 'Hypertension'],
    medications: ['Lisinopril 10mg', 'Atorvastatin 20mg'],
    isProfileComplete: true,
  );

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('Batch 5: Profile, Identity & Medication Reminders Suite (Figma 20:24204 - 20:24653)', () {
    testWidgets('1. PatientProfileScreen (20:24204) renders header logo, health bento & settings groups', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const PatientProfileScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify Verified Status & Identity
      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);

      // Verify Status Cards
      expect(find.text('Card'), findsOneWidget);
      expect(find.text('Active'), findsWidgets);
      expect(find.text('Insurance'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);

      // Verify Settings Groups
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Medical Information'), findsOneWidget);
      expect(find.text('Health Profiles'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Biometric Login'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Application'), findsOneWidget);
      expect(find.text('Account Actions'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('2. PersonalDetailsIdentityScreen (20:24653) renders header, form inputs and security card', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const PersonalDetailsIdentityScreen(
            initialProfile: testProfile,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('Personal Details'), findsOneWidget);

      // Verify Profile Header & CareID tag
      expect(find.text('Sarah Jenkins'), findsWidgets);
      expect(find.text('CareID: #8829-X'), findsOneWidget);

      // Verify Form Fields
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('1992-05-12'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Blood Group'), findsOneWidget);
      expect(find.text('O+'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('sarah.j@email.com'), findsOneWidget);

      // Verify Information Integrity Card
      expect(find.text('Cryptographic Identity Integrity'), findsOneWidget);

      // Verify Action Buttons
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('3. MedicalInfoSummaryScreen (20:24484) renders clinical baseline bento and allergies', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MedicalInfoSummaryScreen(
            initialProfile: testProfile,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('Medical Profile'), findsOneWidget);

      // Verify Clinical Baseline Section
      expect(find.text('Clinical Baseline'), findsOneWidget);
      expect(find.text('HIPAA Secured'), findsOneWidget);

      // Verify Known Allergies Bento
      expect(find.text('Known Allergies'), findsOneWidget);
      expect(find.text('Penicillin'), findsOneWidget);
      expect(find.text('Peanuts'), findsOneWidget);

      // Verify Immunization & Conditions
      expect(find.text('Immunization & Vaccines'), findsOneWidget);
      expect(find.text('COVID-19 Bivalent'), findsOneWidget);
      expect(find.text('Chronic Medical Conditions'), findsOneWidget);
      expect(find.text('Type 1 Diabetes'), findsOneWidget);

      // Verify Primary Physician & Insurance Summary
      expect(find.text('Primary Care Physician'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins, MD'), findsOneWidget);
      expect(find.text('Active Health Insurance'), findsOneWidget);
      expect(find.text('BlueCross Platinum Plus'), findsOneWidget);
    });

    testWidgets('4. MedicationReminderDetailScreen (20:24101) renders hero card, dosage and toggles collected state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MedicationReminderDetailScreen(
            medicationName: 'Atorvastatin 20mg',
            dosage: '1 tablet daily with evening meal',
            doctorName: 'Dr. Sarah Jenkins',
            specialty: 'Cardiology & Internal Medicine',
            collectByDate: '12/06',
            pharmacyName: 'City Health Apothecary',
            pharmacyAddress: '425 Clinical Way, Suite 200',
            pharmacyPhone: '+1 (555) 234-5678',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Logo
      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('Prescription Reminder'), findsOneWidget);

      // Verify Hero Card & Medication details
      expect(find.text('Atorvastatin 20mg'), findsOneWidget);
      expect(find.text('1 tablet daily with evening meal'), findsOneWidget);
      expect(find.textContaining('Collect by: 12/06'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);

      // Verify Dosage & Pharmacy
      expect(find.text('Dosage & Instructions'), findsOneWidget);
      expect(find.text('Fulfilling Pharmacy'), findsOneWidget);
      expect(find.text('City Health Apothecary'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);

      // Tap "Mark as Collected" button
      await tester.tap(find.text('Mark as Collected'));
      await tester.pumpAndSettle();

      // State updates to COLLECTED
      expect(find.text('COLLECTED'), findsOneWidget);
      expect(find.textContaining('Collected — Tap to Undo'), findsOneWidget);
    });
  });
}
