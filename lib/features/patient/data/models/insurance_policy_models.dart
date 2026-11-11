export '../../../onboarding/data/models/insurance_models.dart';

/// CareID Insurance Policy & Claims Data Models
/// Grounded in OpenAPI 3.0.0 and Postman Collection for `19. Insurance Platform & Claims`
class InsurancePolicyDto {
  final String id;
  final String? patientProfileId;
  final String providerName;
  final String policyNumber;
  final String? groupNumber;
  final String? planName;
  final String status; // ACTIVE, PENDING, EXPIRED, SUSPENDED
  final String? validFrom;
  final String? validThru;
  final String? coverageDetails;
  final String? cardFrontImageUrl;

  const InsurancePolicyDto({
    required this.id,
    this.patientProfileId,
    required this.providerName,
    required this.policyNumber,
    this.groupNumber,
    this.planName,
    this.status = 'ACTIVE',
    this.validFrom,
    this.validThru,
    this.coverageDetails,
    this.cardFrontImageUrl,
  });

  factory InsurancePolicyDto.fromJson(Map<String, dynamic> json) {
    return InsurancePolicyDto(
      id: json['id']?.toString() ?? '',
      patientProfileId: json['patientProfileId']?.toString(),
      providerName: json['providerName']?.toString() ?? 'Insurance Provider',
      policyNumber: json['policyNumber']?.toString() ?? '',
      groupNumber: json['groupNumber']?.toString() ?? json['group']?.toString(),
      planName: json['planName']?.toString() ?? json['plan']?['name']?.toString(),
      status: (json['status']?.toString() ?? 'ACTIVE').toUpperCase(),
      validFrom: json['validFrom']?.toString() ?? json['startDate']?.toString(),
      validThru: json['validThru']?.toString() ?? json['endDate']?.toString(),
      coverageDetails: json['coverageDetails']?.toString(),
      cardFrontImageUrl: json['cardFrontImageUrl']?.toString() ?? json['cardImageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'providerName': providerName,
    'policyNumber': policyNumber,
    if (groupNumber != null) 'groupNumber': groupNumber,
    if (coverageDetails != null) 'coverageDetails': coverageDetails,
    'status': status,
  };
}

class InsuranceClaimDto {
  final String id;
  final String? claimNumber;
  final String? providerName;
  final String status; // DRAFT, SUBMITTED, APPROVED, REJECTED
  final double? amount;
  final String? createdAt;
  final String? description;

  const InsuranceClaimDto({
    required this.id,
    this.claimNumber,
    this.providerName,
    this.status = 'SUBMITTED',
    this.amount,
    this.createdAt,
    this.description,
  });

  factory InsuranceClaimDto.fromJson(Map<String, dynamic> json) {
    return InsuranceClaimDto(
      id: json['id']?.toString() ?? '',
      claimNumber: json['claimNumber']?.toString() ?? 'CLM-${json['id']?.toString().substring(0, 6)}',
      providerName: json['providerName']?.toString() ?? 'Primary Carrier',
      status: (json['status']?.toString() ?? 'SUBMITTED').toUpperCase(),
      amount: (json['amount'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble(),
      createdAt: json['createdAt']?.toString(),
      description: json['description']?.toString() ?? json['diagnosis']?.toString(),
    );
  }
}

