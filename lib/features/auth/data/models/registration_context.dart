/// CareID Patient App — Registration Context
/// Secure continuation data object passed across onboarding steps
/// (from Create Account [Frame 20:30644] -> Mobile OTP [Frame 20:30756] -> Health Info [Frame 20:30900] -> Insurance [Frame 20:33068]).
class RegistrationContext {
  final String fullName;
  final String phone;
  final String email;
  final String? profileId;
  final String? patientNumber;
  final String? status;
  final int onboardingStep;
  final String? challengeId;

  // Health Information & Demographics (Step 3)
  final String? bloodGroup;
  final double? height;
  final String? heightUnit; // 'cm' or 'ft'
  final double? weight;
  final String? weightUnit; // 'kg' or 'lb'
  final List<String> chronicConditions;
  final List<String> knownAllergies;
  final List<String> currentMedications;
  final List<String> surgeries;
  final List<String> familyHistory;
  final String? dateOfBirth;
  final String? gender;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;

  // Insurance Information (Step 4)
  final String? insuranceProvider;
  final String? insuranceMemberId;
  final String? insuranceGroupNumber;
  final String? insuranceCardFrontPath;
  final bool isInsuranceSkipped;

  const RegistrationContext({
    required this.fullName,
    required this.phone,
    required this.email,
    this.profileId,
    this.patientNumber,
    this.status,
    this.onboardingStep = 1,
    this.challengeId,
    this.bloodGroup,
    this.height,
    this.heightUnit = 'cm',
    this.weight,
    this.weightUnit = 'kg',
    this.chronicConditions = const [],
    this.knownAllergies = const [],
    this.currentMedications = const [],
    this.surgeries = const [],
    this.familyHistory = const [],
    this.dateOfBirth,
    this.gender,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.insuranceProvider,
    this.insuranceMemberId,
    this.insuranceGroupNumber,
    this.insuranceCardFrontPath,
    this.isInsuranceSkipped = false,
  });

  bool get hasInsurance =>
      insuranceProvider != null &&
      insuranceMemberId != null &&
      !isInsuranceSkipped;

  /// Formatted masked phone display (e.g. +1 (•••) •••-2671).
  String get maskedPhone {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      final last4 = digits.substring(digits.length - 4);
      final country = digits.length > 10
          ? '+${digits.substring(0, digits.length - 10)} '
          : '+1 ';
      return '$country(•••) •••-$last4';
    }
    return phone;
  }

  RegistrationContext copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? profileId,
    String? patientNumber,
    String? status,
    int? onboardingStep,
    String? challengeId,
    String? bloodGroup,
    double? height,
    String? heightUnit,
    double? weight,
    String? weightUnit,
    List<String>? chronicConditions,
    List<String>? knownAllergies,
    List<String>? currentMedications,
    List<String>? surgeries,
    List<String>? familyHistory,
    String? dateOfBirth,
    String? gender,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
    String? insuranceProvider,
    String? insuranceMemberId,
    String? insuranceGroupNumber,
    String? insuranceCardFrontPath,
    bool? isInsuranceSkipped,
  }) {
    return RegistrationContext(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileId: profileId ?? this.profileId,
      patientNumber: patientNumber ?? this.patientNumber,
      status: status ?? this.status,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      challengeId: challengeId ?? this.challengeId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      height: height ?? this.height,
      heightUnit: heightUnit ?? this.heightUnit,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      knownAllergies: knownAllergies ?? this.knownAllergies,
      currentMedications: currentMedications ?? this.currentMedications,
      surgeries: surgeries ?? this.surgeries,
      familyHistory: familyHistory ?? this.familyHistory,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelationship:
          emergencyContactRelationship ?? this.emergencyContactRelationship,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceMemberId: insuranceMemberId ?? this.insuranceMemberId,
      insuranceGroupNumber: insuranceGroupNumber ?? this.insuranceGroupNumber,
      insuranceCardFrontPath:
          insuranceCardFrontPath ?? this.insuranceCardFrontPath,
      isInsuranceSkipped: isInsuranceSkipped ?? this.isInsuranceSkipped,
    );
  }

  @override
  String toString() {
    return 'RegistrationContext(patientNumber: $patientNumber, step: $onboardingStep, bloodGroup: $bloodGroup)';
  }
}
