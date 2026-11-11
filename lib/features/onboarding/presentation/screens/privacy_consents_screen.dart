import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../data/models/consent_models.dart';
import '../../data/repositories/onboarding_repository.dart';
import 'confirmed_screen.dart';

/// CareID Privacy & Consents Screen
/// Faithfully implements Step 5 of 6 in Patient Onboarding (Figma Node 20:31164, "Privacy & Consents").
/// Follows Step 4 (Add Insurance Info) and precedes Step 6 (Confirmed / Digital Health Card).
class PrivacyConsentsScreen extends StatefulWidget {
  final RegistrationContext registrationContext;
  final ApiClient? apiClient;
  final OnboardingRepository? onboardingRepository;
  final String language;

  final double initialScrollOffset;

  const PrivacyConsentsScreen({
    super.key,
    required this.registrationContext,
    this.apiClient,
    this.onboardingRepository,
    this.language = 'en',
    this.initialScrollOffset = 0.0,
  });

  @override
  State<PrivacyConsentsScreen> createState() => _PrivacyConsentsScreenState();
}

class _PrivacyConsentsScreenState extends State<PrivacyConsentsScreen> {
  late final ScrollController _scrollController;
  late String _currentLanguage;
  late OnboardingRepository _repository;

  // Mandatory Consents (Section 1)
  bool _termsAccepted = false;
  bool _privacyPolicyAccepted = false;

  // Health Information Consent (Section 2)
  bool _healthVaultStorageEnabled = true;

  // Healthcare Sharing Permission (Section 3)
  bool _shareWithHealthcareProviders = true;

  // Optional Communications (Section 4)
  bool _productUpdatesMarketing = false;
  bool _clinicalAppointmentReminders = true;
  final bool _securityAlertsAcknowledged = true; // Mandatory, cannot disable

  // Submission & Network State
  bool _isSaving = false;
  String? _errorMessage;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: widget.initialScrollOffset);
    _currentLanguage = widget.language;
    _repository =
        widget.onboardingRepository ??
        OnboardingRepository(
          apiClient: widget.apiClient,
          tokenStorage: widget.apiClient?.tokenStorage,
        );

    // Pre-hydrate from RegistrationContext if available
    _termsAccepted = widget.registrationContext.termsAccepted;
    _privacyPolicyAccepted = widget.registrationContext.privacyPolicyAccepted;
    _healthVaultStorageEnabled =
        widget.registrationContext.healthStorageConsent;
    _shareWithHealthcareProviders =
        widget.registrationContext.shareWithProvidersConsent;
    _productUpdatesMarketing = widget.registrationContext.marketingConsent;
    _clinicalAppointmentReminders =
        widget.registrationContext.clinicalRemindersConsent;
  }

  bool get _isEn => _currentLanguage == 'en';

  bool get _canContinue => _termsAccepted && _privacyPolicyAccepted;

  Future<void> _handleSubmit({bool isReviewLater = false}) async {
    setState(() {
      _validationError = null;
      _errorMessage = null;
    });

    if (!isReviewLater) {
      if (!_termsAccepted && !_privacyPolicyAccepted) {
        setState(() {
          _validationError = _isEn
              ? 'Please accept both the Terms of Service and Privacy Policy to proceed.'
              : 'Por favor acepta tanto los Términos del Servicio como la Política de Privacidad para continuar.';
        });
        return;
      }
      if (!_termsAccepted) {
        setState(() {
          _validationError = _isEn
              ? 'You must accept the Terms of Service to continue.'
              : 'Debes aceptar los Términos del Servicio para continuar.';
        });
        return;
      }
      if (!_privacyPolicyAccepted) {
        setState(() {
          _validationError = _isEn
              ? 'You must accept the Privacy Policy to continue.'
              : 'Debes aceptar la Política de Privacidad para continuar.';
        });
        return;
      }
    }

    setState(() => _isSaving = true);

    final dto = PrivacyConsentsDto(
      termsOfServiceAccepted: _termsAccepted,
      privacyPolicyAccepted: _privacyPolicyAccepted,
      healthVaultStorageEnabled: _healthVaultStorageEnabled,
      shareWithHealthcareProviders: _shareWithHealthcareProviders,
      productUpdatesMarketing: _productUpdatesMarketing,
      clinicalAppointmentReminders: _clinicalAppointmentReminders,
      securityAlertsAcknowledged: _securityAlertsAcknowledged,
    );

    final updatedContext = widget.registrationContext.copyWith(
      onboardingStep: 6,
      termsAccepted: _termsAccepted,
      privacyPolicyAccepted: _privacyPolicyAccepted,
      healthStorageConsent: _healthVaultStorageEnabled,
      shareWithProvidersConsent: _shareWithHealthcareProviders,
      marketingConsent: _productUpdatesMarketing,
      clinicalRemindersConsent: _clinicalAppointmentReminders,
    );

    // Call real API: POST /api/v1/patients/onboarding/health-card
    final result = await _repository.saveConsents(dto);

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      success: (data, message) {
        _navigateToNextStep(updatedContext);
      },
      failure: (message, statusCode, error) {
        setState(() {
          if (statusCode == 401) {
            _errorMessage = _isEn
                ? 'Backend session unauthenticated (401). OTP verification must precede saving consents to the remote vault.'
                : 'Sesión no autenticada (401). La verificación OTP debe preceder al guardado de consentimientos en la bóveda.';
          } else {
            _errorMessage = message;
          }
        });
      },
    );
  }

  void _navigateToNextStep(RegistrationContext context) {
    Navigator.of(this.context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConfirmedScreen(
          registrationContext: context,
          language: _currentLanguage,
          apiClient: widget.apiClient,
          onboardingRepository: _repository,
        ),
      ),
    );
  }

  void _showDocumentModal({
    required String title,
    required String content,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle pill
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Modal Title & Close
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF494552)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF494552),
                    ),
                  ),
                ),
              ),
              // Close CTA
              Padding(
                padding: const EdgeInsets.all(20),
                child: PrimaryButton(
                  text: _isEn ? 'Close & Continue' : 'Cerrar y Continuar',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Branding Header (CareIdLogo + Language Selector) (Figma Node 20:31394)
              _buildTopHeader(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // 2. Step Progress Indicator: Step 5 of 6 (Figma Node 20:31166)
                    _buildStepProgressIndicator(),

                    const SizedBox(height: 24),

                    // 3. Screen Header: Heading 1 & Description (Figma Node 20:31176)
                    _buildScreenHeader(),

                    const SizedBox(height: 20),

                    // Diagnostic Error Banner (if any)
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(_errorMessage!),
                      const SizedBox(height: 16),
                    ],

                    if (_validationError != null) ...[
                      _buildValidationErrorBanner(_validationError!),
                      const SizedBox(height: 16),
                    ],

                    // 4. Section 1: Required Consents (Figma Node 20:31181)
                    _buildSection1RequiredConsents(),

                    const SizedBox(height: 24),

                    // 5. Section 2: Health Information Consent (Figma Node 20:31225)
                    _buildSection2HealthConsent(),

                    const SizedBox(height: 24),

                    // 6. Section 3: Healthcare Sharing Permission (Figma Node 20:31253)
                    _buildSection3SharingPermission(),

                    const SizedBox(height: 24),

                    // 7. Section 4: Optional Communications (Figma Node 20:31279)
                    _buildSection4Communications(),

                    const SizedBox(height: 24),

                    // 8. Section 5: Data Control Information (Figma Node 20:31320)
                    _buildSection5DataControl(),

                    const SizedBox(height: 24),

                    // 9. Section 6: Consent Summary (Figma Node 20:31348)
                    _buildSection6ConsentSummary(),

                    const SizedBox(height: 32),

                    // 10. Section 7: Primary & Secondary Actions (Figma Node 20:31377)
                    _buildSection7ActionButtons(),

                    const SizedBox(height: 20),

                    // 11. Security Footnote (Figma Node 20:31389)
                    _buildSecurityFootnote(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Branding Header: Back Navigation, CareIdLogo & Language Selector (Figma Node 20:31394)
  Widget _buildTopHeader() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Color(0xFF0B1C30),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // Centered CareID Logo (Figma Node 20:31395, 79x18)
          const CareIdLogo.horizontal(height: 18),

          // Bilingual Pill (EN / ESP) (Figma Node 20:31396)
          Container(
            height: 32,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0xFFDCE9FF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _currentLanguage = 'en'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isEn ? const Color(0xFF5B14B8) : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'EN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isEn ? Colors.white : const Color(0xFF414754),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentLanguage = 'es'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: !_isEn ? const Color(0xFF5B14B8) : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'ESP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: !_isEn ? Colors.white : const Color(0xFF414754),
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

  /// Step Progress Indicator: Step 5 of 6 (Figma Node 20:31166)
  Widget _buildStepProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isEn ? 'VERIFICATION STEP' : 'PASO DE VERIFICACIÓN',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00696B),
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _isEn ? 'Step 5 of 6' : 'Paso 5 de 6',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF494552),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 83.3% progress bar (Step 5 of 6)
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE9FF),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * (5 / 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28006D),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Screen Header: Heading 1 & Description (Figma Node 20:31176)
  Widget _buildScreenHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEn ? 'Your privacy & consents' : 'Tu privacidad y consentimientos',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1C30),
            letterSpacing: -0.7,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isEn
              ? 'You control how your health information is stored, accessed, and shared through Care ID.'
              : 'Tú controlas cómo se almacena, accede y comparte tu información médica a través de Care ID.',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xFF494552),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Section 1: Required Consents (Figma Node 20:31181)
  Widget _buildSection1RequiredConsents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row: Heading 2 + Mandatory Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isEn ? 'REQUIRED CONSENTS' : 'CONSENTIMIENTOS REQUERIDOS',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C30),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                _isEn ? 'Mandatory' : 'Obligatorio',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Card 1: Terms of Service (Figma Node 20:31189)
        _buildConsentCard(
          title: _isEn ? 'Terms of Service' : 'Términos del Servicio',
          description: _isEn
              ? 'Review and accept the terms that apply to your Care ID account and cryptographic health passport.'
              : 'Revisa y acepta los términos que aplican a tu cuenta de Care ID y pasaporte de salud criptográfico.',
          checkboxLabel: _isEn
              ? 'I have read and agree to the Terms of Service'
              : 'He leído y acepto los Términos del Servicio',
          isChecked: _termsAccepted,
          onChanged: (val) => setState(() => _termsAccepted = val ?? false),
          onReadPressed: () => _showDocumentModal(
            title: _isEn ? 'Terms of Service' : 'Términos del Servicio',
            content: _termsOfServiceText,
          ),
        ),

        const SizedBox(height: 14),

        // Card 2: Privacy Policy (Figma Node 20:31207)
        _buildConsentCard(
          title: _isEn ? 'Privacy Policy' : 'Política de Privacidad',
          description: _isEn
              ? 'Learn how Care ID collects, stores, and protects your identity credentials and personal data.'
              : 'Aprende cómo Care ID recopila, almacena y protege tus credenciales de identidad y datos personales.',
          checkboxLabel: _isEn
              ? 'I understand and accept how my data is processed in accordance with the Privacy Policy'
              : 'Entiendo y acepto cómo se procesan mis datos conforme a la Política de Privacidad',
          isChecked: _privacyPolicyAccepted,
          onChanged: (val) => setState(() => _privacyPolicyAccepted = val ?? false),
          onReadPressed: () => _showDocumentModal(
            title: _isEn ? 'Privacy Policy' : 'Política de Privacidad',
            content: _privacyPolicyText,
          ),
        ),
      ],
    );
  }

  /// Reusable Card for Terms of Service & Privacy Policy
  Widget _buildConsentCard({
    required String title,
    required String description,
    required String checkboxLabel,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onReadPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked ? const Color(0xFFC4B5FD) : const Color(0xFFDCE9FF),
          width: isChecked ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF494552),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // "Read" Action Button (Figma Node 20:31197)
              InkWell(
                onTap: onReadPressed,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDCE9FF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_new, size: 13, color: Color(0xFF5B14B8)),
                      const SizedBox(width: 4),
                      Text(
                        _isEn ? 'Read' : 'Leer',
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
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          // Interactive Checkbox row (Figma Node 20:31202)
          InkWell(
            onTap: () => onChanged(!isChecked),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: onChanged,
                      activeColor: const Color(0xFF5B14B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      checkboxLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                        color: isChecked ? const Color(0xFF0B1C30) : const Color(0xFF494552),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section 2: Health Information Consent (Figma Node 20:31225)
  Widget _buildSection2HealthConsent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row: Heading 2 + HIPAA Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isEn ? 'HEALTH INFORMATION CONSENT' : 'CONSENTIMIENTO DE INFORMACIÓN MÉDICA',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C30),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user_outlined, size: 11, color: Color(0xFF059669)),
                  const SizedBox(width: 4),
                  Text(
                    _isEn ? 'HIPAA Compliant' : 'Cumple con HIPAA',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Prominent Feature Card with soft tint (Figma Node 20:31234)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDD6FE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x105B14B8),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_person_outlined,
                      color: Color(0xFF5B14B8),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEn ? 'Care ID Encrypted Health Vault' : 'Bóveda de Salud Encriptada Care ID',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isEn ? 'Personal Encrypted Health Storage' : 'Almacenamiento Médico Encriptado Personal',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _isEn
                    ? 'Allow Care ID to securely store your clinical records, health metrics, and medical data in your encrypted personal Care ID Vault.'
                    : 'Permite que Care ID almacene de forma segura tus registros clínicos, métricas y datos médicos en tu Bóveda personal encriptada.',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF494552),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              // Switch Container (Figma Node 20:31247)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isEn
                            ? 'Enable encrypted health vault storage'
                            : 'Habilitar almacenamiento seguro en bóveda',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                    ),
                    Switch(
                      value: _healthVaultStorageEnabled,
                      activeThumbColor: const Color(0xFF5B14B8),
                      onChanged: (val) => setState(() => _healthVaultStorageEnabled = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section 3: Healthcare Sharing Permission (Figma Node 20:31253)
  Widget _buildSection3SharingPermission() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEn ? 'SHARING YOUR HEALTH INFORMATION' : 'COMPARTIR TU INFORMACIÓN MÉDICA',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1C30),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE9FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEn ? 'Healthcare Professional Access' : 'Acceso para Profesionales de la Salud',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEn
                              ? 'You decide when your health information can be shared with healthcare professionals or other authorized people.'
                              : 'Tú decides cuándo se puede compartir tu información de salud con profesionales médicos u otras personas autorizadas.',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF494552),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Prominent Callout Banner (Figma Node 20:31268)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF1D4ED8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEn
                            ? 'You have complete authority. No provider can view your records without your explicit approval, and you can revoke access at any time.'
                            : 'Tienes control total. Ningún proveedor puede ver tus registros sin tu aprobación explícita, y puedes revocar el acceso en cualquier momento.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E40AF),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Switch row (Figma Node 20:31273)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _isEn
                          ? 'Allow sharing with authorized providers'
                          : 'Permitir compartir con proveedores autorizados',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                  ),
                  Switch(
                    value: _shareWithHealthcareProviders,
                    activeThumbColor: const Color(0xFF5B14B8),
                    onChanged: (val) => setState(() => _shareWithHealthcareProviders = val),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section 4: Optional Communications (Figma Node 20:31279)
  Widget _buildSection4Communications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEn ? 'COMMUNICATION PREFERENCES' : 'PREFERENCIAS DE COMUNICACIÓN',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1C30),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isEn
              ? 'Choose which non-essential updates and reminders you would like to receive.'
              : 'Elige qué actualizaciones y recordatorios no esenciales deseas recibir.',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF494552),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE9FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              // Item 1: Marketing / Product Updates (Figma Node 20:31288)
              InkWell(
                onTap: () => setState(() => _productUpdatesMarketing = !_productUpdatesMarketing),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _productUpdatesMarketing,
                          activeColor: const Color(0xFF5B14B8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _productUpdatesMarketing = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEn ? 'Product Updates & Health News' : 'Novedades y Consejos de Salud',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isEn
                                  ? 'Receive announcements about new Care ID features and wellness tips.'
                                  : 'Recibe anuncios sobre nuevas funciones de Care ID y consejos de bienestar.',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF494552)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),

              // Item 2: Clinical reminders (Figma Node 20:31297)
              InkWell(
                onTap: () => setState(() => _clinicalAppointmentReminders = !_clinicalAppointmentReminders),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _clinicalAppointmentReminders,
                          activeColor: const Color(0xFF5B14B8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _clinicalAppointmentReminders = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEn ? 'Clinical & Appointment Reminders' : 'Recordatorios Clínicos y Citas',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isEn
                                  ? 'Receive SMS and email reminders for upcoming appointments and preventive care.'
                                  : 'Recibe alertas por SMS y correo para próximas citas y cuidado preventivo.',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF494552)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),

              // Item 3: Security & Critical Alerts (Required) (Figma Node 20:31306)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.lock,
                        size: 18,
                        color: Color(0xFF5B14B8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _isEn
                                      ? 'Security & Account Alerts (Required)'
                                      : 'Alertas de Seguridad y Cuenta (Requerido)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0B1C30),
                                  ),
                                ),
                              ),
                              const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isEn
                                ? 'Critical security notifications and identity verification notices cannot be disabled.'
                                : 'Los avisos críticos de seguridad e identidad no se pueden desactivar.',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section 5: Data Control Information (Figma Node 20:31320)
  Widget _buildSection5DataControl() {
    final items = [
      _isEn
          ? 'You own and control your health data at all times.'
          : 'Eres el único dueño de tus datos médicos en todo momento.',
      _isEn
          ? 'All records are encrypted end-to-end with cryptographic keys.'
          : 'Todos los registros están encriptados con claves criptográficas.',
      _isEn
          ? 'You can export, transfer, or permanently delete your vault at any time.'
          : 'Puedes exportar, transferir o eliminar permanentemente tu bóveda.',
      _isEn
          ? 'Care ID never sells or shares your personal data with third-party advertisers.'
          : 'Care ID nunca vende ni comercializa tus datos privados.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE9FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                color: Color(0xFF5B14B8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEn ? 'Your Rights & Data Control' : 'Tus Derechos y Control de Datos',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5B14B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF494552),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section 6: Consent Summary (Figma Node 20:31348)
  Widget _buildSection6ConsentSummary() {
    final allAccepted = _termsAccepted && _privacyPolicyAccepted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE9FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _isEn ? 'Consent Status' : 'Estado de Consentimientos',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: allAccepted ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      allAccepted ? Icons.check_circle : Icons.pending,
                      size: 11,
                      color: allAccepted ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      allAccepted
                          ? (_isEn ? 'All Required Accepted' : 'Requeridos Aceptados')
                          : (_isEn ? 'Pending Required' : 'Pendientes Requeridos'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: allAccepted ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 2x2 Grid of Status Boxes (Figma Node 20:31356)
          Row(
            children: [
              Expanded(
                child: _buildSummaryBox(
                  title: _isEn ? 'Terms of Service' : 'Términos del Servicio',
                  status: _termsAccepted
                      ? (_isEn ? 'Accepted' : 'Aceptado')
                      : (_isEn ? 'Required' : 'Requerido'),
                  isPositive: _termsAccepted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryBox(
                  title: _isEn ? 'Privacy Policy' : 'Política Privacidad',
                  status: _privacyPolicyAccepted
                      ? (_isEn ? 'Accepted' : 'Aceptado')
                      : (_isEn ? 'Required' : 'Requerido'),
                  isPositive: _privacyPolicyAccepted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSummaryBox(
                  title: _isEn ? 'Health Storage' : 'Bóveda de Salud',
                  status: _healthVaultStorageEnabled
                      ? (_isEn ? 'Enabled' : 'Habilitado')
                      : (_isEn ? 'Disabled' : 'Deshabilitado'),
                  isPositive: _healthVaultStorageEnabled,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryBox(
                  title: _isEn ? 'Communications' : 'Comunicaciones',
                  status: _clinicalAppointmentReminders
                      ? (_isEn ? 'Alerts Active' : 'Alertas Activas')
                      : (_isEn ? 'Essential Only' : 'Solo Esenciales'),
                  isPositive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox({
    required String title,
    required String status,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? const Color(0xFF0F172A) : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section 7: Primary CTA & Secondary Action (Figma Node 20:31377)
  Widget _buildSection7ActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          label: _isEn ? 'Agree & Continue' : 'Aceptar y Continuar',
          trailingIcon: Icons.arrow_forward_ios,
          isLoading: _isSaving,
          enabled: _canContinue,
          onPressed: _canContinue ? () => _handleSubmit(isReviewLater: false) : null,
        ),

        const SizedBox(height: 12),

        // Secondary Action: "Review Later" (Figma Node 20:31384)
        GestureDetector(
          onTap: _isSaving ? null : () => _handleSubmit(isReviewLater: true),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              _isEn ? 'Review Later' : 'Revisar más tarde',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF494552),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Text(
          _isEn
              ? 'You can revise your consent preferences anytime from your Account Settings.'
              : 'Puedes modificar tus consentimientos en cualquier momento en Ajustes.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  /// Security Footnote (Figma Node 20:31389)
  Widget _buildSecurityFootnote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 14,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _isEn
                  ? 'HIPAA & GDPR Compliant • 256-bit AES Cryptographic Vault Encryption'
                  : 'Cumple con HIPAA y GDPR • Encriptación Criptográfica AES de 256 bits',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Backend Error Banner
  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), height: 1.3),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: const Icon(Icons.close, size: 16, color: Color(0xFF991B1B)),
          ),
        ],
      ),
    );
  }

  /// Client Validation Error Banner
  Widget _buildValidationErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  // Static Legal Text Documents for Modals
  static const String _termsOfServiceText = '''
CareID Patient Terms of Service
Version 2.1 — Updated October 2026

1. Account & Identity Verification
CareID provides decentralized digital identity credentials and a personal cryptographic health vault for patients. You agree to provide accurate information and safeguard your authentication credentials.

2. Patient Vault Ownership
All personal health information, laboratory reports, clinical notes, and insurance cards stored in your CareID Vault remain your sole and exclusive property. CareID acts solely as a zero-knowledge data custodian.

3. Cryptographic Health Passport
Your digital health passport is cryptographically signed and verifiable. You retain total discretion over when, where, and with whom your QR credentials are shared.

4. Revocation Rights
You maintain the right to revoke sharing permissions at any time. Revoking access terminates external provider keys immediately.

5. Emergency Access
If emergency access features are enabled, authorized medical responders may view essential life-saving data (e.g., blood type, severe allergies) solely in acute circumstances.

6. Limitation of Liability
CareID facilitates secure storage and transmission of health records and does not provide medical diagnosis, treatment, or clinical consultation.
''';

  static const String _privacyPolicyText = '''
CareID Patient Privacy Policy
Version 2.1 — Updated October 2026

1. Data Minimization & Encryption
CareID utilizes end-to-end 256-bit AES encryption at rest and TLS 1.3 in transit. Your personal health information is isolated and inaccessible to unauthorized third parties.

2. HIPAA & GDPR Compliance
CareID adheres strictly to the Health Insurance Portability and Accountability Act (HIPAA) Security and Privacy Rules and applicable international data protection standards.

3. Sharing With Healthcare Providers
Your records are never shared with doctors, clinics, hospitals, or pharmacies without your active, explicit consent or scanned QR authorization.

4. Advertising & Monetization
CareID will NEVER sell, rent, license, or monetize your identifiable or de-identified health data to commercial advertisers or data brokers.

5. Data Portability & Erasure
You have the permanent right to export your complete medical vault in standard FHIR/JSON formats, or request the permanent cryptographic erasure of your vault and identity records.
''';
}
