import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../data/models/insurance_models.dart';
import '../../data/repositories/onboarding_repository.dart';
import 'privacy_consents_screen.dart';

/// CareID Add Insurance Info Screen
/// Faithfully implements Step 4 of 6 in Patient Onboarding (Figma Node 20:33068, "Add Insurance Info").
/// Also covers and aligns with Insurance Intake sub-flows:
/// - 20:20311 ("Add Insurance - Select Method")
/// - 20:20258 ("Insurance Card - Camera Capture")
/// - 20:20415 ("OCR Processing - Insurance Card")
/// - 20:20517 ("OCR Extraction Results")
/// - 20:20723 ("Manual Review & Edit")
/// - 20:20890 ("Insurance Card Details")
/// Follows Step 3 (Health Information & Demographics).
class AddInsuranceScreen extends StatefulWidget {
  final RegistrationContext registrationContext;
  final ApiClient? apiClient;
  final OnboardingRepository? onboardingRepository;
  final String language;

  const AddInsuranceScreen({
    super.key,
    required this.registrationContext,
    this.apiClient,
    this.onboardingRepository,
    this.language = 'en',
  });

  @override
  State<AddInsuranceScreen> createState() => _AddInsuranceScreenState();
}

class _AddInsuranceScreenState extends State<AddInsuranceScreen> {
  late String _currentLanguage;
  late OnboardingRepository _repository;

  // Form Controllers
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _memberIdController = TextEditingController();
  final TextEditingController _groupNumberController = TextEditingController();

  // Focus Nodes
  final FocusNode _providerFocus = FocusNode();
  final FocusNode _memberIdFocus = FocusNode();
  final FocusNode _groupNumberFocus = FocusNode();

  // Field-level error messages
  String? _providerError;
  String? _memberIdError;
  String? _groupNumberError;

  // Submission & Network State
  bool _isSaving = false;
  String? _errorMessage;

  // Card Scanning / Camera State
  bool _isScanningCard = false;
  String? _scannedCardNotice;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _repository =
        widget.onboardingRepository ??
        OnboardingRepository(
          apiClient: widget.apiClient,
          tokenStorage: widget.apiClient?.tokenStorage,
        );

    // Pre-hydrate from RegistrationContext if available
    if (widget.registrationContext.insuranceProvider != null) {
      _providerController.text = widget.registrationContext.insuranceProvider!;
    }
    if (widget.registrationContext.insuranceMemberId != null) {
      _memberIdController.text = widget.registrationContext.insuranceMemberId!;
    }
    if (widget.registrationContext.insuranceGroupNumber != null) {
      _groupNumberController.text =
          widget.registrationContext.insuranceGroupNumber!;
    }
  }

  @override
  void dispose() {
    _providerController.dispose();
    _memberIdController.dispose();
    _groupNumberController.dispose();
    _providerFocus.dispose();
    _memberIdFocus.dispose();
    _groupNumberFocus.dispose();
    super.dispose();
  }

  bool get _isEn => _currentLanguage == 'en';

  void _validateProvider() {
    setState(() {
      if (!OnboardInsuranceDto.isValidProviderName(_providerController.text)) {
        _providerError = _isEn
            ? 'Please enter a valid insurance provider.'
            : 'Ingresa un proveedor de seguro válido.';
      } else {
        _providerError = null;
      }
    });
  }

  void _validateMemberId() {
    setState(() {
      if (!OnboardInsuranceDto.isValidPolicyNumber(_memberIdController.text)) {
        _memberIdError = _isEn
            ? 'Please enter a valid member ID (at least 3 characters).'
            : 'Ingresa un ID de miembro válido (al menos 3 caracteres).';
      } else {
        _memberIdError = null;
      }
    });
  }

  void _validateGroupNumber() {
    setState(() {
      if (!OnboardInsuranceDto.isValidGroupNumber(
        _groupNumberController.text,
      )) {
        _groupNumberError = _isEn
            ? 'Invalid group number format.'
            : 'Formato de número de grupo inválido.';
      } else {
        _groupNumberError = null;
      }
    });
  }

  /// Handles card scan via camera simulation modal
  Future<void> _handleScanCard() async {
    setState(() {
      _errorMessage = null;
    });

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF3F1D8B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEn
                        ? 'Scan Insurance Card'
                        : 'Escanear Tarjeta de Seguro',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isEn
                    ? 'Align your insurance card inside the viewfinder. Ensure good lighting.'
                    : 'Alinea tu tarjeta de seguro en el visor. Asegúrate de tener buena luz.',
                style: const TextStyle(fontSize: 14, color: Color(0xFF494552)),
              ),
              const SizedBox(height: 20),
              // Viewfinder frame
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1C30).withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF5B14B8),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.credit_card,
                        size: 48,
                        color: Color(0xFF5B14B8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEn
                            ? 'Front of Insurance Card'
                            : 'Frente de la Tarjeta de Seguro',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      Text(
                        _isEn
                            ? 'Payer name • Member ID • RxBIN'
                            : 'Nombre del pagador • ID de miembro',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF767676),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: _isEn
                    ? 'Take Photo with Camera'
                    : 'Tomar Foto con Cámara',
                onPressed: () {
                  Navigator.pop(ctx);
                  _pickAndProcessCardImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: _isEn
                    ? 'Choose from Gallery'
                    : 'Seleccionar de Galería',
                onPressed: () {
                  Navigator.pop(ctx);
                  _pickAndProcessCardImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  _isEn ? 'Cancel' : 'Cancelar',
                  style: const TextStyle(color: Color(0xFF494552)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Captures or selects an insurance card image and submits to backend OCR extraction
  /// POST /api/v1/insurance/ocr/scan
  Future<void> _pickAndProcessCardImage(ImageSource source) async {
    setState(() {
      _isScanningCard = true;
      _scannedCardNotice = null;
      _errorMessage = null;
    });

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        // User cancelled image selection or capture
        if (mounted) {
          setState(() {
            _isScanningCard = false;
          });
        }
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = pickedFile.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      final dataUri = 'data:$mimeType;base64,$base64Image';

      // Submit to supported CareID backend OCR endpoint
      final ocrResult = await _repository.scanInsuranceCard(
        InsuranceOcrScanDto(imageUrl: dataUri),
      );

      if (!mounted) return;

      ocrResult.when(
        success: (Map<String, dynamic> data, String? message) {
          final extracted = data['extractedData'] is Map<String, dynamic>
              ? data['extractedData'] as Map<String, dynamic>
              : (data['extracted'] is Map<String, dynamic>
                  ? data['extracted'] as Map<String, dynamic>
                  : data);

          final provider = extracted['providerName']?.toString();
          final policyNumber = extracted['policyNumber']?.toString();
          final groupNumber = extracted['groupNumber']?.toString() ??
              extracted['coverageDetails']?.toString();

          setState(() {
            _isScanningCard = false;
            if (provider != null && provider.isNotEmpty) {
              _providerController.text = provider;
            }
            if (policyNumber != null && policyNumber.isNotEmpty) {
              _memberIdController.text = policyNumber;
            }
            if (groupNumber != null && groupNumber.isNotEmpty) {
              _groupNumberController.text = groupNumber;
            }
            _providerError = null;
            _memberIdError = null;
            _groupNumberError = null;
            _scannedCardNotice = _isEn
                ? 'Card details successfully extracted from image via OCR! Please review and verify the information below.'
                : '¡Datos de la tarjeta extraídos mediante OCR! Revisa y verifica la información abajo.';
          });
        },
        failure: (String errorMessage, int? statusCode, Object? error) {
          setState(() {
            _isScanningCard = false;
            // Transparently report the backend response and provide manual-entry fallback
            _scannedCardNotice = _isEn
                ? 'Card image captured. Backend OCR returned: $errorMessage. You can enter your policy details manually below.'
                : 'Tarjeta capturada. El OCR del servidor respondió: $errorMessage. Puedes ingresar los datos manualmente abajo.';
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanningCard = false;
        _scannedCardNotice = _isEn
            ? 'Camera / file access note: $e. You can enter your policy details manually below.'
            : 'Nota de acceso a cámara: $e. Puedes ingresar los datos manualmente abajo.';
      });
    }
  }

  /// Submits the insurance information payload or skips
  Future<void> _handleSubmit({bool isSkipping = false}) async {
    if (_isSaving) return;

    if (isSkipping) {
      final skippedContext = widget.registrationContext.copyWith(
        onboardingStep: 5,
        isInsuranceSkipped: true,
      );
      _navigateToNextStep(skippedContext);
      return;
    }

    _validateProvider();
    _validateMemberId();
    _validateGroupNumber();

    if (_providerError != null ||
        _memberIdError != null ||
        _groupNumberError != null) {
      return;
    }

    final dto = OnboardInsuranceDto(
      providerName: _providerController.text.trim(),
      policyNumber: _memberIdController.text.trim(),
      groupNumber: _groupNumberController.text.trim().isEmpty
          ? null
          : _groupNumberController.text.trim(),
    );

    final validationError = dto.validate();
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    // Update local registration context with entered insurance details
    final updatedContext = widget.registrationContext.copyWith(
      onboardingStep: 5,
      insuranceProvider: dto.providerName,
      insuranceMemberId: dto.policyNumber,
      insuranceGroupNumber: dto.groupNumber,
      isInsuranceSkipped: false,
    );

    // Call real API: POST /api/v1/patients/onboarding/insurance
    final result = await _repository.saveInsurance(dto);

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
                ? 'Backend session unauthenticated (401). OTP verification must precede saving insurance to the remote vault.'
                : 'Sesión no autenticada (401). La verificación OTP debe preceder al guardado del seguro.';
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
        builder: (_) => PrivacyConsentsScreen(
          registrationContext: context,
          apiClient: widget.apiClient,
          onboardingRepository: _repository,
          language: _currentLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildStepProgress(),
                    const SizedBox(height: 24),
                    _buildHeading(),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) ...[
                      _buildInlineErrorBanner(),
                      const SizedBox(height: 16),
                    ],
                    if (_scannedCardNotice != null) ...[
                      _buildScanNoticeBanner(),
                      const SizedBox(height: 16),
                    ],
                    _buildScanCardSection(),
                    const SizedBox(height: 20),
                    _buildInsuranceDetailsCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildVaultSecurityBadge(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top navigation bar with Back Button, CareID Logo, and Language Selector (Figma Node 20:33069)
  Widget _buildTopBar() {
    return Container(
      height: 82,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: const Color(0xFF0B1C30),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              const CareIdLogo(width: 90),
            ],
          ),
          // Language selector (Figma Node 20:33071)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3FE),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0xFFC0C6D6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  offset: Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _currentLanguage = 'en'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isEn
                          ? const Color(0xFF5B14B8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'EN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isEn ? Colors.white : const Color(0xFF414754),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentLanguage = 'es'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: !_isEn
                          ? const Color(0xFF5B14B8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'ESP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: !_isEn ? Colors.white : const Color(0xFF414754),
                        letterSpacing: 0.5,
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

  /// Step 4 of 6 Progress Indicator (Figma Node 20:33079 - 20:33087)
  Widget _buildStepProgress() {
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
              _isEn ? 'Step 4 of 6' : 'Paso 4 de 6',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF494552),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 66.6% progress bar (Step 4 of 6)
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
                    width: constraints.maxWidth * (4 / 6),
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

  /// Heading & Helper Copy (Figma Node 20:33088 - 20:33093)
  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEn ? 'Add your insurance' : 'Agrega tu seguro',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1C30),
            letterSpacing: -0.7,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isEn
              ? 'Adding your insurance now helps speed up your first visit. You can also skip this and add it later.'
              : 'Agregar tu seguro ahora acelera tu primera consulta. También puedes omitirlo y agregarlo más tarde.',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xFF494552),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Card 1: Scan Insurance Card (Figma Node 20:33095 - 20:33106)
  Widget _buildScanCardSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE9FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Icon Badge (56x56)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Center(
              child: Icon(
                Icons.document_scanner_outlined,
                color: Color(0xFF3F1D8B),
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _isEn ? 'Scan Insurance Card' : 'Escanear Tarjeta de Seguro',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B1C30),
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isEn
                ? 'Quickly capture your card details'
                : 'Captura rápidamente los detalles de tu tarjeta',
            style: const TextStyle(fontSize: 14, color: Color(0xFF767676)),
          ),
          const SizedBox(height: 16),
          // "Open Camera" Button (Figma Node 20:33105)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isScanningCard ? null : _handleScanCard,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEFF4FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isScanningCard
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF3F1D8B),
                        ),
                      ),
                    )
                  : Text(
                      _isEn ? 'Open Camera' : 'Abrir Cámara',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F1D8B),
                        letterSpacing: -0.09,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card 2: Insurance Details Form (Figma Node 20:33107 - 20:33134)
  Widget _buildInsuranceDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Icon and "Insurance Details"
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 20,
                color: Color(0xFF3F1D8B),
              ),
              const SizedBox(width: 8),
              Text(
                _isEn ? 'Insurance Details' : 'Detalles del Seguro',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B1C30),
                  letterSpacing: -0.06,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Field 1: Insurance Provider (Figma Node 20:33114)
          _buildFormField(
            label: _isEn ? 'Insurance Provider' : 'Proveedor de Seguro',
            hint: _isEn
                ? 'Enter provider name'
                : 'Ingresa el nombre del proveedor',
            controller: _providerController,
            focusNode: _providerFocus,
            errorText: _providerError,
            onChanged: (_) {
              if (_providerError != null) _validateProvider();
            },
          ),
          const SizedBox(height: 16),

          // Field 2: Member ID (Figma Node 20:33121)
          _buildFormField(
            label: _isEn ? 'Member ID' : 'ID de Miembro',
            hint: _isEn ? 'Enter member ID' : 'Ingresa el ID de miembro',
            controller: _memberIdController,
            focusNode: _memberIdFocus,
            errorText: _memberIdError,
            onChanged: (_) {
              if (_memberIdError != null) _validateMemberId();
            },
          ),
          const SizedBox(height: 16),

          // Field 3: Group Number (Optional) (Figma Node 20:33128)
          _buildFormField(
            label: _isEn
                ? 'Group Number (Optional)'
                : 'Número de Grupo (Opcional)',
            hint: _isEn ? 'Enter group number' : 'Ingresa el número de grupo',
            controller: _groupNumberController,
            focusNode: _groupNumberFocus,
            errorText: _groupNumberError,
            onChanged: (_) {
              if (_groupNumberError != null) _validateGroupNumber();
            },
          ),
        ],
      ),
    );
  }

  /// Reusable Input Field adhering to Figma Node Specs
  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0B1C30),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(8),
            border: errorText != null
                ? Border.all(color: AppColors.errorRed)
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 16, color: Color(0xFF0B1C30)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFF767676),
                fontWeight: FontWeight.normal,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(fontSize: 12, color: AppColors.errorRed),
          ),
        ],
      ],
    );
  }

  /// Action buttons: Primary "Save & Continue" and Secondary "I'll do this later" (Figma Node 20:33135 - 20:33145)
  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          label: _isEn ? 'Save & Continue' : 'Guardar y Continuar',
          trailingIcon: Icons.arrow_forward_ios,
          isLoading: _isSaving,
          onPressed: () => _handleSubmit(isSkipping: false),
        ),
        const SizedBox(height: 12),
        // Secondary Action: "I'll do this later"
        GestureDetector(
          onTap: _isSaving ? null : () => _handleSubmit(isSkipping: true),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              _isEn ? "I'll do this later" : 'Lo haré más tarde',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF494552),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Security Trust Badge: "Your insurance data is encrypted and stored in your private Care ID Vault." (Figma Node 20:33146 - 20:33151)
  Widget _buildVaultSecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 16, color: Color(0xFF494552)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _isEn
                  ? 'Your insurance data is encrypted and stored in your private Care ID Vault.'
                  : 'Tus datos de seguro están cifrados y almacenados en tu Care ID Vault privado.',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF494552),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.errorRed.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.errorRed,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, size: 16, color: AppColors.errorRed),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildScanNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00696B).withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00696B).withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF00696B),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _scannedCardNotice!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF00696B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF00696B)),
            onPressed: () => setState(() => _scannedCardNotice = null),
          ),
        ],
      ),
    );
  }
}
