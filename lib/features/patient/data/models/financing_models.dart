/// CareID Patient App — Healthcare Financing Models
/// Grounded in OpenAPI 3.0.0 and Postman Collection Folder 27
class FinancingOptionDto {
  final String id;
  final String partnerName;
  final String planName;
  final double interestRate;
  final int minTenureMonths;
  final int maxTenureMonths;
  final double maxCreditAmount;
  final String processingFeePercentage;
  final bool isZeroInterest;
  final String? termsAndConditionsUrl;
  final String? logoAsset;

  const FinancingOptionDto({
    required this.id,
    required this.partnerName,
    required this.planName,
    this.interestRate = 0.0,
    this.minTenureMonths = 3,
    this.maxTenureMonths = 24,
    this.maxCreditAmount = 50000.0,
    this.processingFeePercentage = '0%',
    this.isZeroInterest = true,
    this.termsAndConditionsUrl,
    this.logoAsset,
  });

  factory FinancingOptionDto.fromJson(Map<String, dynamic> json) {
    return FinancingOptionDto(
      id: json['id']?.toString() ?? '',
      partnerName: json['partnerName']?.toString() ?? json['partner']?.toString() ?? 'CareFinance Partner',
      planName: json['planName']?.toString() ?? json['title']?.toString() ?? '0% Interest Healthcare Plan',
      interestRate: (json['interestRate'] is num) ? (json['interestRate'] as num).toDouble() : 0.0,
      minTenureMonths: json['minTenureMonths'] is int ? json['minTenureMonths'] as int : 3,
      maxTenureMonths: json['maxTenureMonths'] is int ? json['maxTenureMonths'] as int : 24,
      maxCreditAmount: (json['maxCreditAmount'] is num) ? (json['maxCreditAmount'] as num).toDouble() : 50000.0,
      processingFeePercentage: json['processingFeePercentage']?.toString() ?? '0%',
      isZeroInterest: json['isZeroInterest'] == true || (json['interestRate'] == 0),
      termsAndConditionsUrl: json['termsAndConditionsUrl']?.toString(),
      logoAsset: json['logoAsset']?.toString(),
    );
  }
}

class FinancingOfferDto {
  final String id;
  final String partnerName;
  final String treatmentCategory;
  final double approvedAmount;
  final double monthlyEmi;
  final int tenureMonths;
  final double apr;
  final String status; // PRE_APPROVED, APPLIED, ACCEPTED, REJECTED
  final String validUntil;

  const FinancingOfferDto({
    required this.id,
    required this.partnerName,
    required this.treatmentCategory,
    required this.approvedAmount,
    required this.monthlyEmi,
    required this.tenureMonths,
    this.apr = 0.0,
    this.status = 'PRE_APPROVED',
    this.validUntil = '2026-12-31',
  });

  String get treatmentName => treatmentCategory;
  double get preApprovedAmount => approvedAmount;

  factory FinancingOfferDto.fromJson(Map<String, dynamic> json) {
    return FinancingOfferDto(
      id: json['id']?.toString() ?? '',
      partnerName: json['partnerName']?.toString() ?? json['partner']?.toString() ?? 'CarePay Financial',
      treatmentCategory: json['treatmentCategory']?.toString() ?? json['category']?.toString() ?? 'Dental & Vision Care',
      approvedAmount: (json['approvedAmount'] is num) ? (json['approvedAmount'] as num).toDouble() : 3500.0,
      monthlyEmi: (json['monthlyEmi'] is num) ? (json['monthlyEmi'] as num).toDouble() : 291.66,
      tenureMonths: json['tenureMonths'] is int ? json['tenureMonths'] as int : 12,
      apr: (json['apr'] is num) ? (json['apr'] as num).toDouble() : 0.0,
      status: json['status']?.toString() ?? 'PRE_APPROVED',
      validUntil: json['validUntil']?.toString() ?? '2026-12-31',
    );
  }
}

typedef FinancingOfferModel = FinancingOfferDto;

class FinancingOptionModel {
  final String id;
  final String name;
  final String partnerName;
  final double minAmount;
  final double maxAmount;
  final double interestRate;
  final List<int> availableTenures;
  final bool isActive;

  const FinancingOptionModel({
    required this.id,
    required this.name,
    required this.partnerName,
    required this.minAmount,
    required this.maxAmount,
    required this.interestRate,
    required this.availableTenures,
    this.isActive = true,
  });

  factory FinancingOptionModel.fromJson(Map<String, dynamic> json) {
    return FinancingOptionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      partnerName: json['partnerName']?.toString() ?? '',
      minAmount: (json['minAmount'] as num?)?.toDouble() ?? 0.0,
      maxAmount: (json['maxAmount'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      availableTenures: (json['availableTenures'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class FinancingApplicationModel {
  final String id;
  final String optionId;
  final String treatmentName;
  final double requestedAmount;
  final int tenureMonths;
  final String notes;

  const FinancingApplicationModel({
    required this.id,
    required this.optionId,
    required this.treatmentName,
    required this.requestedAmount,
    required this.tenureMonths,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'optionId': optionId,
      'treatmentName': treatmentName,
      'requestedAmount': requestedAmount,
      'tenureMonths': tenureMonths,
      'notes': notes,
    };
  }

  factory FinancingApplicationModel.fromJson(Map<String, dynamic> json) {
    return FinancingApplicationModel(
      id: json['id']?.toString() ?? '',
      optionId: json['optionId']?.toString() ?? '',
      treatmentName: json['treatmentName']?.toString() ?? '',
      requestedAmount: (json['requestedAmount'] as num?)?.toDouble() ?? 0.0,
      tenureMonths: (json['tenureMonths'] as num?)?.toInt() ?? 12,
      notes: json['notes']?.toString() ?? '',
    );
  }
}
