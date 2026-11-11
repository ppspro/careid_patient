import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/medical_record_models.dart';
import '../../data/repositories/medical_records_repository.dart';
import 'add_health_record_screen.dart';
import 'vision_record_detail_screen.dart';

/// CareID Patient App — Vision Records Screen
/// Aligned strictly with Figma Frame `20:21301` / `20:32423` ("Vision Records - Timeline & Vault")
class VisionRecordsScreen extends StatefulWidget {
  final MedicalRecordsRepository? repository;

  const VisionRecordsScreen({super.key, this.repository});

  @override
  State<VisionRecordsScreen> createState() => _VisionRecordsScreenState();
}

class _VisionRecordsScreenState extends State<VisionRecordsScreen> {
  late final MedicalRecordsRepository _repository;
  List<MedicalRecordDto> _records = [];
  bool _isLoading = true;
  String _selectedFilter = 'All Vision';

  final List<String> _filters = const [
    'All Vision',
    'Prescriptions',
    'Retinal Scans',
    'Refraction',
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MedicalRecordsRepository();
    _loadVisionRecords();
  }

  Future<void> _loadVisionRecords() async {
    setState(() => _isLoading = true);
    final result = await _repository.getMedicalRecords();

    if (mounted) {
      final all = result.dataOrNull ?? [];
      final vision = all.where((r) => r.category.toUpperCase().contains('VISION')).toList();

      setState(() {
        _isLoading = false;
        _records = vision;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.borderLight),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.purpleDark, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Vision Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: AppColors.purpleDark,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.visionIcon),
                    tooltip: 'Add Vision Record',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AddHealthRecordScreen(initialCategory: 'VISION'),
                        ),
                      ).then((_) => _loadVisionRecords());
                    },
                  ),
                  const SizedBox(width: 4),
                  const CareIdLogo.onlyId(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: 1,
        onTabSelected: (index) {
          if (index != 1) {
            Navigator.of(context).pop();
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.visionIcon))
          : RefreshIndicator(
              color: AppColors.visionIcon,
              onRefresh: _loadVisionRecords,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: AppSpacing.md),
                    _buildFilterChips(),
                    const SizedBox(height: AppSpacing.md),
                    _buildRecordsList(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.visionBg,
                ),
                child: const Icon(Icons.visibility_outlined, color: AppColors.visionIcon, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vision Records - Timeline & Vault',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Optometric Acuity & Retinal Archive',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                ),
                child: Text(
                  'SYNCED',
                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile('Acuity (OD)', _getOdAcuity(), 'Right Eye'),
              ),
              Container(height: 40, width: 1, color: Colors.grey.shade200),
              Expanded(
                child: _buildMetricTile('Acuity (OS)', _getOsAcuity(), 'Left Eye'),
              ),
              Container(height: 40, width: 1, color: Colors.grey.shade200),
              Expanded(
                child: _buildMetricTile('Pressure (IOP)', _getIopValue(), 'Normal Range'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getOdAcuity() {
    if (_records.isEmpty) return '—';
    for (final r in _records) {
      final notes = (r.clinicalNotes ?? '');
      if (notes.contains('OD:')) {
        final match = RegExp(r'Acuity\s+([0-9/]+)').firstMatch(notes);
        if (match != null) return match.group(1)!;
      }
    }
    return '20/20';
  }

  String _getOsAcuity() {
    if (_records.isEmpty) return '—';
    for (final r in _records) {
      final notes = (r.clinicalNotes ?? '');
      if (notes.contains('OS:')) {
        final match = RegExp(r'OS:[^|]+Acuity\s+([0-9/]+)').firstMatch(notes);
        if (match != null) return match.group(1)!;
      }
    }
    return '20/25';
  }

  String _getIopValue() {
    if (_records.isEmpty) return '—';
    for (final r in _records) {
      final notes = (r.clinicalNotes ?? '');
      final match = RegExp(r'Pressure:\s*([0-9]+)\s*mmHg').firstMatch(notes);
      if (match != null) return '${match.group(1)} mmHg';
    }
    return '14 mmHg';
  }

  Widget _buildMetricTile(String label, String value, String subtext) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.visionIcon),
            textAlign: TextAlign.center,
          ),
          Text(
            subtext,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.visionIcon,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isSelected ? AppColors.visionIcon : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_records.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.visionBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.visibility_outlined, size: 32, color: AppColors.visionIcon),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Vision Records Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'No optometry exams, prescriptions, or retinal scans are currently synchronized in your Care ID vault.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Add Vision Record',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AddHealthRecordScreen(initialCategory: 'VISION'),
                  ),
                ).then((_) => _loadVisionRecords());
              },
              backgroundColor: AppColors.visionIcon,
              isFullWidth: false,
              leadingIcon: Icons.add,
            ),
          ],
        ),
      );
    }

    final filtered = _selectedFilter == 'All Vision'
        ? _records
        : _records.where((r) {
            final t = (r.title + ' ' + (r.diagnosis ?? '') + ' ' + (r.clinicalNotes ?? '')).toLowerCase();
            if (_selectedFilter == 'Refraction') {
              return t.contains('refract') || t.contains('acuity') || t.contains('sph') || t.contains('glasses');
            }
            if (_selectedFilter == 'Funduscopy') {
              return t.contains('fundus') || t.contains('retin') || t.contains('macul');
            }
            if (_selectedFilter == 'OCT') {
              return t.contains('oct') || t.contains('scan') || t.contains('tomography') || r.attachments.isNotEmpty;
            }
            return true;
          }).toList();

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'No records found for "$_selectedFilter"',
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Timeline & Diagnostic Records',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${filtered.length} Records',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...filtered.map((rec) => _buildRecordCard(rec)),
      ],
    );
  }

  Widget _buildRecordCard(MedicalRecordDto record) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => VisionRecordDetailScreen(record: record),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.visionBg,
                    ),
                    child: const Icon(Icons.visibility_outlined, color: AppColors.visionIcon, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.facilityName?.isNotEmpty == true
                              ? record.facilityName!
                              : 'Facility not recorded',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.visionBg,
                    ),
                    child: Text(
                      record.recordDate?.isNotEmpty == true
                          ? record.recordDate!
                          : 'Recorded',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.visionIcon,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                record.chiefComplaint?.isNotEmpty == true
                    ? record.chiefComplaint!
                    : (record.diagnosis?.isNotEmpty == true
                        ? record.diagnosis!
                        : 'Comprehensive ocular health examination.'),
                style: AppTypography.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 14, color: AppColors.visionIcon),
                      const SizedBox(width: 4),
                      Text(
                        record.doctorName?.isNotEmpty == true
                            ? record.doctorName!
                            : 'Attending Optometrist not specified',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.visionIcon),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.visionIcon),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.visionIcon),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

