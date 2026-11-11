import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/repositories/doctor_repository.dart';

/// CareID Reschedule Appointment Screen
/// Faithfully reproduces Figma frame node 20:30086 ("Care ID - Reschedule Appointment (Date & Time)", 390x1540)
/// Located on canvas "Careid patient app" (node 17:55).
class RescheduleAppointmentScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final String previousDate;
  final String previousTime;
  final String language;

  const RescheduleAppointmentScreen({
    super.key,
    this.appointmentId = 'apt-042',
    this.doctorName = 'Dr. Sarah Jenkins, MD',
    this.previousDate = 'Thu, Nov 16',
    this.previousTime = '09:45 AM',
    this.language = 'en',
  });

  @override
  State<RescheduleAppointmentScreen> createState() => _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState extends State<RescheduleAppointmentScreen> {
  int _selectedDayIndex = 2; // Default to Nov 21
  String _selectedSlot = '10:30 AM';
  String _selectedPeriod = 'morning'; // 'morning' or 'afternoon'
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _availableDays = [
    {'day': 'Mon', 'date': '20', 'month': 'Nov'},
    {'day': 'Tue', 'date': '21', 'month': 'Nov'},
    {'day': 'Wed', 'date': '22', 'month': 'Nov'},
    {'day': 'Thu', 'date': '23', 'month': 'Nov'},
    {'day': 'Fri', 'date': '24', 'month': 'Nov'},
    {'day': 'Mon', 'date': '27', 'month': 'Nov'},
  ];

  final List<String> _morningSlots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:15 AM'];
  final List<String> _afternoonSlots = ['01:30 PM', '02:15 PM', '03:00 PM', '03:45 PM', '04:15 PM'];

  bool get _isEn => widget.language == 'en';

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);

    final selectedDay = _availableDays[_selectedDayIndex];
    final dayName = selectedDay['day'] ?? '';
    final monthName = selectedDay['month'] ?? '';
    final dateNum = selectedDay['date'] ?? '';
    final newDateStr = '$dayName, $monthName $dateNum';

    final repo = DoctorRepository();
    final now = DateTime.now();
    final targetDate = DateTime(now.year, 11, int.tryParse(dateNum) ?? 20);

    await repo.rescheduleAppointment(
      widget.appointmentId,
      newDate: targetDate,
      startTime: _selectedSlot,
      endTime: _selectedSlot,
      reason: _reasonController.text.trim().isNotEmpty ? _reasonController.text.trim() : 'Patient requested reschedule',
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.purplePrimary),
            const SizedBox(width: 8),
            Text(_isEn ? 'Rescheduled' : 'Reagendado'),
          ],
        ),
        content: Text(
          _isEn
              ? 'Your appointment with ${widget.doctorName} has been moved to $newDateStr at $_selectedSlot.'
              : 'Tu cita con ${widget.doctorName} ha sido cambiada para el $newDateStr a las $_selectedSlot.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context, true); // Return to details
            },
            child: Text(_isEn ? 'OK' : 'Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = _availableDays[_selectedDayIndex];
    final newDateDisplay = '${selectedDay['day']}, ${selectedDay['month']} ${selectedDay['date']}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEn ? 'Reschedule Appointment' : 'Reagendar Cita',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CareIdLogo.horizontal(height: 18),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Comparison Card (PREVIOUS vs NEW SLOT)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderMedium),
                  boxShadow: AppSpacing.cardShadow,
                ),
                child: Row(
                  children: [
                    // Previous slot
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEn ? 'PREVIOUS' : 'ANTERIOR',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.previousDate,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                            ),
                            Text(
                              widget.previousTime,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, color: AppColors.purplePrimary),
                    ),
                    // New slot
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.purpleLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.purplePrimary.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEn ? 'NEW SLOT' : 'NUEVO HORARIO',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.purplePrimary, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              newDateDisplay,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.purplePrimary),
                            ),
                            Text(
                              _selectedSlot,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5B14B8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Date Selection Carousel
              Text(
                _isEn ? 'Select Available Date' : 'Selecciona una Fecha',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableDays.length,
                  itemBuilder: (context, index) {
                    final item = _availableDays[index];
                    final isSelected = _selectedDayIndex == index;
                    return InkWell(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 62,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.purplePrimary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.purplePrimary : AppColors.borderMedium,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppColors.purplePrimary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['day']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['date']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 3. Time Slots (Morning vs Afternoon)
              Text(
                _isEn ? 'Select Time Slot' : 'Selecciona un Horario',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              // Period Toggle Pills
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedPeriod = 'morning'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'morning' ? AppColors.purplePrimary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedPeriod == 'morning' ? AppColors.purplePrimary : AppColors.borderMedium),
                        ),
                        child: Text(
                          _isEn ? 'Morning (09:00 AM – 12:00 PM)' : 'Mañana (09:00 AM – 12:00 PM)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedPeriod == 'morning' ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedPeriod = 'afternoon'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'afternoon' ? AppColors.purplePrimary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedPeriod == 'afternoon' ? AppColors.purplePrimary : AppColors.borderMedium),
                        ),
                        child: Text(
                          _isEn ? 'Afternoon (01:30 PM – 04:30 PM)' : 'Tarde (01:30 PM – 04:30 PM)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedPeriod == 'afternoon' ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Slot Pills Wrap
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: (_selectedPeriod == 'morning' ? _morningSlots : _afternoonSlots).map((slot) {
                  final isSelected = _selectedSlot == slot;
                  return InkWell(
                    onTap: () => setState(() => _selectedSlot = slot),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.purplePrimary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.purplePrimary : AppColors.borderMedium),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 4. Reason for Reschedule (Optional)
              Text(
                _isEn ? 'Reason for Rescheduling (Optional)' : 'Motivo del cambio (Opcional)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: _isEn ? 'e.g. Schedule conflict, transportation' : 'ej. Conflicto de horario, transporte',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderMedium)),
                ),
              ),

              const SizedBox(height: 28),

              // 5. Confirm Button
              PrimaryButton.gradient(
                label: _isEn ? 'Confirm Reschedule' : 'Confirmar Cambio',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

