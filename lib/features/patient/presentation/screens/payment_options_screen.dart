import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import 'uninsured_assistance_screen.dart';
import '../../../../shared/widgets/primary_button.dart';

/// CareID Payment Options Screen (Figma node 20:33152)
/// Allows patients to review flexible care financing, sliding-scale subsidies,
/// HSA/FSA direct payment, and 0% APR installment plans.
class PaymentOptionsScreen extends StatelessWidget {
  const PaymentOptionsScreen({super.key});

  void _showPlanDetails(BuildContext context, String title, String description) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.heading2.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTypography.subtitle.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Apply for this Plan',
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected financing plan: ' + title),
                    backgroundColor: const Color(0xFF5B14B8),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar (Figma node 20:33153)
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  // Profile Photo with online status
                  Stack(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.purpleLight,
                          border: Border.all(color: AppColors.purpleBorder),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.purplePrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const CareIdLogo.horizontal(height: 18),
                  const Spacer(),
                  // Notification bell with unread dot
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Screen Context Bar (Figma node 20:33162)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment & Financial',
                        style: AppTypography.heading3.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Options & Assistance',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Secure Badge (Figma node 20:33169)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tealPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      border: Border.all(
                        color: AppColors.tealBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          color: AppColors.tealPrimary,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.tealPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Scrollable Choices Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction (Figma node 20:33173)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FLEXIBLE CARE FINANCING',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.purplePrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose How You Pay for Your Care',
                            style: AppTypography.heading2.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage out-of-pocket costs with verified health plans, HSA/FSA cards, and zero-interest installment options.',
                            style: AppTypography.body.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Choice Card 1: Sliding-Scale Clinic Discount
                    _buildChoiceCard(
                      context: context,
                      icon: Icons.local_offer_rounded,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: AppColors.dentalIcon,
                      title: 'Sliding-Scale Clinic Discount',
                      description:
                          'Qualify for income-based healthcare subsidies and direct clinic write-downs on non-elective procedures.',
                      badgeLabel: 'Up to 70% Off',
                      badgeColor: AppColors.success,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const UninsuredAssistanceScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Choice Card 2: HSA / FSA Direct Pay
                    _buildChoiceCard(
                      context: context,
                      icon: Icons.credit_card_rounded,
                      iconBg: AppColors.purpleLight,
                      iconColor: AppColors.purplePrimary,
                      title: 'HSA / FSA Direct Pay',
                      description:
                          'Link pre-tax Health Savings Accounts and Flexible Spending Accounts for immediate co-pay coverage.',
                      badgeLabel: 'Pre-Tax Savings',
                      badgeColor: AppColors.purplePrimary,
                      onTap: () => _showPlanDetails(
                        context,
                        'HSA / FSA Direct Pay',
                        'Connect your HSA or FSA card for IRS-approved medical payments with instant digital receipt reconciliation and deductible tracking.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Choice Card 3: Zero-Interest Payment Plans
                    _buildChoiceCard(
                      context: context,
                      icon: Icons.payments_rounded,
                      iconBg: AppColors.tealLight,
                      iconColor: AppColors.tealPrimary,
                      title: 'Zero-Interest Payment Plans',
                      description:
                          'Split out-of-pocket medical bills into 3, 6, or 12 monthly installments with 0% APR and no credit penalty.',
                      badgeLabel: '0% APR Available',
                      badgeColor: AppColors.tealPrimary,
                      onTap: () => _showPlanDetails(
                        context,
                        'Zero-Interest Payment Plans',
                        'Spread patient responsibility payments over 3 to 12 equal monthly installments with zero interest and automatic electronic reminders.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Security Note (Figma node 20:33220)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.borderMedium),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            size: 16,
                            color: AppColors.purplePrimary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'All payments and financial disclosures are 256-bit encrypted and HIPAA compliant.',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required String badgeLabel,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.borderMedium),
          boxShadow: AppSpacing.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Background (Figma node 20:33179)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Choice Content (Figma node 20:33182)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          badgeLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
