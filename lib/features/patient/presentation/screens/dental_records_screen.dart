import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_dental_logo.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/medical_record_models.dart';
import '../../data/repositories/medical_records_repository.dart';
import 'add_health_record_screen.dart';
import 'dental_record_detail_screen.dart';

/// CareID Patient App — Dental Records Screen
/// Aligned strictly with Figma Frame `20:21111` ("Dental Records")
class DentalRecordsScreen extends StatefulWidget {
  final MedicalRecordsRepository? repository;

  const DentalRecordsScreen({super.key, this.repository});

  @override
  State<DentalRecordsScreen> createState() => _DentalRecordsScreenState();
}

class _DentalRecordsScreenState extends State<DentalRecordsScreen> {
  late final MedicalRecordsRepository _repository;
  List<MedicalRecordDto> _records = [];
  bool _isLoading = true;
  String _selectedFilter = 'All Dental';

  final List<String> _filters = const [
    'All Dental',
    'Radiographs',
    'Restorations',
    'Cleanings',
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MedicalRecordsRepository();
    _loadDentalRecords();
  }

  Future<void> _loadDentalRecords() async {
    setState(() => _isLoading = true);
    final result = await _repository.getMedicalRecords();

    if (mounted) {
      final all = result.dataOrNull ?? [];
      final dental = all.where((r) => r.category.toUpperCase().contains('DENTAL')).toList();

      setState(() {
        _isLoading = false;
        _records = dental;
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
                    'Dental Records',
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
                    icon: const Icon(Icons.add, color: AppColors.dentalIcon),
                    tooltip: 'Add Dental Record',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AddHealthRecordScreen(initialCategory: 'DENTAL'),
                        ),
                      ).then((_) => _loadDentalRecords());
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.dentalIcon))
          : RefreshIndicator(
              color: AppColors.dentalIcon,
              onRefresh: _loadDentalRecords,
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
                  color: AppColors.dentalBg,
                ),
                child: const CareIdDentalLogo(size: 24, color: AppColors.dentalIcon),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Care ID Dental Vault',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Encrypted Odontogram & Radiographic Archive',
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
                child: _buildMetricTile(
                  'Restorations',
                  _getRestorationsCount(),
                  'Odontogram OK',
                ),
              ),
              Container(height: 40, width: 1, color: Colors.grey.shade200),
              Expanded(
                child: _buildMetricTile(
                  'Last Scaling',
                  _getLastScalingDate(),
                  'Full Arch',
                ),
              ),
              Container(height: 40, width: 1, color: Colors.grey.shade200),
              Expanded(
                child: _buildMetricTile(
                  'Radiographs',
                  _getRadiographsCount(),
                  'High Res',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRestorationsCount() {
    if (_records.isEmpty) return '0 Active';
    final count = _records.where((r) {
      final text = (r.title + ' ' + (r.diagnosis ?? '')).toLowerCase();
      return text.contains('restor') || text.contains('fill') || text.contains('crown');
    }).length;
    return '$count Active';
  }

  String _getLastScalingDate() {
    if (_records.isEmpty) return 'None';
    final scaling = _records.firstWhere(
      (r) {
        final text = (r.title + ' ' + (r.diagnosis ?? '')).toLowerCase();
        return text.contains('clean') || text.contains('scal') || text.contains('prophy');
      },
      orElse: () => _records.first,
    );
    return scaling.recordDate?.isNotEmpty == true ? scaling.recordDate! : 'Recorded';
  }

  String _getRadiographsCount() {
    if (_records.isEmpty) return '0 Stored';
    final count = _records.where((r) {
      final text = (r.title + ' ' + (r.diagnosis ?? '') + ' ' + (r.clinicalNotes ?? '')).toLowerCase();
      return text.contains('x-ray') || text.contains('radio') || text.contains('bitewing') || r.attachments.isNotEmpty;
    }).length;
    return '$count Stored';
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.dentalIcon),
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
              selectedColor: AppColors.dentalIcon,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isSelected ? AppColors.dentalIcon : Colors.grey.shade300,
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
                color: AppColors.dentalBg,
                shape: BoxShape.circle,
              ),
              child: const CareIdDentalLogo(size: 32, color: AppColors.dentalIcon),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Dental Records Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'No dental consultations, radiographs, or restorations are currently synchronized in your Care ID vault.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Add Dental Record',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AddHealthRecordScreen(initialCategory: 'DENTAL'),
                  ),
                ).then((_) => _loadDentalRecords());
              },
              backgroundColor: AppColors.dentalIcon,
              isFullWidth: false,
              leadingIcon: Icons.add,
            ),
          ],
        ),
      );
    }

    final filtered = _selectedFilter == 'All Dental'
        ? _records
        : _records.where((r) {
            final t = (r.title + ' ' + (r.diagnosis ?? '') + ' ' + (r.clinicalNotes ?? '')).toLowerCase();
            if (_selectedFilter == 'Radiographs') {
              return t.contains('x-ray') || t.contains('radio') || t.contains('bitewing') || r.attachments.isNotEmpty;
            }
            if (_selectedFilter == 'Restorations') {
              return t.contains('restor') || t.contains('fill') || t.contains('crown');
            }
            if (_selectedFilter == 'Cleanings') {
              return t.contains('clean') || t.contains('scal') || t.contains('prophy');
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
              builder: (_) => DentalRecordDetailScreen(record: record),
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
                      color: AppColors.dentalBg,
                    ),
                    child: const CareIdDentalLogo(size: 20, color: AppColors.dentalIcon),
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
                      color: AppColors.dentalBg,
                    ),
                    child: Text(
                      record.recordDate?.isNotEmpty == true
                          ? record.recordDate!
                          : 'Recorded',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.dentalIcon,
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
                        : 'Routine dental consultation.'),
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
                      const Icon(Icons.verified, size: 14, color: AppColors.dentalIcon),
                      const SizedBox(width: 4),
                      Text(
                        record.doctorName?.isNotEmpty == true
                            ? record.doctorName!
                            : 'Attending Dentist not specified',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dentalIcon),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.dentalIcon),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.dentalIcon),
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

