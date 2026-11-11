import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/language_toggle.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/registration_context.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../onboarding/presentation/screens/create_account_screen.dart';
import '../../../patient/data/repositories/patient_repository.dart';
import '../../../patient/presentation/screens/patient_main_navigation_shell.dart';
import 'account_recovery_screen.dart';

/// CareID Patient Login Screen
/// Faithfully reproduces Figma frame nodes:
/// - 20:24965 ("Login")
/// - 20:25032 ("OTP Verification - Refined States")
/// Supports phone-based OTP authentication with JWT session generation.
class LoginScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final AuthRepository? authRepository;
  final PatientRepository? patientRepository;
  final String language;

  const LoginScreen({
    super.key,
    this.apiClient,
    this.authRepository,
    this.patientRepository,
    this.language = 'en',
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+1');
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  late String _currentLanguage;
  late final AuthRepository _authRepository;
  late final PatientRepository _patientRepository;
  late final ApiClient _apiClient;

  bool _isOtpSent = false;
  String? _challengeId;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  bool _isLoading = false;
  String? _errorMessage = null;
  String? _infoMessage = null;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _apiClient = widget.apiClient ?? ApiClient();
    final effectiveTokenStorage =
        widget.authRepository?.tokenStorage ?? _apiClient.tokenStorage;
    _authRepository = widget.authRepository ??
        AuthRepository(apiClient: _apiClient, tokenStorage: effectiveTokenStorage);
    _patientRepository = widget.patientRepository ??
        PatientRepository(apiClient: _apiClient, tokenStorage: effectiveTokenStorage);

    _otpControllers = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _countryCodeController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _isEn => _currentLanguage == 'en';
  String get _otpCode => _otpControllers.map((c) => c.text).join();
  bool get _isOtpComplete =>
      _otpControllers.length == 6 &&
      _otpControllers.every((c) => c.text.trim().length == 1);

  static String _extractSixDigitOtp(String text) {
    final match = RegExp(r'\b\d{6}\b').firstMatch(text);
    if (match != null) {
      return match.group(0)!;
    }
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 6 ? digits.substring(0, 6) : digits;
  }

  String get _fullPhone {
    var raw = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    var code = _countryCodeController.text.trim();
    if (!code.startsWith('+')) {
      code = '+$code';
    }
    final codeDigits = code.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.startsWith(codeDigits) && raw.length > 10) {
      raw = raw.substring(codeDigits.length);
    } else if (code == '+1' && raw.startsWith('1') && raw.length == 11) {
      raw = raw.substring(1);
    }
    return '$code$raw';
  }

  void _showCountryPicker() {
    final countries = [
      {'code': '+1', 'name': 'United States / Canada', 'flag': '🇺🇸'},
      {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
      {'code': '+44', 'name': 'United Kingdom', 'flag': '🇬🇧'},
      {'code': '+52', 'name': 'Mexico', 'flag': '🇲🇽'},
      {'code': '+34', 'name': 'Spain', 'flag': '🇪🇸'},
      {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
      {'code': '+57', 'name': 'Colombia', 'flag': '🇨🇴'},
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _isEn ? 'Select Country Code' : 'Selecciona Código de País',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  ...countries.map((c) => ListTile(
                        leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
                        title: Text(c['name']!),
                        trailing: Text(c['code']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          setState(() {
                            _countryCodeController.text = c['code']!;
                          });
                          Navigator.pop(ctx);
                        },
                      )),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendOtp() async {
    if (_isLoading) return;

    final digits = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) {
      setState(() {
        _errorMessage = _isEn
            ? 'Please enter a valid 10-digit mobile number.'
            : 'Por favor ingresa un número de teléfono válido de 10 dígitos.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
      _challengeId = null; // Clear stale challenge ID
    });
    for (final c in _otpControllers) {
      c.clear();
    }

    final phone = _fullPhone;
    final result = await _authRepository.requestOtp(phone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (data, msg) {
        setState(() {
          _isOtpSent = true;
          _challengeId = data.challengeId;
          _infoMessage = _isEn
              ? 'Verification code sent to $phone.'
              : 'Código de verificación enviado a $phone.';
        });
        _startCountdown();
        // Focus first OTP field
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_otpFocusNodes.isNotEmpty) {
            _otpFocusNodes[0].requestFocus();
          }
        });
      },
      failure: (msg, code, err) {
        setState(() {
          if (code == 429) {
            _errorMessage = _isEn
                ? 'Too many login attempts. The backend rate limiter is active. Please try again in a few minutes.'
                : 'Demasiados intentos de acceso. El límite del servidor está activo. Intenta de nuevo en unos minutos.';
          } else {
            _errorMessage = msg;
          }
        });
      },
    );
  }

  Future<void> _pasteOtpFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = data?.text?.trim() ?? '';
    final code = _extractSixDigitOtp(raw);
    if (code.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = code[i];
      }
      _otpFocusNodes[5].requestFocus();
      await _handleVerifyOtp();
    } else {
      setState(() {
        _errorMessage = _isEn
            ? 'No valid 6-digit code found in clipboard.'
            : 'No se encontró un código válido de 6 dígitos en el portapapeles.';
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_isLoading) return;

    if (!_isOtpComplete) {
      setState(() {
        _errorMessage = _isEn
            ? 'Please enter the complete 6-digit code.'
            : 'Por favor ingresa el código completo de 6 dígitos.';
      });
      return;
    }

    final code = _otpCode;

    if (_challengeId == null || _challengeId!.isEmpty) {
      setState(() {
        _errorMessage = _isEn
            ? 'Challenge ID missing. Please resend code.'
            : 'Falta la sesión de verificación. Por favor reenvía el código.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Step 6: Frontend sends exact verification payload expected by backend
    final result = await _authRepository.verifyOtp(
      challengeId: _challengeId!,
      otpCode: code,
    );

    if (!mounted) return;

    await result.when(
      success: (data, msg) async {
        // Step 7: Backend returns access and refresh tokens.
        // Step 8: Frontend securely persists the tokens (saved in AuthRepository).
        // Step 9: Authenticated patient profile is retrieved with robust connect timeout.
        RegistrationContext? regCtx;
        try {
          final profileRes = await _patientRepository
              .getPatientProfile()
              .timeout(AppConfig.connectTimeout);
          profileRes.when(
            success: (profile, _) {
              regCtx = RegistrationContext(
                fullName: profile.fullName,
                phone: profile.phone ?? _fullPhone,
                email: profile.email ?? '',
                bloodGroup: profile.bloodGroup ?? 'O+',
                careIdNumber: profile.patientNumber ?? 'HC-CAREID-2026-0004',
                chronicConditions: profile.conditions,
                knownAllergies: profile.allergies,
                currentMedications: profile.medications,
                profileId: profile.id,
              );
            },
            failure: (_, __, ___) {},
          );
        } catch (_) {}

        if (!mounted) return;
        setState(() => _isLoading = false);

        // Step 10: Patient is redirected to the correct home screen.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (context) => PatientMainNavigationShell(
              apiClient: _apiClient,
              language: _currentLanguage,
              registrationContext: regCtx,
            ),
          ),
          (route) => false,
        );
      },
      failure: (msg, code, err) async {
        setState(() {
          _isLoading = false;
          if (code == 401) {
            _errorMessage = _isEn
                ? 'Invalid verification code. Please check the code and try again.'
                : 'Código de verificación inválido. Por favor verifica e intenta de nuevo.';
          } else {
            _errorMessage = msg;
          }
        });
        // Clear cells on failure
        for (final c in _otpControllers) {
          c.clear();
        }
        if (_otpFocusNodes.isNotEmpty) {
          _otpFocusNodes[0].requestFocus();
        }
      },
    );
  }

  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0 || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    final String? nextChallengeId;
    if (_challengeId != null && _challengeId!.isNotEmpty) {
      final resendResult = await _authRepository.resendOtp(_challengeId!);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (resendResult.isSuccess) {
        nextChallengeId = resendResult.dataOrNull?.challengeId;
      } else {
        setState(() => _errorMessage = resendResult.messageOrNull);
        return;
      }
    } else {
      final requestResult = await _authRepository.requestOtp(_fullPhone);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (requestResult.isSuccess) {
        nextChallengeId = requestResult.dataOrNull?.challengeId;
      } else {
        setState(() => _errorMessage = requestResult.messageOrNull);
        return;
      }
    }

    setState(() {
      _challengeId = nextChallengeId;
      _infoMessage = _isEn
          ? 'New verification code sent.'
          : 'Nuevo código de verificación enviado.';
    });
    for (final c in _otpControllers) {
      c.clear();
    }
    if (_otpFocusNodes.isNotEmpty) {
      _otpFocusNodes[0].requestFocus();
    }
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Branding Header (CareIdLogo + Language Selector)
              _buildTopHeader(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // 2. Navigation Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderMedium),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. Screen Title & Subtitle
                    Text(
                      _isEn ? 'Welcome Back' : 'Bienvenido de nuevo',
                      style: AppTypography.heading1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isOtpSent
                          ? (_isEn
                              ? 'Enter the 6-digit code sent to $_fullPhone'
                              : 'Ingresa el código de 6 dígitos enviado a $_fullPhone')
                          : (_isEn
                              ? 'Sign in to access your secure CareID Health Vault and verifiable records.'
                              : 'Inicia sesión para acceder a tu Bóveda de Salud CareID y registros verificables.'),
                      style: AppTypography.subtitle,
                    ),

                    const SizedBox(height: 24),

                    // 4. Diagnostic messages
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(_errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    if (_infoMessage != null) ...[
                      _buildInfoBanner(_infoMessage!),
                      const SizedBox(height: 16),
                    ],

                    // 5. Main Form Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderMedium),
                        boxShadow: AppSpacing.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isOtpSent) ...[
                            Text(
                              _isEn ? 'Mobile Number' : 'Número de Teléfono',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Country code selector button
                                InkWell(
                                  onTap: _isLoading ? null : _showCountryPicker,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.borderMedium),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _countryCodeController.text,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(
                                          Icons.arrow_drop_down_rounded,
                                          size: 20,
                                          color: AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Phone number text field
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(15),
                                    ],
                                    onChanged: (val) {
                                      final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                                      if (_countryCodeController.text == '+1' && clean.startsWith('1') && clean.length > 10) {
                                        final stripped = clean.substring(1);
                                        _phoneController.value = TextEditingValue(
                                          text: stripped,
                                          selection: TextSelection.collapsed(offset: stripped.length),
                                        );
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: '650 555 0004',
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.borderMedium),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.borderMedium),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.purplePrimary, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: _isEn ? 'Send Verification Code' : 'Enviar Código',
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _handleSendOtp,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => AccountRecoveryScreen(
                                        authRepository: _authRepository,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  _isEn
                                      ? 'Lost access to phone? Recover account'
                                      : '¿Perdiste acceso? Recuperar cuenta',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.purplePrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // OTP verification state
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isEn ? 'Enter 6-Digit Code' : 'Ingresa Código de 6 Dígitos',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => setState(() => _isOtpSent = false),
                                  child: Text(
                                    _isEn ? 'Change Phone' : 'Cambiar',
                                    style: const TextStyle(fontSize: 13, color: AppColors.purplePrimary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // 6 OTP boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: 44,
                                  height: 52,
                                  child: Focus(
                                    onKeyEvent: (node, event) {
                                      if (event is KeyDownEvent &&
                                          event.logicalKey == LogicalKeyboardKey.backspace) {
                                        if (_otpControllers[index].text.isEmpty && index > 0) {
                                          _otpControllers[index - 1].clear();
                                          _otpFocusNodes[index - 1].requestFocus();
                                          return KeyEventResult.handled;
                                        }
                                      }
                                      return KeyEventResult.ignored;
                                    },
                                    child: TextField(
                                      controller: _otpControllers[index],
                                      focusNode: _otpFocusNodes[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppColors.borderMedium),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppColors.purplePrimary, width: 2),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        if (val.length > 2) {
                                          final code = _extractSixDigitOtp(val);
                                          for (int i = 0; i < code.length && i < 6; i++) {
                                            _otpControllers[i].text = code[i];
                                          }
                                          if (code.length >= 6) {
                                            _otpFocusNodes[5].requestFocus();
                                            _handleVerifyOtp();
                                          } else {
                                            _otpFocusNodes[code.length.clamp(0, 5)].requestFocus();
                                          }
                                          return;
                                        }
                                        if (val.length == 2) {
                                          final latestChar = val[1];
                                          _otpControllers[index].value = TextEditingValue(
                                            text: latestChar,
                                            selection: const TextSelection.collapsed(offset: 1),
                                          );
                                          if (index < 5) {
                                            _otpFocusNodes[index + 1].requestFocus();
                                          }
                                        } else if (val.length == 1 && index < 5) {
                                          _otpFocusNodes[index + 1].requestFocus();
                                        } else if (val.isEmpty && index > 0) {
                                          _otpFocusNodes[index - 1].requestFocus();
                                        }

                                        if (_isOtpComplete) {
                                          _handleVerifyOtp();
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton.icon(
                                icon: const Icon(Icons.content_paste_rounded, size: 16, color: AppColors.purplePrimary),
                                label: Text(
                                  _isEn ? 'Paste Code' : 'Pegar Código',
                                  style: const TextStyle(fontSize: 13, color: AppColors.purplePrimary, fontWeight: FontWeight.w600),
                                ),
                                onPressed: _isLoading ? null : _pasteOtpFromClipboard,
                              ),
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: _isEn ? 'Verify & Sign In' : 'Verificar e Iniciar Sesión',
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _handleVerifyOtp,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: (_resendCountdown == 0 && !_isLoading)
                                    ? _handleResendOtp
                                    : null,
                                child: Text(
                                  _resendCountdown > 0
                                      ? (_isEn
                                          ? 'Resend SMS in ${_resendCountdown}s'
                                          : 'Reenviar SMS en ${_resendCountdown}s')
                                      : (_isEn ? 'Resend SMS' : 'Reenviar SMS'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _resendCountdown > 0
                                        ? AppColors.textSecondary
                                        : AppColors.purplePrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 6. Security Assurance Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security_rounded, size: 20, color: AppColors.purplePrimary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isEn
                                  ? 'CareID uses end-to-end cryptographic authentication. Your patient data is always encrypted.'
                                  : 'CareID utiliza autenticación criptográfica de extremo a extremo. Tus datos siempre están cifrados.',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 7. Don't have account footer link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _isEn ? "Don't have an account?" : '¿No tienes una cuenta?',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (context) => CreateAccountScreen(
                                  apiClient: _apiClient,
                                  language: _currentLanguage,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            _isEn ? 'Create Account' : 'Crear Cuenta',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.purplePrimary,
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
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
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

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E40AF)),
            ),
          ),
        ],
      ),
    );
  }
}
