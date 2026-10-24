import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/language_toggle.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../../shared/widgets/service_feature_card.dart';
import 'create_account_screen.dart';

/// CareID Welcome Screen
/// Faithfully reproduces Figma frame node 20:19794 ("Welcome - Option 2")
/// located on canvas "Careid patient app" (node 17-55).
class WelcomeScreen extends StatefulWidget {
  final ApiClient? apiClient;

  const WelcomeScreen({super.key, this.apiClient});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _currentLanguage = 'en';
  bool _isCheckingHealth = false;
  String? _apiHealthStatus;

  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _verifyBackendConnection();
  }

  Future<void> _verifyBackendConnection() async {
    setState(() => _isCheckingHealth = true);
    final result = await _apiClient.checkHealth();
    if (!mounted) return;

    result.when(
      success: (data, message) {
        setState(() {
          _isCheckingHealth = false;
          _apiHealthStatus = 'Connected: ${data['status'] ?? 'ok'}';
        });
      },
      failure: (message, statusCode, error) {
        setState(() {
          _isCheckingHealth = false;
          _apiHealthStatus = 'Offline';
        });
      },
    );
  }

  bool get _isEn => _currentLanguage == 'en';

  String get _heading =>
      _isEn ? AppStrings.welcomeHeadingEn : AppStrings.welcomeHeadingEs;
  String get _subtitle =>
      _isEn ? AppStrings.welcomeSubtitleEn : AppStrings.welcomeSubtitleEs;

  String get _medicalTitle =>
      _isEn ? AppStrings.medicalTitleEn : AppStrings.medicalTitleEs;
  String get _medicalSubtitle =>
      _isEn ? AppStrings.medicalSubtitleEn : AppStrings.medicalSubtitleEs;

  String get _dentalTitle =>
      _isEn ? AppStrings.dentalTitleEn : AppStrings.dentalTitleEs;
  String get _dentalSubtitle =>
      _isEn ? AppStrings.dentalSubtitleEn : AppStrings.dentalSubtitleEs;

  String get _visionTitle =>
      _isEn ? AppStrings.visionTitleEn : AppStrings.visionTitleEs;
  String get _visionSubtitle =>
      _isEn ? AppStrings.visionSubtitleEn : AppStrings.visionSubtitleEs;

  String get _petsTitle =>
      _isEn ? AppStrings.petsTitleEn : AppStrings.petsTitleEs;
  String get _petsSubtitle =>
      _isEn ? AppStrings.petsSubtitleEn : AppStrings.petsSubtitleEs;

  String get _getStarted =>
      _isEn ? AppStrings.getStartedEn : AppStrings.getStartedEs;
  String get _alreadyHaveAccount =>
      _isEn ? AppStrings.alreadyHaveAccountEn : AppStrings.alreadyHaveAccountEs;

  void _onGetStarted() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CreateAccountScreen(
          apiClient: _apiClient,
          language: _currentLanguage,
        ),
      ),
    );
  }

  void _onAlreadyHaveAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEn
              ? 'Login Flow (Frame 20:24965) scheduled for subsequent phase.'
              : 'Inicio de sesión programado para la siguiente fase.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showServiceInfo(String title, String description) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.purpleLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.purplePrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTypography.heading2),
                        const SizedBox(height: 2),
                        const Text(
                          'CareID Encrypted Vault',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tealPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(description, style: AppTypography.subtitle),
              const SizedBox(height: 12),
              Text(
                _isEn
                    ? 'Records in this category are cryptographically protected and verifiable using your decentralized CareID digital card.'
                    : 'Los registros de esta categoría están protegidos criptográficamente y son verificables con su tarjeta digital CareID.',
                style: AppTypography.body,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _isEn ? 'Close' : 'Cerrar',
                icon: null,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Language Selector Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Health status indicator badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                _apiHealthStatus != null &&
                                    !_apiHealthStatus!.contains('Offline')
                                ? AppColors.success
                                : AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isCheckingHealth
                              ? 'API...'
                              : (_apiHealthStatus ?? 'CareID API'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Language Switcher (Figma Node 20:19868)
                  LanguageToggle(
                    currentLanguage: _currentLanguage,
                    onLanguageChanged: (newLang) {
                      setState(() => _currentLanguage = newLang);
                    },
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXl,
                            ),
                            boxShadow: AppSpacing.cardShadow,
                            border: Border.all(
                              color: AppColors.borderLight,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 24.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // CareID Logo
                              const CareIdLogo(size: 116),

                              const SizedBox(height: 20),

                              // Screen Title
                              Text(
                                _heading,
                                textAlign: TextAlign.center,
                                style: AppTypography.heading1,
                              ),

                              const SizedBox(height: 12),

                              // Subtitle
                              Text(
                                _subtitle,
                                textAlign: TextAlign.center,
                                style: AppTypography.subtitle,
                              ),

                              const SizedBox(height: 28),

                              // Feature Cards Grid (4 items)
                              ServiceFeatureCard(
                                type: ServiceType.medical,
                                title: _medicalTitle,
                                description: _medicalSubtitle,
                                onTap: () => _showServiceInfo(
                                  _medicalTitle,
                                  _medicalSubtitle,
                                ),
                              ),
                              ServiceFeatureCard(
                                type: ServiceType.dental,
                                title: _dentalTitle,
                                description: _dentalSubtitle,
                                onTap: () => _showServiceInfo(
                                  _dentalTitle,
                                  _dentalSubtitle,
                                ),
                              ),
                              ServiceFeatureCard(
                                type: ServiceType.vision,
                                title: _visionTitle,
                                description: _visionSubtitle,
                                onTap: () => _showServiceInfo(
                                  _visionTitle,
                                  _visionSubtitle,
                                ),
                              ),
                              ServiceFeatureCard(
                                type: ServiceType.pets,
                                title: _petsTitle,
                                description: _petsSubtitle,
                                onTap: () =>
                                    _showServiceInfo(_petsTitle, _petsSubtitle),
                              ),

                              const SizedBox(height: 24),

                              // Primary CTA: "Get Started →"
                              PrimaryButton(
                                label: _getStarted,
                                onPressed: _onGetStarted,
                              ),

                              const SizedBox(height: 12),

                              // Secondary CTA: "I already have an account"
                              SecondaryButton(
                                label: _alreadyHaveAccount,
                                onPressed: _onAlreadyHaveAccount,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
