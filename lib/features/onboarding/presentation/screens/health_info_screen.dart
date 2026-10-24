import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/language_toggle.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../data/models/health_info_models.dart';
import '../../data/repositories/onboarding_repository.dart';
import 'add_insurance_screen.dart';

/// CareID Health Info Screen
/// Faithfully implements Step 3 of 6 in Patient Onboarding (Figma Node 20:30900, "Health_info").
/// Follows Step 2 (Mobile Number & OTP Verification).
class HealthInfoScreen extends StatefulWidget {
  final RegistrationContext registrationContext;
  final ApiClient? apiClient;
  final OnboardingRepository? onboardingRepository;
  final String language;

  const HealthInfoScreen({
    super.key,
    required this.registrationContext,
    this.apiClient,
    this.onboardingRepository,
    this.language = 'en',
  });

  @override
  State<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen> {
  late String _currentLanguage;
  late OnboardingRepository _repository;

  // Section 1: Basic Health Info
  String? _selectedBloodGroup;
  final TextEditingController _heightController = TextEditingController(
    text: '175',
  );
  String _heightUnit = 'cm'; // 'cm' or 'ft'
  final TextEditingController _weightController = TextEditingController(
    text: '70',
  );
  String _weightUnit = 'kg'; // 'kg' or 'lb'

  // Section 2: Medical History (Chronic Conditions)
  final Set<String> _selectedConditions = <String>{};
  final TextEditingController _otherConditionController =
      TextEditingController();
  bool _hasNoneConditions = false;

  // Section 3: Allergies
  final List<AllergyItem> _allergies = <AllergyItem>[
    const AllergyItem(
      id: 'all_1',
      name: 'Penicillin',
      reaction: 'Mild rash',
      category: 'Medication',
    ),
  ];
  bool _noKnownAllergies = false;

  // Section 4: Current Medications
  final List<MedicationItem> _medications = <MedicationItem>[
    const MedicationItem(
      id: 'med_1',
      name: 'Atorvastatin 20mg',
      dosage: '1 tablet daily',
      timing: 'Evening',
    ),
  ];
  bool _noMedications = false;

  // Section 5: Previous Surgeries / Procedures
  final List<SurgeryProcedureItem> _surgeries = <SurgeryProcedureItem>[];
  bool _noSurgeries = false;

  // Section 6: Family Health History
  final Set<String> _selectedFamilyHistory = <String>{};
  final TextEditingController _otherFamilyConditionController =
      TextEditingController();
  bool _noFamilyHistoryKnown = false;

  // Submission & Error State
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _repository =
        widget.onboardingRepository ??
        OnboardingRepository(
          apiClient: widget.apiClient,
          tokenStorage: InMemoryTokenStorage(),
        );

    // Hydrate from RegistrationContext if available
    if (widget.registrationContext.bloodGroup != null) {
      _selectedBloodGroup = widget.registrationContext.bloodGroup;
    } else {
      _selectedBloodGroup = BloodGroup.oPositive; // Approved Figma default
    }

    if (widget.registrationContext.height != null) {
      _heightController.text = widget.registrationContext.height!
          .toStringAsFixed(0);
      _heightUnit = widget.registrationContext.heightUnit ?? 'cm';
    }
    if (widget.registrationContext.weight != null) {
      _weightController.text = widget.registrationContext.weight!
          .toStringAsFixed(0);
      _weightUnit = widget.registrationContext.weightUnit ?? 'kg';
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _otherConditionController.dispose();
    _otherFamilyConditionController.dispose();
    super.dispose();
  }

  bool get _isEn => _currentLanguage == 'en';

  // Toggle helpers
  void _toggleCondition(String condition) {
    setState(() {
      _errorMessage = null;
      if (condition == 'None of these') {
        _hasNoneConditions = !_hasNoneConditions;
        if (_hasNoneConditions) {
          _selectedConditions.clear();
        }
      } else {
        _hasNoneConditions = false;
        if (_selectedConditions.contains(condition)) {
          _selectedConditions.remove(condition);
        } else {
          _selectedConditions.add(condition);
        }
      }
    });
  }

  void _toggleFamilyHistory(String condition) {
    setState(() {
      _errorMessage = null;
      if (condition == 'None known') {
        _noFamilyHistoryKnown = !_noFamilyHistoryKnown;
        if (_noFamilyHistoryKnown) {
          _selectedFamilyHistory.clear();
        }
      } else {
        _noFamilyHistoryKnown = false;
        if (_selectedFamilyHistory.contains(condition)) {
          _selectedFamilyHistory.remove(condition);
        } else {
          _selectedFamilyHistory.add(condition);
        }
      }
    });
  }

  void _removeAllergy(String id) {
    setState(() {
      _allergies.removeWhere((item) => item.id == id);
      _errorMessage = null;
    });
  }

  void _removeMedication(String id) {
    setState(() {
      _medications.removeWhere((item) => item.id == id);
      _errorMessage = null;
    });
  }

  void _removeSurgery(String id) {
    setState(() {
      _surgeries.removeWhere((item) => item.id == id);
      _errorMessage = null;
    });
  }

  // Dialog: Add Allergy
  Future<void> _showAddAllergyDialog() async {
    final nameCtrl = TextEditingController();
    final reactionCtrl = TextEditingController();
    String category = 'Medication';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        decoration: BoxDecoration(
                          color: AppColors.borderMedium,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isEn ? 'Add Known Allergy' : 'Agregar Alergia Conocida',
                      style: AppTypography.heading2,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: _isEn
                            ? 'Allergy or Trigger Name'
                            : 'Nombre de la alergia',
                        hintText: _isEn ? 'e.g. Peanuts, Aspirin' : 'ej. Maní',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reactionCtrl,
                      decoration: InputDecoration(
                        labelText: _isEn
                            ? 'Reaction / Symptoms (optional)'
                            : 'Reacción / Síntomas',
                        hintText: _isEn
                            ? 'e.g. Hives, swelling'
                            : 'ej. Urticaria',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: _isEn ? 'Category' : 'Categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Medication',
                          child: Text('Medication'),
                        ),
                        DropdownMenuItem(value: 'Food', child: Text('Food')),
                        DropdownMenuItem(
                          value: 'Environmental',
                          child: Text('Environmental'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => category = val);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: _isEn ? 'Add Allergy' : 'Agregar Alergia',
                      onPressed: () {
                        if (nameCtrl.text.trim().isNotEmpty) {
                          setState(() {
                            _allergies.add(
                              AllergyItem(
                                id: 'all_${DateTime.now().millisecondsSinceEpoch}',
                                name: nameCtrl.text.trim(),
                                reaction: reactionCtrl.text.trim().isEmpty
                                    ? null
                                    : reactionCtrl.text.trim(),
                                category: category,
                              ),
                            );
                            _noKnownAllergies = false;
                          });
                          Navigator.pop(ctx);
                        }
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

  // Dialog: Add Medication
  Future<void> _showAddMedicationDialog() async {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final timingCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    decoration: BoxDecoration(
                      color: AppColors.borderMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEn
                      ? 'Add Current Medication'
                      : 'Agregar Medicamento Actual',
                  style: AppTypography.heading2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: _isEn
                        ? 'Medication Name'
                        : 'Nombre del Medicamento',
                    hintText: _isEn
                        ? 'e.g. Metformin 500mg'
                        : 'ej. Metformina 500mg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageCtrl,
                  decoration: InputDecoration(
                    labelText: _isEn ? 'Dosage' : 'Dosis',
                    hintText: _isEn
                        ? 'e.g. 1 tablet daily'
                        : 'ej. 1 tableta diaria',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timingCtrl,
                  decoration: InputDecoration(
                    labelText: _isEn ? 'Timing / Frequency' : 'Horario',
                    hintText: _isEn ? 'e.g. Morning / Evening' : 'ej. Noche',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: _isEn ? 'Save Medication' : 'Guardar Medicamento',
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _medications.add(
                          MedicationItem(
                            id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text.trim(),
                            dosage: dosageCtrl.text.trim().isEmpty
                                ? '1 dose'
                                : dosageCtrl.text.trim(),
                            timing: timingCtrl.text.trim().isEmpty
                                ? 'Daily'
                                : timingCtrl.text.trim(),
                          ),
                        );
                        _noMedications = false;
                      });
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog: Add Surgery / Procedure
  Future<void> _showAddProcedureDialog() async {
    final nameCtrl = TextEditingController();
    final yearCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    decoration: BoxDecoration(
                      color: AppColors.borderMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEn
                      ? 'Add Previous Surgery / Procedure'
                      : 'Agregar Cirugía / Procedimiento',
                  style: AppTypography.heading2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: _isEn
                        ? 'Procedure or Surgery Name'
                        : 'Nombre del Procedimiento',
                    hintText: _isEn
                        ? 'e.g. Appendectomy'
                        : 'ej. Apendicectomía',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _isEn ? 'Year (approximate)' : 'Año aproximado',
                    hintText: 'e.g. 2018',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: _isEn ? 'Add Procedure' : 'Agregar Procedimiento',
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _surgeries.add(
                          SurgeryProcedureItem(
                            id: 'surg_${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text.trim(),
                            year: yearCtrl.text.trim().isEmpty
                                ? null
                                : yearCtrl.text.trim(),
                          ),
                        );
                        _noSurgeries = false;
                      });
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Submits the health info payload and transitions to Step 4 (Add Insurance Info)
  Future<void> _handleSubmit({bool isSkipping = false}) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // Compile active allergies
    final activeAllergies = _noKnownAllergies
        ? <String>[]
        : _allergies.map((a) => a.displayTag).toList();

    // Compile active chronic conditions
    final activeConditions = _hasNoneConditions
        ? <String>[]
        : _selectedConditions.toList();
    if (_otherConditionController.text.trim().isNotEmpty) {
      activeConditions.add(_otherConditionController.text.trim());
    }

    // Compile medications
    final activeMeds = _noMedications
        ? <String>[]
        : _medications.map((m) => '${m.name} (${m.dosage})').toList();

    // Compile surgeries
    final activeSurgeries = _noSurgeries
        ? <String>[]
        : _surgeries
              .map((s) => s.year != null ? '${s.name} (${s.year})' : s.name)
              .toList();

    // Compile family history
    final activeFamily = _noFamilyHistoryKnown
        ? <String>[]
        : _selectedFamilyHistory.toList();

    final medicalSummaryDto = MedicalSummaryDto(
      bloodGroup: _selectedBloodGroup,
      knownAllergies: activeAllergies,
      chronicConditions: activeConditions,
      disabilities: const [],
    );

    // Update local registration context
    final updatedContext = widget.registrationContext.copyWith(
      onboardingStep: 4,
      bloodGroup: _selectedBloodGroup,
      height: double.tryParse(_heightController.text.trim()),
      heightUnit: _heightUnit,
      weight: double.tryParse(_weightController.text.trim()),
      weightUnit: _weightUnit,
      knownAllergies: activeAllergies,
      chronicConditions: activeConditions,
      currentMedications: activeMeds,
      surgeries: activeSurgeries,
      familyHistory: activeFamily,
    );

    if (isSkipping) {
      setState(() => _isSaving = false);
      _navigateToNextStep(updatedContext);
      return;
    }

    // Call real API
    final result = await _repository.submitHealthInformation(
      medicalSummary: medicalSummaryDto,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      success: (data, message) {
        setState(() {
          _successMessage = _isEn
              ? 'Health profile saved successfully.'
              : 'Perfil de salud guardado con éxito.';
        });
        _navigateToNextStep(updatedContext);
      },
      failure: (message, statusCode, error) {
        setState(() {
          if (statusCode == 401) {
            _errorMessage = _isEn
                ? 'Backend session unauthenticated (401). OTP verification must precede saving health details to the remote vault.'
                : 'Sesión no autenticada (401). La verificación OTP debe preceder al guardado.';
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
        builder: (_) => AddInsuranceScreen(
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Top Header: Branding & Back Navigation
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
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
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Step Progress Indicator: Step 3 of 6 (Figma Node 20:30904)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isEn
                                    ? 'VERIFICATION STEP'
                                    : 'PASO DE VERIFICACIÓN',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.purplePrimary,
                                ),
                              ),
                              Text(
                                _isEn ? 'Step 3 of 6' : 'Paso 3 de 6',
                                style: const TextStyle(
                                  fontSize: 12,
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
                              value: 3.0 / 6.0,
                              color: AppColors.purplePrimary,
                              backgroundColor: AppColors.borderLight,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Heading & Context (Figma Node 20:30913)
                          Text(
                            _isEn
                                ? 'Tell us about your health'
                                : 'Cuéntenos sobre su salud',
                            style: AppTypography.heading1.copyWith(
                              fontSize: 24,
                              color: const Color(0xFF2E1065),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isEn
                                ? 'Your health history helps Care ID organize your information and provide a more complete health profile.'
                                : 'Su historial de salud ayuda a Care ID a organizar su información y proporcionar un perfil más completo.',
                            style: AppTypography.subtitle.copyWith(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Verified Patient Summary Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_user_rounded,
                                  size: 20,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${widget.registrationContext.fullName} • ${widget.registrationContext.maskedPhone}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // SECTION 1: Basic Health Information (Figma Node 20:30919)
                          _buildSectionCard(
                            icon: Icons.favorite_border_rounded,
                            title: _isEn
                                ? 'Basic Health Information'
                                : 'Información Básica de Salud',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEn ? 'Blood Group' : 'Grupo Sanguíneo',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Blood group chips grid
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ...[
                                      'A+',
                                      'A-',
                                      'B+',
                                      'B-',
                                      'AB+',
                                      'AB-',
                                      'O+',
                                      'O-',
                                    ].map((bg) => _buildBloodGroupChip(bg)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildBloodGroupChip(
                                  BloodGroup.unknown,
                                  isFullWidth: true,
                                ),
                                const SizedBox(height: 20),

                                // Height & Weight Grid (Figma Node 20:30947)
                                Row(
                                  children: [
                                    // Height Card
                                    Expanded(
                                      child: _buildMeasurementCard(
                                        label: _isEn ? 'Height' : 'Altura',
                                        controller: _heightController,
                                        unit: _heightUnit,
                                        units: const ['cm', 'ft'],
                                        onUnitChanged: (u) =>
                                            setState(() => _heightUnit = u),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Weight Card
                                    Expanded(
                                      child: _buildMeasurementCard(
                                        label: _isEn ? 'Weight' : 'Peso',
                                        controller: _weightController,
                                        unit: _weightUnit,
                                        units: const ['kg', 'lb'],
                                        onUnitChanged: (u) =>
                                            setState(() => _weightUnit = u),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // SECTION 2: Medical History (Figma Node 20:30988)
                          _buildSectionCard(
                            icon: Icons.healing_outlined,
                            title: _isEn
                                ? 'Medical History'
                                : 'Historial Médico',
                            subtitle: _isEn
                                ? 'Select anything that applies to you.'
                                : 'Seleccione lo que corresponda.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildConditionChip('Diabetes'),
                                    _buildConditionChip('High Blood Pressure'),
                                    _buildConditionChip('Heart Condition'),
                                    _buildConditionChip('Asthma'),
                                    _buildConditionChip('Kidney Condition'),
                                    _buildConditionChip('Liver Condition'),
                                    _buildConditionChip('Thyroid Condition'),
                                    _buildConditionChip('Cancer'),
                                    _buildConditionChip('High Cholesterol'),
                                    _buildConditionChip(
                                      'None of these',
                                      isExclusive: true,
                                      isSelected: _hasNoneConditions,
                                    ),
                                    _buildConditionChip('Other'),
                                  ],
                                ),
                                if (_selectedConditions.contains('Other')) ...[
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _otherConditionController,
                                    decoration: InputDecoration(
                                      hintText: _isEn
                                          ? 'Specify other condition...'
                                          : 'Especifique otra condición...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // SECTION 3: Allergies (Figma Node 20:31022)
                          _buildSectionCard(
                            icon: Icons.shield_outlined,
                            title: _isEn ? 'Allergies' : 'Alergias',
                            badge: _noKnownAllergies
                                ? (_isEn ? '0 Recorded' : '0 Registrado')
                                : '${_allergies.length} ${_isEn ? 'Recorded' : 'Registrado'}',
                            subtitle: _isEn
                                ? 'Include food, medication, or environmental triggers.'
                                : 'Incluya medicamentos, alimentos o factores ambientales.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Quick selection tags
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilterChip(
                                      label: Text(
                                        _isEn
                                            ? 'No known allergies'
                                            : 'Sin alergias conocidas',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _noKnownAllergies
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      selected: _noKnownAllergies,
                                      selectedColor: AppColors.purplePrimary,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: _noKnownAllergies
                                              ? AppColors.purplePrimary
                                              : AppColors.borderMedium,
                                        ),
                                      ),
                                      onSelected: (val) {
                                        setState(() {
                                          _noKnownAllergies = val;
                                          if (val) _allergies.clear();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Added Allergies Tags
                                if (!_noKnownAllergies &&
                                    _allergies.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _allergies.map((allergy) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3E8FF),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFD8B4FE),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.warning_amber_rounded,
                                              size: 14,
                                              color: AppColors.purplePrimary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              allergy.displayTag,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.purplePrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () =>
                                                  _removeAllergy(allergy.id),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                size: 14,
                                                color: AppColors.purplePrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Add Allergy Action
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(
                                    _isEn
                                        ? 'Add another allergy'
                                        : 'Agregar otra alergia',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.purplePrimary,
                                    side: const BorderSide(
                                      color: AppColors.purplePrimary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  onPressed: _showAddAllergyDialog,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // SECTION 4: Current Medications (Figma Node 20:31057)
                          _buildSectionCard(
                            icon: Icons.medication_outlined,
                            title: _isEn
                                ? 'Current Medications'
                                : 'Medicamentos Actuales',
                            subtitle: _isEn
                                ? 'Add medicines you currently take, if any.'
                                : 'Agregue los medicamentos que toma.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!_noMedications &&
                                    _medications.isNotEmpty) ...[
                                  ..._medications.map((med) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF5FF),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE9D5FF),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3E8FF),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.medication_liquid_rounded,
                                              color: AppColors.purplePrimary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  med.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  '${med.dosage} • ${med.timing}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                            onPressed: () =>
                                                _removeMedication(med.id),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 6),
                                ],

                                // Add Medication Button
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(
                                    _isEn
                                        ? 'Add Medication'
                                        : 'Agregar Medicamento',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.purplePrimary,
                                    side: const BorderSide(
                                      color: AppColors.purplePrimary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  onPressed: _showAddMedicationDialog,
                                ),
                                const SizedBox(height: 10),

                                // Checkbox: No regular medications
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _noMedications,
                                      activeColor: AppColors.purplePrimary,
                                      onChanged: (val) {
                                        setState(() {
                                          _noMedications = val ?? false;
                                          if (_noMedications) {
                                            _medications.clear();
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        _isEn
                                            ? 'I do not take any medications regularly'
                                            : 'No tomo medicamentos regularmente',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // SECTION 5: Previous Surgeries / Procedures (Figma Node 20:31091)
                          _buildSectionCard(
                            icon: Icons.content_cut_rounded,
                            title: _isEn
                                ? 'Previous Surgeries or Major Procedures'
                                : 'Cirugías o Procedimientos Anteriores',
                            subtitle: _isEn
                                ? 'Document previous operations to keep surgical history intact.'
                                : 'Documente operaciones previas.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!_noSurgeries && _surgeries.isNotEmpty) ...[
                                  ..._surgeries.map((surg) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.borderLight,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 18,
                                            color: AppColors.purplePrimary,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              surg.year != null
                                                  ? '${surg.name} (${surg.year})'
                                                  : surg.name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                            onPressed: () =>
                                                _removeSurgery(surg.id),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 6),
                                ],

                                OutlinedButton.icon(
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(
                                    _isEn
                                        ? 'Add Procedure'
                                        : 'Agregar Procedimiento',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.purplePrimary,
                                    side: const BorderSide(
                                      color: AppColors.purplePrimary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  onPressed: _showAddProcedureDialog,
                                ),
                                const SizedBox(height: 10),

                                // Checkbox: No previous surgeries
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _noSurgeries,
                                      activeColor: AppColors.purplePrimary,
                                      onChanged: (val) {
                                        setState(() {
                                          _noSurgeries = val ?? false;
                                          if (_noSurgeries) {
                                            _surgeries.clear();
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        _isEn
                                            ? 'I have no previous surgeries or major procedures'
                                            : 'No tengo cirugías previas ni procedimientos mayores',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // SECTION 6: Family Health History (Figma Node 20:31108)
                          _buildSectionCard(
                            icon: Icons.family_restroom_rounded,
                            title: _isEn
                                ? 'Family Health History'
                                : 'Historial de Salud Familiar',
                            subtitle: _isEn
                                ? 'Select conditions present in your direct family lines.'
                                : 'Seleccione condiciones presentes en su familia directa.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildFamilyChip('Heart Disease'),
                                    _buildFamilyChip('Diabetes'),
                                    _buildFamilyChip('High Blood Pressure'),
                                    _buildFamilyChip('Cancer'),
                                    _buildFamilyChip('Stroke'),
                                    _buildFamilyChip(
                                      'None known',
                                      isExclusive: true,
                                      isSelected: _noFamilyHistoryKnown,
                                    ),
                                    _buildFamilyChip('Other'),
                                  ],
                                ),
                                if (_selectedFamilyHistory.contains(
                                  'Other',
                                )) ...[
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _otherFamilyConditionController,
                                    decoration: InputDecoration(
                                      hintText: _isEn
                                          ? 'Specify family condition...'
                                          : 'Especifique condición familiar...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // SECTION 7: Optional Document Notice (Figma Node 20:31131)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.file_present_rounded,
                                    color: AppColors.purplePrimary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isEn
                                            ? 'Already have health documents?'
                                            : '¿Ya tiene documentos de salud?',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isEn
                                            ? 'Add past medical documents later directly from your Care ID Vault. Document upload is not required right now.'
                                            : 'Agregue documentos médicos más tarde desde su Bóveda Care ID. La carga no es obligatoria ahora.',
                                        style: const TextStyle(
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
                          const SizedBox(height: 16),

                          // Inline Error Banner
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
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
                                        fontSize: 13,
                                        color: AppColors.error,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Actions & Navigation (Figma Node 20:31140)
                          PrimaryButton(
                            text: _isEn
                                ? 'Save & Continue'
                                : 'Guardar y Continuar',
                            isLoading: _isSaving,
                            onPressed: _handleSubmit,
                          ),
                          const SizedBox(height: 10),
                          SecondaryButton(
                            text: _isEn ? 'Skip for now' : 'Omitir por ahora',
                            onPressed: () => _handleSubmit(isSkipping: true),
                          ),
                          const SizedBox(height: 16),

                          // Trust & Security Reassurance Footer
                          Center(
                            child: Text(
                              _isEn
                                  ? 'You can complete or revise your health history later from your Care ID Vault.'
                                  : 'Puede completar o modificar su historial más tarde en su Bóveda.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isEn
                                    ? 'Encrypted & HIPAA Compliant Storage'
                                    : 'Almacenamiento Cifrado y Seguro',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
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
      ),
    );
  }

  // --- REUSABLE CARD & WIDGET BUILDERS ---

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.purplePrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.purplePrimary,
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildBloodGroupChip(String bg, {bool isFullWidth = false}) {
    final isSelected = _selectedBloodGroup == bg;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBloodGroup = bg;
          _errorMessage = null;
        });
      },
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purplePrimary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.purplePrimary
                : AppColors.borderMedium,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x338B5CF6),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          bg,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementCard({
    required String label,
    required TextEditingController controller,
    required String unit,
    required List<String> units,
    required void Function(String) onUnitChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Row(
                  children: units.map((u) {
                    final isSelected = u == unit;
                    return GestureDetector(
                      onTap: () => onUnitChanged(u),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.purplePrimary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          u,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(
    String condition, {
    bool isExclusive = false,
    bool? isSelected,
  }) {
    final selected = isSelected ?? _selectedConditions.contains(condition);
    return FilterChip(
      label: Text(
        condition,
        style: TextStyle(
          fontSize: 12,
          color: selected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.purplePrimary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColors.purplePrimary : AppColors.borderMedium,
        ),
      ),
      onSelected: (_) => _toggleCondition(condition),
    );
  }

  Widget _buildFamilyChip(
    String condition, {
    bool isExclusive = false,
    bool? isSelected,
  }) {
    final selected = isSelected ?? _selectedFamilyHistory.contains(condition);
    return FilterChip(
      label: Text(
        condition,
        style: TextStyle(
          fontSize: 12,
          color: selected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.purplePrimary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColors.purplePrimary : AppColors.borderMedium,
        ),
      ),
      onSelected: (_) => _toggleFamilyHistory(condition),
    );
  }
}
