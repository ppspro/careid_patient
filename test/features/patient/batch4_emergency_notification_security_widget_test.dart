import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/features/patient/data/models/notification_models.dart';
import 'package:careid_patient_app/features/patient/data/models/patient_profile_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/notification_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/patient_repository.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/access_history_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/emergency_center_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/notification_center_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/security_privacy_controls_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';

class _FakePatientRepository extends PatientRepository {
  _FakePatientRepository() : super(apiClient: ApiClient(baseUrl: 'https://360api.vnvision.in'));

  @override
  Future<ApiResult<PatientProfileDto>> getPatientProfile() async {
    return const ApiSuccess(
      data: PatientProfileDto(
        id: 'patient-test-787e',
        firstName: 'Johnathan',
        lastName: 'Doe',
        email: 'johnathan.doe@example.com',
        phone: '+1 (650) 555-0199',
        dateOfBirth: '1988-04-12',
        gender: 'Male',
        bloodGroup: 'O+',
        allergies: ['Penicillin', 'Peanuts'],
        conditions: ['Type 1 Diabetes', 'Hypertension'],
        emergencyContactName: 'Jane Doe',
        emergencyContactPhone: '+1 (650) 555-0007',
        emergencyContactRelationship: 'Primary ICE (Spouse)',
      ),
    );
  }
}

class _FakeNotificationRepository extends NotificationRepository {
  _FakeNotificationRepository() : super(apiClient: ApiClient(baseUrl: 'https://360api.vnvision.in'));

  @override
  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    return ApiSuccess(data: [
      NotificationModel(
        id: 'notif-001',
        title: 'Prescription Refill Ready',
        message: 'Your Lisinopril 10mg refill is ready for pickup at CVS Pharmacy #402.',
        notificationType: 'MEDICATION',
        priority: 'HIGH',
        sentAt: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-002',
        title: 'New Clinical Note Added',
        message: 'Dr. Sarah Jenkins uploaded the consultation summary for your cardiology visit.',
        notificationType: 'RECORD',
        priority: 'NORMAL',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
    ]);
  }
}

void main() {
  group('Batch 4: Emergency, Notifications & Security Suite (Figma 20:23450 - 20:24805)', () {
    testWidgets('EmergencyCenterScreen renders header, SOS hero, bento medical ID, ICE contacts and QR button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeRepo = _FakePatientRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: EmergencyCenterScreen(repository: fakeRepo),
        ),
      );

      await tester.pump();
      await tester.pump();

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);

      // SOS Section
      expect(find.text('Emergency Protocol Active'), findsOneWidget);
      expect(find.text('TRIGGER 911 EMERGENCY SOS'), findsOneWidget);

      // Bento Medical ID
      expect(find.text('Critical Medical ID'), findsOneWidget);
      expect(find.text('BLOOD O+'), findsOneWidget);
      expect(find.text('Penicillin'), findsOneWidget);
      expect(find.text('Type 1 Diabetes'), findsOneWidget);
      expect(find.textContaining('Organ Donor'), findsOneWidget);

      // ICE Contacts
      expect(find.text('Emergency Contacts (ICE)'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('1 Linked'), findsOneWidget);

      // Trauma Center
      expect(find.text('Designated Level 1 Trauma Center'), findsOneWidget);
      expect(find.text('City General Hospital Emergency Department'), findsOneWidget);

      // Share Emergency Pass button
      expect(find.text('Share Emergency Medical Pass (QR)'), findsOneWidget);
    });

    testWidgets('NotificationCenterScreen renders header, filter chips, and priority notification cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeNotifRepo = _FakeNotificationRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationCenterScreen(repository: fakeNotifRepo),
        ),
      );

      await tester.pump();
      await tester.pump();

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);

      // Filter chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);
      expect(find.text('Appointments'), findsOneWidget);
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Care Team'), findsOneWidget);

      // Notification cards
      expect(find.text('Prescription Refill Ready'), findsOneWidget);
      expect(find.text('ACTION REQUIRED'), findsOneWidget);
      expect(find.text('New Clinical Note Added'), findsOneWidget);
    });

    testWidgets('SecurityPrivacyControlsScreen renders header, biometric switches, session controls, and export dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: SecurityPrivacyControlsScreen(),
        ),
      );

      await tester.pump();

      // Header branding
      expect(find.byType(CareIdLogo), findsNWidgets(2)); // horizontal title + emblem action

      // Biometric settings
      expect(find.text('BIOMETRIC SECURITY'), findsOneWidget);
      expect(find.text('Biometric Authentication'), findsOneWidget);
      expect(find.text('Auto-Lock Screen'), findsOneWidget);

      // PIN & Session
      expect(find.text('PIN MANAGEMENT'), findsOneWidget);
      expect(find.text('SESSION MANAGEMENT'), findsOneWidget);
      expect(find.textContaining('Android Device'), findsOneWidget);

      // Data Sovereignty
      expect(find.text('PRIVACY & DATA SOVEREIGNTY'), findsOneWidget);
      expect(find.text('Access History'), findsOneWidget);
      expect(find.text('Download My Data'), findsOneWidget);
      expect(find.text('Consent Management'), findsOneWidget);
    });

    testWidgets('AccessHistoryScreen renders header, Stats Bento section, search and timeline entries', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testLogs = [
        {
          'provider': 'Dr. Sarah Jenkins, MD',
          'specialty': 'Cardiology & Internal Medicine',
          'action': 'Viewed Cardiology Consultation & ECG Report',
          'date': 'Nov 16, 2026 • 09:45 AM',
          'status': 'VERIFIED',
          'category': 'recent',
          'accessType': 'Direct Consultation',
        },
        {
          'provider': 'City Hospital Emergency Desk',
          'specialty': 'Emergency Care Unit',
          'action': 'Scanned Emergency QR Pass (Blood Group O+, ICE)',
          'date': 'Nov 10, 2026 • 11:20 PM',
          'status': 'ONE_TIME',
          'category': 'recent',
          'accessType': 'Emergency SOS Pass',
        },
        {
          'provider': 'Premier Dental Clinic (Dr. Michael Chen)',
          'specialty': 'Dental Surgery',
          'action': 'Requested Access to Panoramic Radiographs',
          'date': 'Nov 02, 2026 • 02:15 PM',
          'status': 'PENDING',
          'category': 'pending',
          'accessType': 'Pending Consent',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: AccessHistoryScreen(initialLogs: testLogs),
        ),
      );

      await tester.pump();

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);

      // Stats Bento Section
      expect(find.text('Total Access'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Clinicians'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Search & Filters
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search access logs...'), findsOneWidget);
      expect(find.text('All Logs'), findsOneWidget);
      expect(find.text('Recent Sessions'), findsOneWidget);
      expect(find.text('Pending Requests'), findsOneWidget);

      // Timeline logs
      expect(find.text('Dr. Sarah Jenkins, MD'), findsOneWidget);
      expect(find.text('City Hospital Emergency Desk'), findsOneWidget);
      expect(find.text('Premier Dental Clinic (Dr. Michael Chen)'), findsOneWidget);
      expect(find.text('VERIFIED'), findsAtLeastNWidgets(1));
      expect(find.text('PENDING'), findsOneWidget);
    });
  });
}
