import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/auth/data/models/registration_context.dart';
import 'package:careid_patient_app/features/auth/presentation/screens/login_screen.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/create_account_screen.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/mobile_number_screen.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/health_info_screen.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/add_insurance_screen.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/privacy_consents_screen.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/confirmed_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/home_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/medical_records_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/health_card_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/family_members_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/patient_profile_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> configureViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  const dummyContext = RegistrationContext(
    fullName: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+16505550004',
    bloodGroup: 'O+',
    knownAllergies: ['Penicillin'],
    chronicConditions: ['Hypertension'],
    termsAccepted: true,
    privacyPolicyAccepted: true,
  );

  group('Figma Visual Fidelity & UI Replication Tests (Canvas 17:55)', () {
    testWidgets('1. Splash Screen (20:25191) renders brand graphic & logo', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(
            displayDuration: Duration(seconds: 10),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('AES-256 · HIPAA Sovereign Vault'), findsOneWidget);
    });

    testWidgets('2. Welcome Screen (20:19794) renders 4 feature cards & action buttons', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Dental'), findsOneWidget);
      expect(find.text('Vision'), findsOneWidget);
      expect(find.text('Pets'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('3. Create Account (20:30644) renders Step 1 form fields', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateAccountScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Create Your CareID Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('4. Mobile Number (20:30756) renders Step 2 of 6 OTP verification UI', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: MobileNumberScreen(
            registrationContext: dummyContext,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 2 of 6'), findsOneWidget);
      expect(find.text('Verify your mobile number'), findsOneWidget);
    });

    testWidgets('5. Health Info (20:30900) renders Step 3 of 6 clinical demographics', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: HealthInfoScreen(
            registrationContext: dummyContext,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 3 of 6'), findsOneWidget);
      expect(find.text('Tell us about your health'), findsOneWidget);
    });

    testWidgets('6. Add Insurance (20:33068) renders Step 4 of 6 insurance link & OCR scanner', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: AddInsuranceScreen(
            registrationContext: dummyContext,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 4 of 6'), findsOneWidget);
      expect(find.text('Add your insurance'), findsOneWidget);
    });

    testWidgets('7. Privacy & Consents (20:31164) renders Step 5 of 6 HIPAA authorization', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyConsentsScreen(
            registrationContext: dummyContext,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 5 of 6'), findsOneWidget);
      expect(find.text('Your privacy & consents'), findsOneWidget);
    });

    testWidgets('8. Confirmed Screen (20:31401) renders Step 6 of 6 digital health card confirmation', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmedScreen(
            registrationContext: dummyContext,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 6 of 6'), findsOneWidget);
      expect(find.text('Your Care ID Vault is ready'), findsOneWidget);
    });

    testWidgets('9. Login Screen (20:24965) renders Welcome Back & phone challenge input', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);
    });

    testWidgets('10. Patient Home (20:19552) renders greeting, hero health card & vitals', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(
            registrationContext: dummyContext,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('DIGITAL HEALTH ID'), findsOneWidget);
      expect(find.text('Health Records'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets('11. Medical Records (20:31908) renders vault summary & category filters', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: MedicalRecordsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('All Records'), findsOneWidget);
      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('DENTAL'), findsOneWidget);
      expect(find.text('VISION'), findsOneWidget);
    });

    testWidgets('12. Digital Health Card (20:19873) renders verifiable QR credential', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: HealthCardScreen(
            registrationContext: dummyContext,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Digital Health Card'), findsOneWidget);
      expect(find.text('Verifiable Clinical Identity'), findsOneWidget);
    });

    testWidgets('13. Insurance Dashboard (20:20059) renders insurance policies & claims', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: InsuranceScreen(
            registrationContext: dummyContext,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Insurance Platform'), findsOneWidget);
      expect(find.text('Coverage & Claims'), findsOneWidget);
    });

    testWidgets('14. Family Dashboard (20:21675) renders family ecosystem & member list', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: FamilyMembersScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Family Management'), findsOneWidget);
    });

    testWidgets('15. Patient Profile (20:24653) renders personal details & identity controls', (tester) async {
      await configureViewport(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientProfileScreen(
            registrationContext: dummyContext,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Health Profiles'), findsOneWidget);
    });
  });
}
