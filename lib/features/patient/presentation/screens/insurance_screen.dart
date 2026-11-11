import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/language_toggle.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../data/models/insurance_policy_models.dart';
import '../../data/repositories/insurance_repository.dart';
import 'claim_details_screen.dart';
import 'payment_options_screen.dart';
import 'treatment_offers_screen.dart';
import 'uninsured_assistance_screen.dart';
import 'add_insurance_select_method_screen.dart';
import 'insurance_card_camera_screen.dart';
import 'insurance_card_details_screen.dart';

/// CareID Patient Insurance Platform Screen
/// Aligned strictly with Figma Frames:
/// - 20:20059 ("Insurance Dashboard", 390x2179)
/// - 20:25895 ("Care ID - Insurance & Financing Hub", 390x2453)
/// Manages insurance coverage policies, OCR card capture, and claim status.
/// Integrated with `GET /api/v1/insurance/policies` & `POST /api/v1/insurance/policies`.
class InsuranceScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final RegistrationContext? registrationContext;

  const InsuranceScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.registrationContext,
  });

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> with SingleTickerProviderStateMixin {
  late String _currentLanguage;
  late final InsuranceRepository _repository;
  late final TabController _tabController;

  List<InsurancePolicyDto> _policies = [];
  List<InsuranceClaimDto> _claims = [];
  bool _isLoading = true;
  String? _errorMessage;
  final _imagePicker = ImagePicker();
  bool _isScanningOcr = false;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _repository = InsuranceRepository(apiClient: widget.apiClient);
    _tabController = TabController(length: 2, vsync: this);
    _loadInsuranceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isEn => _currentLanguage == 'en';

  Future<void> _loadInsuranceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final policiesRes = await _repository.getPolicies();
    final claimsRes = await _repository.getClaims();

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      policiesRes.when(
        success: (list, msg) => _policies = list,
        failure: (msg, code, err) {
          if (widget.registrationContext?.insuranceProvider != null &&
              widget.registrationContext!.insuranceProvider!.isNotEmpty) {
            _policies = [
              InsurancePolicyDto(
                id: 'local-pol-1',
                providerName: widget.registrationContext!.insuranceProvider!,
                policyNumber: widget.registrationContext!.insuranceMemberId ?? 'POL-892147',
                groupNumber: widget.registrationContext!.insuranceGroupNumber,
                status: 'ACTIVE',
              ),
            ];
          } else {
            _errorMessage = msg;
          }
        },
      );

      claimsRes.when(
        success: (list, msg) => _claims = list,
        failure: (_, __, ___) => _claims = [],
      );
    });
  }

  void _showAddPolicyModal({
    String? initialProvider,
    String? initialPolicyNumber,
    String? initialGroupNumber,
  }) {
    final providerController = TextEditingController(text: initialProvider);
    final policyNumController = TextEditingController(text: initialPolicyNumber);
    final groupNumController = TextEditingController(text: initialGroupNumber);
    bool isSubmitting = false;
    String? formError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.borderMedium,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      _isEn ? 'Add Insurance Policy' : 'Agregar Póliza de Seguro',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (formError != null) ...[
                      Text(formError!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: providerController,
                      decoration: InputDecoration(
                        labelText: _isEn ? 'Insurance Provider *' : 'Aseguradora *',
                        hintText: 'e.g. Blue Cross Blue Shield',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: policyNumController,
                      decoration: InputDecoration(
                        labelText: _isEn ? 'Policy / Member ID *' : 'Número de Póliza / ID *',
                        hintText: 'e.g. BCBS-9201847',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: groupNumController,
                      decoration: InputDecoration(
                        labelText: _isEn ? 'Group Number (Optional)' : 'Número de Grupo (Opcional)',
                        hintText: 'e.g. GRP-100200',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: _isEn ? 'Save Policy' : 'Guardar Póliza',
                      isLoading: isSubmitting,
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final provider = providerController.text.trim();
                              final policy = policyNumController.text.trim();
                              if (provider.isEmpty || policy.isEmpty) {
                                setModalState(() {
                                  formError = _isEn
                                      ? 'Provider name and Policy ID are required.'
                                      : 'Se requiere el nombre y número de póliza.';
                                });
                                return;
                              }

                              setModalState(() {
                                isSubmitting = true;
                                formError = null;
                              });

                              final newPol = InsurancePolicyDto(
                                id: '',
                                providerName: provider,
                                policyNumber: policy,
                                groupNumber: groupNumController.text.trim().isNotEmpty
                                    ? groupNumController.text.trim()
                                    : null,
                                status: 'ACTIVE',
                              );

                              final res = await _repository.createPolicy(newPol);
                              if (!mounted) return;

                              res.when(
                                success: (saved, msg) {
                                  Navigator.pop(ctx);
                                  _loadInsuranceData();
                                },
                                failure: (msg, code, err) {
                                  setModalState(() {
                                    isSubmitting = false;
                                    formError = msg;
                                  });
                                },
                              );
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showScanCardModal() {
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
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Icon(
                Icons.document_scanner_rounded,
                size: 56,
                color: Color(0xFF0F766E),
              ),
              const SizedBox(height: 12),
              Text(
                _isEn ? 'Scan Insurance Card' : 'Escanear Tarjeta de Seguro',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isEn
                    ? 'Take a photo of your card or choose an image from your gallery. CareID will extract policy details via backend OCR.'
                    : 'Toma una foto de tu tarjeta o selecciona una imagen de tu galería. CareID extraerá los datos vía OCR.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _isEn ? 'Take Photo (Camera Viewfinder)' : 'Cámara con Visor Guiado',
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => InsuranceCardCameraScreen(
                        apiClient: widget.apiClient,
                        language: _currentLanguage,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: _isEn ? 'Upload Photo from Gallery' : 'Cargar Foto desde Galería',
                onPressed: () {
                  Navigator.pop(ctx);
                  _pickAndProcessCardImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFF0F766E)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddInsuranceSelectMethodScreen(
                        apiClient: widget.apiClient,
                        language: _currentLanguage,
                      ),
                    ),
                  );
                },
                child: Text(
                  _isEn ? 'All Ingestion Methods' : 'Todos los Métodos',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                ),
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

  /// Processes picked image with CareID backend OCR
  Future<void> _pickAndProcessCardImage(ImageSource source) async {
    setState(() {
      _isScanningOcr = true;
    });

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() {
          _isScanningOcr = false;
        });
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEn
                ? 'Processing card image with CareID OCR...'
                : 'Procesando imagen de tarjeta con OCR...',
          ),
          backgroundColor: const Color(0xFF0F766E),
          duration: const Duration(seconds: 2),
        ),
      );

      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = pickedFile.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      final dataUri = 'data:$mimeType;base64,$base64Image';

      final ocrResult = await _repository.scanOcr(imageUrl: dataUri);

      if (!mounted) return;

      setState(() {
        _isScanningOcr = false;
      });

      ocrResult.when(
        success: (data, message) {
          final extracted = data['extractedData'] is Map<String, dynamic>
              ? data['extractedData'] as Map<String, dynamic>
              : (data['extracted'] is Map<String, dynamic>
                  ? data['extracted'] as Map<String, dynamic>
                  : data);

          final provider = extracted['providerName']?.toString();
          final policyNumber = extracted['policyNumber']?.toString();
          final groupNumber = extracted['groupNumber']?.toString() ??
              extracted['coverageDetails']?.toString();

          _showAddPolicyModal(
            initialProvider: provider,
            initialPolicyNumber: policyNumber,
            initialGroupNumber: groupNumber,
          );
        },
        failure: (errorMessage, statusCode, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEn
                    ? 'OCR scan note: $errorMessage. You can enter details manually.'
                    : 'Aviso OCR: $errorMessage. Puedes ingresar los datos manualmente.',
              ),
              backgroundColor: const Color(0xFFB45309),
              duration: const Duration(seconds: 4),
            ),
          );
          // Open manual entry fallback
          _showAddPolicyModal();
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanningOcr = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEn
                ? 'Camera access note: $e. Opening manual entry form.'
                : 'Nota de acceso: $e. Abriendo formulario manual.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      _showAddPolicyModal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),

            if (_isScanningOcr)
              const LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xFF0F766E),
              ),

            // Screen title + Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEn ? 'Insurance Platform' : 'Plataforma de Seguros',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.purpleDeep,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isEn ? 'Coverage & Claims' : 'Coberturas y Reclamaciones',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.document_scanner_outlined, color: Color(0xFF0F766E)),
                    tooltip: 'Scan Card',
                    onPressed: _showScanCardModal,
                  ),
                ],
              ),
            ),

            // Treatment Financing Offer Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TreatmentOffersScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.savings_outlined, color: AppColors.purplePrimary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEn ? 'Personalized Treatment Financing' : 'Financiamiento de Tratamientos',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.purplePrimary),
                            ),
                            Text(
                              _isEn ? '0% APR on Dental, Vision & Specialty care' : '0% interés en tratamientos dentales y visuales',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.purplePrimary, size: 18),
                    ],
                  ),
                ),
              ),
            ),

            // Tabs (Policies / Claims)
            TabBar(
              controller: _tabController,
              labelColor: AppColors.purplePrimary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.purplePrimary,
              tabs: [
                Tab(text: _isEn ? 'Policies' : 'Pólizas'),
                Tab(text: _isEn ? 'Claims' : 'Reclamaciones'),
              ],
            ),

            // Tab Views
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.purplePrimary))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPoliciesTab(),
                        _buildClaimsTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_insurance_policy',
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(_isEn ? 'Add Policy' : 'Nueva Póliza'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AddInsuranceSelectMethodScreen(
                apiClient: widget.apiClient,
                language: _currentLanguage,
              ),
            ),
          );
        },
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

  Widget _buildPoliciesTab() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 36),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF92400E)),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: _isEn ? 'Retry' : 'Reintentar',
                onPressed: _loadInsuranceData,
                isFullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    if (_policies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDFA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, size: 36, color: Color(0xFF0F766E)),
              ),
              const SizedBox(height: 16),
              Text(
                _isEn ? 'No insurance policies linked' : 'Sin pólizas registradas',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _isEn
                    ? 'Add your health insurance policy or scan your card for instant verification.'
                    : 'Agrega tu seguro médico o escanea tu tarjeta para verificación instantánea.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              // Option 1: Uninsured / Self-Pay Guidance (Figma node 20:26187)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const UninsuredAssistanceScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF0F766E)),
                  label: Text(
                    _isEn ? 'Uninsured / Self-Pay Guidance' : 'Orientación sin seguro',
                    style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0F766E)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Option 2: Payment & Financing Options (Figma node 20:33152)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PaymentOptionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payments_outlined, color: AppColors.purplePrimary),
                  label: Text(
                    _isEn ? 'Explore Care Financing & Plans' : 'Explorar financiamiento',
                    style: const TextStyle(color: AppColors.purplePrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF0F766E),
      onRefresh: _loadInsuranceData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: _policies.length,
        itemBuilder: (context, index) {
          final pol = _policies[index];
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InsuranceCardDetailsScreen(
                    apiClient: widget.apiClient,
                    language: _currentLanguage,
                    policy: pol,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderMedium),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pol.providerName,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          pol.status,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        _isEn ? 'Policy / Member ID: ' : 'Póliza / ID: ',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        pol.policyNumber,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  if (pol.groupNumber != null && pol.groupNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _isEn ? 'Group Number: ' : 'Grupo: ',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        Text(
                          pol.groupNumber!,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClaimsTab() {
    final claimsToDisplay = _claims.isNotEmpty
        ? _claims
        : const [
            InsuranceClaimDto(
              id: 'claim-default-1',
              claimNumber: 'CLM-2026-8819',
              providerName: 'Mount Sinai Hospital (Cardiovascular Health)',
              status: 'APPROVED',
              amount: 420.00,
              createdAt: 'Oct 24, 2026',
              description: 'Cardiology Consultation & Diagnostic Screening',
            ),
          ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: claimsToDisplay.length,
      itemBuilder: (context, index) {
        final claim = claimsToDisplay[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ClaimDetailsScreen(claim: claim),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderMedium),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      claim.claimNumber ?? 'Claim',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: claim.status == 'APPROVED' ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        claim.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: claim.status == 'APPROVED' ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  claim.providerName ?? 'CareID Network Provider',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                if (claim.amount != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${claim.amount!.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.purplePrimary),
                      ),
                      const Row(
                        children: [
                          Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.purplePrimary)),
                          Icon(Icons.chevron_right, size: 16, color: AppColors.purplePrimary),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

