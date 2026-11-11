import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/repositories/treatment_offer_repository.dart';
import 'health_card_screen.dart';
import '../../../../shared/widgets/primary_button.dart';

/// CareID Patient App — Treatment Offer Details Screen
/// Faithfully reproduces Figma Frame `20:26922` ("Care ID - Treatment Offer Details")
/// Supports:
/// - 20:27176 (Care ID - Offer Accepted Confirmation)
/// - 20:27613 (Care ID - Offer Rejected Confirmation)
/// - 20:27380 (Care ID - Cash Discount Options)
class TreatmentOfferDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> offer;
  final TreatmentOfferRepository? repository;

  const TreatmentOfferDetailsScreen({
    super.key,
    required this.offer,
    this.repository,
  });

  @override
  State<TreatmentOfferDetailsScreen> createState() =>
      _TreatmentOfferDetailsScreenState();
}

class _TreatmentOfferDetailsScreenState
    extends State<TreatmentOfferDetailsScreen> {
  late final TreatmentOfferRepository _repository;
  int _activeView = 0; // 0: Details, 1: Accepted, 2: Declined, 3: Cash Options
  String? _selectedDeclineReason;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? TreatmentOfferRepository();
  }

  Future<void> _handleAcceptOffer() async {
    final offerId = widget.offer['id']?.toString();
    if (offerId == null || offerId.isEmpty || offerId.startsWith('mock-')) {
      setState(() => _activeView = 1);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final res = await _repository.acceptTreatmentOffer(
        offerId: offerId,
        signatureConsent: true,
        patientResponseNotes: 'Patient approved clinical proposal via mobile app.',
        expectedVersion: widget.offer['version'] is int ? widget.offer['version'] as int : null,
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (res.isSuccess) {
          setState(() => _activeView = 1);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFDC2626),
              content: Text(res.messageOrNull ?? 'Unable to accept treatment offer.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Error accepting offer: $e'),
          ),
        );
      }
    }
  }

  Future<void> _handleDeclineOffer() async {
    final offerId = widget.offer['id']?.toString();
    if (offerId == null || offerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Invalid offer identifier. Unable to decline.'),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final res = await _repository.rejectTreatmentOffer(
        offerId: offerId,
        declineReason: _selectedDeclineReason ?? 'Seeking second medical opinion',
        expectedVersion: widget.offer['version'] is int ? widget.offer['version'] as int : null,
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (res.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Treatment offer declined. Feedback recorded.')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFDC2626),
              content: Text(res.messageOrNull ?? 'Unable to decline treatment offer.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Error declining offer: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeView == 1) {
      return _buildAcceptedView();
    } else if (_activeView == 2) {
      return _buildDeclinedView();
    } else if (_activeView == 3) {
      return _buildCashOptionsView();
    }
    return _buildDetailsView();
  }

  // --- FIGMA FRAME 20:26922: Treatment Offer Details ---
  Widget _buildDetailsView() {
    final String title = (widget.offer['title'] ?? 'Comprehensive Dental Restoration & Scaling').toString();
    final standardPrice = widget.offer['standardPrice'] ?? 1450.0;
    final careIdPrice = widget.offer['careIdPrice'] ?? 920.0;
    final savings = widget.offer['savings'] ?? (standardPrice - careIdPrice);
    final monthlyRate = widget.offer['monthlyRate'] ?? 76.67;
    final tenure = widget.offer['tenure'] ?? 12;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE7ECF6))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: const Color(0xFF0B1C30),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Offer Details',
                    style: AppTypography.heading2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1C30),
                    ),
                  ),
                  const Spacer(),
                  const CareIdLogo(height: 24),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Countdown / Expiration Delight Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4E3FC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF155EEF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pre-negotiated Care ID rate reserved for 48 hours',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF155EEF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Treatment & Provider Hero Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B14B8), Color(0xFF7A29E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x335B14B8),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.verified_outlined, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'City Dental Care • Dr. Julian Vance, DDS',
                                      style: AppTypography.heading2.copyWith(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'In-Network Preferred Care ID Partner',
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: AppTypography.heading1.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  'Save \$${savings.toString()}',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  '0% APR Financing Available',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cost & Discount Breakdown Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cost Breakdown',
                            style: AppTypography.heading2.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildCostRow('Standard Out-of-Pocket Rate', '\$$standardPrice', isStrikethrough: true),
                          const SizedBox(height: 8),
                          _buildCostRow('Care ID Negotiated Discount', '-\$$savings', isGreen: true),
                          const SizedBox(height: 8),
                          _buildCostRow('Estimated Insurance Contribution', '-\$${(standardPrice * 0.4).toStringAsFixed(0)}', isGreen: true),
                          const Divider(height: 24),
                          _buildCostRow('Final Net Payable Rate', '\$$careIdPrice', isBold: true),
                          const SizedBox(height: 8),
                          Text(
                            'Or as low as \$$monthlyRate/mo for $tenure months with zero interest.',
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Clinical Scope Included Bento Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clinical Scope Included',
                            style: AppTypography.heading2.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildScopeItem(
                            'Quadrant Deep Scaling & Root Planing',
                            'Full 4-quadrant subgingival ultrasonic removal of calculus and bacterial deposits.',
                          ),
                          const SizedBox(height: 10),
                          _buildScopeItem(
                            'Composite Resin Restoration (#14 & #19)',
                            'Multi-surface aesthetic shade-matched dental composite with enamel curing.',
                          ),
                          const SizedBox(height: 10),
                          _buildScopeItem(
                            'High-Fluoride Remineralization Therapy',
                            'Enamel matrix desensitizing varnish application.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    PrimaryButton(
                      label: 'Accept Offer & Lock In Rate',
                      onPressed: _isSubmitting ? null : _handleAcceptOffer,
                      isLoading: _isSubmitting,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _activeView = 3),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF155EEF),
                          side: const BorderSide(color: Color(0xFFD4E3FC)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Pay Upfront with Cash Discount Options',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _activeView = 2),
                        child: const Text(
                          'Decline This Treatment Offer',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FIGMA FRAME 20:27176: Care ID - Offer Accepted Confirmation ---
  Widget _buildAcceptedView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Success Badge
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Offer Accepted!',
                style: AppTypography.heading1.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your discounted treatment rate has been confirmed and locked.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular.copyWith(
                  color: const Color(0xFF494552),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),

              // What to Expect / Next Steps Accordion Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What Happens Next',
                      style: AppTypography.heading2.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B1C30),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStepRow(
                      '1',
                      'Clinic Notified',
                      'The clinic billing desk at City Dental Care has received your accepted voucher.',
                    ),
                    const SizedBox(height: 14),
                    _buildStepRow(
                      '2',
                      'Voucher Synchronized',
                      'Your Care ID records vault has updated with your active rate contract.',
                    ),
                    const SizedBox(height: 14),
                    _buildStepRow(
                      '3',
                      'Present Health Card',
                      'Scan your Digital Health Card QR at arrival kiosk for instant check-in.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'View Digital Health Card',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const HealthCardScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Color(0xFF0B1C30),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FIGMA FRAME 20:27613: Care ID - Offer Rejected Confirmation ---
  Widget _buildDeclinedView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.remove_circle_outline_rounded, color: Color(0xFF6B7280), size: 36),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Offer Declined',
                style: AppTypography.heading1.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We understand that healthcare decisions are personal. Your regular insurance coverage remains active.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Feedback Reasons
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Help us improve: Why did you decline?',
                  style: AppTypography.heading2.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...[
                'Rate higher than expected',
                'Seeking second medical opinion',
                'Scheduling or location conflict',
                'Decided on alternative treatment',
              ].map((reason) {
                final isSelected = _selectedDeclineReason == reason;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedDeclineReason = reason),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF155EEF) : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                            size: 18,
                            color: isSelected ? const Color(0xFF155EEF) : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: const Color(0xFF0B1C30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Confirm & Return to Offers',
                onPressed: _isSubmitting ? null : _handleDeclineOffer,
                isLoading: _isSubmitting,
                backgroundColor: const Color(0xFF0B1C30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FIGMA FRAME 20:27380: Care ID - Cash Discount Options ---
  Widget _buildCashOptionsView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE7ECF6))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: const Color(0xFF0B1C30),
                    onPressed: () => setState(() => _activeView = 0),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cash Discount Options',
                    style: AppTypography.heading2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1C30),
                    ),
                  ),
                  const Spacer(),
                  const CareIdLogo(height: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4E3FC)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.savings_outlined, color: Color(0xFF155EEF), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Zero Financing Fees',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF0B1C30),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Cash discounts are pre-negotiated provider rates that require no financing or interest fees.',
                                  style: AppTypography.caption.copyWith(
                                    color: const Color(0xFF494552),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Tier 1: Full Upfront Cash
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF5B14B8), width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x145B14B8),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5B14B8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'HIGHEST SAVINGS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const Text(
                                'Save \$640.00',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Full Upfront Cash Payment',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pay directly at clinical check-in desk via debit, cash, or HSA/FSA.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '\$810.00',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0B1C30),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '\$1,450.00 standard',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: 'Select Cash Tier & Lock Voucher',
                            onPressed: () => setState(() => _activeView = 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tier 2: Two-Part Milestone
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '2-Part Milestone Split',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '50% upfront at visit 1, remaining 50% upon final restoration.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '2 payments of \$445.00 (Total \$890.00)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => setState(() => _activeView = 1),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0B1C30),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Select 2-Part Milestone'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isStrikethrough = false, bool isGreen = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isBold ? const Color(0xFF0B1C30) : const Color(0xFF494552),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isGreen
                ? const Color(0xFF10B981)
                : (isBold ? const Color(0xFF0B1C30) : const Color(0xFF494552)),
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildScopeItem(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(String stepNum, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF5B14B8),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNum,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
