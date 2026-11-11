import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/features/patient/data/models/appointment_models.dart';
import 'package:careid_patient_app/features/patient/data/models/doctor_models.dart';
import 'package:careid_patient_app/features/patient/data/models/family_models.dart';
import 'package:careid_patient_app/features/patient/data/models/insurance_policy_models.dart';
import 'package:careid_patient_app/features/patient/data/models/medical_record_models.dart';
import 'package:careid_patient_app/features/patient/data/models/notification_models.dart';
import 'package:careid_patient_app/features/patient/data/models/patient_profile_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/family_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/medical_records_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/notification_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/patient_repository.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/add_family_member_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/add_health_record_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/appointment_details_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/book_appointment_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/claim_details_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/dental_records_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/doctor_profile_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/doctors_directory_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/emergency_center_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/my_appointments_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/notification_center_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/record_detail_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/treatment_offers_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/vision_records_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';

class MockMedicalRecordsRepository extends MedicalRecordsRepository {
  final List<MedicalRecordDto> mockRecords;
  MockMedicalRecordsRepository([this.mockRecords = const []]);

  @override
  Future<ApiResult<List<MedicalRecordDto>>> getMedicalRecords() async {
    return ApiSuccess(data: mockRecords);
  }
}

class MockFamilyRepository extends FamilyRepository {
  @override
  Future<ApiResult<FamilyInvitationDto>> sendInvitation(FamilyInvitationDto dto) async {
    return ApiSuccess(data: dto);
  }
}

class MockNotificationRepository extends NotificationRepository {
  @override
  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    return ApiSuccess(data: [
      NotificationModel(
        id: 'notif-001',
        title: 'Security Alert: New Sign-In Detected',
        message: 'A new login was verified from NYC.',
        notificationType: 'EMERGENCY',
        priority: 'HIGH',
        status: 'SENT',
        sentAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-002',
        title: 'Medication Reminder: Lisinopril 10mg',
        message: 'Time for your scheduled dose of Lisinopril 10mg.',
        notificationType: 'REMINDER',
        priority: 'NORMAL',
        status: 'SENT',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ]);
  }
}

class MockPatientRepository extends PatientRepository {
  final PatientProfileDto profile;
  MockPatientRepository(this.profile);

  @override
  Future<ApiResult<PatientProfileDto>> getPatientProfile() async {
    return ApiSuccess(data: profile);
  }
}

void main() {
  const testDoctor = DoctorModel(
    id: 'doc-test-1',
    fullName: 'Dr. Sarah Jenkins, MD',
    primarySpecialization: 'Cardiology',
    secondarySpecializations: ['Internal Medicine Specialist'],
    yearsOfExperience: 12,
    facilityName: 'Mount Sinai Hospital (Cardiovascular Health)',
    rating: 4.9,
    reviewCount: 154,
    registrationNumber: 'MED-REG-2026-3950',
    licenseNumber: 'NY-55193',
  );

  final testAppointment = AppointmentModel(
    id: 'apt-test-1',
    doctorId: 'doc-test-1',
    doctorName: 'Dr. Sarah Jenkins, MD',
    specialization: 'Cardiology & Internal Medicine',
    facility: 'Mount Sinai Hospital • Heart Center',
    dateTime: DateTime.now().add(const Duration(days: 2)),
    consultationType: 'In-Person Consultation',
    status: AppointmentStatus.upcoming,
    reasonForVisit: 'Routine cardiovascular checkup and lipid panel review',
    preparationNote: 'Arrive 10 mins prior with current physical prescriptions.',
    qrPassCode: 'CAREID-APT-PASS-9901',
    suiteRoom: '4th Floor, Suite 400 • Check-in Kiosk 2',
  );

  const testDentalRecord = MedicalRecordDto(
    id: 'rec-test-1',
    title: 'Panoramic Dental Radiography & Scaling',
    category: 'DENTAL',
    chiefComplaint: 'Biannual prophylaxis, molar scaling and full arch radiograph',
    clinicalNotes: 'Panoramic OPG shows no periapical radiolucency. Mild subgingival calculus removed.',
    treatmentPlan: 'Daily flossing, fluoride rinse, follow-up in 6 months.',
    diagnosis: 'K02.9 - Routine Dental Examination & Prophylaxis',
    doctorName: 'Dr. Julian Vance, DDS',
    facilityName: 'Apex Dental Care Institute',
    recordDate: '2023-08-15',
  );

  const testVisionRecord = MedicalRecordDto(
    id: 'rec-test-2',
    title: 'Retinal Fundus High-Res Diagnostic',
    category: 'VISION',
    chiefComplaint: 'Annual comprehensive ocular health examination & funduscopy',
    clinicalNotes: 'Normal fundus examination with clear media and intact macula.',
    treatmentPlan: 'Recheck in 12 months.',
    diagnosis: 'H35.31 - Non-exudative age-related macular screening',
    doctorName: 'Dr. Laura Zhao, OD',
    facilityName: 'VisionCare Eye Specialists',
    recordDate: '2023-10-18',
  );

  const testProfile = PatientProfileDto(
    id: 'p-test-01',
    firstName: 'John',
    lastName: 'Doe',
    bloodGroup: 'O+',
    allergies: ['Penicillin', 'Peanuts'],
    conditions: ['Type 1 Diabetes'],
    emergencyContactName: 'Jane Doe',
    emergencyContactPhone: '+1 (650) 555-0007',
    emergencyContactRelationship: 'Primary ICE (Spouse)',
  );

  const testClaim = InsuranceClaimDto(
    id: 'claim-test-1',
    claimNumber: 'CLM-2026-8819',
    providerName: 'Mount Sinai Hospital (Cardiovascular Health)',
    status: 'APPROVED',
    amount: 420.00,
    createdAt: 'Oct 24, 2026',
    description: 'Cardiology Consultation & Diagnostic Screening',
  );

  group('Remaining Patient App Pages Tests (Canvas 17:55)', () {
    testWidgets('1. DoctorsDirectoryScreen (20:28020) renders search, filter chips and doctor cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DoctorsDirectoryScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Doctors/ Providers'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All Clinicians'), findsOneWidget);
      expect(find.text('Medical (MD)'), findsOneWidget);
      expect(find.text('Dental (DDS)'), findsOneWidget);
      expect(find.text('Vision (OD)'), findsOneWidget);
      expect(find.byType(CareIdLogo), findsOneWidget);
    });

    testWidgets('2. DoctorProfileScreen (20:28961) renders doctor portrait, credentials, and Book Consultation CTA', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DoctorProfileScreen(doctor: testDoctor)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins, MD'), findsOneWidget);
      expect(find.text('Last Consultation'), findsOneWidget);
      expect(find.text('Synced Records'), findsOneWidget);
      expect(find.text('Clinical Specializations & Practice'), findsOneWidget);
      expect(find.textContaining('Care ID Tier-1 Verified Partner'), findsOneWidget);
      expect(find.text('Book Consultation'), findsOneWidget);
    });

    testWidgets('3. BookAppointmentScreen (20:28764 & 20:28312 & 20:28595) progresses through booking stepper', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BookAppointmentScreen(doctor: testDoctor)),
      );
      await tester.pump();

      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('Select Consultation Type'), findsOneWidget);
      expect(find.text('In-Person Consultation'), findsOneWidget);
      expect(find.text('Continue to Date & Time'), findsOneWidget);

      // Advance to Step 2
      await tester.tap(find.text('Continue to Date & Time'));
      await tester.pump();

      expect(find.text('Select Appointment Date'), findsOneWidget);
      expect(find.text('Select Time Slot'), findsOneWidget);
      expect(find.text('Review Appointment Details'), findsOneWidget);

      // Advance to Step 3
      await tester.tap(find.text('Review Appointment Details'));
      await tester.pump();

      expect(find.text('Appointment Summary'), findsOneWidget);
      expect(find.text('Confirm & Book Appointment'), findsOneWidget);
    });

    testWidgets('4. MyAppointmentsScreen (20:29664) renders tabs and appointment cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MyAppointmentsScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('5. AppointmentDetailsScreen (20:29860) renders digital check-in pass, facility and specs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AppointmentDetailsScreen(appointment: testAppointment)),
      );
      await tester.pump();

      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);
      expect(find.text('Doctor & Facility'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins, MD'), findsOneWidget);
      expect(find.text('Appointment Specification'), findsOneWidget);
      expect(find.text('Preparation & Linked Vault Records'), findsOneWidget);
      expect(find.text('Cancel Appointment'), findsOneWidget);
    });

    testWidgets('6. DentalRecordsScreen (20:21111) renders vault overview, metrics, and dental timeline', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DentalRecordsScreen(
            repository: MockMedicalRecordsRepository([testDentalRecord]),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Dental Records'), findsOneWidget);
      expect(find.text('Care ID Dental Vault'), findsOneWidget);
      expect(find.text('All Dental'), findsOneWidget);
      expect(find.text('Timeline & Diagnostic Records'), findsOneWidget);
      expect(find.text('Panoramic Dental Radiography & Scaling'), findsOneWidget);
    });

    testWidgets('7. VisionRecordsScreen (20:21301) renders optical metrics, visual acuity, and vision timeline', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VisionRecordsScreen(
            repository: MockMedicalRecordsRepository([testVisionRecord]),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Vision Records'), findsOneWidget);
      expect(find.text('Vision Records - Timeline & Vault'), findsOneWidget);
      expect(find.text('Acuity (OD)'), findsOneWidget);
      expect(find.text('Acuity (OS)'), findsOneWidget);
      expect(find.text('Timeline & Diagnostic Records'), findsOneWidget);
      expect(find.text('Retinal Fundus High-Res Diagnostic'), findsOneWidget);
    });

    testWidgets('8. RecordDetailScreen (20:25410 & 20:25653) renders encrypted security strip, provider, diagnosis and DICOM', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RecordDetailScreen(record: testDentalRecord)),
      );
      await tester.pump();

      expect(find.text('Record Details'), findsOneWidget);
      expect(find.text('Verified & End-to-End Encrypted'), findsOneWidget);
      expect(find.text('CR-7721-D'), findsOneWidget);
      expect(find.text('Attending Provider'), findsOneWidget);
      expect(find.text('Clinical Details'), findsOneWidget);
      expect(find.text('Dental Arch & Periodontal Status'), findsOneWidget);
      expect(find.text('Export PDF'), findsOneWidget);
      expect(find.text('Share Link'), findsOneWidget);
    });

    testWidgets('9. AddHealthRecordScreen (20:33245) renders categories, vitals, symptoms and save CTA', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AddHealthRecordScreen(initialCategory: 'GENERAL')),
      );
      await tester.pump();

      expect(find.text('Add Health Record'), findsOneWidget);
      expect(find.text('Record Category'), findsOneWidget);
      expect(find.text('Clinical Vitals'), findsOneWidget);
      expect(find.text('Symptoms'), findsOneWidget);
      expect(find.text('Headache'), findsOneWidget);
      expect(find.text('Save Health Record'), findsOneWidget);
    });

    testWidgets('10. NotificationCenterScreen (20:23812) renders category filters, mark all read, and cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationCenterScreen(repository: MockNotificationRepository()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('Security Alert: New Sign-In Detected'), findsOneWidget);
    });

    testWidgets('11. EmergencyCenterScreen (20:23956) renders emergency banner, blood type, allergies, ICE contacts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: EmergencyCenterScreen(repository: MockPatientRepository(testProfile))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CareIdLogo), findsOneWidget);
      expect(find.text('Emergency Protocol Active'), findsOneWidget);
      expect(find.text('BLOOD O+'), findsOneWidget);
      expect(find.text('Emergency Contacts (ICE)'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Designated Level 1 Trauma Center'), findsOneWidget);
      expect(find.text('Share Emergency Medical Pass (QR)'), findsOneWidget);
    });

    testWidgets('12. AddFamilyMemberScreen (20:22023) progresses through member info, permissions and review', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddFamilyMemberScreen(repository: MockFamilyRepository()),
        ),
      );
      await tester.pump();

      expect(find.text('Add Family Member'), findsOneWidget);
      expect(find.text('Member Information'), findsOneWidget);
      expect(find.text('Full Legal Name *'), findsOneWidget);
      expect(find.text('Mobile Phone Number *'), findsOneWidget);
      expect(find.text('Continue to Permissions'), findsOneWidget);

      // Enter required fields
      await tester.enterText(find.widgetWithText(TextField, 'Full Legal Name *'), 'Jane Doe');
      await tester.enterText(find.widgetWithText(TextField, 'Mobile Phone Number *'), '+16505550007');
      await tester.pump();

      // Proceed to Step 2
      await tester.tap(find.text('Continue to Permissions'));
      await tester.pump();

      expect(find.text('Healthcare Data Sharing Permissions'), findsOneWidget);
      expect(find.text('Medical Records Access'), findsOneWidget);
      expect(find.text('Review Invitation'), findsOneWidget);

      // Proceed to Step 3
      await tester.tap(find.text('Review Invitation'));
      await tester.pump();

      expect(find.text('Review Linkage Invitation'), findsOneWidget);
      expect(find.text('Send Linkage Invitation'), findsOneWidget);
    });

    testWidgets('13. TreatmentOffersScreen (20:26404) renders 0% APR hero banner, estimator, and packages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TreatmentOffersScreen()),
      );
      await tester.pump();

      expect(find.text('Treatment Offers & Financing'), findsOneWidget);
      expect(find.text('Care ID Health Credit'), findsOneWidget);
      expect(find.text('0% APR ELIGIBLE'), findsOneWidget);
      expect(find.text('Installment Estimator'), findsOneWidget);
      expect(find.text('Personalized Clinical Savings'), findsOneWidget);
      expect(find.text('Comprehensive Dental Restoration & Scaling'), findsOneWidget);
    });

    testWidgets('14. ClaimDetailsScreen (20:20158) renders adjudication timeline, payment breakdown, and EOB CTA', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ClaimDetailsScreen(claim: testClaim)),
      );
      await tester.pump();

      expect(find.text('Claim Details'), findsOneWidget);
      expect(find.text('CLM-2026-8819'), findsOneWidget);
      expect(find.text('Adjudication Status Tracker'), findsOneWidget);
      expect(find.text('Payment & Coverage Breakdown'), findsOneWidget);
      expect(find.text('Total Invoiced Amount'), findsOneWidget);
      expect(find.text('Covered by Insurance (80%)'), findsOneWidget);
      expect(find.text('Download Statement & EOB'), findsOneWidget);
    });
  });
}
