/// CareID Patient App — Privacy & Consents Models & DTOs
/// Grounded strictly in Figma Frame 20:31164 ("Privacy & Consents", Step 5 of 6)
/// and the OpenAPI 3.0.0 specification from https://360api.vnvision.in/docs.
class PrivacyConsentsDto {
  final bool termsOfServiceAccepted;
  final bool privacyPolicyAccepted;
  final bool healthVaultStorageEnabled;
  final bool shareWithHealthcareProviders;
  final bool productUpdatesMarketing;
  final bool clinicalAppointmentReminders;
  final bool securityAlertsAcknowledged;
  final String? consentTimestamp;

  const PrivacyConsentsDto({
    required this.termsOfServiceAccepted,
    required this.privacyPolicyAccepted,
    this.healthVaultStorageEnabled = true,
    this.shareWithHealthcareProviders = true,
    this.productUpdatesMarketing = false,
    this.clinicalAppointmentReminders = true,
    this.securityAlertsAcknowledged = true,
    this.consentTimestamp,
  });

  /// Factory constructor to hydrate from JSON if needed.
  factory PrivacyConsentsDto.fromJson(Map<String, dynamic> json) {
    return PrivacyConsentsDto(
      termsOfServiceAccepted: json['termsOfServiceAccepted'] as bool? ?? false,
      privacyPolicyAccepted: json['privacyPolicyAccepted'] as bool? ?? false,
      healthVaultStorageEnabled:
          json['healthVaultStorageEnabled'] as bool? ?? true,
      shareWithHealthcareProviders:
          json['shareWithHealthcareProviders'] as bool? ?? true,
      productUpdatesMarketing:
          json['productUpdatesMarketing'] as bool? ?? false,
      clinicalAppointmentReminders:
          json['clinicalAppointmentReminders'] as bool? ?? true,
      securityAlertsAcknowledged:
          json['securityAlertsAcknowledged'] as bool? ?? true,
      consentTimestamp: json['consentTimestamp'] as String?,
    );
  }

  /// Converts to standard JSON payload aligned with CareID backend contracts.
  Map<String, dynamic> toJson() {
    return {
      'termsOfServiceAccepted': termsOfServiceAccepted,
      'privacyPolicyAccepted': privacyPolicyAccepted,
      'healthVaultStorageEnabled': healthVaultStorageEnabled,
      'shareWithHealthcareProviders': shareWithHealthcareProviders,
      'productUpdatesMarketing': productUpdatesMarketing,
      'clinicalAppointmentReminders': clinicalAppointmentReminders,
      'securityAlertsAcknowledged': securityAlertsAcknowledged,
      'consentTimestamp':
          consentTimestamp ?? DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Validates mandatory patient consents.
  /// Both Terms of Service and Privacy Policy acceptance are strictly required to proceed.
  String? validate({bool isEn = true}) {
    if (!termsOfServiceAccepted && !privacyPolicyAccepted) {
      return isEn
          ? 'Please review and accept both the Terms of Service and Privacy Policy.'
          : 'Por favor revisa y acepta tanto los Términos del Servicio como la Política de Privacidad.';
    }
    if (!termsOfServiceAccepted) {
      return isEn
          ? 'You must accept the Terms of Service to continue.'
          : 'Debes aceptar los Términos del Servicio para continuar.';
    }
    if (!privacyPolicyAccepted) {
      return isEn
          ? 'You must accept the Privacy Policy to continue.'
          : 'Debes aceptar la Política de Privacidad para continuar.';
    }
    return null;
  }

  /// Returns true only when all mandatory consents are accepted.
  bool get isValid => termsOfServiceAccepted && privacyPolicyAccepted;

  /// Number of mandatory consents accepted (out of 2).
  int get mandatoryAcceptedCount {
    int count = 0;
    if (termsOfServiceAccepted) count++;
    if (privacyPolicyAccepted) count++;
    return count;
  }

  PrivacyConsentsDto copyWith({
    bool? termsOfServiceAccepted,
    bool? privacyPolicyAccepted,
    bool? healthVaultStorageEnabled,
    bool? shareWithHealthcareProviders,
    bool? productUpdatesMarketing,
    bool? clinicalAppointmentReminders,
    bool? securityAlertsAcknowledged,
    String? consentTimestamp,
  }) {
    return PrivacyConsentsDto(
      termsOfServiceAccepted:
          termsOfServiceAccepted ?? this.termsOfServiceAccepted,
      privacyPolicyAccepted:
          privacyPolicyAccepted ?? this.privacyPolicyAccepted,
      healthVaultStorageEnabled:
          healthVaultStorageEnabled ?? this.healthVaultStorageEnabled,
      shareWithHealthcareProviders:
          shareWithHealthcareProviders ?? this.shareWithHealthcareProviders,
      productUpdatesMarketing:
          productUpdatesMarketing ?? this.productUpdatesMarketing,
      clinicalAppointmentReminders:
          clinicalAppointmentReminders ?? this.clinicalAppointmentReminders,
      securityAlertsAcknowledged:
          securityAlertsAcknowledged ?? this.securityAlertsAcknowledged,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
    );
  }
}
