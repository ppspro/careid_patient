/// Domain models for Phase 6: Insurance, Financing & Treatment Offers

class InsurancePolicy {
  final String id;
  final String providerName;
  final String memberName;
  final String policyNumber;
  final String groupNumber;
  final String payerId;
  final String rxBin;
  final String rxPcn;
  final String rxGroup;
  final String planType;
  final String effectiveDate;
  final String expiryDate;
  final String deductibleAnnual;
  final double totalBenefitsUsed;
  final double totalBenefitsMax;
  final int inpatientCoveragePercent;
  final int prescriptionCoveragePercent;
  final bool isVerified;
  final String status;
  final String emergencyPhone;

  const InsurancePolicy({
    required this.id,
    required this.providerName,
    required this.memberName,
    required this.policyNumber,
    required this.groupNumber,
    required this.payerId,
    required this.rxBin,
    required this.rxPcn,
    required this.rxGroup,
    required this.planType,
    required this.effectiveDate,
    required this.expiryDate,
    this.deductibleAnnual = r'$250.00 / Year',
    this.totalBenefitsUsed = 1240.0,
    this.totalBenefitsMax = 5000.0,
    this.inpatientCoveragePercent = 95,
    this.prescriptionCoveragePercent = 80,
    this.isVerified = true,
    this.status = 'Active',
    this.emergencyPhone = '1-800-HEALTH-360',
  });

  InsurancePolicy copyWith({
    String? id,
    String? providerName,
    String? memberName,
    String? policyNumber,
    String? groupNumber,
    String? payerId,
    String? rxBin,
    String? rxPcn,
    String? rxGroup,
    String? planType,
    String? effectiveDate,
    String? expiryDate,
    String? deductibleAnnual,
    double? totalBenefitsUsed,
    double? totalBenefitsMax,
    int? inpatientCoveragePercent,
    int? prescriptionCoveragePercent,
    bool? isVerified,
    String? status,
    String? emergencyPhone,
  }) {
    return InsurancePolicy(
      id: id ?? this.id,
      providerName: providerName ?? this.providerName,
      memberName: memberName ?? this.memberName,
      policyNumber: policyNumber ?? this.policyNumber,
      groupNumber: groupNumber ?? this.groupNumber,
      payerId: payerId ?? this.payerId,
      rxBin: rxBin ?? this.rxBin,
      rxPcn: rxPcn ?? this.rxPcn,
      rxGroup: rxGroup ?? this.rxGroup,
      planType: planType ?? this.planType,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      expiryDate: expiryDate ?? this.expiryDate,
      deductibleAnnual: deductibleAnnual ?? this.deductibleAnnual,
      totalBenefitsUsed: totalBenefitsUsed ?? this.totalBenefitsUsed,
      totalBenefitsMax: totalBenefitsMax ?? this.totalBenefitsMax,
      inpatientCoveragePercent: inpatientCoveragePercent ?? this.inpatientCoveragePercent,
      prescriptionCoveragePercent: prescriptionCoveragePercent ?? this.prescriptionCoveragePercent,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    );
  }
}

class InsuranceActivityItem {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final String type; // 'verified', 'claim', 'updated'

  const InsuranceActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });
}

class TreatmentOfferItem {
  final String id;
  final String category;
  final String providerName;
  final String title;
  final String subtitle;
  final String doctorAttribution;
  final String doctorAvatar;
  final double amount;
  final double originalAmount;
  final String discountBadge;
  final String status; // 'Pending', 'Accepted', 'Declined'
  final String validUntil;
  final String? monthlyInstallment;
  final String referenceCode;

  const TreatmentOfferItem({
    required this.id,
    this.category = 'Dental Plan',
    required this.providerName,
    required this.title,
    required this.subtitle,
    this.doctorAttribution = 'City Dental Care • Dr. Julian Vance, DDS',
    this.doctorAvatar = '',
    required this.amount,
    this.originalAmount = 1850.0,
    required this.discountBadge,
    this.status = 'Pending',
    this.validUntil = 'Nov 30, 2023',
    this.monthlyInstallment,
    this.referenceCode = '#TX-88410',
  });
}

class CashDiscountOption {
  final String id;
  final String title;
  final String description;
  final double standardRate;
  final double finalPrice;
  final double savingsAmount;
  final int discountPercent;
  final List<String> acceptedChannels;
  final bool isFeatured;

  const CashDiscountOption({
    required this.id,
    required this.title,
    required this.description,
    required this.standardRate,
    required this.finalPrice,
    required this.savingsAmount,
    required this.discountPercent,
    required this.acceptedChannels,
    this.isFeatured = false,
  });
}

class FinancingPlan {
  final String id;
  final String planName;
  final double monthlyAmount;
  final int termMonths;
  final double apr;
  final double totalFinanced;
  final double downPayment;
  final String treatmentTitle;
  final String clinicName;

  const FinancingPlan({
    required this.id,
    this.planName = '0% APR Interest-Free',
    required this.monthlyAmount,
    this.termMonths = 12,
    this.apr = 0.0,
    required this.totalFinanced,
    this.downPayment = 0.0,
    this.treatmentTitle = 'Dental Implant & Crown',
    this.clinicName = 'City Dental Care • Dr. A. Morgan',
  });
}

class PartnerHospital {
  final String id;
  final String name;
  final String subtitle;
  final String distance;
  final String imageAsset;

  const PartnerHospital({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.distance,
    required this.imageAsset,
  });
}

class HistoricalOfferItem {
  final String id;
  final String title;
  final String clinic;
  final String category; // 'dental', 'vision', 'therapy'
  final String status; // 'Accepted', 'Declined', 'Completed', 'Expired'
  final String date;
  final String referenceCode;
  final double amount;
  final double? savedAmount;
  final double? originalAmount;
  final String? badgeText;
  final String amountLabel;

  const HistoricalOfferItem({
    required this.id,
    required this.title,
    required this.clinic,
    required this.category,
    required this.status,
    required this.date,
    required this.referenceCode,
    required this.amount,
    this.savedAmount,
    this.originalAmount,
    this.badgeText,
    this.amountLabel = 'Total Amount',
  });
}


