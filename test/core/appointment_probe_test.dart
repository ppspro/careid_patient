import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/config/app_config.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/auth/data/repositories/auth_repository.dart';
import 'package:careid_patient_app/features/patient/data/models/appointment_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/doctor_repository.dart';

void main() {
  test('Live Doctor & Appointment Booking Probe', () async {
    const seededPhone = '+16505550004';
    const testOtp = '123456';

    final tokenStorage = InMemoryTokenStorage();
    final apiClient = ApiClient(
      baseUrl: AppConfig.apiBaseUrl,
      tokenStorage: tokenStorage,
    );

    final authRepo = AuthRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );
    final doctorRepo = DoctorRepository(apiClient: apiClient);

    // 1. Auth
    final reqRes = await authRepo.requestOtp(seededPhone);
    final chId = reqRes.dataOrNull?.challengeId ?? '';
    final verifyRes = await authRepo.verifyOtp(
      challengeId: chId,
      otpCode: testOtp,
    );
    print('Verify OTP: ${verifyRes.isSuccess}, Token: ${verifyRes.dataOrNull?.accessToken.isNotEmpty}');

    // 2. Doctors
    final docRes = await doctorRepo.getDoctors();
    print('Doctors count: ${docRes.dataOrNull?.length}');
    final doc = docRes.dataOrNull!.first;
    print('Using doctor: ${doc.id} (${doc.fullName})');

    // 3. Test Booking via POST /api/v1/appointments
    final testDate = DateTime.now().add(const Duration(days: 30));
    final testApt = AppointmentModel(
      id: '',
      doctorId: doc.id,
      doctorName: doc.fullName,
      specialization: doc.primarySpecialization,
      facility: doc.facilityName,
      dateTime: DateTime(testDate.year, testDate.month, testDate.day, 10, 30),
      consultationType: 'IN_PERSON',
      status: AppointmentStatus.upcoming,
      reasonForVisit: 'Test automated appointment verification',
      durationMinutes: 15,
    );

    final bookRes = await doctorRepo.bookAppointment(testApt);
    print('Book result: isSuccess: ${bookRes.isSuccess}, data: ${bookRes.dataOrNull?.id}');
    if (bookRes is ApiFailure) {
      final f = bookRes as ApiFailure;
      print('Book failure: code: ${f.statusCode}, message: ${f.message}');
    }

    if (bookRes.isSuccess && bookRes.dataOrNull != null) {
      final bookedId = bookRes.dataOrNull!.id;
      print('Booked appointment successfully with ID: $bookedId');

      // 4. Test Conflict Booking (same doctor, same time window -> expect 409 Conflict)
      final conflictRes = await doctorRepo.bookAppointment(testApt);
      print('Conflict booking result: isSuccess: ${conflictRes.isSuccess}');
      if (conflictRes is ApiFailure) {
        final f = conflictRes as ApiFailure;
        print('Conflict confirmed: status: ${f.statusCode}, msg: ${f.message}');
        expect(f.statusCode, equals(409));
      }

      // 5. Clean up by cancelling the test appointment immediately
      final cancelRes = await doctorRepo.cancelAppointment(bookedId, reason: 'Automated test teardown cleanup');
      print('Cancel appointment cleanup: ${cancelRes.isSuccess}');
    }
  });
}
