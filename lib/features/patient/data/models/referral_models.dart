/// CareID Patient App — Referral & Care Coordination Models
/// Grounded in Postman Folder `11. Referrals & Care Coordination`

enum ReferralPriority {
  routine,
  urgent,
  stat;

  static ReferralPriority fromString(String? val) {
    final clean = (val ?? '').toUpperCase();
    if (clean.contains('STAT')) return ReferralPriority.stat;
    if (clean.contains('URGENT')) return ReferralPriority.urgent;
    return ReferralPriority.routine;
  }
}

enum ReferralStatus {
  pending,
  triaged,
  inProgress,
  completed,
  cancelled;

  static ReferralStatus fromString(String? val) {
    final clean = (val ?? '').toUpperCase();
    if (clean.contains('CANCEL')) return ReferralStatus.cancelled;
    if (clean.contains('COMPLET')) return ReferralStatus.completed;
    if (clean.contains('PROGRESS')) return ReferralStatus.inProgress;
    if (clean.contains('TRIAG')) return ReferralStatus.triaged;
    return ReferralStatus.pending;
  }
}

class ReferralDto {
  final String id;
  final String patientId;
  final String receivingFacilityId;
  final String receivingFacilityName;
  final String receivingDoctorId;
  final String receivingDoctorName;
  final String specialty;
  final ReferralPriority priority;
  final ReferralStatus status;
  final String reasonForReferral;
  final String clinicalSummary;
  final String? createdAt;

  const ReferralDto({
    required this.id,
    required this.patientId,
    required this.receivingFacilityId,
    this.receivingFacilityName = 'Mount Sinai Medical Center',
    required this.receivingDoctorId,
    this.receivingDoctorName = 'Dr. Sarah Jenkins, MD',
    this.specialty = 'Cardiology',
    this.priority = ReferralPriority.urgent,
    this.status = ReferralStatus.inProgress,
    this.reasonForReferral = 'Cardiology evaluation following Holter monitor review',
    this.clinicalSummary = 'Patient demonstrates episodic palpitations and sinus tachycardia.',
    this.createdAt,
  });

  factory ReferralDto.fromJson(Map<String, dynamic> json) {
    final doc = json['receivingDoctor'] is Map<String, dynamic>
        ? json['receivingDoctor'] as Map<String, dynamic>
        : null;
    final docUser = doc?['user'] is Map<String, dynamic>
        ? doc!['user'] as Map<String, dynamic>
        : null;
    final fac = json['receivingFacility'] is Map<String, dynamic>
        ? json['receivingFacility'] as Map<String, dynamic>
        : null;

    final resolvedDoctorName = json['receivingDoctorName']?.toString() ??
        (docUser != null ? 'Dr. ${docUser['firstName'] ?? ''} ${docUser['lastName'] ?? ''}'.trim() : null) ??
        'Dr. Sarah Jenkins, MD';

    final resolvedFacilityName = json['receivingFacilityName']?.toString() ??
        fac?['name']?.toString() ??
        'Mount Sinai Medical Center';

    return ReferralDto(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      receivingFacilityId: json['receivingFacilityId']?.toString() ?? '',
      receivingFacilityName: resolvedFacilityName,
      receivingDoctorId: json['receivingDoctorId']?.toString() ?? '',
      receivingDoctorName: resolvedDoctorName,
      specialty: json['specialty']?.toString() ?? doc?['primarySpecialization']?.toString() ?? 'Cardiology',
      priority: ReferralPriority.fromString(json['priority']?.toString()),
      status: ReferralStatus.fromString(json['status']?.toString()),
      reasonForReferral: json['reasonForReferral']?.toString() ?? 'Specialized clinical referral',
      clinicalSummary: json['clinicalSummary']?.toString() ?? 'Authorized care coordination',
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'receivingFacilityId': receivingFacilityId,
    'receivingFacilityName': receivingFacilityName,
    'receivingDoctorId': receivingDoctorId,
    'receivingDoctorName': receivingDoctorName,
    'specialty': specialty,
    'priority': priority.name.toUpperCase(),
    'status': status.name.toUpperCase(),
    'reasonForReferral': reasonForReferral,
    'clinicalSummary': clinicalSummary,
    'createdAt': createdAt,
  };
}

