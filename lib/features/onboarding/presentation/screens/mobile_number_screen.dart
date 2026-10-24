import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/language_toggle.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import 'health_info_screen.dart';

/// CareID Mobile Number & OTP Verification Screen
/// Faithfully reproduces Figma frame node 20:30756 ("Mobile_number")
/// Step 2 of 6 in the Patient Registration Journey.
class MobileNumberScreen extends StatefulWidget {
  final RegistrationContext registrationContext;
  final ApiClient? apiClient;
  final AuthRepository? authRepository;
  final String language;

  const MobileNumberScreen({
    super.key,
    required this.registrationContext,
    this.apiClient,
    this.authRepository,
    this.language = 'en',
  });

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  late String _currentLanguage;
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  late final AuthRepository _authRepository;
  String? _challengeId;

  int _resendCountdown = 60;
  Timer? _countdownTimer;

  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());

    _authRepository =
        widget.authRepository ?? AuthRepository(apiClient: widget.apiClient);
    _challengeId = widget.registrationContext.challengeId;

    _startCountdown();

    // If challengeId was not initialized during registration, request it now
    if (_challengeId == null || _challengeId!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestInitialOtp();
      });
    }
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

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  bool get _isEn => _currentLanguage == 'en';

  /// Initial OTP dispatch if not already initiated
  Future<void> _requestInitialOtp() async {
    setState(() {
      _isRequestingOtp = true;
      _errorMessage = null;
    });

    final result = await _authRepository.requestOtp(
      widget.registrationContext.phone,
    );

    if (!mounted) return;

    setState(() => _isRequestingOtp = false);

    result.when(
      success: (data, msg) {
        setState(() {
          _challengeId = data.challengeId;
          _infoMessage =
              msg ?? (_isEn ? 'Verification code sent.' : 'Código enviado.');
        });
      },
      failure: (msg, code, err) {
        setState(() {
          _errorMessage = msg;
        });
      },
    );
  }

  /// Verifies the entered 6-digit OTP code against the backend
  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length < 6) {
      setState(() {
        _errorMessage = _isEn
            ? 'Please enter the complete 6-digit verification code.'
            : 'Ingrese el código de verificación completo de 6 dígitos.';
      });
      return;
    }

    if (_challengeId == null || _challengeId!.isEmpty) {
      setState(() {
        _errorMessage = _isEn
            ? 'Challenge session identifier missing. Please tap "Resend SMS" to request a new code.'
            : 'Falta el identificador de sesión. Toque "Reenviar SMS" para solicitar un nuevo código.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    final result = await _authRepository.verifyOtp(
      challengeId: _challengeId!,
      otpCode: code,
    );

    if (!mounted) return;

    setState(() => _isVerifying = false);

    result.when(
      success: (tokens, msg) {
        // Update registration context with verified status and next step
        final updatedContext = widget.registrationContext.copyWith(
          onboardingStep: 3,
          status: 'VERIFIED',
          challengeId: _challengeId,
        );

        // Navigate to Step 3: Health Info Screen (Figma Frame 20:30900)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => HealthInfoScreen(
              registrationContext: updatedContext,
              apiClient: widget.apiClient,
              language: _currentLanguage,
            ),
          ),
        );
      },
      failure: (msg, code, err) {
        setState(() {
          _errorMessage = msg;
          // Clear OTP cells to prompt re-entry
          for (final c in _otpControllers) {
            c.clear();
          }
          if (_otpFocusNodes.isNotEmpty) {
            _otpFocusNodes[0].requestFocus();
          }
        });
      },
    );
  }

  /// Resends an OTP to the registered mobile number
  Future<void> _resendOtp() async {
    if (_isResending || _resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    final result = (_challengeId != null && _challengeId!.isNotEmpty)
        ? await _authRepository.resendOtp(_challengeId!)
        : await _authRepository.requestOtp(widget.registrationContext.phone);

    if (!mounted) return;

    setState(() => _isResending = false);

    result.when(
      success: (data, msg) {
        setState(() {
          final dynamic resData = data;
          if (resData != null && resData.challengeId != null) {
            _challengeId = resData.challengeId.toString();
          }
          _infoMessage = _isEn
              ? 'New verification code dispatched to your phone.'
              : 'Nuevo código de verificación enviado a su teléfono.';
        });
        _startCountdown();
      },
      failure: (msg, code, err) {
        setState(() => _errorMessage = msg);
      },
    );
  }

  /// Handles paste, auto-focus traversal, and backspace
  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (value.length > 1) {
        // User pasted multiple digits (e.g. "123456")
        final digits = value.replaceAll(RegExp(r'\D'), '').split('');
        for (int i = 0; i < digits.length && (index + i) < 6; i++) {
          _otpControllers[index + i].text = digits[i];
        }
        final nextIndex = (index + digits.length).clamp(0, 5);
        _otpFocusNodes[nextIndex].requestFocus();
      } else if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    final hasCompleteCode = _otpCode.length == 6;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Branding & Back Navigation (Figma Node 20:30890)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const CareIdLogo(size: 64),
                  LanguageToggle(
                    currentLanguage: _currentLanguage,
                    onLanguageChanged: (String lang) =>
                        setState(() => _currentLanguage = lang),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Step Progress Indicator: Step 2 of 6 (Figma Node 20:30759)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isEn
                                  ? 'Mobile Verification'
                                  : 'Verificación móvil',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.purplePrimary,
                              ),
                            ),
                            const Text(
                              'Step 2 of 6',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 2.0 / 6.0,
                            color: AppColors.purplePrimary,
                            backgroundColor: AppColors.borderLight,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title & Context Area (Figma Node 20:30768)
                        Text(
                          _isEn
                              ? 'Verify your mobile number'
                              : 'Verifique su número móvil',
                          style: AppTypography.heading1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isEn
                              ? 'We sent a 6-digit verification code to your registered mobile number.'
                              : 'Enviamos un código de verificación de 6 dígitos a su número registrado.',
                          style: AppTypography.subtitle,
                        ),
                        const SizedBox(height: 20),

                        // Masked Phone Badge with Action (Figma Node 20:30775)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.tealLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.phone_iphone_rounded,
                                  color: AppColors.tealPrimary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Registered Phone',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.registrationContext.maskedPhone,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.edit_outlined, size: 14),
                                label: const Text(
                                  'Change',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.tealPrimary,
                                  side: const BorderSide(
                                    color: AppColors.tealAccent,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Autofill Chip Helper (Figma Node 20:30790)
                        Center(
                          child: InkWell(
                            onTap: () {
                              const testCode = '123456';
                              for (int i = 0; i < 6; i++) {
                                _otpControllers[i].text = testCode[i];
                              }
                              setState(() => _errorMessage = null);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE9D5FF),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.sms_outlined,
                                    size: 14,
                                    color: AppColors.purplePrimary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Autofill code: 123456',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.purplePrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Verification Code Section (Figma Node 20:30797)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Verification Code',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 14,
                                  color: AppColors.tealPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _resendCountdown > 0
                                      ? 'Expires in ${_resendCountdown}s'
                                      : 'Expired',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _resendCountdown > 0
                                        ? AppColors.textSecondary
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 6 OTP Input Boxes with auto-focus & backspace support
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 50,
                              height: 56,
                              child: RawKeyboardListener(
                                focusNode: FocusNode(),
                                onKey: (RawKeyEvent event) {
                                  if (event is RawKeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.backspace) {
                                    if (_otpControllers[index].text.isEmpty &&
                                        index > 0) {
                                      _otpControllers[index - 1].clear();
                                      _otpFocusNodes[index - 1].requestFocus();
                                    }
                                  }
                                },
                                child: TextFormField(
                                  controller: _otpControllers[index],
                                  focusNode: _otpFocusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.purplePrimary,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.borderMedium,
                                        width: 1.2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.purplePrimary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (String val) =>
                                      _onOtpChanged(index, val),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),

                        // Inline Info Message
                        if (_infoMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF86EFAC),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _infoMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFF166534),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Inline Error Banner (Figma Node 20:30831)
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5),
                              ),
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
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                  ),
                                  color: const Color(0xFFB91C1C),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () =>
                                      setState(() => _errorMessage = null),
                                ),
                              ],
                            ),
                          ),

                        // Timer & Resend Controls (Figma Node 20:30843)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    (_resendCountdown == 0 && !_isResending)
                                    ? _resendOtp
                                    : null,
                                icon: _isResending
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.refresh_rounded,
                                        size: 16,
                                      ),
                                label: Text(
                                  _resendCountdown > 0
                                      ? 'Resend (${_resendCountdown}s)'
                                      : 'Resend SMS',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.purplePrimary,
                                  side: const BorderSide(
                                    color: AppColors.borderMedium,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Voice call verification scheduled for subsequent release.',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.phone_in_talk_rounded,
                                  size: 16,
                                ),
                                label: const Text('Call me instead'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.tealPrimary,
                                  side: const BorderSide(
                                    color: AppColors.borderMedium,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Primary Verification Action CTA (Figma Node 20:30864)
                        PrimaryButton(
                          label: _isEn
                              ? 'Verify & Continue'
                              : 'Verificar y Continuar',
                          isLoading: _isVerifying || _isRequestingOtp,
                          onPressed: hasCompleteCode ? _verifyOtp : null,
                        ),
                        const SizedBox(height: 24),

                        // Trust & Security Reassurance Card (Figma Node 20:30874)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.tealLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.tealPrimary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Two-Step Clinical Safeguard',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Binding your verifiable phone number ensures that only you can authorize access to your encrypted medical records and patient health cards.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Support Footer Action (Figma Node 20:30886)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Need help? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'CareID Patient Support: support@careid.health',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Contact Care ID Support',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.purplePrimary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
