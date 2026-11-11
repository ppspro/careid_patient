/// CareID Patient Profile Data Models
/// Grounded in OpenAPI 3.0.0 and Postman Collection for `06. Patient App`
class PatientProfileDto {
  final String id;
  final String? patientNumber;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> medications;
  final String? photoUrl;
  final String? status;
  final int? onboardingStep;
  final bool isProfileComplete;

  const PatientProfileDto({
    required this.id,
    this.patientNumber,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.allergies = const [],
    this.conditions = const [],
    this.medications = const [],
    this.photoUrl,
    this.status,
    this.onboardingStep,
    this.isProfileComplete = false,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'CareID Patient';
  }

  factory PatientProfileDto.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return PatientProfileDto(
      id: json['id']?.toString() ?? '',
      patientNumber: json['patientNumber']?.toString() ?? json['careId']?.toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString() ?? json['dob']?.toString(),
      gender: json['gender']?.toString(),
      bloodGroup: json['bloodGroup']?.toString(),
      address: () {
        final addr = json['currentAddress'] ?? json['address'];
        if (addr is Map) {
          final parts = [
            addr['line1'],
            addr['city'],
            addr['state'],
            addr['postalCode'],
            addr['country'],
          ].where((e) => e != null && e.toString().trim().isNotEmpty).map((e) => e.toString().trim());
          return parts.isNotEmpty ? parts.join(', ') : null;
        }
        return addr?.toString();
      }(),
      emergencyContactName: json['emergencyContact'] is Map
          ? json['emergencyContact']['name']?.toString()
          : json['emergencyContactName']?.toString(),
      emergencyContactPhone: json['emergencyContact'] is Map
          ? json['emergencyContact']['phone']?.toString()
          : json['emergencyContactPhone']?.toString(),
      emergencyContactRelationship: json['emergencyContact'] is Map
          ? json['emergencyContact']['relationship']?.toString()
          : json['emergencyContactRelationship']?.toString(),
      allergies: parseList(json['knownAllergies'] ?? json['allergies']),
      conditions: parseList(json['chronicConditions'] ?? json['conditions']),
      medications: parseList(json['medications'] ?? json['regularMedications']),
      photoUrl: json['photoUrl']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      onboardingStep: json['onboardingStep'] is num
          ? (json['onboardingStep'] as num).toInt()
          : null,
      isProfileComplete: json['isProfileComplete'] == true ||
          json['status'] == 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientNumber': patientNumber,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'bloodGroup': bloodGroup,
    'address': address,
    'allergies': allergies,
    'chronicConditions': conditions,
    'photoUrl': photoUrl,
    'status': status,
  };
}

/// Profile completion metrics
class ProfileCompletionDto {
  final int percentage;
  final int totalSteps;
  final int completedSteps;
  final List<String> missingFields;

  const ProfileCompletionDto({
    required this.percentage,
    this.totalSteps = 6,
    this.completedSteps = 6,
    this.missingFields = const [],
  });

  factory ProfileCompletionDto.fromJson(Map<String, dynamic> json) {
    final pct = json['percentage'] ?? json['completionPercentage'] ?? 100;
    return ProfileCompletionDto(
      percentage: pct is num ? pct.toInt().clamp(0, 100) : 100,
      totalSteps: (json['totalSteps'] as num?)?.toInt() ?? 6,
      completedSteps: (json['completedSteps'] as num?)?.toInt() ?? 6,
      missingFields: (json['missingFields'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

