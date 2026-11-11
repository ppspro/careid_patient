import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../../onboarding/presentation/screens/add_insurance_screen.dart';
import 'payment_options_screen.dart';

/// CareID Insurance Status (Uninsured / Self-Pay) Screen (Figma node 20:26187)
/// Detailed guidance, value proposition bento cards, and curated financial assistance
/// programs for uninsured or self-pay patients.
class UninsuredAssistanceScreen extends StatelessWidget {
  const UninsuredAssistanceScreen({super.key});

  void _showOfferDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.borderMedium),
        ),
        title: Text(
          'Make an Out-of-Pocket Offer',
          style: AppTypography.heading3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit a self-pay settlement offer or payment plan request directly to the billing department.',
              style: AppTypography.bodySmall.copyWith(
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: AppTypography.heading2.copyWith(color: AppColors.purplePrimary),
                hintText: 'Proposed amount (e.g. 250)',
                hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.borderMedium),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          PrimaryButton(
            label: 'Submit Offer',
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offer submitted for billing department review.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            isFullWidth: false,
            height: 42,
          ),
        ],
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
            // Top App Bar (Figma node 20:26362)
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
                  // Profile Photo
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
                  // Notifications
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Screen Context Bar (Figma node 20:26190)
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
                        'Insurance Status',
                        style: AppTypography.heading3.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Status & Verification',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Status Badge: Self-Pay / Uninsured
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Self-Pay',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Empty-State Physical Card Frame (Figma node 20:26304)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(
                          color: AppColors.borderMedium,
                        ),
                        boxShadow: AppSpacing.cardShadow,
                      ),
                      child: Column(
                        children: [
                          // Decorative concentric orbit & shield icon
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.purplePrimary.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: AppColors.purpleLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.credit_card_off_rounded,
                                    color: AppColors.purplePrimary,
                                    size: 32,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                bottom: 6,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.priority_high_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Text(
                            'No Active Insurance on File',
                            style: AppTypography.heading2.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          Text(
                            'Add your policy card to unlock instant hospital eligibility checks, automated claim filing, and zero-paperwork visits.',
                            style: AppTypography.bodySmall.copyWith(
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Action Buttons Stack (Figma node 20:26328)
                          PrimaryButton(
                            label: 'Add Insurance Card',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const AddInsuranceScreen(
                                    registrationContext: RegistrationContext(
                                      fullName: 'John Doe',
                                      phone: '+16505550004',
                                      email: 'patient.careid@vnvision.in',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const PaymentOptionsScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.purplePrimary,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                              ),
                              child: Text(
                                'Treatment & Finance Options',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.purplePrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Value Prop Bento Cards (Figma node 20:26204)
                    Text(
                      'WHY ADD AN INSURANCE CARD',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.purplePrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    _buildValuePropCard(
                      icon: Icons.flash_on_rounded,
                      title: 'Instant Hospital Eligibility',
                      description: 'Digital verification in under 4 seconds at clinic check-in desks.',
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    _buildValuePropCard(
                      icon: Icons.assignment_turned_in_rounded,
                      title: 'Zero-Paperwork Admission',
                      description: 'Pre-authorized forms sent directly to your attending physician.',
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    _buildValuePropCard(
                      icon: Icons.track_changes_rounded,
                      title: 'Automated Claim Tracking',
                      description: 'Live reimbursement status updates directly in your timeline.',
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Curated Partner Assistance Section (Figma node 20:26245)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FINANCIAL ASSISTANCE',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.purplePrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '2 Options',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Partner Card 1: CareCredit Medical
                    _buildPartnerCard(
                      context: context,
                      initial: 'CC',
                      name: 'CareCredit Health',
                      tag: 'Popular',
                      benefit: '0% APR for 12 mos',
                      description: 'Dedicated healthcare financing line for planned and urgent procedures.',
                      buttonText: 'Apply',
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Partner Card 2: Community Subsidy
                    _buildPartnerCard(
                      context: context,
                      initial: 'CP',
                      name: 'Community Care Subsidy',
                      tag: 'Sliding Scale',
                      benefit: 'Up to 70% off',
                      description: 'Income-qualified discount program supported by participating regional clinics.',
                      buttonText: 'Check Eligibility',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Action Button: Make an Offer (Figma node 20:26357)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: PrimaryButton(
                label: 'Make a Self-Pay Offer',
                onPressed: () => _showOfferDialog(context),
                leadingIcon: Icons.handshake_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValuePropCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.purpleLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.purplePrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard({
    required BuildContext context,
    required String initial,
    required String name,
    required String tag,
    required String benefit,
    required String description,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderMedium),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.purpleBorder),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.purplePrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.purpleLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.purplePrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      benefit,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: buttonText,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Inquiring with partner: $name')),
                );
              },
              isFullWidth: false,
              height: 34,
              backgroundColor: AppColors.tealPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
