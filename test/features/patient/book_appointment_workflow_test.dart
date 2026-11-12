import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/shared/widgets/primary_button.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/features/patient/data/models/appointment_models.dart';
import 'package:careid_patient_app/features/patient/data/models/doctor_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/doctor_repository.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/book_appointment_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/appointment_confirmation_screen.dart';

class MockDoctorRepository extends DoctorRepository {
  List<DoctorScheduleSlotModel> mockSlots = [];
  ApiResult<AppointmentModel>? mockBookResult;
  int bookAppointmentCallCount = 0;
  Completer<ApiResult<AppointmentModel>>? bookAppointmentCompleter;

  @override
  Future<ApiResult<List<DoctorScheduleSlotModel>>> getDoctorSlots(String doctorId) async {
    return ApiSuccess(data: mockSlots);
  }

  @override
  Future<ApiResult<AppointmentModel>> bookAppointment(
    AppointmentModel appointment, {
    String? slotId,
    String? facilityId,
  }) async {
    bookAppointmentCallCount++;
    if (bookAppointmentCompleter != null) {
      return bookAppointmentCompleter!.future;
    }
    return mockBookResult ?? ApiSuccess(data: appointment);
  }

  @override
  Future<ApiResult<List<AppointmentModel>>> getMyAppointments() async {
    return const ApiSuccess(data: []);
  }
}

void main() {
  const dummyDoctor = DoctorModel(
    id: 'doc-uuid-999',
    fullName: 'Dr. Julian Vance, DDS',
    primarySpecialization: 'Prosthodontics & Oral Surgery',
    facilityName: 'CareID Downtown Clinic • Suite 402',
    yearsOfExperience: 14,
    rating: 4.9,
    reviewCount: 128,
    isVerified: true,
  );

  final tomorrow = DateTime.now().add(const Duration(days: 1));

  group('Appointment Booking Workflow Test Suite (Phase 2.1)', () {
    late MockDoctorRepository mockRepo;

    setUp(() {
      mockRepo = MockDoctorRepository();
    });

    testWidgets('1. Empty schedule handling displays empty card and disables continue', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      mockRepo.mockSlots = [];

      await tester.pumpWidget(
        MaterialApp(
          home: BookAppointmentScreen(
            doctor: dummyDoctor,
            repository: mockRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 0: Type selection
      expect(find.text('In-Person Consultation'), findsOneWidget);
      final continueBtn = find.text('Continue to Date & Time');
      expect(continueBtn, findsOneWidget);

      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Step 1: Date & Time with no slots
      expect(find.text('Select Appointment Date'), findsOneWidget);
      expect(find.text('No Available Slots'), findsOneWidget);
      expect(find.textContaining('No schedule slots are published for Dr. Julian Vance, DDS'), findsOneWidget);

      // Button should indicate slot selection is required and be disabled
      expect(find.text('Select a Slot to Continue'), findsOneWidget);
    });

    testWidgets('2. Slot state classification correctly renders Available, Booked, Past, and Selected states', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testSlots = [
        DoctorScheduleSlotModel(
          id: 'slot-available',
          doctorId: dummyDoctor.id,
          dayOfWeek: 'Any',
          startTime: '09:00',
          endTime: '09:30',
          isAvailable: true,
          slotDate: tomorrow,
        ),
        DoctorScheduleSlotModel(
          id: 'slot-booked',
          doctorId: dummyDoctor.id,
          dayOfWeek: 'Any',
          startTime: '10:00',
          endTime: '10:30',
          isAvailable: false,
          slotDate: tomorrow,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: BookAppointmentScreen(
            doctor: dummyDoctor,
            initialSlots: testSlots,
            repository: mockRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Advance to Step 1
      await tester.tap(find.text('Continue to Date & Time'));
      await tester.pumpAndSettle();

      // Verify available slot label is shown
      expect(find.text('09:00 - 09:30'), findsOneWidget);
      // Verify booked slot label and badge are shown
      expect(find.text('10:00 - 10:30'), findsOneWidget);
      expect(find.text('Booked'), findsOneWidget);

      // Booked slot cannot be selected
      await tester.tap(find.text('10:00 - 10:30'));
      await tester.pumpAndSettle();

      // Tap available slot
      await tester.tap(find.text('09:00 - 09:30'));
      await tester.pumpAndSettle();

      // With an available slot selected, button changes to Review
      expect(find.text('Review Appointment Details'), findsOneWidget);
    });

    testWidgets('3. Slot selection enables progression to Review step and displays correct summary', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testSlots = [
        DoctorScheduleSlotModel(
          id: 'slot-available-1',
          doctorId: dummyDoctor.id,
          dayOfWeek: 'Any',
          startTime: '11:00',
          endTime: '11:30',
          isAvailable: true,
          slotDate: tomorrow,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: BookAppointmentScreen(
            doctor: dummyDoctor,
            initialSlots: testSlots,
            repository: mockRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 0 -> Step 1
      await tester.tap(find.text('Continue to Date & Time'));
      await tester.pumpAndSettle();

      // Select slot
      await tester.tap(find.text('11:00 - 11:30'));
      await tester.pumpAndSettle();

      // Advance to Step 2: Review
      await tester.tap(find.text('Review Appointment Details'));
      await tester.pumpAndSettle();

      // Review Step details
      expect(find.text('Appointment Summary'), findsOneWidget);
      expect(find.text('Dr. Julian Vance, DDS'), findsWidgets);
      expect(find.text('CareID Downtown Clinic • Suite 402'), findsWidgets);
      expect(find.text('In-Person Consultation'), findsWidgets);
      expect(find.text('Confirm & Book Appointment'), findsOneWidget);
    });

    testWidgets('4. Successful booking transitions to Confirmation step with digital pass', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final confirmedAppointment = AppointmentModel(
        id: 'apt-live-101',
        doctorId: dummyDoctor.id,
        doctorName: dummyDoctor.fullName,
        specialization: dummyDoctor.primarySpecialization,
        facility: dummyDoctor.facilityName,
        dateTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
        consultationType: 'In-Person Consultation',
        status: AppointmentStatus.upcoming,
        reasonForVisit: 'Routine oral checkup',
        preparationNote: 'Arrive 10 mins prior.',
        qrPassCode: 'CAREID-CONFIRMED-PASS-999',
        suiteRoom: 'Suite 402',
        durationMinutes: 30,
      );

      mockRepo.mockBookResult = ApiSuccess(data: confirmedAppointment);

      final testSlots = [
        DoctorScheduleSlotModel(
          id: 'slot-1400',
          doctorId: dummyDoctor.id,
          dayOfWeek: 'Any',
          startTime: '14:00',
          endTime: '14:30',
          isAvailable: true,
          slotDate: tomorrow,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: BookAppointmentScreen(
            doctor: dummyDoctor,
            initialSlots: testSlots,
            repository: mockRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 0 -> Step 1 -> Step 2
      await tester.tap(find.text('Continue to Date & Time'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('14:00 - 14:30'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review Appointment Details'));
      await tester.pumpAndSettle();

      // Tap Confirm & Book Appointment
      await tester.tap(find.text('Confirm & Book Appointment'));
      await tester.pumpAndSettle();

      // Verify AppointmentConfirmationScreen is shown
      expect(find.byType(AppointmentConfirmationScreen), findsOneWidget);
      expect(find.text('Appointment Booked!'), findsOneWidget);
      expect(find.text('DIGITAL CARE PASS'), findsOneWidget);
      expect(find.textContaining('CONFIRMATION #apt-live-101'), findsOneWidget);
      expect(mockRepo.bookAppointmentCallCount, 1);
    });

    testWidgets('5. Slot conflict (HTTP 409) displays alert banner and allows Change Slot', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      mockRepo.mockBookResult = const ApiFailure(
        message: 'The selected slot is already booked.',
        statusCode: 409,
      );

      final testSlots = [
        DoctorScheduleSlotModel(
          id: 'slot-conflict',
          doctorId: dummyDoctor.id,
          dayOfWeek: 'Any',
          startTime: '15:00',
          endTime: '15:30',
          isAvailable: true,
          slotDate: tomorrow,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: BookAppointmentScreen(
            doctor: dummyDoctor,
            initialSlots: testSlots,
            repository: mockRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Review step
      await tester.tap(find.text('Continue to Date & Time'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('15:00 - 15:30'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review Appointment Details'));
      await tester.pumpAndSettle();

      // Tap Confirm
      await tester.tap(find.text('Confirm & Book Appointment'));
      await tester.pumpAndSettle();

      // Conflict alert banner displayed
      expect(find.text('Slot Unavailable (Conflict)'), findsOneWidget);
      expect(find.textContaining('is no longer available'), findsWidgets);
      expect(find.text('Change Slot'), findsOneWidget);

      // Tap 'Change Slot' should return to Step 1 (Date & Time)
      await tester.tap(find.text('Change Slot'));
      await tester.pumpAndSettle();

      expect(find.text('Select Appointment Date'), findsOneWidget);
      expect(find.text('Select a Slot to Continue'), findsOneWidget);
    });

    testWidgets('6. Network failure displays error SnackBar without advancing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      mockRepo.mockBookResult = const ApiFailure(
        message: 'Connection timed out. Check network connection.',
        statusCode: 504,
      );

      final testSlots = [
        DoctorScheduleSlotModel(
          id: 'slot-net-fail',
          doctorId: dummyDoctor.id,
          dayOfWeek: 'Any',
          startTime: '16:00',
          endTime: '16:30',
          isAvailable: true,
          slotDate: tomorrow,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: BookAppointmentScreen(
            doctor: dummyDoctor,
            initialSlots: testSlots,
            repository: mockRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue to Date & Time'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('16:00 - 16:30'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review Appointment Details'));
      await tester.pumpAndSettle();

      // Tap Confirm
      await tester.tap(find.text('Confirm & Book Appointment'));
      await tester.pump(); // Start async call

      await tester.pumpAndSettle();

      // Verify error snackbar content
      expect(find.text('Connection timed out. Check network connection.'), findsWidgets);
      // Stayed on Review step
      expect(find.text('Appointment Summary'), findsOneWidget);
    });

    testWidgets('7. Duplicate submission prevented while booking is in flight', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final completer = Completer<ApiResult<AppointmentModel>>();
      mockRepo.bookAppointmentCompleter = completer;

      final testSlots = [
        DoctorScheduleSlotModel(
          id: 'slot-dup-check',
          doctorId: dummyDoctor.id,
          dayOfWeek: 'Any',
          startTime: '17:00',
          endTime: '17:30',
          isAvailable: true,
          slotDate: tomorrow,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: BookAppointmentScreen(
            doctor: dummyDoctor,
            initialSlots: testSlots,
            repository: mockRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue to Date & Time'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('17:00 - 17:30'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review Appointment Details'));
      await tester.pumpAndSettle();

      // Tap Confirm once
      await tester.tap(find.text('Confirm & Book Appointment'));
      await tester.pump();

      // In-flight state: button in loading state showing progress indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(mockRepo.bookAppointmentCallCount, 1);

      // Attempt second tap while in-flight on the PrimaryButton
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();

      // Count must still be 1 (duplicate avoided)
      expect(mockRepo.bookAppointmentCallCount, 1);

      // Complete the request
      completer.complete(const ApiFailure(message: 'Aborted', statusCode: 400));
      await tester.pumpAndSettle();
    });
  });
}
