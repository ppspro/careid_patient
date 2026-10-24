/// CareID Patient App — Health Info & Onboarding Models
/// Grounded strictly in the OpenAPI 3.0.0 specification from https://360api.vnvision.in/docs
/// and Figma Frame 20:30900 (Step 3: Tell us about your health).

/// Standard blood groups supported by CareID and clinical health vaults.
class BloodGroup {
  static const String aPositive = 'A+';
  static const String aNegative = 'A-';
  static const String bPositive = 'B+';
  static const String bNegative = 'B-';
  static const String abPositive = 'AB+';
  static const String abNegative = 'AB-';
  static const String oPositive = 'O+';
  static const String oNegative = 'O-';
  static const String unknown = 'Unknown / Not sure';

  static const List<String> all = [
    aPositive,
    aNegative,
    bPositive,
    bNegative,
    abPositive,
    abNegative,
    oPositive,
    oNegative,
    unknown,
  ];

  static bool isValid(String? value) {
    if (value == null || value.isEmpty) return false;
    return all.contains(value);
  }
}

/// Helper for ISO-8601 YYYY-MM-DD date validation.
bool isValidIsoDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return false;
  final regExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (!regExp.hasMatch(dateStr)) return false;
  try {
    final parsed = DateTime.parse(dateStr);
    return parsed.year >= 1900 &&
        parsed.isBefore(DateTime.now().add(const Duration(days: 1)));
  } catch (_) {
    return false;
  }
}

/// Helper for phone normalization (E.164 format).
String normalizePhone(String phone) {
  final clean = phone.trim();
  final digits = clean.replaceAll(RegExp(r'\D'), '');
  if (clean.startsWith('+')) {
    return '+$digits';
  }
  if (digits.length == 10) {
    return '+1$digits';
  }
  return '+$digits';
}

/// DTO for Step 2 Demographics: POST /api/v1/patients/onboarding/demographics
class DemographicsDto {
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String? bloodGroup;
  final String? address;

  const DemographicsDto({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.bloodGroup,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'dateOfBirth': dateOfBirth.trim(),
      'gender': gender.trim(),
    };
    if (bloodGroup != null &&
        bloodGroup!.isNotEmpty &&
        bloodGroup != BloodGroup.unknown) {
      map['bloodGroup'] = bloodGroup;
    }
    if (address != null && address!.isNotEmpty) {
      map['address'] = address!.trim();
    }
    return map;
  }

  factory DemographicsDto.fromJson(Map<String, dynamic> json) {
    return DemographicsDto(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String?,
      address: json['address'] as String?,
    );
  }
}

/// DTO for Step 3 Emergency Contact: POST /api/v1/patients/onboarding/emergency-contact
class EmergencyContactDto {
  final String name;
  final String relationship;
  final String phone;

  const EmergencyContactDto({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'relationship': relationship.trim(),
      'phone': normalizePhone(phone),
    };
  }

  factory EmergencyContactDto.fromJson(Map<String, dynamic> json) {
    return EmergencyContactDto(
      name: json['name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}

/// DTO for Medical Summary: PATCH /api/v1/patients/me/medical-summary
class MedicalSummaryDto {
  final String? bloodGroup;
  final List<String> knownAllergies;
  final List<String> chronicConditions;
  final List<String> disabilities;

  const MedicalSummaryDto({
    this.bloodGroup,
    this.knownAllergies = const [],
    this.chronicConditions = const [],
    this.disabilities = const [],
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'knownAllergies': knownAllergies,
      'chronicConditions': chronicConditions,
      'disabilities': disabilities,
    };
    if (bloodGroup != null &&
        bloodGroup!.isNotEmpty &&
        bloodGroup != BloodGroup.unknown) {
      map['bloodGroup'] = bloodGroup;
    }
    return map;
  }

  factory MedicalSummaryDto.fromJson(Map<String, dynamic> json) {
    return MedicalSummaryDto(
      bloodGroup: json['bloodGroup'] as String?,
      knownAllergies:
          (json['knownAllergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      chronicConditions:
          (json['chronicConditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      disabilities:
          (json['disabilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

/// Medication item entered during Health Info (Figma Frame 20:31065)
class MedicationItem {
  final String id;
  final String name;
  final String dosage;
  final String timing;

  const MedicationItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timing,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'dosage': dosage, 'timing': timing};
  }

  factory MedicationItem.fromJson(Map<String, dynamic> json) {
    return MedicationItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      timing: json['timing'] as String? ?? '',
    );
  }
}

/// Allergy item entered during Health Info (Figma Frame 20:31044)
class AllergyItem {
  final String id;
  final String name;
  final String? reaction;
  final String category; // 'Medication', 'Food', 'Environmental', 'Other'

  const AllergyItem({
    required this.id,
    required this.name,
    this.reaction,
    this.category = 'Medication',
  });

  String get displayTag {
    if (reaction != null && reaction!.isNotEmpty) {
      return '$name ($reaction)';
    }
    return name;
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'reaction': reaction, 'category': category};
  }

  factory AllergyItem.fromJson(Map<String, dynamic> json) {
    return AllergyItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      reaction: json['reaction'] as String?,
      category: json['category'] as String? ?? 'Medication',
    );
  }
}

/// Surgical or procedure history item (Figma Frame 20:31091)
class SurgeryProcedureItem {
  final String id;
  final String name;
  final String? year;
  final String? notes;

  const SurgeryProcedureItem({
    required this.id,
    required this.name,
    this.year,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'year': year, 'notes': notes};
  }

  factory SurgeryProcedureItem.fromJson(Map<String, dynamic> json) {
    return SurgeryProcedureItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      year: json['year'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// DTO for Onboarding Progress: GET /api/v1/patients/onboarding/progress
class OnboardingProgressDto {
  final int totalSteps;
  final int completedSteps;
  final int? currentStep;
  final bool isComplete;

  const OnboardingProgressDto({
    this.totalSteps = 6,
    this.completedSteps = 2,
    this.currentStep = 3,
    this.isComplete = false,
  });

  factory OnboardingProgressDto.fromJson(Map<String, dynamic> json) {
    return OnboardingProgressDto(
      totalSteps: (json['totalSteps'] as num?)?.toInt() ?? 6,
      completedSteps: (json['completedSteps'] as num?)?.toInt() ?? 2,
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 3,
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }
}
