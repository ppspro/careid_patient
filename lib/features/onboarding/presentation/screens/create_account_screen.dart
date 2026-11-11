import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/data/models/register_patient_request.dart';
import '../../../auth/data/repositories/registration_repository.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'mobile_number_screen.dart';

/// CareID Create Account Screen
/// Faithfully reproduces Figma frame node 20:30644 ("CareID-Create Account")
/// Step 1 of the initial 6-step patient registration journey.
class CreateAccountScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final RegistrationRepository? registrationRepository;
  final String language;

  const CreateAccountScreen({
    super.key,
    this.apiClient,
    this.registrationRepository,
    this.language = 'en',
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  late final RegistrationRepository _registrationRepository;
  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _registrationRepository =
        widget.registrationRepository ??
        RegistrationRepository(apiClient: _apiClient);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isEn => widget.language == 'en';

  /// Calculates password complexity score [0.0 - 1.0].
  double get _passwordStrength {
    final pwd = _passwordController.text;
    if (pwd.isEmpty) return 0.0;
    double score = 0.0;
    if (pwd.length >= 8) score += 0.3;
    if (pwd.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (pwd.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (pwd.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s < 0.4) return AppColors.error;
    if (s < 0.7) return AppColors.warning;
    return AppColors.success;
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s == 0.0) return '';
    if (s < 0.4) return _isEn ? 'Weak' : 'Débil';
    if (s < 0.7) return _isEn ? 'Medium' : 'Media';
    return _isEn ? 'Strong' : 'Fuerte';
  }

  Future<void> _submitRegistration() async {
    // Prevent duplicate submissions
    if (_isSubmitting || _registrationRepository.isInFlight) return;

    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      setState(() {
        _errorMessage = _isEn
            ? 'Please accept the Terms & Privacy Agreement to continue.'
            : 'Acepte los Términos y la Política de Privacidad para continuar.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final request = RegisterPatientRequest(
      fullName: _fullNameController.text.trim(),
      phone: _mobileController.text.trim(),
      email: _emailController.text.trim(),
    );

    final result = await _registrationRepository.registerPatient(request);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    result.when(
      success: (contextData, message) {
        // Continue to Step 2: Mobile Number & OTP Verification (Frame 20:30756)
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => MobileNumberScreen(
              registrationContext: contextData,
              apiClient: _apiClient,
              language: widget.language,
            ),
          ),
        );
      },
      failure: (message, statusCode, error) {
        // Display inline error and preserve entered form data
        setState(() {
          _errorMessage = message;
        });
      },
    );
  }

  void _showTermsModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
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
            const SizedBox(height: 16),
            const Text(
              'Terms of Service & Privacy Policy',
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),
            const Text(
              'CareID Health Vault — Patient Data Custody Agreement',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.tealPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Text(
                  '1. Patient Data Custody & Encryption\n'
                  'CareID operates under zero-knowledge encryption protocols. Your medical records, dental charts, optical prescriptions, and pet veterinary files are protected with AES-256 at rest and TLS 1.3 in transit.\n\n'
                  '2. Verification & HIPAA Compliance\n'
                  'CareID complies with HIPAA and international data security standards. Your phone number is verified via clinical multi-factor challenge to ensure that only authorized custodians access your digital health card.\n\n'
                  '3. Consent Revocation\n'
                  'You retain full sovereignty over your patient health records. You may grant or revoke access to providers, clinics, and family members at any time from your CareID dashboard.\n\n'
                  '4. Emergency Access Protocol\n'
                  'When emergency flags are activated, certified trauma responders may view vital health summaries via your verified QR card.',
                  style: AppTypography.body,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: _isEn ? 'I Understand & Agree' : 'Entendido y Acepto',
              onPressed: () {
                setState(() => _agreedToTerms = true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEn ? 'Create Account' : 'Crear Cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header Section (Figma Node 20:30660, 107x64 stacked)
                    const CareIdLogo.stacked(width: 107, height: 64),
                    const SizedBox(height: 16),
                    Text(
                      _isEn
                          ? 'Create Your CareID Account'
                          : 'Cree su cuenta CareID',
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEn
                          ? 'Enter your information to register your secure digital health card.'
                          : 'Ingrese sus datos para registrar su tarjeta de salud digital segura.',
                      style: AppTypography.subtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Inline Error Banner
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              color: const Color(0xFFB91C1C),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  setState(() => _errorMessage = null),
                            ),
                          ],
                        ),
                      ),

                    // 1. Full Name Field (Figma Node 20:30669)
                    _buildTextField(
                      controller: _fullNameController,
                      label: _isEn ? 'Full Name' : 'Nombre Completo',
                      hint: _isEn
                          ? 'Enter your full name'
                          : 'Ingrese su nombre completo',
                      icon: Icons.person_outline_rounded,
                      autofillHints: const [AutofillHints.name],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return _isEn
                              ? 'Full name is required'
                              : 'El nombre completo es requerido';
                        }
                        if (v.trim().length < 2) {
                          return _isEn
                              ? 'Name must be at least 2 characters'
                              : 'El nombre debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 2. Mobile Number Field (Figma Node 20:30678)
                    _buildPhoneField(),
                    const SizedBox(height: 14),

                    // 3. Email Field (Figma Node 20:30690)
                    _buildTextField(
                      controller: _emailController,
                      label: _isEn ? 'Email Address' : 'Correo Electrónico',
                      hint: _isEn
                          ? 'Enter your email address'
                          : 'Ingrese su correo electrónico',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return _isEn
                              ? 'Email address is required'
                              : 'El correo electrónico es requerido';
                        }
                        if (!RegisterPatientRequest.isValidEmail(v)) {
                          return _isEn
                              ? 'Enter a valid email address (e.g. name@example.com)'
                              : 'Ingrese un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 4. Password Field (Figma Node 20:30699)
                    _buildTextField(
                      controller: _passwordController,
                      label: _isEn ? 'Password' : 'Contraseña',
                      hint: _isEn ? 'Create a password' : 'Cree una contraseña',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return _isEn
                              ? 'Password is required'
                              : 'La contraseña es requerida';
                        }
                        if (v.length < 8) {
                          return _isEn
                              ? 'Password must be at least 8 characters'
                              : 'La contraseña debe tener al menos 8 caracteres';
                        }
                        return null;
                      },
                    ),

                    // Password Strength Indicator (Figma Node 20:30712)
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _passwordStrength,
                                color: _strengthColor,
                                backgroundColor: AppColors.borderLight,
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _strengthColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),

                    // 5. Confirm Password Field (Figma Node 20:30717)
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: _isEn
                          ? 'Confirm Password'
                          : 'Confirmar Contraseña',
                      hint: _isEn
                          ? 'Re-enter your password'
                          : 'Vuelva a ingresar su contraseña',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                      validator: (String? v) {
                        if (v != _passwordController.text) {
                          return _isEn
                              ? 'Passwords do not match'
                              : 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Terms & Privacy Agreement Checkbox (Figma Node 20:30730)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          activeColor: AppColors.purplePrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (bool? val) =>
                              setState(() => _agreedToTerms = val ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Wrap(
                              children: [
                                Text(
                                  _isEn ? 'I agree to the ' : 'Acepto los ',
                                  style: AppTypography.body,
                                ),
                                GestureDetector(
                                  onTap: _showTermsModal,
                                  child: Text(
                                    _isEn
                                        ? 'Terms of Service'
                                        : 'Términos de Servicio',
                                    style: const TextStyle(
                                      color: AppColors.purplePrimary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text(
                                  _isEn ? ' and ' : ' y la ',
                                  style: AppTypography.body,
                                ),
                                GestureDetector(
                                  onTap: _showTermsModal,
                                  child: Text(
                                    _isEn
                                        ? 'Privacy Policy'
                                        : 'Política de Privacidad',
                                    style: const TextStyle(
                                      color: AppColors.purplePrimary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text(
                                  _isEn
                                      ? ', and consent to CareID vault storage.'
                                      : ', y doy mi consentimiento para el almacenamiento en CareID.',
                                  style: AppTypography.body,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button CTA (Figma Node 20:30741)
                    PrimaryButton(
                      label: _isEn
                          ? 'Continue to Step 2'
                          : 'Continuar al Paso 2',
                      isLoading: _isSubmitting,
                      onPressed: _submitRegistration,
                    ),

                    const SizedBox(height: 20),

                    // Sign In Navigation Link (Figma Node 20:30747)
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _isEn
                              ? 'Already have an account? '
                              : '¿Ya tiene una cuenta? ',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => LoginScreen(
                                  apiClient: widget.apiClient,
                                  language: widget.language,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            _isEn ? 'Sign In' : 'Iniciar Sesión',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.purplePrimary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Footer Trust Notice (Figma Node 20:30750)
                    const Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: AppColors.tealPrimary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '256-bit Encrypted • HIPAA Ready Security',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEn ? 'Mobile Number' : 'Número Móvil',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          validator: (String? v) {
            if (v == null || v.trim().isEmpty) {
              return _isEn
                  ? 'Mobile number is required'
                  : 'El número móvil es requerido';
            }
            if (!RegisterPatientRequest.isValidPhone(v)) {
              return _isEn
                  ? 'Enter a valid 10-digit mobile number'
                  : 'Ingrese un número móvil válido de 10 dígitos';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: '(555) 000-0000',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 12),
                const Icon(
                  Icons.phone_iphone_rounded,
                  color: AppColors.purplePrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '+1',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(height: 20, width: 1, color: AppColors.borderMedium),
                const SizedBox(width: 8),
              ],
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderMedium),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderLight,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.purplePrimary,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(icon, color: AppColors.purplePrimary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderMedium),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderLight,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.purplePrimary,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
