import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../shared/widgets/careid_logo.dart';

/// CareID Patient App — Medication Reminder Detail Screen
/// Faithfully reproduces Figma Frame `20:24101` ("Medication Reminder Detail", 390x862)
/// Located on canvas "Careid patient app" (node 17:55).
class MedicationReminderDetailScreen extends StatefulWidget {
  final String medicationName;
  final String dosage;
  final String doctorName;
  final String specialty;
  final String collectByDate;
  final String pharmacyName;
  final String pharmacyAddress;
  final String pharmacyPhone;
  final String language;

  const MedicationReminderDetailScreen({
    super.key,
    this.medicationName = 'Atorvastatin 20mg',
    this.dosage = '1 tablet daily with evening meal',
    this.doctorName = 'Dr. Sarah Jenkins',
    this.specialty = 'Cardiology & Internal Medicine',
    this.collectByDate = '12/06',
    this.pharmacyName = 'City Health Apothecary',
    this.pharmacyAddress = '425 Clinical Way, Suite 200',
    this.pharmacyPhone = '+1 (555) 234-5678',
    this.language = 'en',
  });

  @override
  State<MedicationReminderDetailScreen> createState() =>
      _MedicationReminderDetailScreenState();
}

class _MedicationReminderDetailScreenState
    extends State<MedicationReminderDetailScreen> {
  bool _isCollected = false;

  bool get _isEn => widget.language == 'en';

  void _toggleCollected() {
    setState(() {
      _isCollected = !_isCollected;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isCollected ? const Color(0xFF16A34A) : const Color(0xFFD97706),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(
              _isCollected ? Icons.check_circle_rounded : Icons.schedule_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isCollected
                  ? (_isEn ? 'Medication marked as collected!' : '¡Medicamento marcado como recogido!')
                  : (_isEn ? 'Medication marked as pending collection.' : 'Marcado como pendiente de recogida.'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEn ? 'Prescription Reminder' : 'Recordatorio de Receta',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const CareIdLogo.horizontal(height: 18),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMedicationHeroCard(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildDosageSection(),
            const SizedBox(height: 20),
            _buildPharmacyInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B14B8), Color(0xFF7E22CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B14B8).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isCollected ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCollected ? Icons.check_circle_rounded : Icons.pending_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isCollected ? (_isEn ? 'COLLECTED' : 'RECOGIDO') : (_isEn ? 'PENDING' : 'PENDIENTE'),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_isEn ? "Collect by:" : "Recoger antes de:"} ${widget.collectByDate}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            widget.medicationName,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.dosage,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.doctorName} • ${widget.specialty}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          label: _isCollected
              ? (_isEn ? 'Collected — Tap to Undo' : 'Recogido — Toca para desmarcar')
              : (_isEn ? 'Mark as Collected' : 'Marcar como Recogido'),
          onPressed: _toggleCollected,
          backgroundColor: _isCollected ? const Color(0xFF16A34A) : null,
          leadingIcon: _isCollected ? Icons.check_circle_rounded : Icons.task_alt_rounded,
          height: 52,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEn ? 'Reminder added to calendar.' : 'Recordatorio añadido al calendario.'),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: Text(_isEn ? 'Add to Device Calendar' : 'Añadir al Calendario'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5B14B8),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDosageSection() {
    final instructions = [
      {'label': _isEn ? 'Frequency' : 'Frecuencia', 'val': _isEn ? 'Once Daily' : 'Una vez al día', 'icon': Icons.repeat_rounded},
      {'label': _isEn ? 'Administration' : 'Administración', 'val': _isEn ? 'Take with food/meal' : 'Tomar con alimentos', 'icon': Icons.restaurant_rounded},
      {'label': _isEn ? 'Refills Left' : 'Recargas', 'val': '2 refills (Rx #99104)', 'icon': Icons.sync_rounded},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEn ? 'Dosage & Instructions' : 'Dosis e Instrucciones',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          ...instructions.map((inst) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(inst['icon'] as IconData, size: 18, color: const Color(0xFF5B14B8)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inst['label'] as String,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        inst['val'] as String,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPharmacyInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_pharmacy_rounded, size: 18, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 10),
              Text(
                _isEn ? 'Fulfilling Pharmacy' : 'Farmacia Asignada',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.pharmacyName,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.pharmacyAddress,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.pharmacyPhone,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFF5B14B8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: _isEn ? 'Directions' : 'Ruta',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isEn ? 'Opening pharmacy in maps...' : 'Abriendo farmacia en mapas...'),
                      ),
                    );
                  },
                  leadingIcon: Icons.directions_rounded,
                  backgroundColor: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isEn ? 'Calling pharmacy...' : 'Llamando a la farmacia...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: Text(_isEn ? 'Call' : 'Llamar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
