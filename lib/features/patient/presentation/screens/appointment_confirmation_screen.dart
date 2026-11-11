import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../data/models/appointment_models.dart';
import 'appointment_details_screen.dart';

/// CareID Patient App — Appointment Confirmation Screen
/// Faithfully reproduces Figma Frame `20:29208` ("Care ID - Appointment Confirmation", 390x1464.5)
/// Features celebration checkmark, digital care pass credential preview, step-by-step kiosk arrival guide,
/// calendar synchronization shortcut, and full doctor consultation metadata.
class AppointmentConfirmationScreen extends StatelessWidget {
  final ApiClient? apiClient;
  final String language;
  final AppointmentModel? appointment;

  const AppointmentConfirmationScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.appointment,
  });

  bool get _isEn => language == 'en';

  AppointmentModel get _apt =>
      appointment ??
      AppointmentModel(
        id: 'APT-88204-NY',
        doctorId: 'doc-sarah-jenkins',
        doctorName: 'Dr. Sarah Jenkins, MD',
        specialization: 'Department of Cardiology',
        facility: 'Mount Sinai Hospital • Heart Center',
        dateTime: DateTime(2023, 11, 16, 9, 45),
        consultationType: 'In-Person Consultation',
        suiteRoom: '4th Floor, Suite 400 • Check-in Kiosk 2',
        durationMinutes: 45,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Bar
            _buildTopHeader(context),

            // 2. Scrollable Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  // Sub-header Bar: APPOINTMENT STATUS
                  _buildStatusSubBar(context),
                  const SizedBox(height: 20),

                  // Hero Celebration Section
                  _buildHeroCelebration(),
                  const SizedBox(height: 20),

                  // Digital Care Pass Card
                  _buildDigitalCarePassCard(),
                  const SizedBox(height: 24),

                  // Arrival & Next Steps (Step-by-step)
                  _buildArrivalNextSteps(context),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: 2, // Doctor tab active with cyan capsule
        language: language,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('/records');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/profile');
          }
        },
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF2E006A)),
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Image.asset(
            'assets/images/careid_logo_horizontal.png',
            height: 22,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'CareID',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E006A),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF2E006A)),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSubBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFECFEFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5F3FC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF00838F)),
              SizedBox(width: 8),
              Text(
                'APPOINTMENT STATUS',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00838F),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFCFFAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF00838F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCelebration() {
    return Column(
      children: [
        // Star & Checkmark Badge
        Stack(
          alignment: Alignment.center,
          children: [
            // Background sparkles
            const Positioned(
              left: 10,
              top: 10,
              child: Icon(Icons.auto_awesome, size: 18, color: Color(0xFFE879F9)),
            ),
            const Positioned(
              right: 12,
              top: 4,
              child: Icon(Icons.auto_awesome, size: 20, color: Color(0xFF818CF8)),
            ),
            const Positioned(
              left: 16,
              bottom: 8,
              child: Icon(Icons.star_rounded, size: 16, color: Color(0xFFF472B6)),
            ),
            // Purple circle with checkmark
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          _isEn ? 'Appointment Booked!' : '¡Cita Reservada!',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2E006A),
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _isEn
                ? 'Your consultation with ${_apt.doctorName} has been confirmed and scheduled.'
                : 'Tu consulta con ${_apt.doctorName} ha sido confirmada y agendada.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Confirmation ID Capsule
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDD6FE)),
          ),
          child: Text(
            '# CONFIRMATION #${_apt.id}',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5B14B8),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalCarePassCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dark Purple Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2E006A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_outlined, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'DIGITAL CARE PASS',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004D40),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Info Row
                Row(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 52,
                        height: 52,
                        color: const Color(0xFFF1F5F9),
                        child: Image.asset(
                          'assets/images/doctor_sarah_jenkins.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/careid_splash_nurse.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _apt.doctorName,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _apt.specialization,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00838F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date & Time Bento Boxes
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF5B14B8)),
                                SizedBox(width: 6),
                                Text(
                                  'Date',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Thu, Nov 16, 2023',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF5B14B8)),
                                SizedBox(width: 6),
                                Text(
                                  'Time',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              '09:45 AM EST',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location Block
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF00838F)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _apt.facility,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _apt.suiteRoom ?? '4th Floor, Suite 400 • Check-in Kiosk 2',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Consultation Strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.medical_services_outlined, size: 16, color: Color(0xFF00838F)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _apt.consultationType,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00838F),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_apt.durationMinutes} Min',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00838F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalNextSteps(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Arrival & Next Steps',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Step-by-step',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Step 1: Digital Pass Created
        _buildStepTile(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF5B14B8),
          bgColor: const Color(0xFFF5F3FF),
          title: 'Digital Pass Created',
          description: 'Added to your Care ID Appointment Hub and automatically synced to your medical timeline.',
        ),
        const SizedBox(height: 10),

        // Step 2: Fast Arrival Registration
        _buildStepTile(
          icon: Icons.qr_code_scanner_rounded,
          iconColor: const Color(0xFF00796B),
          bgColor: const Color(0xFFE0F7FA),
          title: 'Fast Arrival Registration',
          description: 'Present your Care ID Health Card QR at the Suite 400 kiosk for zero-wait registration.',
        ),
        const SizedBox(height: 10),

        // Step 3: Device Calendar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Calendar',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sync reminders & drive alerts',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment synced to device calendar!')),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00796B),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '+ Add to Calendar',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Button 1: View Appointment Details ->
        PrimaryButton(
          label: _isEn ? 'View Appointment Details' : 'Ver Detalles de Cita',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AppointmentDetailsScreen(
                  appointment: _apt,
                ),
              ),
            );
          },
          trailingIcon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: 12),

        // Button 2: Return to Home
        PrimaryButton(
          label: _isEn ? 'Return to Home' : 'Volver al Inicio',
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
          },
          backgroundColor: const Color(0xFFEFF6FF),
          textColor: const Color(0xFF2E006A),
        ),
      ],
    );
  }
}
