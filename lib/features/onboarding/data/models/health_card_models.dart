/// CareID Health Card Data Transfer Models
/// Grounded strictly in OpenAPI 3.0.0 specification from https://360api.vnvision.in/docs.
class HealthCardDto {
  final String? id;
  final String? patientProfileId;
  final String? cardNumber;
  final String? status;
  final String? qrPayload;
  final String? issuedAt;
  final String? expiresAt;
  final bool emergencyFlag;

  const HealthCardDto({
    this.id,
    this.patientProfileId,
    this.cardNumber,
    this.status,
    this.qrPayload,
    this.issuedAt,
    this.expiresAt,
    this.emergencyFlag = false,
  });

  factory HealthCardDto.fromJson(Map<String, dynamic> json) {
    return HealthCardDto(
      id: json['id'] as String?,
      patientProfileId: json['patientProfileId'] as String?,
      cardNumber: json['cardNumber'] as String?,
      status: json['status'] as String?,
      qrPayload: json['qrPayload'] as String?,
      issuedAt: json['issuedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      emergencyFlag: json['emergencyFlag'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (patientProfileId != null) 'patientProfileId': patientProfileId,
      if (cardNumber != null) 'cardNumber': cardNumber,
      if (status != null) 'status': status,
      if (qrPayload != null) 'qrPayload': qrPayload,
      if (issuedAt != null) 'issuedAt': issuedAt,
      if (expiresAt != null) 'expiresAt': expiresAt,
      'emergencyFlag': emergencyFlag,
    };
  }
}
