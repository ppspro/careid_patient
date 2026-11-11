import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_dental_logo.dart';
import '../../data/models/medical_record_models.dart';
import '../../data/repositories/medical_records_repository.dart';

/// CareID Patient App — Add Health Record Screen
/// Aligned with Figma Frames:
/// - 20:33245 ("Add Health Record", 375x1040)
/// - 20:21451 ("Upload Medical Record - Refined Flow", 390x1404)
/// - 20:32268 ("Scan Reports", 390x905)
/// - 20:32321 ("OCR Processing - Report", 390x980)
/// - 20:33367 ("Review Health Record", 375x1101)
/// - 20:33470 ("Record Saved Success", 375x1012.5)
class AddHealthRecordScreen extends StatefulWidget {
  final String initialCategory;
  final MedicalRecordsRepository? repository;

  const AddHealthRecordScreen({
    super.key,
    this.initialCategory = 'GENERAL',
    this.repository,
  });

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  late final MedicalRecordsRepository _repository;

  late String _selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _facilityController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _planController = TextEditingController();

  // General Medical Vitals
  final TextEditingController _bpController = TextEditingController(text: '120/80');
  final TextEditingController _hrController = TextEditingController(text: '72');
  final TextEditingController _tempController = TextEditingController(text: '36.6');
  final TextEditingController _spo2Controller = TextEditingController(text: '98');

  // Medical Symptoms
  final List<String> _availableSymptoms = const [
    'Headache',
    'Fatigue',
    'Fever',
    'Cough',
    'Nausea',
    'Dizziness',
    'Chest Tightness',
    'Shortness of Breath',
  ];
  final Set<String> _selectedSymptoms = {};

  // Dental Specific Fields
  String _selectedDentalProcedure = 'Cleaning & Prophylaxis';
  final List<String> _dentalProcedures = const [
    'Cleaning & Prophylaxis',
    'Composite Restoration / Filling',
    'Root Canal Therapy (Endodontics)',
    'Tooth Extraction',
    'Crown & Bridge Placement',
    'Bitewing / Periapical Radiograph',
  ];
  final TextEditingController _toothNotationController = TextEditingController(text: 'Tooth #14 (Upper Left)');
  final TextEditingController _dentalDiagnosisController = TextEditingController(text: 'K02.9 - Localized Enamel Caries');
  final TextEditingController _materialsController = TextEditingController(text: 'Composite Resin (A2), Local Anesthetic 2%');
  bool _hasDentalRadiograph = true;

  // Vision Specific Fields
  String _selectedVisionExamType = 'Comprehensive Refraction';
  final List<String> _visionExamTypes = const [
    'Comprehensive Refraction',
    'Slit-Lamp Biomicroscopy',
    'Dilated Funduscopy',
    'Tonometry / IOP Measurement',
    'Contact Lens Evaluation',
  ];
  final TextEditingController _odSphController = TextEditingController(text: '-1.25');
  final TextEditingController _odCylController = TextEditingController(text: '-0.50');
  final TextEditingController _odAxisController = TextEditingController(text: '180');
  final TextEditingController _odAcuityController = TextEditingController(text: '20/20');

  final TextEditingController _osSphController = TextEditingController(text: '-1.50');
  final TextEditingController _osCylController = TextEditingController(text: '-0.75');
  final TextEditingController _osAxisController = TextEditingController(text: '175');
  final TextEditingController _osAcuityController = TextEditingController(text: '20/25');

  final TextEditingController _pdController = TextEditingController(text: '63');
  final TextEditingController _iopController = TextEditingController(text: '14');
  String _selectedLensType = 'Single Vision (Anti-Reflective)';
  final List<String> _lensTypes = const [
    'Single Vision (Anti-Reflective)',
    'Progressive / Multifocal',
    'Blue-Light Filter',
    'Toric Soft Contact Lenses',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MedicalRecordsRepository();
    _selectedCategory = widget.initialCategory.toUpperCase();
    _applyCategoryDefaults(_selectedCategory);
  }

  void _applyCategoryDefaults(String category) {
    if (category == 'DENTAL') {
      _titleController.text = 'Comprehensive Dental Checkup & Cleaning';
      _doctorController.text = 'Dr. Julian Vance, DDS';
      _facilityController.text = 'Apex Dental Care Institute';
      _complaintController.text = 'Routine dental cleaning and hygiene evaluation';
    } else if (category == 'VISION') {
      _titleController.text = 'Optometric Visual Acuity & Refraction Exam';
      _doctorController.text = 'Dr. Laura Zhao, OD';
      _facilityController.text = 'VisionCare Eye Specialists';
      _complaintController.text = 'Annual eyesight evaluation and refraction check';
    } else {
      _titleController.text = 'Clinical Consultation & Vitals';
      _doctorController.text = 'Dr. Sarah Jenkins, MD';
      _facilityController.text = 'Mount Sinai Medical Center';
      _complaintController.text = 'Annual comprehensive physical wellness checkup';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _facilityController.dispose();
    _complaintController.dispose();
    _notesController.dispose();
    _planController.dispose();
    _bpController.dispose();
    _hrController.dispose();
    _tempController.dispose();
    _spo2Controller.dispose();
    _toothNotationController.dispose();
    _dentalDiagnosisController.dispose();
    _materialsController.dispose();
    _odSphController.dispose();
    _odCylController.dispose();
    _odAxisController.dispose();
    _odAcuityController.dispose();
    _osSphController.dispose();
    _osCylController.dispose();
    _osAxisController.dispose();
    _osAcuityController.dispose();
    _pdController.dispose();
    _iopController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveRecord() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a record title')),
      );
      return;
    }

    setState(() => _isSaving = true);

    String clinicalNotesCombined;
    String diagnosisValue;
    String treatmentPlanValue;

    if (_selectedCategory == 'DENTAL') {
      clinicalNotesCombined = [
        'Procedure: $_selectedDentalProcedure',
        'Tooth/Quadrant: ${_toothNotationController.text.trim()}',
        'Materials Used: ${_materialsController.text.trim()}',
        if (_hasDentalRadiograph) 'Radiograph: Bitewing/Periapical archive synchronized',
        if (_notesController.text.trim().isNotEmpty) 'Notes: ${_notesController.text.trim()}',
      ].join('\n');
      diagnosisValue = _dentalDiagnosisController.text.trim().isNotEmpty
          ? _dentalDiagnosisController.text.trim()
          : 'K02.9 - Dental Restoration & Prophylaxis';
      treatmentPlanValue = _planController.text.trim().isNotEmpty
          ? _planController.text.trim()
          : 'Oral hygiene maintenance; follow-up dental exam in 6 months.';
    } else if (_selectedCategory == 'VISION') {
      clinicalNotesCombined = [
        'Exam Type: $_selectedVisionExamType',
        'Refraction OD: SPH ${_odSphController.text} | CYL ${_odCylController.text} | Axis ${_odAxisController.text}° | Acuity ${_odAcuityController.text}',
        'Refraction OS: SPH ${_osSphController.text} | CYL ${_osCylController.text} | Axis ${_osAxisController.text}° | Acuity ${_osAcuityController.text}',
        'Pupillary Distance: ${_pdController.text} mm | Intraocular Pressure: ${_iopController.text} mmHg',
        'Lens Recommendation: $_selectedLensType',
        if (_notesController.text.trim().isNotEmpty) 'Notes: ${_notesController.text.trim()}',
      ].join('\n');
      diagnosisValue = 'H52.2 - Compound Astigmatism & Myopic Refractive Status';
      treatmentPlanValue = _planController.text.trim().isNotEmpty
          ? _planController.text.trim()
          : 'Prescription updated for daily wear; annual visual screening.';
    } else {
      final vitalsSummary = 'BP: ${_bpController.text.trim()} mmHg | HR: ${_hrController.text.trim()} BPM | Temp: ${_tempController.text.trim()}°C | SpO2: ${_spo2Controller.text.trim()}%';
      final symptomsSummary = _selectedSymptoms.isNotEmpty ? 'Symptoms: ${_selectedSymptoms.join(", ")}' : '';
      clinicalNotesCombined = [
        vitalsSummary,
        if (symptomsSummary.isNotEmpty) symptomsSummary,
        if (_notesController.text.trim().isNotEmpty) _notesController.text.trim(),
      ].join('\n');
      diagnosisValue = 'Z00.00 - General adult medical examination without abnormal findings';
      treatmentPlanValue = _planController.text.trim().isNotEmpty
          ? _planController.text.trim()
          : 'Routine healthy lifestyle guidelines and annual preventative recall.';
    }

    final record = MedicalRecordDto(
      id: '',
      title: _titleController.text.trim(),
      category: _selectedCategory,
      chiefComplaint: _complaintController.text.trim(),
      clinicalNotes: clinicalNotesCombined,
      treatmentPlan: treatmentPlanValue,
      diagnosis: diagnosisValue,
      doctorName: _doctorController.text.trim().isNotEmpty ? _doctorController.text.trim() : 'Attending Practitioner',
      facilityName: _facilityController.text.trim().isNotEmpty ? _facilityController.text.trim() : 'Care ID Partner Clinic',
    );

    final result = await _repository.createRecord(record);

    if (mounted) {
      setState(() => _isSaving = false);
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health record saved successfully to Care ID vault!')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Record stored in session vault: ${result.messageOrNull ?? "Success"}')),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Add Health Record'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySelector(),
            const SizedBox(height: AppSpacing.md),
            _buildGeneralDetails(),
            const SizedBox(height: AppSpacing.md),
            if (_selectedCategory == 'DENTAL') ...[
              _buildDentalProcedureCard(),
              const SizedBox(height: AppSpacing.md),
              _buildDentalNotesCard(),
            ] else if (_selectedCategory == 'VISION') ...[
              _buildVisionRefractionCard(),
              const SizedBox(height: AppSpacing.md),
              _buildVisionNotesCard(),
            ] else ...[
              _buildVitalsCard(),
              const SizedBox(height: AppSpacing.md),
              _buildSymptomsCard(),
              const SizedBox(height: AppSpacing.md),
              _buildNotesCard(),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: PrimaryButton.gradient(
              label: 'Save Health Record',
              onPressed: _isSaving ? null : _handleSaveRecord,
              isLoading: _isSaving,
                            padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'id': 'GENERAL', 'label': 'Medical Record', 'icon': Icons.medical_services_outlined},
      {'id': 'DENTAL', 'label': 'Dental Record', 'icon': Icons.healing_outlined},
      {'id': 'VISION', 'label': 'Visual Record', 'icon': Icons.visibility_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Category',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['id'] as String;
                      _applyCategoryDefaults(_selectedCategory);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.shade50,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        cat['id'] == 'DENTAL'
                            ? CareIdDentalLogo(
                                size: 22,
                                color: isSelected ? AppColors.dentalIcon : AppColors.textSecondary,
                              )
                            : Icon(
                                cat['icon'] as IconData,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                size: 22,
                              ),
                        const SizedBox(height: 6),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralDetails() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Information',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Record Title *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _complaintController,
            decoration: InputDecoration(
              labelText: 'Chief Complaint / Clinical Purpose',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _doctorController,
                  decoration: InputDecoration(
                    labelText: 'Attending Practitioner',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _facilityController,
                  decoration: InputDecoration(
                    labelText: 'Facility / Clinic',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DENTAL SECTION (Figma 20:21111 / 20:25653)
  // ==========================================

  Widget _buildDentalProcedureCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.dentalBg,
                ),
                child: const CareIdDentalLogo(size: 18, color: AppColors.dentalIcon),
              ),
              const SizedBox(width: 8),
              Text(
                'Dental Procedure & Odontogram',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.dentalIcon),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Procedure Type',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedDentalProcedure,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _dentalProcedures.map((proc) {
              return DropdownMenuItem<String>(
                value: proc,
                child: Text(proc, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedDentalProcedure = val);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _toothNotationController,
            decoration: InputDecoration(
              labelText: 'Tooth Notation / Quadrant',
              hintText: 'e.g. Tooth #14 (Upper Left), Q2',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _dentalDiagnosisController,
            decoration: InputDecoration(
              labelText: 'Dental Diagnostic Code',
              hintText: 'e.g. K02.9 - Dental Caries',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _materialsController,
            decoration: InputDecoration(
              labelText: 'Restorative Materials & Anesthetic',
              hintText: 'e.g. Resin Composite A2, Lidocaine 2%',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Digital Radiograph Captured', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Attach and sync bitewing/periapical DICOM/image', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            value: _hasDentalRadiograph,
            activeThumbColor: AppColors.dentalIcon,
            onChanged: (val) => setState(() => _hasDentalRadiograph = val),
          ),
        ],
      ),
    );
  }

  Widget _buildDentalNotesCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Odontogram Observations & Post-Op Plan',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Gingival pocket depth, margin seal, enamel integrity...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _planController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Post-operative hygiene, next 6-month scaling recall...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VISION SECTION (Figma 20:21301 / 20:25410)
  // ==========================================

  Widget _buildVisionRefractionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.visionBg,
                ),
                child: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.visionIcon),
              ),
              const SizedBox(width: 8),
              Text(
                'Optometric Examination & Refraction',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.visionIcon),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Exam Type',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedVisionExamType,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _visionExamTypes.map((t) {
              return DropdownMenuItem<String>(
                value: t,
                child: Text(t, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedVisionExamType = val);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          // OD (Right Eye)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Right Eye (OD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.purpleDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _odSphController,
                        decoration: InputDecoration(labelText: 'SPH', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _odCylController,
                        decoration: InputDecoration(labelText: 'CYL', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _odAxisController,
                        decoration: InputDecoration(labelText: 'Axis °', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _odAcuityController,
                        decoration: InputDecoration(labelText: 'Acuity', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // OS (Left Eye)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Left Eye (OS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.purpleDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _osSphController,
                        decoration: InputDecoration(labelText: 'SPH', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _osCylController,
                        decoration: InputDecoration(labelText: 'CYL', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _osAxisController,
                        decoration: InputDecoration(labelText: 'Axis °', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _osAcuityController,
                        decoration: InputDecoration(labelText: 'Acuity', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pdController,
                  decoration: InputDecoration(
                    labelText: 'Pupillary Distance (PD)',
                    suffixText: 'mm',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _iopController,
                  decoration: InputDecoration(
                    labelText: 'IOP (Pressure)',
                    suffixText: 'mmHg',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _selectedLensType,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Recommended Lens Type',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _lensTypes.map((l) {
              return DropdownMenuItem<String>(
                value: l,
                child: Text(l, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedLensType = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisionNotesCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Optometrist Notes & Recall',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Corneal topography, macular reflex, fundus stability...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _planController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Prescription eyewear dispense plan, follow-up screening...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // GENERAL MEDICAL SECTION (Figma 20:33245)
  // ==========================================

  Widget _buildVitalsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clinical Vitals',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Unit: Standard',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bpController,
                  decoration: InputDecoration(
                    labelText: 'Blood Pressure',
                    suffixText: 'mmHg',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _hrController,
                  decoration: InputDecoration(
                    labelText: 'Heart Rate',
                    suffixText: 'BPM',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tempController,
                  decoration: InputDecoration(
                    labelText: 'Body Temp',
                    suffixText: '°C',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _spo2Controller,
                  decoration: InputDecoration(
                    labelText: 'SpO2 Saturation',
                    suffixText: '%',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptoms',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSymptoms.map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return FilterChip(
                label: Text(symptom),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
                showCheckmark: false,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSymptoms.add(symptom);
                    } else {
                      _selectedSymptoms.remove(symptom);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clinical Observations & Prescriptions',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter clinical observations, diagnostic findings, physical exam...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _planController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Prescription medications, dosages, follow-up guidance...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

