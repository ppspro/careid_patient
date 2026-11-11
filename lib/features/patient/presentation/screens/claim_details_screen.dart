import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/insurance_policy_models.dart';

/// CareID Patient App — Insurance Claim Details Screen
/// Aligned strictly with Figma Frame `20:20158` ("Section - Activity & Claims List")
class ClaimDetailsScreen extends StatelessWidget {
  final InsuranceClaimDto claim;

  const ClaimDetailsScreen({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    final status = claim.status.toUpperCase();
    final isApproved = status == 'APPROVED';
    final isPending = status == 'SUBMITTED' || status == 'UNDER_REVIEW';

    final totalAmount = claim.amount ?? 420.00;
    final coveredAmount = totalAmount * 0.80;
    final copayAmount = totalAmount * 0.20;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Claim Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClaimHeader(totalAmount, isApproved, isPending),
            const SizedBox(height: AppSpacing.md),
            _buildAdjudicationTimeline(status),
            const SizedBox(height: AppSpacing.md),
            _buildFinancialBreakdown(totalAmount, coveredAmount, copayAmount),
            const SizedBox(height: AppSpacing.md),
            _buildLinkedEncounterCard(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Explanation of Benefits (EOB) PDF...')),
              );
            },
            icon: const Icon(Icons.download_outlined, color: AppColors.primary),
            label: const Text('Download Statement & EOB', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClaimHeader(double totalAmount, bool isApproved, bool isPending) {
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
                claim.claimNumber ?? 'CLM-2026-8819',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isApproved
                      ? Colors.green.shade50
                      : isPending
                          ? Colors.orange.shade50
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  claim.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isApproved
                        ? Colors.green.shade700
                        : isPending
                            ? Colors.orange.shade700
                            : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            claim.providerName ?? 'CareID Health Direct Network',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Billed Amount', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('\$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Filing Date', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(claim.createdAt ?? 'Oct 24, 2026', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdjudicationTimeline(String status) {
    final steps = ['Draft', 'Submitted', 'Under Review', 'Approved'];
    int activeIndex = status == 'APPROVED' ? 3 : status == 'UNDER_REVIEW' ? 2 : 1;

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
          Text(
            'Adjudication Status Tracker',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(steps.length, (index) {
              final isReached = index <= activeIndex;
              final isCurrent = index == activeIndex;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isReached ? AppColors.primary : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isReached ? Icons.check : Icons.circle,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            steps[index],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isReached ? AppColors.textPrimary : Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        height: 2,
                        width: 14,
                        color: index < activeIndex ? AppColors.primary : Colors.grey.shade300,
                        margin: const EdgeInsets.only(bottom: 20),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialBreakdown(double total, double covered, double copay) {
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
          Text(
            'Payment & Coverage Breakdown',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildBreakdownRow('Total Invoiced Amount', '\$${total.toStringAsFixed(2)}', false),
          const Divider(height: 16),
          _buildBreakdownRow('Covered by Insurance (80%)', '-\$${covered.toStringAsFixed(2)}', true),
          const Divider(height: 16),
          _buildBreakdownRow('Patient Out-of-Pocket Copay', '\$${copay.toStringAsFixed(2)}', false, isBold: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, bool isDeduction, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 15 : 13,
            color: isDeduction ? Colors.green : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedEncounterCard() {
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
          Text(
            'Linked Clinical Service & Encounter',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.description ?? 'Cardiology Consultation & Diagnostic Screening',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'Mount Sinai Hospital (Cardiovascular Health)',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

