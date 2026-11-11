import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/wallet_badges.dart';

/// CareID Full Kiosk Check-In Pass Screen
/// Faithfully reproduces Figma frame node 20:32906 ("Full Kiosk Pass", 375x1145)
/// Also aligns with QR Pass & Verification Suite:
/// - 20:22771 ("QR Dashboard", 390x1105)
/// - 20:23195 ("Share Options", 390x2205)
/// - 20:23338 ("QR Preview", 390x1150)
/// - 20:23597 ("Manage Shared Access", 390x1282)
/// - 20:23745 ("Access Verification", 390x1324)
/// Located on canvas "Careid patient app" (node 17:55).
class FullKioskPassScreen extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String dateTime;
  final String location;
  final String patientName;
  final String careIdNumber;
  final String language;

  const FullKioskPassScreen({
    super.key,
    this.doctorName = 'Dr. Sarah Jenkins, MD',
    this.specialty = 'Cardiology & Internal Medicine',
    this.dateTime = 'Thursday, Nov 16 • 09:30 AM',
    this.location = '1190 5th Ave, Suite 400, New York, NY 10029',
    this.patientName = 'Sarah Jenkins',
    this.careIdNumber = 'CID #8472-9901',
    this.language = 'en',
  });

  bool get _isEn => language == 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B), // Deep indigo/purple kiosk background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEn ? 'Kiosk Pass' : 'Pase de Quiosco',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEn ? 'Kiosk Pass ready for sharing' : 'Pase listo para compartir'),
                  backgroundColor: AppColors.purplePrimary,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Digital Kiosk Pass Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top header ribbon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.purplePrimary,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEn ? 'Express Kiosk Pass' : 'Pase Exprés de Quiosco',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isEn
                                      ? 'Scan this code at the clinic kiosk for express check-in.'
                                      : 'Escanea este código en el quiosco para registrarte rápido.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pre-authorization Badge
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isEn
                                  ? 'Pre-authorized with 5 Care ID Vault records'
                                  : 'Pre-autorizado con 5 registros de Bóveda CareID',
                              style: const TextStyle(
                                color: Color(0xFF166534),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Large High-Density QR / Barcode Area
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.purplePrimary.withValues(alpha: 0.3), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purplePrimary.withValues(alpha: 0.08),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.qr_code_2_rounded,
                                size: 160,
                                color: AppColors.purplePrimary,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                careIdNumber,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Dashed perforation divider
                    Row(
                      children: List.generate(
                        30,
                        (i) => Expanded(
                          child: Container(
                            height: 2,
                            color: i % 2 == 0 ? Colors.grey.shade300 : Colors.transparent,
                          ),
                        ),
                      ),
                    ),

                    // Details Section
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            icon: Icons.person_outline_rounded,
                            label: _isEn ? 'Patient Info' : 'Datos del Paciente',
                            value: '$patientName • $careIdNumber',
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.medical_services_outlined,
                            label: _isEn ? 'Physician & Specialty' : 'Médico y Especialidad',
                            value: '$doctorName\n$specialty',
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.calendar_today_rounded,
                            label: _isEn ? 'Appointment Time' : 'Hora de Consulta',
                            value: dateTime,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.location_on_outlined,
                            label: _isEn ? 'Location' : 'Ubicación de la Clínica',
                            value: location,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Add to Wallet Buttons (Figma Nodes 20:33017 & 20:33023)
              AppleWalletButton(
                height: 52,
                label: _isEn ? 'Apple Wallet' : 'Apple Wallet',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isEn ? 'Pass added to Apple Wallet' : 'Pase añadido a Apple Wallet'),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              GoogleWalletButton(
                height: 52,
                label: _isEn ? 'Google Pay' : 'Google Pay',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isEn ? 'Pass added to Google Wallet' : 'Pase añadido a Google Wallet'),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                label: _isEn ? 'Done / Back to Home' : 'Listo / Regresar',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.purplePrimary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
