/// CareID Patient App — Appointment & Consultation Models
/// Aligned with Figma screens 20:29664, 20:29860, 20:28764, 20:28312, 20:29208

enum AppointmentStatus {
  upcoming,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case AppointmentStatus.upcoming:
        return 'Upcoming';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  static AppointmentStatus fromString(String? val) {
    final clean = (val ?? '').toUpperCase();
    if (clean.contains('CANCEL')) return AppointmentStatus.cancelled;
    if (clean.contains('COMPLET') || clean.contains('PAST')) return AppointmentStatus.completed;
    return AppointmentStatus.upcoming;
  }
}

class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialization;
  final String facility;
  final DateTime dateTime;
  final String consultationType;
  final AppointmentStatus status;
  final String reasonForVisit;
  final String preparationNote;
  final String qrPassCode;
  final String? suiteRoom;
  final int durationMinutes;

  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.facility,
    required this.dateTime,
    this.consultationType = 'In-Person Consultation',
    this.status = AppointmentStatus.upcoming,
    this.reasonForVisit = 'Routine cardiovascular checkup and review',
    this.preparationNote = 'Arrive 10 mins prior with current physical prescriptions.',
    this.qrPassCode = 'CAREID-APT-PASS-8842',
    this.suiteRoom = '4th Floor, Suite 400 • Kiosk 2',
    this.durationMinutes = 45,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now().add(const Duration(days: 3));
      }
      return DateTime.now().add(const Duration(days: 3));
    }

    final docObj = json['doctor'] is Map<String, dynamic> ? json['doctor'] as Map<String, dynamic> : null;
    final docUser = docObj?['user'] is Map<String, dynamic> ? docObj!['user'] as Map<String, dynamic> : null;
    final facilityObj = json['facility'] is Map<String, dynamic> ? json['facility'] as Map<String, dynamic> : null;

    final resolvedDoctorName = json['doctorName']?.toString() ??
        (docObj?['fullName']?.toString()) ??
        (docObj?['firstName'] != null ? '\ '.trim() : null) ??
        (docUser != null ? 'Dr. \ '.trim() : null) ??
        'Dr. Julian Vance, MD';

    final resolvedSpecialization = json['specialization']?.toString() ??
        docObj?['primarySpecialization']?.toString() ??
        docObj?['specialization']?.toString() ??
        'Cardiology & Internal Medicine';

    final resolvedFacility = json['facility'] is String
        ? json['facility'].toString()
        : (facilityObj?['name']?.toString() ?? 'Mount Sinai Hospital • Heart Center');

    final fullDate = json['dateTime'] ??
        (json['appointmentDate'] != null && json['startTime'] != null
            ? '\T\:00'
            : (json['appointmentDate'] ?? json['startTime']));

    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? docObj?['id']?.toString() ?? '',
      doctorName: resolvedDoctorName,
      specialization: resolvedSpecialization,
      facility: resolvedFacility,
      dateTime: parseDate(fullDate),
      consultationType: json['consultationType']?.toString() ?? (json['type']?.toString() == 'IN_PERSON' ? 'In-Person Consultation' : 'Virtual Consultation'),
      status: AppointmentStatus.fromString(json['status']?.toString()),
      reasonForVisit: json['reasonForVisit']?.toString() ?? json['reason']?.toString() ?? 'Routine cardiovascular checkup and review',
      preparationNote: json['preparationNote']?.toString() ?? 'Arrive 10 mins prior with current physical prescriptions.',
      qrPassCode: json['qrPassCode']?.toString() ?? 'CAREID-APT-PASS-8842',
      suiteRoom: json['suiteRoom']?.toString() ?? '4th Floor, Suite 400 • Kiosk 2',
      durationMinutes: json['durationMinutes'] is int ? json['durationMinutes'] as int : 45,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'specialization': specialization,
    'facility': facility,
    'dateTime': dateTime.toIso8601String(),
    'consultationType': consultationType,
    'status': status.name.toUpperCase(),
    'reasonForVisit': reasonForVisit,
    'preparationNote': preparationNote,
    'qrPassCode': qrPassCode,
    'suiteRoom': suiteRoom,
    'durationMinutes': durationMinutes,
  };
}

