import '../../../../shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../data/models/appointment_models.dart';

/// Care ID - Cancel Appointment Confirmation Dialog (Figma node `20:30384`)
/// A modal bottom sheet dialog matching the approved Figma design specifications.
class CancelAppointmentDialog extends StatelessWidget {
  final AppointmentModel appointment;
  final int remainingCancellations;

  const CancelAppointmentDialog({
    super.key,
    required this.appointment,
    this.remainingCancellations = 2,
  });

  static Future<bool?> show(
    BuildContext context, {
    required AppointmentModel appointment,
    int remainingCancellations = 2,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CancelAppointmentDialog(
        appointment: appointment,
        remainingCancellations: remainingCancellations,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dt = appointment.dateTime;
    final wd = weekdays[(dt.weekday - 1).clamp(0, 6)];
    final mo = months[(dt.month - 1).clamp(0, 11)];
    final formattedDate = '$wd, $mo ${dt.day}, ${dt.year}';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final formattedTime = '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';

    final doctorName = appointment.doctorName.isNotEmpty
        ? appointment.doctorName
        : 'Dr. Sarah Jenkins';
    final facility = appointment.facility.isNotEmpty
        ? appointment.facility
        : 'Mount Sinai Heart Center';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 50,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag Handle Indicator (20:30473)
              Center(
                child: Container(
                  width: 40,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0x99CBC4D4),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),

              // Warning Cancel Badge Icon (20:30488)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDAD6),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBA1A1A).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.event_busy_rounded,
                          color: Color(0xFFBA1A1A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBA1A1A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.priority_high,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Heading 2 - Dialog Title (20:30476)
              Text(
                'Cancel Appointment?',
                style: AppTypography.heading2.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B1C30),
                  letterSpacing: -0.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Explanatory Text (20:30479)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTypography.bodyRegular.copyWith(
                    fontSize: 15,
                    height: 1.5,
                    color: const Color(0xFF494552),
                  ),
                  children: [
                    const TextSpan(text: 'Are you sure you want to cancel your consultation with '),
                    TextSpan(
                      text: doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    const TextSpan(text: ' scheduled for '),
                    TextSpan(
                      text: formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    const TextSpan(text: ' at '),
                    TextSpan(
                      text: formattedTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    const TextSpan(text: ' at '),
                    TextSpan(
                      text: facility,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reassuring Notice Box (20:30481)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4E3FC), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF155EEF),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your reserved slot will be released. You can book a new consultation anytime through the Doctors Directory.',
                            style: AppTypography.caption.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF494552),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.caption.copyWith(
                                fontSize: 13,
                                color: const Color(0xFF494552),
                                height: 1.4,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Important: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: '3 or more cancellations',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0B1C30),
                                  ),
                                ),
                                TextSpan(
                                  text: ' will prevent you from booking future appointments online. You will only be seen on a ',
                                ),
                                TextSpan(
                                  text: 'walk-in basis',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0B1C30),
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Button - Destructive Action (20:30497)
              PrimaryButton(
                label: 'Cancel Appointment ($remainingCancellations) Remaining',
                onPressed: () => Navigator.of(context).pop(true),
                backgroundColor: const Color(0xFFBA1A1A),
                leadingIcon: Icons.close_rounded,
                height: 50,
              ),
              const SizedBox(height: 12),

              // Button - Keep / Dismiss Action (20:30503)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE5EEFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: Text(
                    'Keep Appointment',
                    style: AppTypography.buttonText.copyWith(
                      color: const Color(0xFF0B1C30),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secure Care ID Micro-trust Indicator (20:30507)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: Color(0xCC494552),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CareID HIPAA Protected Patient Action',
                    style: AppTypography.caption.copyWith(
                      fontSize: 12,
                      color: const Color(0xCC494552),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
