export '../../../onboarding/data/models/health_card_models.dart';

/// CareID Digital Health Card Verification and History Models
/// Grounded in `07. Digital Health Cards & Passes`
class HealthCardHistoryItemDto {
  final String id;
  final String action;
  final String? previousStatus;
  final String? newStatus;
  final String? reason;
  final String timestamp;

  const HealthCardHistoryItemDto({
    required this.id,
    required this.action,
    this.previousStatus,
    this.newStatus,
    this.reason,
    required this.timestamp,
  });

  factory HealthCardHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return HealthCardHistoryItemDto(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? 'STATUS_CHANGE',
      previousStatus: json['previousStatus']?.toString(),
      newStatus: json['newStatus']?.toString(),
      reason: json['reason']?.toString(),
      timestamp: json['timestamp']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }
}

class VerifyQrResponseDto {
  final bool isValid;
  final String? cardNumber;
  final String? patientName;
  final String? firstName;
  final String? lastName;
  final String? patientNumber;
  final String? dateOfBirth;
  final String? bloodGroup;
  final String? verificationStatus;
  final String? message;

  const VerifyQrResponseDto({
    required this.isValid,
    this.cardNumber,
    this.patientName,
    this.firstName,
    this.lastName,
    this.patientNumber,
    this.dateOfBirth,
    this.bloodGroup,
    this.verificationStatus,
    this.message,
  });

  factory VerifyQrResponseDto.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString().toUpperCase() ?? '';
    final isValidFlag = json['valid'] == true ||
        json['isValid'] == true ||
        statusStr == 'VALID' ||
        statusStr == 'VERIFIED';

    final pd = json['patientDetails'] is Map<String, dynamic>
        ? json['patientDetails'] as Map<String, dynamic>
        : null;

    final parsedFirstName = pd?['firstName']?.toString() ?? json['firstName']?.toString();
    final parsedLastName = pd?['lastName']?.toString() ?? json['lastName']?.toString();
    final combinedName = [parsedFirstName, parsedLastName]
        .where((e) => e != null && e.trim().isNotEmpty)
        .join(' ');

    return VerifyQrResponseDto(
      isValid: isValidFlag,
      cardNumber: json['cardNumber']?.toString() ?? pd?['cardNumber']?.toString(),
      patientName: json['patientName']?.toString() ??
          json['name']?.toString() ??
          (combinedName.isNotEmpty ? combinedName : null),
      firstName: parsedFirstName,
      lastName: parsedLastName,
      patientNumber: pd?['patientNumber']?.toString() ?? json['patientNumber']?.toString(),
      dateOfBirth: pd?['dateOfBirth']?.toString() ?? json['dateOfBirth']?.toString(),
      bloodGroup: pd?['bloodGroup']?.toString() ?? json['bloodGroup']?.toString(),
      verificationStatus: json['status']?.toString() ?? (isValidFlag ? 'VERIFIED' : 'INVALID'),
      message: json['message']?.toString(),
    );
  }
}

class SharedAccessGrantDto {
  final String id;
  final String granteeName;
  final String granteeRole;
  final String facilityName;
  final List<String> scopes;
  final String status; // ACTIVE, PENDING, EXPIRED, REVOKED
  final String createdAt;
  final String expiresAt;

  const SharedAccessGrantDto({
    required this.id,
    required this.granteeName,
    this.granteeRole = 'Physician',
    required this.facilityName,
    required this.scopes,
    this.status = 'ACTIVE',
    required this.createdAt,
    required this.expiresAt,
  });

  factory SharedAccessGrantDto.fromJson(Map<String, dynamic> json) {
    return SharedAccessGrantDto(
      id: json['id']?.toString() ?? '',
      granteeName: json['granteeName']?.toString() ?? json['doctorName']?.toString() ?? 'Attending Clinician',
      granteeRole: json['granteeRole']?.toString() ?? json['specialty']?.toString() ?? 'Practitioner',
      facilityName: json['facilityName']?.toString() ?? json['clinic']?.toString() ?? 'Mount Sinai Medical Center',
      scopes: json['scopes'] is List
          ? (json['scopes'] as List).map((e) => e.toString()).toList()
          : ['Health Profile', 'Vitals'],
      status: (json['status']?.toString() ?? 'ACTIVE').toUpperCase(),
      createdAt: json['createdAt']?.toString() ?? '2026-10-31T10:00:00Z',
      expiresAt: json['expiresAt']?.toString() ?? '2026-11-01T10:00:00Z',
    );
  }

  Map<String, dynamic> toJson() => {
    'granteeName': granteeName,
    'granteeRole': granteeRole,
    'facilityName': facilityName,
    'scopes': scopes,
    'status': status,
    'expiresAt': expiresAt,
  };
}

