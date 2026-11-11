import '../models/insurance_domain_models.dart';

class MockInsuranceRepository {
  MockInsuranceRepository._();
  static final MockInsuranceRepository instance = MockInsuranceRepository._();

  InsurancePolicy _primaryPolicy = const InsurancePolicy(
    id: 'pol-001',
    providerName: 'BlueCross BlueShield PPO',
    memberName: 'Alexander J. Thompson',
    policyNumber: 'HVT-9923-X8',
    groupNumber: '12903-X',
    payerId: 'BCBS-GLOBAL-88',
    rxBin: '004336',
    rxPcn: 'ADV',
    rxGroup: 'RX992-P',
    planType: 'Individual PPO Premium',
    effectiveDate: 'January 01, 2024',
    expiryDate: '12 / 2026',
    deductibleAnnual: r'$250.00 / Year',
    totalBenefitsUsed: 1240.0,
    totalBenefitsMax: 5000.0,
    inpatientCoveragePercent: 95,
    prescriptionCoveragePercent: 80,
    isVerified: true,
    status: 'Active',
    emergencyPhone: '1-800-HEALTH-360',
  );

  InsurancePolicy get primaryPolicy => _primaryPolicy;

  void updatePrimaryPolicy(InsurancePolicy updated) {
    _primaryPolicy = updated;
  }

  final List<InsuranceActivityItem> _activities = [
    const InsuranceActivityItem(
      id: 'act-01',
      title: 'Policy Verified',
      description: 'Your BlueCross PPO was successfully re-verified.',
      timestamp: '2d ago',
      type: 'verified',
    ),
    const InsuranceActivityItem(
      id: 'act-02',
      title: 'New Claim Submitted',
      description: 'Annual physical exam claim #920-X.',
      timestamp: '5d ago',
      type: 'claim',
    ),
    const InsuranceActivityItem(
      id: 'act-03',
      title: 'Details Updated',
      description: 'You updated the emergency contact info.',
      timestamp: '1w ago',
      type: 'updated',
    ),
  ];

  List<InsuranceActivityItem> get activities => List.unmodifiable(_activities);

  final List<TreatmentOfferItem> _treatmentOffers = [
    const TreatmentOfferItem(
      id: 'offer-01',
      category: 'Dental Plan',
      providerName: 'City Dental Care',
      title: 'Comprehensive Dental Restoration & Scaling',
      subtitle: 'City Dental Care • Dr. Vance',
      doctorAttribution: 'Recommended by Dr. Julian Vance, DDS',
      doctorAvatar: 'assets/images/06a82332265255b7f77a603775af37fac540e185.png',
      amount: 1572.50,
      originalAmount: 1850.0,
      discountBadge: '15% Direct Clinic Discount',
      status: 'Pending',
      validUntil: 'Nov 30, 2023',
      referenceCode: '#TX-88410',
    ),
    const TreatmentOfferItem(
      id: 'offer-02',
      category: 'Ophthalmology Care',
      providerName: 'VisionCare Specialists',
      title: 'Retinal Fundus High-Res Diagnostic & Treatment',
      subtitle: 'VisionCare Specialists',
      doctorAttribution: 'Care ID Partner • Dr. Laura Zhao, MD',
      doctorAvatar: 'assets/images/d2aa38af25a18eba089afd205f91ed218bf60c72.png',
      amount: 920.0,
      originalAmount: 920.0,
      discountBadge: '0% Interest 6-Month Financing',
      status: 'Pending',
      validUntil: 'Dec 10, 2023',
      monthlyInstallment: r'$153.33 / mo',
      referenceCode: '#TX-91024',
    ),
    const TreatmentOfferItem(
      id: 'offer-03',
      category: 'Pathology & Labs',
      providerName: "St. Mary's General Hospital",
      title: 'Annual Comprehensive Bloodwork Panel',
      subtitle: "St. Mary's General Hospital",
      doctorAttribution: 'Validated by Hospital Clinical Pathology Dept.',
      doctorAvatar: 'assets/images/c1c4a88cb83c006f5a654a6c44c94e6597802765.png',
      amount: 382.50,
      originalAmount: 450.0,
      discountBadge: '15% Prompt Cash Discount Applied',
      status: 'Accepted',
      validUntil: 'Oct 18, 2023',
      referenceCode: '#TX-77412',
    ),
    const TreatmentOfferItem(
      id: 'offer-04',
      category: 'Cardio Health',
      providerName: 'Metro Heart Institute',
      title: 'Preventative Holter Monitoring 48h',
      subtitle: 'Metro Heart Institute',
      doctorAttribution: 'Alternative therapy chosen by patient',
      doctorAvatar: 'assets/images/4ea3999e6f20b841c2216c2af09a17eb921e311a.png',
      amount: 620.0,
      originalAmount: 620.0,
      discountBadge: r'Original Estimate: $620.00',
      status: 'Declined',
      validUntil: 'Sep 04, 2023',
      referenceCode: '#TX-65109',
    ),
  ];

  List<TreatmentOfferItem> get treatmentOffers => List.unmodifiable(_treatmentOffers);

  final List<PartnerHospital> _partnerHospitals = [
    const PartnerHospital(
      id: 'hosp-01',
      name: 'Metro Health Academic Center',
      subtitle: 'Accepts 0% Financing & Direct Discounts',
      distance: '2.4 miles away • In-Network',
      imageAsset: 'assets/images/e99affd91b9cf73e272a31f7fb4c07a40f4cb10e.png',
    ),
  ];

  List<PartnerHospital> get partnerHospitals => List.unmodifiable(_partnerHospitals);

  final List<HistoricalOfferItem> _historicalOffers = [
    const HistoricalOfferItem(
      id: 'hist-1',
      title: 'Comprehensive Dental Restoration',
      clinic: 'City Dental Care',
      category: 'dental',
      status: 'Accepted',
      date: 'Oct 20, 2023',
      referenceCode: '#TRT-OFFER-8841',
      amount: 1522.50,
      savedAmount: 327.50,
      amountLabel: 'Total Amount',
    ),
    const HistoricalOfferItem(
      id: 'hist-2',
      title: 'Retinal Fundus High-Res Diagnostic',
      clinic: 'VisionCare Optometry',
      category: 'vision',
      status: 'Declined',
      date: 'Oct 14, 2023',
      referenceCode: '#OPT-8012',
      amount: 920.00,
      badgeText: 'Declined by Patient',
      amountLabel: 'Quoted Estimate',
    ),
    const HistoricalOfferItem(
      id: 'hist-3',
      title: 'Panoramic Radiography & Scaling',
      clinic: 'City Dental Care',
      category: 'dental',
      status: 'Completed',
      date: 'Sep 12, 2023',
      referenceCode: '#DEN-7390',
      amount: 382.50,
      badgeText: 'Cash Discount',
      amountLabel: 'Paid Total',
    ),
    const HistoricalOfferItem(
      id: 'hist-4',
      title: 'Physical Therapy Package',
      clinic: 'Metro Health Center',
      category: 'therapy',
      status: 'Expired',
      date: 'Aug 01, 2023',
      referenceCode: '#PT-6521',
      amount: 600.00,
      badgeText: 'Validity expired 30 days',
      amountLabel: 'Original Offer',
    ),
  ];

  List<HistoricalOfferItem> get historicalOffers => List.unmodifiable(_historicalOffers);
}

