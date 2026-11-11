import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/auth/presentation/screens/account_recovery_screen.dart';
import 'package:careid_patient_app/features/auth/presentation/screens/biometric_setup_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/access_history_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/document_viewer_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/full_kiosk_pass_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/live_chat_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/payment_options_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/reschedule_appointment_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/security_privacy_controls_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/uninsured_assistance_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';

void main() {
  group('10 New Figma Canvas 17:55 Screens Widget Tests', () {
    testWidgets('1. FullKioskPassScreen renders express kiosk pass & credentials', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: FullKioskPassScreen(
            doctorName: 'Dr. Sarah Jenkins, MD',
            specialty: 'Cardiology & Internal Medicine',
            dateTime: 'Thursday, Nov 16 • 09:30 AM',
            location: '1190 5th Ave, Suite 400, New York, NY 10029',
            patientName: 'Sarah Jenkins',
            careIdNumber: 'CID #8472-9901',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Express Kiosk Pass'), findsOneWidget);
      expect(find.text('Pre-authorized with 5 Care ID Vault records'), findsOneWidget);
      expect(find.text('Apple Wallet'), findsOneWidget);
      expect(find.text('Google Pay'), findsOneWidget);
    });

    testWidgets('2. LiveChatScreen renders care team messaging & message composer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LiveChatScreen(
            doctorName: 'Dr. Sarah Jenkins, MD',
            specialty: 'Cardiology & Internal Medicine',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sarah Jenkins, MD'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget);
    });

    testWidgets('3. RescheduleAppointmentScreen renders slot selector & reason input', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: RescheduleAppointmentScreen(
            appointmentId: 'apt-042',
            doctorName: 'Dr. Sarah Jenkins, MD',
            previousDate: 'Thu, Nov 16',
            previousTime: '09:45 AM',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reschedule Appointment'), findsOneWidget);
      expect(find.text('Morning (09:00 AM – 12:00 PM)'), findsOneWidget);
      expect(find.text('Confirm Reschedule'), findsOneWidget);
    });

    testWidgets('4. SecurityPrivacyControlsScreen renders biometrics & export options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecurityPrivacyControlsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.text('BIOMETRIC SECURITY'), findsOneWidget);
      expect(find.text('Biometric Authentication'), findsOneWidget);
      expect(find.text('Download My Data'), findsOneWidget);
      expect(find.text('Consent Management'), findsOneWidget);
    });

    testWidgets('5. AccessHistoryScreen renders access logs and audit search', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CareIdLogo), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All Logs'), findsOneWidget);
      expect(find.text('Recent Sessions'), findsOneWidget);
      expect(find.text('Pending Requests'), findsOneWidget);
    });

    testWidgets('6. DocumentViewerScreen renders document viewer & AES seal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DocumentViewerScreen(
            title: 'Dental X-Ray Report',
            fileName: 'X-Ray Report_042.pdf',
            verifiedDate: 'May 14, 2024',
            doctorName: 'Dr. Sarah Jenkins, MD',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dental X-Ray Report'), findsWidgets);
      expect(find.textContaining('X-Ray Report_042.pdf'), findsOneWidget);
      expect(find.text('AES-256'), findsOneWidget);
      expect(find.text('OFFICIAL RECORD'), findsOneWidget);
    });

    testWidgets('7. AccountRecoveryScreen renders phone recovery form', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountRecoveryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account Recovery'), findsOneWidget);
      expect(find.text('Send Recovery Code'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
      expect(find.text('256-bit HIPAA Compliant Security Protocol'), findsOneWidget);
    });

    testWidgets('8. BiometricSetupScreen renders biometric activation hero & buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BiometricSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Secure Your CareID Vault'), findsOneWidget);
      expect(find.text('Enable Biometrics'), findsOneWidget);
      expect(find.text('Use PIN Instead'), findsOneWidget);
      expect(find.text('Skip for Now'), findsOneWidget);
    });

    testWidgets('9. PaymentOptionsScreen renders sliding-scale, HSA/FSA, & 0% APR plans', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentOptionsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Choose How You Pay for Your Care'), findsOneWidget);
      expect(find.text('Sliding-Scale Clinic Discount'), findsOneWidget);
      expect(find.text('HSA / FSA Direct Pay'), findsOneWidget);
      expect(find.text('Zero-Interest Payment Plans'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('10. UninsuredAssistanceScreen renders empty-state & value prop bento cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UninsuredAssistanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Active Insurance on File'), findsOneWidget);
      expect(find.text('Instant Hospital Eligibility'), findsOneWidget);
      expect(find.text('Zero-Paperwork Admission'), findsOneWidget);
      expect(find.text('Automated Claim Tracking'), findsOneWidget);
      expect(find.text('Add Insurance Card'), findsOneWidget);
      expect(find.text('Make a Self-Pay Offer'), findsOneWidget);
    });
  });
}
