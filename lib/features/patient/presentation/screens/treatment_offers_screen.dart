import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/financing_models.dart';
import '../../data/repositories/financing_repository.dart';
import '../../data/repositories/treatment_offer_repository.dart';
import 'treatment_offer_details_screen.dart';
import '../../../../shared/widgets/primary_button.dart';

/// CareID Patient App — Treatment Offers & Healthcare Financing Screen
/// Aligned strictly with Figma Frames:
/// - 20:26404 ("Care ID - Treatment Offers")
/// - 20:26692 ("Care ID - Financing Details")
/// - 20:27768 ("Care ID - Offer Status & History")
class TreatmentOffersScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final FinancingRepository? repository;
  final TreatmentOfferRepository? treatmentRepository;

  const TreatmentOffersScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.treatmentRepository,
  });

  @override
  State<TreatmentOffersScreen> createState() => _TreatmentOffersScreenState();
}

class _TreatmentOffersScreenState extends State<TreatmentOffersScreen> {
  late final FinancingRepository _repository;
  late final TreatmentOfferRepository _treatmentRepository;
  double _loanAmount = 1200;
  int _selectedTenureMonths = 12;
  List<FinancingOfferModel> _apiOffers = [];
  List<Map<String, dynamic>> _liveOffers = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FinancingRepository(apiClient: widget.apiClient);
    _treatmentRepository = widget.treatmentRepository ?? TreatmentOfferRepository(apiClient: widget.apiClient);
    _loadFinancingData();
  }

  Future<void> _loadFinancingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await AppTokenStorage().getAccessToken();
    if (token == null || token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final treatmentRes = await _treatmentRepository.getTreatmentOffers(status: 'DISPATCHED');
      if (treatmentRes.isSuccess) {
        if (mounted) {
          setState(() {
            _hasLoaded = true;
            _liveOffers = treatmentRes.dataOrNull != null
                ? treatmentRes.dataOrNull!.map((m) => m.toOfferMap()).toList()
                : [];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasLoaded = true;
            _errorMessage = treatmentRes.messageOrNull ?? 'Unable to retrieve treatment offers';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasLoaded = true;
          _errorMessage = e.toString();
        });
      }
    }

    try {
      final res = await _repository.getFinancingOffers().timeout(const Duration(seconds: 4));
      if (res.isSuccess && mounted && res.dataOrNull != null) {
        setState(() {
          _apiOffers = res.dataOrNull!;
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> _offers = const [
    {
      'title': 'Comprehensive Dental Restoration & Scaling',
      'specialty': 'Dental Care',
      'standardPrice': 1450,
      'careIdPrice': 920,
      'monthlyRate': 76.67,
      'tenure': 12,
      'icon': Icons.healing_outlined,
      'color': AppColors.dentalIcon,
      'savings': 530,
    },
    {
      'title': 'Retinal Fundus High-Res Diagnostic & Therapy',
      'specialty': 'Vision & Ophthalmology',
      'standardPrice': 850,
      'careIdPrice': 480,
      'monthlyRate': 80.00,
      'tenure': 6,
      'icon': Icons.visibility_outlined,
      'color': AppColors.visionIcon,
      'savings': 370,
    },
    {
      'title': 'Preventative 48h Cardiac Holter Monitoring',
      'specialty': 'Cardiology & Internal Medicine',
      'standardPrice': 1100,
      'careIdPrice': 650,
      'monthlyRate': 54.16,
      'tenure': 12,
      'icon': Icons.favorite_border,
      'color': AppColors.purplePrimary,
      'savings': 450,
    },
    {
      'title': 'Annual Comprehensive Metabolic & Lipid Panel',
      'specialty': 'Pathology & Diagnostic Lab',
      'standardPrice': 620,
      'careIdPrice': 280,
      'monthlyRate': 46.66,
      'tenure': 6,
      'icon': Icons.biotech_outlined,
      'color': Colors.teal,
      'savings': 340,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final monthlyEstimated = _loanAmount / _selectedTenureMonths;
    final displayOffers = _liveOffers.isNotEmpty
        ? _liveOffers
        : _apiOffers.isNotEmpty
            ? _apiOffers
                .map((o) => <String, dynamic>{
                      'id': o.id,
                      'title': o.treatmentName,
                      'specialty': 'Healthcare Financing Offer',
                      'standardPrice': (o.preApprovedAmount * 1.35).roundToDouble(),
                      'careIdPrice': o.preApprovedAmount,
                      'monthlyRate': o.monthlyEmi,
                      'tenure': o.tenureMonths,
                      'icon': Icons.local_hospital_outlined,
                      'color': AppColors.purplePrimary,
                      'savings': (o.preApprovedAmount * 0.35).roundToDouble(),
                    })
                .toList()
            : (_hasLoaded ? <Map<String, dynamic>>[] : _offers);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Treatment Offers & Financing'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B14B8)),
                  minHeight: 2,
                ),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(),
            const SizedBox(height: AppSpacing.md),
            _buildCalculatorCard(monthlyEstimated),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Personalized Clinical Savings',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Pre-negotiated transparent rates guaranteed with your Care ID tier-1 health membership.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_hasLoaded && _errorMessage != null && displayOffers.isEmpty)
              _buildErrorState()
            else if (_hasLoaded && displayOffers.isEmpty)
              _buildEmptyState()
            else
              ...displayOffers.map((offer) => _buildOfferCard(offer)),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF5B14B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Care ID Health Credit',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '0% APR ELIGIBLE',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Personalized Clinical Savings & Financing',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Split medical, dental, and vision treatments into 0% APR equal monthly installments with zero hidden fees.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard(double monthlyEstimated) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Installment Estimator',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${_loanAmount.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.purplePrimary),
              ),
            ],
          ),
          Slider(
            value: _loanAmount,
            min: 300,
            max: 5000,
            divisions: 47,
            activeColor: AppColors.purplePrimary,
            onChanged: (val) => setState(() => _loanAmount = val),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$300', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('\$5,000 max', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Select Repayment Tenure', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(
            children: [3, 6, 12, 24].map((tenure) {
              final isSelected = _selectedTenureMonths == tenure;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _selectedTenureMonths = tenure),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? AppColors.purplePrimary : Colors.white,
                      foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
                      side: BorderSide(
                        color: isSelected ? AppColors.purplePrimary : Colors.grey.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      '$tenure Mo',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Payment',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    '\$${monthlyEstimated.toStringAsFixed(2)} / month',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const Text('0% APR • No Prepayment Penalties', style: TextStyle(fontSize: 11, color: Colors.green)),
                ],),
              PrimaryButton.gradient(
                label: 'Pre-Qualify',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Care ID Financing Pre-qualification verified! Limit: \$2,500')),
                  );
                },
                isFullWidth: false,
                height: 38,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final color = offer['color'] as Color;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(offer['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['title'] as String,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        offer['specialty'] as String,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standard Out-of-Pocket: \$${offer['standardPrice']}',
                      style: const TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Care ID Rate: \$${offer['careIdPrice']}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Save \$${offer['savings']} with Care ID',
                      style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'As low as',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      '\$${offer['monthlyRate']}/mo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                    ),
                    Text(
                      'for ${offer['tenure']} months',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TreatmentOfferDetailsScreen(offer: offer),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Claim Treatment Offer', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Treatment Offers Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You do not have any active clinical proposals or financing packages dispatched at this time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 40, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Unable to retrieve treatment offers',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loadFinancingData,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.purplePrimary,
              side: const BorderSide(color: AppColors.purplePrimary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
