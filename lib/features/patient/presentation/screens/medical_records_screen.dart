import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/careid_dental_logo.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/language_toggle.dart';
import '../../data/models/immunisation_models.dart';
import '../../data/models/medical_record_models.dart';
import '../../data/repositories/immunisation_repository.dart';
import '../../data/repositories/medical_records_repository.dart';
import 'add_health_record_screen.dart';
import 'dental_records_screen.dart';
import 'pet_records_screen.dart';
import 'record_detail_screen.dart';
import 'vision_records_screen.dart';

/// CareID Patient Medical Records Screen
/// Aligned strictly with Figma Frames:
/// - 20:31908 ("Medical Records", 390x1272)
/// - 20:25209 ("Care ID - Health Records Landing (Refined)", 390x1386)
/// Displays unified records across General Medical, Dental, Vision, and Pets disciplines.
/// Integrated with `GET /api/v1/medical-records` & `POST /api/v1/medical-records`.
class MedicalRecordsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final ImmunisationRepository? immunisationRepository;
  final String language;

  const MedicalRecordsScreen({
    super.key,
    this.apiClient,
    this.immunisationRepository,
    this.language = 'en',
  });

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  late String _currentLanguage;
  late final MedicalRecordsRepository _repository;
  late final ImmunisationRepository _immunisationRepository;

  String _selectedCategory = 'ALL'; // ALL, GENERAL, DENTAL, VISION, VACCINES
  bool _isTimelineView = false;
  final _searchController = TextEditingController();

  List<MedicalRecordDto> _allRecords = [];
  List<MedicalTimelineItemDto> _timelineItems = [];
  List<VaccineDto> _vaccines = [];
  bool _isLoading = true;
  bool _isLoadingVaccines = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _repository = MedicalRecordsRepository(apiClient: widget.apiClient);
    _immunisationRepository = widget.immunisationRepository ?? ImmunisationRepository(apiClient: widget.apiClient);
    _loadRecords();
    _loadVaccines();
  }

  Future<void> _loadVaccines() async {
    setState(() => _isLoadingVaccines = true);
    try {
      final res = await _immunisationRepository.getVaccines();
      if (mounted && res.isSuccess) {
        setState(() {
          _vaccines = res.dataOrNull ?? [];
        });
      }
    } catch (_) {
      // Graceful fallback
    } finally {
      if (mounted) setState(() => _isLoadingVaccines = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isEn => _currentLanguage == 'en';

  List<MedicalRecordDto> get _filteredRecords {
    var list = _allRecords;
    if (_selectedCategory != 'ALL') {
      list = list.where((r) => r.category.toUpperCase() == _selectedCategory).toList();
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((r) =>
          r.title.toLowerCase().contains(q) ||
          (r.chiefComplaint?.toLowerCase().contains(q) ?? false) ||
          (r.diagnosis?.toLowerCase().contains(q) ?? false)).toList();
    }
    return list;
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final recordsResult = await _repository.getMedicalRecords();
    final timelineResult = await _repository.getTimeline();

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      recordsResult.when(
        success: (records, msg) {
          _allRecords = records;
        },
        failure: (msg, code, err) {
          if (code == 401) {
            _errorMessage = _isEn
                ? 'Backend session unauthenticated (401). Sign in to synchronize live clinical records.'
                : 'Sesión no autenticada (401). Inicia sesión para sincronizar registros clínicos.';
          } else {
            _errorMessage = msg;
          }
        },
      );

      timelineResult.when(
        success: (items, msg) => _timelineItems = items,
        failure: (_, __, ___) => _timelineItems = [],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopHeader(),

            // Search Bar & Filter Tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: _isEn ? 'Search records, diagnosis...' : 'Buscar registros...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderMedium),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isTimelineView ? Icons.list_rounded : Icons.timeline_rounded,
                          color: AppColors.purplePrimary,
                        ),
                        onPressed: () => setState(() => _isTimelineView = !_isTimelineView),
                        tooltip: _isTimelineView ? 'List View' : 'Timeline View',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Category chips & Specialized Vaults
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...['ALL', 'GENERAL', 'DENTAL', 'VISION', 'VACCINES'].map((cat) {
                          final isSel = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                cat == 'ALL'
                                    ? (_isEn ? 'All Records' : 'Todos')
                                    : cat,
                              ),
                              selected: isSel,
                              selectedColor: AppColors.purplePrimary,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              onSelected: (val) {
                                if (val) setState(() => _selectedCategory = cat);
                              },
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: const CareIdDentalLogo(size: 16, color: AppColors.dentalIcon),
                            label: const Text('Dental Vault', style: TextStyle(color: AppColors.dentalIcon, fontWeight: FontWeight.bold, fontSize: 12)),
                            backgroundColor: AppColors.dentalBg,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const DentalRecordsScreen(),
                                ),
                              ).then((_) => _loadRecords());
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.visionIcon),
                            label: const Text('Vision Vault', style: TextStyle(color: AppColors.visionIcon, fontWeight: FontWeight.bold, fontSize: 12)),
                            backgroundColor: AppColors.visionBg,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const VisionRecordsScreen(),
                                ),
                              ).then((_) => _loadRecords());
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: const Icon(Icons.pets_outlined, size: 16, color: AppColors.petsIcon),
                            label: const Text('Pet Vault', style: TextStyle(color: AppColors.petsIcon, fontWeight: FontWeight.bold, fontSize: 12)),
                            backgroundColor: AppColors.petsBg,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PetRecordsScreen(
                                    apiClient: widget.apiClient,
                                    language: widget.language,
                                  ),
                                ),
                              ).then((_) => _loadRecords());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.purplePrimary),
                    )
                  : RefreshIndicator(
                      color: AppColors.purplePrimary,
                      onRefresh: _loadRecords,
                      child: _buildContent(records),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_medical_record',
        backgroundColor: AppColors.purplePrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(_isEn ? 'Add Record' : 'Nuevo'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AddHealthRecordScreen(),
            ),
          ).then((_) => _loadRecords());
        },
      ),
    );
  }

  Widget _buildTopHeader() {
    final canPop = Navigator.of(context).canPop();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Row(
        children: [
          if (canPop) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.purpleDark, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              _isEn ? 'Medical Records' : 'Historial Médico',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                color: AppColors.purpleDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CareIdLogo.onlyId(height: 18),
          const SizedBox(width: 8),
          LanguageToggle(
            currentLanguage: _currentLanguage,
            onLanguageChanged: (lang) => setState(() => _currentLanguage = lang),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<MedicalRecordDto> records) {
    if (_selectedCategory == 'VACCINES') {
      return _buildVaccinesContent();
    }
    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 32),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: _isEn ? 'Retry' : 'Reintentar',
                  onPressed: _loadRecords,
                  isFullWidth: false,
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_isTimelineView && _timelineItems.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: _timelineItems.length,
        itemBuilder: (context, index) {
          final item = _timelineItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.purplePrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${item.eventType} • ${item.date}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (records.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.purpleLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    size: 40,
                    color: AppColors.purplePrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEn ? 'No medical records found' : 'No hay registros médicos',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEn
                      ? 'Tap "+ Add Record" below or upload records to your CareID cryptographic vault.'
                      : 'Presiona "+ Nuevo" abajo o sube registros a tu bóveda CareID.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RecordDetailScreen(record: record),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (_) {
                    final isDental = record.category.toUpperCase() == 'DENTAL';
                    final isVision = record.category.toUpperCase() == 'VISION';
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDental
                            ? AppColors.dentalBg
                            : (isVision ? AppColors.visionBg : AppColors.purpleLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isDental
                          ? const CareIdDentalLogo(size: 22, color: AppColors.dentalIcon)
                          : Icon(
                              isVision ? Icons.visibility_outlined : Icons.medical_services_outlined,
                              color: isVision ? AppColors.visionIcon : AppColors.purplePrimary,
                              size: 22,
                            ),
                    );
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              record.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.purplePrimary,
                              ),
                            ),
                          ),
                          Text(
                            record.recordDate != null && record.recordDate!.length >= 10
                                ? record.recordDate!.substring(0, 10)
                                : '',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        record.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (record.chiefComplaint != null && record.chiefComplaint!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          record.chiefComplaint!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaccinesContent() {
    if (_isLoadingVaccines) {
      return const Center(child: CircularProgressIndicator(color: AppColors.purplePrimary));
    }

    final q = _searchController.text.trim().toLowerCase();
    final filtered = _vaccines.where((v) {
      if (q.isEmpty) return true;
      return v.name.toLowerCase().contains(q) ||
          (v.manufacturer?.toLowerCase().contains(q) ?? false) ||
          (v.code?.toLowerCase().contains(q) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.vaccines_outlined,
                    size: 40,
                    color: AppColors.purplePrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEn ? 'No immunization records found' : 'No hay vacunas registradas',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEn
                      ? 'Vaccine directory entries and patient immunization schedules will appear here once administered or cataloged.'
                      : 'El directorio de vacunas y esquemas de inmunización aparecerán aquí una vez administrados.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final vaccine = filtered[index];
        return Container(
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
                  Expanded(
                    child: Text(
                      vaccine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: vaccine.isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: vaccine.isActive ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      vaccine.isActive ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: vaccine.isActive ? const Color(0xFF047857) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${vaccine.manufacturer ?? "Standard Formulary"} • Code: ${vaccine.code ?? "VAC-GEN"}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.purplePrimary),
                  const SizedBox(width: 6),
                  Text(
                    'Doses Required: ${vaccine.requiredDoses}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 16),
                  if (vaccine.targetGroup != null) ...[
                    const Icon(Icons.people_outline, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      vaccine.targetGroup!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ],
              ),
              if (vaccine.description != null && vaccine.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  vaccine.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

}
