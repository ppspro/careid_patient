import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/appointment_models.dart';
import '../../data/repositories/doctor_repository.dart';
import '../dialogs/cancel_appointment_dialog.dart';
import 'full_kiosk_pass_screen.dart';
import 'live_chat_screen.dart';
import 'reschedule_appointment_screen.dart';

/// CareID Patient App — Appointment Details & Actions Screen
/// Aligned strictly with Figma Frame `20:29860` & `20:29399`
class AppointmentDetailsScreen extends StatefulWidget {
  final AppointmentModel appointment;
  final DoctorRepository? repository;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
    this.repository,
  });

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  late final DoctorRepository _repository;
  late AppointmentModel _appointment;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DoctorRepository();
    _appointment = widget.appointment;
  }

  Future<void> _handleCancel() async {
    // Care ID - Cancel Appointment Confirmation Dialog (Figma node 20:30384)
    final confirm = await CancelAppointmentDialog.show(
      context,
      appointment: _appointment,
      remainingCancellations: 2,
    );

    if (confirm == true) {
      setState(() => _isCancelling = true);
      await _repository.cancelAppointment(_appointment.id);
      if (mounted) {
        setState(() {
          _isCancelling = false;
          _appointment = AppointmentModel(
            id: _appointment.id,
            doctorId: _appointment.doctorId,
            doctorName: _appointment.doctorName,
            specialization: _appointment.specialization,
            facility: _appointment.facility,
            dateTime: _appointment.dateTime,
            consultationType: _appointment.consultationType,
            status: AppointmentStatus.cancelled,
            reasonForVisit: _appointment.reasonForVisit,
            preparationNote: _appointment.preparationNote,
            qrPassCode: _appointment.qrPassCode,
            suiteRoom: _appointment.suiteRoom,
            durationMinutes: _appointment.durationMinutes,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment has been cancelled.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${_appointment.dateTime.day} ${monthNames[_appointment.dateTime.month - 1]} ${_appointment.dateTime.year}';
    final timeStr = '${_appointment.dateTime.hour > 12 ? _appointment.dateTime.hour - 12 : _appointment.dateTime.hour}:${_appointment.dateTime.minute.toString().padLeft(2, '0')} ${_appointment.dateTime.hour >= 12 ? 'PM' : 'AM'}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const CareIdLogo.horizontal(height: 18),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPassHeader(dateStr, timeStr),
            const SizedBox(height: AppSpacing.md),
            _buildDoctorFacilityCard(),
            const SizedBox(height: AppSpacing.md),
            _buildSpecificationCard(),
            const SizedBox(height: AppSpacing.md),
            _buildPreparationCard(),
            const SizedBox(height: AppSpacing.lg),
            if (_appointment.status == AppointmentStatus.upcoming) ...[
              _buildActionButtons(),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildPassHeader(String dateStr, String timeStr) {
    final isUpcoming = _appointment.status == AppointmentStatus.upcoming;
    final isCancelled = _appointment.status == AppointmentStatus.cancelled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? Colors.green.shade50
                      : isCancelled
                          ? Colors.red.shade50
                          : Colors.grey.shade100,
                ),
                child: Text(
                  _appointment.status.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUpcoming
                        ? Colors.green.shade700
                        : isCancelled
                            ? Colors.red.shade700
                            : Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${_appointment.durationMinutes} min consultation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dateStr,
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '$timeStr (EST)',
            style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
          const Divider(height: 24),
          if (isUpcoming) ...[
            const Icon(Icons.qr_code_scanner, size: 84, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              'Digital Check-In Pass: ${_appointment.qrPassCode}',
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Present at arrival kiosk or reception desk',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ] else ...[
            Icon(
              isCancelled ? Icons.cancel_outlined : Icons.check_circle_outline,
              size: 56,
              color: isCancelled ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 6),
            Text(
              isCancelled ? 'Appointment Cancelled' : 'Consultation Completed',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoctorFacilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doctor & Facility',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  _appointment.doctorName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _appointment.doctorName,
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _appointment.specialization,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _appointment.facility,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _appointment.suiteRoom ?? 'Suite 400 • Check-in Kiosk 2',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Specification',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow('Visit Type', _appointment.consultationType),
          const Divider(height: 16),
          _buildInfoRow('Reason for Visit', _appointment.reasonForVisit),
          const Divider(height: 16),
          _buildInfoRow('Patient Context', 'John Doe (Self)'),
        ],
      ),
    );
  }

  Widget _buildPreparationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Preparation & Linked Vault Records',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _appointment.preparationNote,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Care ID Cardiology Vault record shared with clinic',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isCancelled = _appointment.status == AppointmentStatus.cancelled;
    final isCompleted = _appointment.status == AppointmentStatus.completed;

    return Column(
      children: [
        if (!isCancelled && !isCompleted) ...[
          // 1. View Express Kiosk Pass (Figma node 20:32906)
          PrimaryButton(
            label: 'View Express Kiosk Pass',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FullKioskPassScreen(
                    doctorName: _appointment.doctorName,
                    specialty: _appointment.specialization,
                    dateTime:
                        '${_appointment.dateTime.day} Nov • ${_appointment.dateTime.hour > 12 ? _appointment.dateTime.hour - 12 : _appointment.dateTime.hour}:${_appointment.dateTime.minute.toString().padLeft(2, '0')} ${_appointment.dateTime.hour >= 12 ? 'PM' : 'AM'}',
                    location: _appointment.facility,
                    patientName: 'John Doe',
                    careIdNumber: 'CID #8472-9901',
                  ),
                ),
              );
            },
            backgroundColor: AppColors.tealPrimary,
            leadingIcon: Icons.qr_code_2_rounded,
                        padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 2. Reschedule Appointment (Figma node 20:30086)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => RescheduleAppointmentScreen(
                      appointmentId: _appointment.id,
                      doctorName: _appointment.doctorName,
                      previousDate: '${_appointment.dateTime.day} Nov',
                      previousTime:
                          '${_appointment.dateTime.hour > 12 ? _appointment.dateTime.hour - 12 : _appointment.dateTime.hour}:${_appointment.dateTime.minute.toString().padLeft(2, '0')} ${_appointment.dateTime.hour >= 12 ? 'PM' : 'AM'}',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month_rounded, color: AppColors.purplePrimary),
              label: const Text(
                'Reschedule Appointment',
                style: TextStyle(color: AppColors.purplePrimary, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.purplePrimary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 3. Message Clinic Care Team (Figma node 20:31689)
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LiveChatScreen(
                      conversationTitle: _appointment.doctorName,
                      participantSubtitle: '${_appointment.specialization} • ${_appointment.facility}',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.purplePrimary),
              label: const Text(
                'Chat with Care Team',
                style: TextStyle(color: AppColors.purplePrimary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Cancel Button
        if (!isCancelled && !isCompleted)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isCancelling ? null : _handleCancel,
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: _isCancelling
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                    )
                  : const Text(
                      'Cancel Appointment',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                ),
              ),
            ),
          ),
      ],
    );
  }
}

