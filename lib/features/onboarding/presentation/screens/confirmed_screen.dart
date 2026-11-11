import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/language_toggle.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../../patient/presentation/screens/patient_main_navigation_shell.dart';
import '../../data/models/health_card_models.dart';
import '../../data/repositories/onboarding_repository.dart';

/// CareID Patient App — Step 6: Confirmed Screen
/// Matches approved Figma frame: Confirmed_Screen (node 20:31401, 390 x 2033 pt).
/// Final onboarding confirmation screen showcasing the digital health card,
/// cryptographic vault status, discipline preview, profile strength, and primary CTAs.
class ConfirmedScreen extends StatefulWidget {
  final RegistrationContext registrationContext;
  final String language;
  final ApiClient? apiClient;
  final OnboardingRepository? onboardingRepository;
  final double initialScrollOffset;

  const ConfirmedScreen({
    super.key,
    required this.registrationContext,
    this.language = 'en',
    this.apiClient,
    this.onboardingRepository,
    this.initialScrollOffset = 0.0,
  });

  @override
  State<ConfirmedScreen> createState() => _ConfirmedScreenState();
}

class _ConfirmedScreenState extends State<ConfirmedScreen> {
  late final ScrollController _scrollController;
  late String _currentLanguage;
  late OnboardingRepository _repository;

  // Real backend sync status
  bool _isSyncing = false;
  String? _syncMessage;
  bool _isUnauthenticated = false;
  HealthCardDto? _healthCard;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );
    _currentLanguage = widget.language;
    _repository =
        widget.onboardingRepository ??
        OnboardingRepository(
          apiClient: widget.apiClient,
          tokenStorage: widget.apiClient?.tokenStorage,
        );

    // Attempt real backend synchronization on load
    _syncWithBackend();
  }

  bool get _isEn => _currentLanguage == 'en';

  Future<void> _syncWithBackend() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = null;
      _isUnauthenticated = false;
    });

    // 1. Finalize onboarding via real API: POST /api/v1/patients/onboarding/complete
    final completeResult = await _repository.completeOnboarding();

    if (!mounted) return;

    completeResult.when(
      success: (data, message) {
        // 2. Fetch active Health Card details via real API: GET /api/v1/health-cards
        _fetchHealthCard();
      },
      failure: (message, statusCode, error) {
        setState(() {
          _isSyncing = false;
          if (statusCode == 401) {
            _isUnauthenticated = true;
            _syncMessage = _isEn
                ? 'Backend session unauthenticated (401). OTP verification issue is active on backend. Displaying registration summary preview.'
                : 'Sesión no autenticada (401). El problema de verificación OTP está activo en el backend. Mostrando vista previa del registro.';
          } else {
            _syncMessage = message;
          }
        });
      },
    );
  }

  Future<void> _fetchHealthCard() async {
    final cardResult = await _repository.getHealthCard();
    if (!mounted) return;

    cardResult.when(
      success: (card, message) {
        setState(() {
          _isSyncing = false;
          _healthCard = card;
        });
      },
      failure: (message, statusCode, error) {
        setState(() {
          _isSyncing = false;
          // Graceful fallback if card is not yet issued
        });
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _copyCareId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEn ? 'Care ID copied to clipboard: $id' : 'Care ID copiado: $id',
        ),
        backgroundColor: const Color(0xFF5B14B8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHelpModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEn ? 'CareID Support & Help' : 'Ayuda y Soporte CareID',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _isEn
                    ? 'Your CareID Vault is your private cryptographic store for health records.\n\n'
                        '• Your data is 256-bit AES encrypted.\n'
                        '• Only you decide which healthcare providers or family members can view your records.\n'
                        '• Need assistance? Contact our 24/7 support team at support@careid.health'
                    : 'Tu bóveda CareID es tu almacén criptográfico privado para registros médicos.\n\n'
                        '• Tus datos están cifrados con AES de 256 bits.\n'
                        '• Solo tú decides qué proveedores o familiares pueden ver tus registros.\n'
                        '• ¿Necesitas ayuda? Contacta a soporte 24/7 en support@careid.health',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF494552),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton.gradient(
                text: _isEn ? 'Got it' : 'Entendido',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareHealthCardModal() {
    final careId = _healthCard?.cardNumber ?? widget.registrationContext.displayCareId;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Icon(
                Icons.qr_code_2_rounded,
                size: 64,
                color: Color(0xFF5B14B8),
              ),
              const SizedBox(height: 12),
              Text(
                _isEn ? 'Share Digital Health Card' : 'Compartir Tarjeta Digital de Salud',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isEn
                    ? 'Present your Care ID credential to healthcare providers:'
                    : 'Presenta tu credencial de Care ID a proveedores de salud:',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      careId,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF5B14B8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      color: const Color(0xFF5B14B8),
                      onPressed: () {
                        _copyCareId(careId);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton.gradient(
                text: _isEn ? 'Done' : 'Listo',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onEnterCareIdPressed() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (context) => PatientMainNavigationShell(
          apiClient: widget.apiClient,
          language: _currentLanguage,
          initialIndex: 0,
          registrationContext: widget.registrationContext,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header - Top Branding (CareIdLogo + Language Selector) (Figma Node 20:31682)
              _buildTopHeader(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // 2. Top Navigation Bar (Back + Help) (Figma Node 20:31404)
                    _buildTopNavigationBar(),

                    const SizedBox(height: 16),

                    // 3. Stepper: Phase 5 of 5 Complete (Figma Node 20:31411)
                    _buildStepper(),

                    const SizedBox(height: 20),

                    // 4. Hero Status Header (Figma Node 20:31441)
                    _buildHeroStatusHeader(),

                    const SizedBox(height: 16),

                    // Diagnostic status banner if syncing / unauthenticated / sync message
                    if (_isSyncing || _syncMessage != null) ...[
                      _buildSyncStatusBanner(),
                      const SizedBox(height: 16),
                    ],

                    // 5. Section 1: Care ID Profile Digital Credential Card (Figma Node 20:31453)
                    _buildSection1DigitalCredentialCard(),

                    const SizedBox(height: 24),

                    // 6. Section 2: Vault Disciplines (Figma Node 20:31521)
                    _buildSection2VaultDisciplines(),

                    const SizedBox(height: 24),

                    // 7. Section 3: Health Profile Completion Meter (Figma Node 20:31640)
                    _buildSection3CompletionMeter(),

                    const SizedBox(height: 24),

                    // 8. Section 4: Privacy & Ownership Control (Figma Node 20:31606)
                    _buildSection4PrivacyControl(),

                    const SizedBox(height: 20),

                    // 9. Section 5: Security Trust Badge (Figma Node 20:31620)
                    _buildSection5SecurityBadge(),

                    const SizedBox(height: 28),

                    // 10. Primary Call-to-Actions (Figma Node 20:31629)
                    _buildPrimaryActions(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Branding Header (CareIdLogo + Language Selector) (Figma Node 20:31682)
  Widget _buildTopHeader() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: CareIdLogo.horizontal(height: 18),
          ),
          Positioned(
            right: 0,
            child: LanguageToggle(
              currentLanguage: _currentLanguage,
              onLanguageChanged: (lang) => setState(() => _currentLanguage = lang),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Top Navigation & Context Bar (Figma Node 20:31404)
  Widget _buildTopNavigationBar() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Button - Go back to Consents (20:31405)
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF0B1C30),
              ),
            ),
          ),
          // Button - Help and Support (20:31408)
          InkWell(
            onTap: _showHelpModal,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                size: 20,
                color: Color(0xFF5B14B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Stepper: Phase 5 of 5 Complete (Figma Node 20:31411)
  Widget _buildStepper() {
    const activeColor = Color(0xFF5B14B8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _isEn ? AppStrings.step6Of6En : AppStrings.step6Of6Es,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isEn ? AppStrings.completeBadgeEn : AppStrings.completeBadgeEs,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 5 completed horizontal bars
          Row(
            children: [
              _buildStepSegment(
                title: _isEn ? 'Account' : 'Cuenta',
                color: activeColor,
              ),
              const SizedBox(width: 6),
              _buildStepSegment(
                title: _isEn ? 'Phone' : 'Teléfono',
                color: activeColor,
              ),
              const SizedBox(width: 6),
              _buildStepSegment(
                title: _isEn ? 'Health' : 'Salud',
                color: activeColor,
              ),
              const SizedBox(width: 6),
              _buildStepSegment(
                title: _isEn ? 'Insurance' : 'Seguro',
                color: activeColor,
              ),
              const SizedBox(width: 6),
              _buildStepSegment(
                title: _isEn ? 'Vault' : 'Bóveda',
                color: activeColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepSegment({required String title, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Hero Status Header (Figma Node 20:31441)
  Widget _buildHeroStatusHeader() {
    return Column(
      children: [
        // Active Vault Pill Badge (20:31442)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _isEn ? AppStrings.vaultActiveBadgeEn : AppStrings.vaultActiveBadgeEs,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Heading 1 (20:31450)
        Text(
          _isEn ? AppStrings.confirmedHeadingEn : AppStrings.confirmedHeadingEs,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0B1C30),
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        // Description (20:31452)
        Text(
          _isEn ? AppStrings.confirmedSubtitleEn : AppStrings.confirmedSubtitleEs,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF494552),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Diagnostic Sync / Blocker Banner
  Widget _buildSyncStatusBanner() {
    if (_isSyncing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isEn
                    ? 'Synchronizing vault credentials with CareID backend...'
                    : 'Sincronizando credenciales con el servidor CareID...',
                style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isUnauthenticated
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isUnauthenticated
              ? const Color(0xFFFDE68A)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _isUnauthenticated
                ? Icons.info_outline_rounded
                : Icons.sync_rounded,
            size: 20,
            color: _isUnauthenticated
                ? const Color(0xFFD97706)
                : const Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _syncMessage ?? '',
              style: TextStyle(
                fontSize: 12,
                color: _isUnauthenticated
                    ? const Color(0xFF92400E)
                    : const Color(0xFF1E40AF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Section 1: Care ID Profile Digital Credential Card (Figma Node 20:31453)
  Widget _buildSection1DigitalCredentialCard() {
    final patientName = widget.registrationContext.fullName.isNotEmpty
        ? widget.registrationContext.fullName
        : 'Sarah Jenkins';

    final careId = _healthCard?.cardNumber ?? widget.registrationContext.displayCareId;
    final dob = widget.registrationContext.dateOfBirth ?? '12/05/1992';
    final bloodGroup = widget.registrationContext.bloodGroup ?? 'O Positive (O+)';
    final phone = widget.registrationContext.maskedPhone.isNotEmpty
        ? widget.registrationContext.maskedPhone
        : '+91 ••••• ••890';
    final email = widget.registrationContext.email.isNotEmpty
        ? widget.registrationContext.email
        : 'sarah.j@email.com';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8F5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x145B14B8),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Brand Watermark Silhouette in bottom right (20:31497)
          const Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.shield_rounded,
                size: 180,
                color: Color(0xFF5B14B8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Card Header (20:31454)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: Color(0xFF5B14B8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _isEn
                                  ? AppStrings.digitalCredentialTitleEn
                                  : AppStrings.digitalCredentialTitleEs,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Holographic Security Badge Tag (20:31461)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            size: 11,
                            color: Color(0xFF1D4ED8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isEn
                                ? AppStrings.hipaaSecuredTagEn
                                : AppStrings.hipaaSecuredTagEs,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Identity Overview Section (20:31499)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Photo with Status Pin (20:31500)
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5B14B8), Color(0xFFA44CFF)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  patientName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B1C30),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '32 yrs',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Care ID Monospaced Pill (20:31513)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => _copyCareId(careId),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFDDD6FE),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        careId,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF5B14B8),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.copy_rounded,
                                        size: 12,
                                        color: Color(0xFF5B14B8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 14),

                // Details Grid (20:31466) 2x2
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCell(
                        label: _isEn ? 'Date of Birth' : 'Fecha de Nacimiento',
                        value: dob,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCell(
                        label: _isEn ? 'Blood Group' : 'Grupo Sanguíneo',
                        value: bloodGroup,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCell(
                        label: _isEn ? 'Mobile Contact' : 'Contacto Móvil',
                        value: phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCell(
                        label: _isEn ? 'Registered Email' : 'Correo Registrado',
                        value: email,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Edit Profile Action Button (20:31491)
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: Color(0xFF5B14B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isEn ? 'Edit profile details' : 'Editar detalles',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B14B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCell({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0B1C30),
          ),
        ),
      ],
    );
  }

  // 6. Section 2: Vault Disciplines (Figma Node 20:31521)
  Widget _buildSection2VaultDisciplines() {
    final hasInsurance = widget.registrationContext.hasInsurance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isEn
              ? AppStrings.vaultDisciplinesHeadingEn
              : AppStrings.vaultDisciplinesHeadingEs,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1C30),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isEn
              ? AppStrings.vaultDisciplinesSubtitleEn
              : AppStrings.vaultDisciplinesSubtitleEs,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),

        // 1. Medical Records Card (20:31529)
        _buildDisciplineCard(
          icon: Icons.local_hospital_rounded,
          iconColor: const Color(0xFF5B14B8),
          iconBgColor: const Color(0xFFF3E8FF),
          title: _isEn ? 'Medical Records' : 'Registros Médicos',
          badgeText: _isEn ? 'Ready' : 'Listo',
          badgeColor: const Color(0xFFDCFCE7),
          badgeTextColor: const Color(0xFF15803D),
          description: _isEn
              ? 'Clinical records, diagnoses, prescriptions and medical documents.'
              : 'Registros clínicos, diagnósticos, recetas y documentos médicos.',
        ),
        const SizedBox(height: 12),

        // 2. Dental Records Card (20:31543)
        _buildDisciplineCard(
          icon: Icons.health_and_safety_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBgColor: const Color(0xFFE0F2FE),
          title: _isEn ? 'Dental Records' : 'Registros Dentales',
          badgeText: _isEn ? 'Ready' : 'Listo',
          badgeColor: const Color(0xFFDCFCE7),
          badgeTextColor: const Color(0xFF15803D),
          description: _isEn
              ? 'Dental visits, hygiene charting, treatments and oral surgery files.'
              : 'Consultas dentales, registros de higiene, tratamientos y archivos quirúrgicos.',
        ),
        const SizedBox(height: 12),

        // 3. Vision Records Card (20:31557)
        _buildDisciplineCard(
          icon: Icons.visibility_rounded,
          iconColor: const Color(0xFFD97706),
          iconBgColor: const Color(0xFFFEF3C7),
          title: _isEn ? 'Vision Records' : 'Registros de Visión',
          badgeText: _isEn ? 'Ready' : 'Listo',
          badgeColor: const Color(0xFFDCFCE7),
          badgeTextColor: const Color(0xFF15803D),
          description: _isEn
              ? 'Eye examinations, optical prescriptions and vision test diagnostics.'
              : 'Exámenes oculares, prescripciones ópticas y diagnósticos visuales.',
        ),
        const SizedBox(height: 12),

        // 5. Pet Records Card (20:31571)
        _buildDisciplineCard(
          icon: Icons.pets_rounded,
          iconColor: const Color(0xFF059669),
          iconBgColor: const Color(0xFFD1FAE5),
          title: _isEn ? 'Pet Records' : 'Registros de Mascotas',
          badgeText: _isEn ? 'Pet ready' : 'Listo',
          badgeColor: const Color(0xFFECFDF5),
          badgeTextColor: const Color(0xFF047857),
          description: _isEn
              ? 'Organize vaccinations, vet visits, prescriptions, and lab results.'
              : 'Organiza vacunas, consultas veterinarias, recetas y resultados de laboratorio.',
        ),
        const SizedBox(height: 12),

        // 4. Insurance Records Card (20:31591)
        _buildDisciplineCard(
          icon: Icons.shield_rounded,
          iconColor: const Color(0xFF4F46E5),
          iconBgColor: const Color(0xFFEEF2FF),
          title: _isEn ? 'Insurance Records' : 'Registros de Seguro',
          badgeText: hasInsurance
              ? (_isEn ? 'Policy linked' : 'Póliza vinculada')
              : (_isEn ? '1 Ready' : '1 Listo'),
          badgeColor: const Color(0xFFEFF6FF),
          badgeTextColor: const Color(0xFF1D4ED8),
          description: _isEn
              ? 'Upload, auto-digitize, and organize insurance reports.'
              : 'Sube, digitaliza automáticamente y organiza reportes de seguros.',
        ),
      ],
    );
  }

  Widget _buildDisciplineCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. Section 3: Health Profile Completion Meter (Figma Node 20:31640)
  Widget _buildSection3CompletionMeter() {
    final hasEmergency =
        widget.registrationContext.emergencyContactPhone != null &&
        widget.registrationContext.emergencyContactPhone!.isNotEmpty;

    final percent = hasEmergency ? 100 : 90;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row (20:31641)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 20,
                      color: Color(0xFF5B14B8),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _isEn
                            ? 'Profile Strength: $percent%'
                            : 'Fuerza del Perfil: $percent%',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hasEmergency
                    ? (_isEn ? 'All Complete' : 'Completo')
                    : (_isEn ? '1 item remaining' : '1 elemento pendiente'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar (20:31649)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: const Color(0xFFE2E8F0),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent / 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5B14B8), Color(0xFFA44CFF)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Completed Items Check Grid (20:31651)
          Row(
            children: [
              Expanded(
                child: _buildCheckItem(
                  text: _isEn ? 'Personal Info' : 'Datos Personales',
                  checked: true,
                ),
              ),
              Expanded(
                child: _buildCheckItem(
                  text: _isEn ? 'Phone Verified' : 'Teléfono Verificado',
                  checked: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCheckItem(
                  text: _isEn ? 'Medical Summary' : 'Resumen Médico',
                  checked: true,
                ),
              ),
              Expanded(
                child: _buildCheckItem(
                  text: _isEn ? 'Insurance Card' : 'Tarjeta de Seguro',
                  checked: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCheckItem(
            text: hasEmergency
                ? (_isEn ? 'Emergency Contact' : 'Contacto de Emergencia')
                : (_isEn
                    ? 'Emergency Contact (Optional)'
                    : 'Contacto de Emergencia (Opcional)'),
            checked: hasEmergency,
          ),
          if (!hasEmergency) ...[
            const SizedBox(height: 14),
            // Boost banner (20:31677)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEn
                          ? 'Add your emergency contact to reach 100% health profile completeness.'
                          : 'Agrega tu contacto de emergencia para alcanzar el 100% de completitud.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5B14B8),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B14B8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isEn ? 'Add' : 'Agregar',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckItem({required String text, required bool checked}) {
    return Row(
      children: [
        Icon(
          checked
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 15,
          color: checked ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: checked
                  ? const Color(0xFF0B1C30)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  // 8. Section 4: Privacy & Ownership Control (Figma Node 20:31606)
  Widget _buildSection4PrivacyControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_rounded,
                size: 18,
                color: Color(0xFF5B14B8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEn ? 'You own your health data' : 'Eres dueño de tus datos de salud',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isEn
                ? 'You decide what information you add to your Care ID Vault and when you authorize it to be shared with healthcare providers.'
                : 'Tú decides qué información agregas a tu bóveda Care ID y cuándo autorizas que se comparta con proveedores de salud.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF494552),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isEn ? 'Manage consent settings' : 'Administrar consentimientos',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B14B8),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: Color(0xFF5B14B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 9. Section 5: Security Trust Badge (Figma Node 20:31620)
  Widget _buildSection5SecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              size: 20,
              color: Color(0xFF5B14B8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEn ? 'End-to-End Cryptographic Security' : 'Seguridad Criptográfica Extremo a Extremo',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEn
                      ? '256-bit AES vault encryption with cryptographic tamper-proofing.'
                      : 'Cifrado de bóveda AES de 256 bits con protección criptográfica contra manipulaciones.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 10. Primary Call-to-Actions (Figma Node 20:31629)
  Widget _buildPrimaryActions() {
    return Column(
      children: [
        // Primary Button: Enter Care ID (20:31630)
        PrimaryButton.gradient(
          text: _isEn ? AppStrings.enterCareIdEn : AppStrings.enterCareIdEs,
          icon: Icons.arrow_forward_rounded,
          onPressed: _onEnterCareIdPressed,
        ),
        const SizedBox(height: 12),
        // Secondary Button: Share Digital Health Card (20:31635)
        InkWell(
          onTap: _showShareHealthCardModal,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_rounded,
                    size: 18,
                    color: Color(0xFF5B14B8),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _isEn
                          ? AppStrings.shareDigitalHealthCardEn
                          : AppStrings.shareDigitalHealthCardEs,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B14B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Footnote (20:31639)
        Text(
          _isEn
              ? 'By proceeding, your biometric credentials and health cards are secured according to HIPAA and GDPR standards.'
              : 'Al continuar, tus credenciales biométricas y tarjetas de salud están protegidas bajo estándares HIPAA y GDPR.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
