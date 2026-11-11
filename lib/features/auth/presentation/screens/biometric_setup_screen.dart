import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';

/// CareID Biometric Setup Screen (Figma node 20:25097)
/// Presents the post-verification biometrics prompt allowing patients to enable
/// fingerprint / FaceID hardware authentication for their CareID Vault.
class BiometricSetupScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const BiometricSetupScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  bool _isEnabling = false;

  Future<void> _handleEnableBiometrics() async {
    setState(() => _isEnabling = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    setState(() => _isEnabling = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Biometric authentication activated for CareID Vault'),
        backgroundColor: AppColors.success,
      ),
    );

    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _handleUsePin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('6-digit security PIN mode selected'),
        backgroundColor: AppColors.purplePrimary,
      ),
    );
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _handleSkip() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.tealPrimary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purpleDeep.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: [
                  // CareID Logo
                  const Center(
                    child: CareIdLogo.horizontal(height: 18),
                  ),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hero Concentric Rings & Biometric Shield Graphic (Figma node 20:25102)
                            SizedBox(
                              width: 260,
                              height: 260,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer concentric ring
                                  Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.tealPrimary.withValues(alpha: 0.15),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  // Mid concentric ring
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.tealPrimary.withValues(alpha: 0.25),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  // Center Card with Biometric Symbol (Figma node 20:25113)
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                                      border: Border.all(
                                        color: AppColors.tealBorder,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.tealPrimary.withValues(alpha: 0.15),
                                          blurRadius: 24,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.fingerprint_rounded,
                                            size: 64,
                                            color: AppColors.tealPrimary,
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            width: 48,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: AppColors.tealPrimary.withValues(alpha: 0.6),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Floating Secondary Node: Shield (Top Right)
                                  Positioned(
                                    top: 15,
                                    right: 25,
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.borderMedium,
                                        ),
                                        boxShadow: AppSpacing.toggleShadow,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.verified_user_rounded,
                                          color: AppColors.tealPrimary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Floating Secondary Node: Key/Lock (Bottom Left)
                                  Positioned(
                                    bottom: 25,
                                    left: 20,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.borderMedium,
                                        ),
                                        boxShadow: AppSpacing.toggleShadow,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.lock_rounded,
                                          color: AppColors.purplePrimary,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // Heading (Figma node 20:25124)
                            Text(
                              'Secure Your CareID Vault',
                              style: AppTypography.heading1.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // Description (Figma node 20:25126)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Enable biometric authentication for faster, encrypted one-tap access to your digital health records.',
                                style: AppTypography.subtitle.copyWith(
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Actions Section (Figma node 20:25128)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary Button: Enable Biometrics
                      PrimaryButton(
                        label: 'Enable Biometrics',
                        onPressed: _isEnabling ? null : _handleEnableBiometrics,
                        isLoading: _isEnabling,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Secondary Action: Use PIN Instead
                      SecondaryButton(
                        label: 'Use PIN Instead',
                        onPressed: _handleUsePin,
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Skip Button: Skip for Now
                      TextButton(
                        onPressed: _handleSkip,
                        child: Text(
                          'Skip for Now',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Security footnote
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              'Biometric keys are stored solely on your device hardware.',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
