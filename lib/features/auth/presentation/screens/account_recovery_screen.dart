import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/repositories/auth_repository.dart';

/// CareID Account Recovery Screen (Figma node 20:25143)
/// Allows patients to recover access to their CareID Vault by requesting
/// a secure recovery OTP challenge to their registered mobile phone number.
class AccountRecoveryScreen extends StatefulWidget {
  final AuthRepository? authRepository;

  const AccountRecoveryScreen({
    super.key,
    this.authRepository,
  });

  @override
  State<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends State<AccountRecoveryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  late final AuthRepository _authRepository;

  final String _countryCode = '+1';
  bool _isLoading = false;
  bool _codeSent = false;
  String? _challengeId;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? AuthRepository();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleSendRecoveryCode() async {
    final rawNumber = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (rawNumber.length < 10) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
        _successMessage = null;
      });
      return;
    }

    final fullNumber = '$_countryCode$rawNumber';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _authRepository.requestOtp(fullNumber);
      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess && result.dataOrNull != null) {
        setState(() {
          _codeSent = true;
          _challengeId = result.dataOrNull!.challengeId;
          _successMessage = 'A secure recovery code has been sent to $fullNumber';
        });
      } else {
        setState(() {
          _errorMessage = result.messageOrNull ?? 'Failed to send recovery code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to send recovery code. Please check your connection.';
      });
    }
  }

  Future<void> _handleVerifyRecoveryCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit verification code';
      });
      return;
    }

    if (_challengeId == null) {
      setState(() {
        _errorMessage = 'Session expired. Please request a new recovery code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authRepository.verifyOtp(
        challengeId: _challengeId!,
        otpCode: code,
      );
      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account successfully verified! Please sign in with your updated session.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = result.messageOrNull ?? 'Invalid or expired code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid or expired code. Please verify and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient gradient glow
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
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
            bottom: 40,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CareID Logo
                    const Center(
                      child: CareIdLogo.horizontal(height: 18),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Main Glassmorphic Card (Figma node 20:25151)
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Lock / Key Icon Badge
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.tealPrimary.withValues(alpha: 0.12),
                              border: Border.all(
                                color: AppColors.tealBorder,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.lock_reset_rounded,
                                color: AppColors.tealPrimary,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Heading
                          Text(
                            _codeSent ? 'Verify Recovery Code' : 'Account Recovery',
                            style: AppTypography.heading2.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          // Subtitle
                          Text(
                            _codeSent
                                ? 'Enter the 6-digit recovery code delivered to your registered device.'
                                : 'Enter your registered mobile phone number to receive a secure recovery code.',
                            style: AppTypography.bodySmall.copyWith(
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Error Message Banner
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                border: Border.all(
                                  color: AppColors.errorRed.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.errorRed,
                                    size: 18,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.errorRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Success Message Banner
                          if (_successMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                border: Border.all(
                                  color: AppColors.success.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      _successMessage!,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Input Fields
                          if (!_codeSent) ...[
                            // Phone input with country selector
                            Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                border: Border.all(
                                  color: AppColors.borderMedium,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: AppColors.borderMedium,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          _countryCode,
                                          style: AppTypography.body.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: AppColors.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '(555) 000-0000',
                                        hintStyle: AppTypography.body.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Send Recovery Code Button
                            PrimaryButton(
                              label: 'Send Recovery Code',
                              onPressed: _isLoading ? null : _handleSendRecoveryCode,
                              isLoading: _isLoading,
                            ),
                          ] else ...[
                            // Verification Code Input
                            TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: AppTypography.heading2.copyWith(
                                color: AppColors.purplePrimary,
                                letterSpacing: 8,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '000000',
                                hintStyle: AppTypography.heading2.copyWith(
                                  color: AppColors.textTertiary,
                                  letterSpacing: 8,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceMuted,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  borderSide: const BorderSide(color: AppColors.borderMedium),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  borderSide: const BorderSide(color: AppColors.purplePrimary, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Verify Code Button
                            PrimaryButton(
                              label: 'Verify & Access Account',
                              onPressed: _isLoading ? null : _handleVerifyRecoveryCode,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: _isLoading ? null : () => setState(() => _codeSent = false),
                              child: Text(
                                'Change phone number',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.purplePrimary,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.md),

                          // Back to Sign In Link (Figma node 20:25178)
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                              color: AppColors.purplePrimary,
                            ),
                            label: Text(
                              'Back to Sign In',
                              style: AppTypography.body.copyWith(
                                color: AppColors.purplePrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Footer Compliance / Trust Indicator (Figma node 20:25183)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '256-bit HIPAA Compliant Security Protocol',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
