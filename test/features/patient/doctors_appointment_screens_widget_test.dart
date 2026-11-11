import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/features/patient/data/models/appointment_models.dart';
import 'package:careid_patient_app/features/patient/data/models/doctor_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/doctors_directory_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/doctor_profile_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/book_appointment_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/my_appointments_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/appointment_confirmation_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/appointment_details_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';

void main() {
  const dummyDoctor = DoctorModel(
    id: 'doc-001',
    fullName: 'Dr. Julian Vance, DDS',
    primarySpecialization: 'Prosthodontics & Oral Surgery',
    facilityName: 'CareID Downtown Clinic • Suite 402',
    yearsOfExperience: 14,
    rating: 4.9,
    reviewCount: 128,
    isVerified: true,
  );

  final dummyAppointment = AppointmentModel(
    id: 'apt-001',
    doctorId: dummyDoctor.id,
    doctorName: dummyDoctor.fullName,
    specialization: dummyDoctor.primarySpecialization,
    facility: dummyDoctor.facilityName,
    dateTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
    consultationType: 'In-Person Consultation',
    status: AppointmentStatus.upcoming,
    reasonForVisit: 'Routine oral surgery follow-up',
    preparationNote: 'Arrive 10 mins prior.',
    qrPassCode: 'CAREID-APT-PASS-9901',
    suiteRoom: 'Suite 402 • Dental Operatory 1',
    durationMinutes: 45,
  );

  group('Doctor Directory & Appointment Flow Suite (Figma 20:28020 - 20:29860)', () {
    testWidgets('DoctorsDirectoryScreen renders header logo, search, and category chips', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorsDirectoryScreen(showBottomNav: false),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);

      // Section title & subtitle
      expect(find.text('Doctors/ Providers'), findsOneWidget);
      expect(find.text('Find and manage doctors connected to your Care ID vault'), findsOneWidget);

      // Search input
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search by name, clinic, or specialty...'), findsOneWidget);

      // Category chips
      expect(find.text('All Clinicians'), findsOneWidget);
      expect(find.text('Medical (MD)'), findsOneWidget);
      expect(find.text('Dental (DDS)'), findsOneWidget);
      expect(find.text('Vision (OD)'), findsOneWidget);
      expect(find.text('My Appointments'), findsOneWidget);
    });

    testWidgets('DoctorProfileScreen renders header logo, credentials, and actions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorProfileScreen(doctor: dummyDoctor),
        ),
      );

      await tester.pump();

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);

      // Doctor identity
      expect(find.text('Dr. Julian Vance, DDS'), findsWidgets);
      expect(find.text('Prosthodontics & Oral Surgery'), findsWidgets);
      expect(find.text('CareID Downtown Clinic • Suite 402'), findsWidgets);

      // Actions
      expect(find.text('Book Consultation'), findsOneWidget);
    });

    testWidgets('BookAppointmentScreen renders header logo, step progress, and consultation types', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: BookAppointmentScreen(doctor: dummyDoctor),
        ),
      );

      await tester.pump();

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);

      // Step progress
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Date & Time'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);

      // Consultation options
      expect(find.text('In-Person Consultation'), findsOneWidget);
      expect(find.text('Lab & Medication Review'), findsOneWidget);
      expect(find.text('Specialized Evaluation'), findsOneWidget);
    });

    testWidgets('MyAppointmentsScreen renders header logo, tabs, and action button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: MyAppointmentsScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);

      // Tabs
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('AppointmentDetailsScreen renders header logo, facility info, and pass code', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: AppointmentDetailsScreen(appointment: dummyAppointment),
        ),
      );

      await tester.pump();

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);

      // Doctor & pass details
      expect(find.text('Dr. Julian Vance, DDS'), findsWidgets);
      expect(find.text('CareID Downtown Clinic • Suite 402'), findsWidgets);
      expect(find.textContaining('CAREID-APT-PASS-9901'), findsOneWidget);
    });

    testWidgets('AppointmentConfirmationScreen (20:29208) renders booked title, digital pass card, and next steps', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: AppointmentConfirmationScreen(appointment: dummyAppointment),
        ),
      );

      await tester.pump();

      expect(find.text('Appointment Booked!'), findsOneWidget);
      expect(find.text('APPOINTMENT STATUS'), findsOneWidget);
      expect(find.text('DIGITAL CARE PASS'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('View Appointment Details'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Arrival & Next Steps'), findsOneWidget);
      expect(find.text('View Appointment Details'), findsOneWidget);
      expect(find.text('Return to Home'), findsOneWidget);
    });
  });
}
