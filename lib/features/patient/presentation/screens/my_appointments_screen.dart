import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/appointment_models.dart';
import '../../data/repositories/doctor_repository.dart';
import 'appointment_details_screen.dart';
import 'doctors_directory_screen.dart';

/// CareID Patient App — My Appointments Screen
/// Aligned strictly with Figma Frame `20:29664`
class MyAppointmentsScreen extends StatefulWidget {
  final DoctorRepository? repository;

  const MyAppointmentsScreen({super.key, this.repository});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final DoctorRepository _repository;
  late final TabController _tabController;

  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DoctorRepository();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final result = await _repository.getMyAppointments();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _appointments = result.dataOrNull ?? [];
      });
    }
  }

  List<AppointmentModel> _getFilteredAppointments(AppointmentStatus status) {
    return _appointments.where((a) => a.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const CareIdLogo.horizontal(height: 18),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF5B14B8)),
            tooltip: 'Book New Appointment',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DoctorsDirectoryScreen(),
                ),
              ).then((_) => _loadAppointments());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF5B14B8),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF5B14B8),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Plus Jakarta Sans'),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Plus Jakarta Sans'),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList(AppointmentStatus.upcoming),
                _buildAppointmentList(AppointmentStatus.completed),
                _buildAppointmentList(AppointmentStatus.cancelled),
              ],
            ),
    );
  }

  Widget _buildAppointmentList(AppointmentStatus status) {
    final list = _getFilteredAppointments(status);

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status == AppointmentStatus.upcoming
                    ? Icons.event_available_outlined
                    : status == AppointmentStatus.completed
                        ? Icons.fact_check_outlined
                        : Icons.event_busy_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No ${status.label} Appointments',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                status == AppointmentStatus.upcoming
                    ? 'You have no scheduled appointments at this time.'
                    : 'No ${status.label.toLowerCase()} consultations recorded.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              if (status == AppointmentStatus.upcoming) ...[
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton.gradient(
                  label: 'Book an Appointment',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DoctorsDirectoryScreen(),
                      ),
                    ).then((_) => _loadAppointments());
                  },
                  isFullWidth: false,
                  leadingIcon: Icons.add,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 120.0),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final apt = list[index];
          return _buildAppointmentCard(apt);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel apt) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${apt.dateTime.day} ${monthNames[apt.dateTime.month - 1]} ${apt.dateTime.year}';
    final timeStr = '${apt.dateTime.hour > 12 ? apt.dateTime.hour - 12 : apt.dateTime.hour}:${apt.dateTime.minute.toString().padLeft(2, '0')} ${apt.dateTime.hour >= 12 ? 'PM' : 'AM'}';

    final isUpcoming = apt.status == AppointmentStatus.upcoming;

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
              builder: (_) => AppointmentDetailsScreen(
                appointment: apt,
                repository: _repository,
              ),
            ),
          ).then((_) => _loadAppointments());
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeStr,
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      apt.doctorName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apt.doctorName,
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          apt.specialization,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      apt.facility,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    apt.consultationType,
                    style: TextStyle(
                      fontSize: 11,
                      color: isUpcoming ? Colors.green.shade700 : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AppointmentDetailsScreen(
                          appointment: apt,
                          repository: _repository,
                        ),
                      ),
                    ).then((_) => _loadAppointments());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const RoundedRectangleBorder(
                    ),
                  ),
                  child: Text(isUpcoming ? 'View Pass & Details' : 'View Record & Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
