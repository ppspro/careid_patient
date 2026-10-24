/// Matches RegisterPatientResponseDto from CareID OpenAPI specification.
/// Endpoint: POST /api/v1/patients/register
class PatientRegistrationDraft {
  final String profileId;
  final String patientNumber;
  final String status;
  final int onboardingStep;

  const PatientRegistrationDraft({
    required this.profileId,
    required this.patientNumber,
    required this.status,
    required this.onboardingStep,
  });

  factory PatientRegistrationDraft.fromJson(Map<String, dynamic> json) {
    return PatientRegistrationDraft(
      profileId: json['profileId']?.toString() ?? '',
      patientNumber: json['patientNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? 'DRAFT',
      onboardingStep: (json['onboardingStep'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'patientNumber': patientNumber,
      'status': status,
      'onboardingStep': onboardingStep,
    };
  }
}
