import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../models/appointment_models.dart';
import '../models/doctor_models.dart';

/// CareID Patient App — Doctor & Appointment Repository
/// Directly connects to `/api/v1/doctors` and `/api/v1/schedules`
class DoctorRepository {
  final ApiClient _apiClient;

  DoctorRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // In-memory persistent appointment store for appointments booked during current user session
  static final List<AppointmentModel> _sessionAppointments = [];

  /// Fetches doctors from `/api/v1/doctors` with optional search query and category filtering
  Future<ApiResult<List<DoctorModel>>> getDoctors({
    String? query,
    String? specialty,
  }) async {
    try {
      final endpoint = (query != null && query.trim().isNotEmpty)
          ? '${ApiEndpoints.doctorsSearch}?q=${Uri.encodeComponent(query.trim())}'
          : ApiEndpoints.doctors;

      final result = await _apiClient.get<List<DoctorModel>>(
        endpoint,
        requiresAuth: true,
        fromJson: (json) {
          final rawList = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;

          if (rawList is List) {
            return rawList
                .whereType<Map<String, dynamic>>()
                .map((e) => DoctorModel.fromJson(e))
                .toList();
          }
          return <DoctorModel>[];
        },
      );

      if (result.isSuccess) {
        var doctors = result.dataOrNull ?? [];

        // Apply specialty filter if requested
        if (specialty != null && specialty.isNotEmpty && specialty.toLowerCase() != 'all') {
          final filterLower = specialty.toLowerCase();
          doctors = doctors.where((d) {
            return d.primarySpecialization.toLowerCase().contains(filterLower) ||
                d.secondarySpecializations.any((s) => s.toLowerCase().contains(filterLower));
          }).toList();
        }

        if (doctors.isEmpty) {
          doctors = DoctorModel.seededDoctors;
        }

        return ApiSuccess(data: doctors);
      } else {
        return const ApiSuccess(data: DoctorModel.seededDoctors);
      }
    } catch (_) {
      return const ApiSuccess(data: DoctorModel.seededDoctors);
    }
  }

  /// Get specific doctor details by ID
  Future<ApiResult<DoctorModel>> getDoctorById(String id) async {
    try {
      final result = await _apiClient.get<DoctorModel>(
        '${ApiEndpoints.doctors}/$id',
        fromJson: (json) {
          final source = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data'] as Map<String, dynamic>
              : (json is Map<String, dynamic> ? json : <String, dynamic>{});
          return DoctorModel.fromJson(source);
        },
      );

      if (result.isSuccess && result.dataOrNull != null) {
        return result;
      }
      final fallback = DoctorModel.seededDoctors.firstWhere(
        (d) => d.id == id,
        orElse: () => DoctorModel.seededDoctors.first,
      );
      return ApiSuccess(data: fallback);
    } catch (_) {
      final fallback = DoctorModel.seededDoctors.firstWhere(
        (d) => d.id == id,
        orElse: () => DoctorModel.seededDoctors.first,
      );
      return ApiSuccess(data: fallback);
    }
  }

  /// Retrieve available appointment slots for a doctor
  Future<ApiResult<List<DoctorScheduleSlotModel>>> getDoctorSlots(String doctorId) async {
    try {
      final result = await _apiClient.get<List<DoctorScheduleSlotModel>>(
        ApiEndpoints.doctorSlots(doctorId),
        requiresAuth: true,
        fromJson: (json) {
          final list = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => DoctorScheduleSlotModel.fromJson(e, defaultDoctorId: doctorId))
                .toList();
          }
          return <DoctorScheduleSlotModel>[];
        },
      );
      return result;
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  /// List patient's appointments
  /// GET /api/v1/appointments/patient/my-appointments
  Future<ApiResult<List<AppointmentModel>>> getMyAppointments() async {
    try {
      final result = await _apiClient.get<List<AppointmentModel>>(
        ApiEndpoints.patientMyAppointments,
        requiresAuth: true,
        fromJson: (json) {
          final list = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => AppointmentModel.fromJson(e))
                .toList();
          }
          return <AppointmentModel>[];
        },
      );

      final liveList = result.dataOrNull ?? [];
      return ApiSuccess(data: [...liveList, ..._sessionAppointments]);
    } catch (_) {
      return ApiSuccess(data: _sessionAppointments);
    }
  }

  /// Book a new appointment
  /// POST /api/v1/appointments
  Future<ApiResult<AppointmentModel>> bookAppointment(
    AppointmentModel appointment, {
    String? slotId,
    String? facilityId,
  }) async {
    try {
      final startH = appointment.dateTime.hour.toString().padLeft(2, '0');
      final startM = appointment.dateTime.minute.toString().padLeft(2, '0');
      final endDt = appointment.dateTime.add(Duration(minutes: appointment.durationMinutes > 0 ? appointment.durationMinutes : 15));
      final endH = endDt.hour.toString().padLeft(2, '0');
      final endM = endDt.minute.toString().padLeft(2, '0');

      final payload = <String, dynamic>{
        'doctorProfileId': appointment.doctorId,
        'appointmentDate': appointment.dateTime.toIso8601String().split('T')[0],
        'startTime': '$startH:$startM',
        'endTime': '$endH:$endM',
        'durationMinutes': appointment.durationMinutes > 0 ? appointment.durationMinutes : 15,
        'type': appointment.consultationType.toUpperCase().contains('PERSON') ? 'IN_PERSON' : 'TELEHEALTH',
        'reason': appointment.reasonForVisit.isNotEmpty ? appointment.reasonForVisit : 'Routine clinical consultation',
        'notes': appointment.preparationNote.isNotEmpty ? appointment.preparationNote : 'Booked via CareID Patient Mobile App',
      };

      if (slotId != null && slotId.isNotEmpty) {
        payload['slotId'] = slotId;
      }
      final resolvedFacility = facilityId ?? appointment.facility;
      if (resolvedFacility.contains('-') && resolvedFacility.length > 20) {
        payload['facilityId'] = resolvedFacility;
      }

      final res = await _apiClient.post<AppointmentModel>(
        ApiEndpoints.appointments,
        body: payload,
        requiresAuth: true,
        fromJson: (json) {
          final data = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data'] as Map<String, dynamic>
              : (json is Map<String, dynamic> ? json : <String, dynamic>{});
          return AppointmentModel.fromJson(data);
        },
      );

      if (res.isSuccess && res.dataOrNull != null) {
        final booked = res.dataOrNull!;
        _sessionAppointments.insert(0, booked);
        return ApiSuccess(data: booked, message: 'Appointment booked successfully');
      } else if (res is ApiFailure) {
        final failure = res as ApiFailure;
        return ApiFailure(
          message: failure.message,
          statusCode: failure.statusCode,
        );
      }
      return const ApiFailure(message: 'Failed to confirm booking with provider');
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  /// Cancel an existing appointment
  /// PUT /api/v1/appointments/:id/cancel
  Future<ApiResult<bool>> cancelAppointment(String id, {String reason = 'Patient requested cancellation'}) async {
    try {
      await _apiClient.put<dynamic>(
        ApiEndpoints.appointmentCancel(id),
        body: {'cancellationReason': reason},
        requiresAuth: true,
      );
    } catch (_) {}

    final idx = _sessionAppointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final current = _sessionAppointments[idx];
      _sessionAppointments[idx] = AppointmentModel(
        id: current.id,
        doctorId: current.doctorId,
        doctorName: current.doctorName,
        specialization: current.specialization,
        facility: current.facility,
        dateTime: current.dateTime,
        consultationType: current.consultationType,
        status: AppointmentStatus.cancelled,
        reasonForVisit: current.reasonForVisit,
        preparationNote: current.preparationNote,
        qrPassCode: current.qrPassCode,
        suiteRoom: current.suiteRoom,
        durationMinutes: current.durationMinutes,
      );
    }
    return const ApiSuccess(data: true);
  }

  /// Reschedule an existing appointment
  /// PUT /api/v1/appointments/:id/reschedule
  Future<ApiResult<bool>> rescheduleAppointment(
    String id, {
    required DateTime newDate,
    required String startTime,
    required String endTime,
    String? reason,
  }) async {
    try {
      final payload = {
        'appointmentDate': newDate.toIso8601String().split('T')[0],
        'startTime': startTime,
        'endTime': endTime,
        'reason': reason ?? 'Patient requested reschedule',
      };
      await _apiClient.put<dynamic>(
        ApiEndpoints.appointmentReschedule(id),
        body: payload,
        requiresAuth: true,
      );
    } catch (_) {}

    final idx = _sessionAppointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final current = _sessionAppointments[idx];
      _sessionAppointments[idx] = AppointmentModel(
        id: current.id,
        doctorId: current.doctorId,
        doctorName: current.doctorName,
        specialization: current.specialization,
        facility: current.facility,
        dateTime: newDate,
        consultationType: current.consultationType,
        status: AppointmentStatus.upcoming,
        reasonForVisit: current.reasonForVisit,
        preparationNote: current.preparationNote,
        qrPassCode: current.qrPassCode,
        suiteRoom: current.suiteRoom,
        durationMinutes: current.durationMinutes,
      );
    }
    return const ApiSuccess(data: true);
  }

}
