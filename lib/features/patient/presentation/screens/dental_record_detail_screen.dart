import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../shared/widgets/careid_dental_logo.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/medical_record_models.dart';
import 'document_viewer_screen.dart';

/// CareID Patient App — Dental Record Detail Screen
/// Faithfully reproduces Figma Frame `20:25653` ("Care ID - Dental Record Detail", 390x1854)
class DentalRecordDetailScreen extends StatelessWidget {
  final MedicalRecordDto? record;
  final String? patientInitials;
  final String language;

  const DentalRecordDetailScreen({
    super.key,
    this.record,
    this.patientInitials,
    this.language = 'en',
  });

  bool get _isEn => language == 'en';

  @override
  Widget build(BuildContext context) {
    final title = record?.title.isNotEmpty == true ? record!.title : (_isEn ? 'Dental X-Ray & Routine Exam' : 'Radiografía Dental y Examen');
    final doctor = record?.doctorName?.isNotEmpty == true
        ? record!.doctorName!
        : (_isEn ? 'Attending Dentist not specified' : 'Dentista no especificado');
    final facility = record?.facilityName?.isNotEmpty == true
        ? record!.facilityName!
        : (_isEn ? 'Facility not recorded' : 'Instalación no registrada');
    final date = record?.recordDate?.isNotEmpty == true
        ? record!.recordDate!
        : (_isEn ? 'Date not recorded' : 'Fecha no registrada');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSecurityStrip(),
                    const SizedBox(height: 14),
                    _buildHeroXrayCard(context, title),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: 16),
                    _buildAttendingProviderCard(doctor, facility),
                    const SizedBox(height: 16),
                    _buildClinicalDetailsSection(date),
                    const SizedBox(height: 16),
                    _buildToothArchStatus(),
                    const SizedBox(height: 16),
                    _buildAttachmentsSection(context),
                    const SizedBox(height: 16),
                    _buildPatientNotesCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  // 1. Top App Bar (Figma 20:25883 / 20:25884)
  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7ECF6), width: 1)),
        boxShadow: [
          BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF28006D)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 4),
              Text(
                _isEn ? 'Record Details' : 'Detalles del Registro',
                style: const TextStyle(
                  fontSize: 19,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF28006D),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CareIdLogo(width: 26, showWordmark: false),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF3F1D8B), width: 2),
                  color: const Color(0xFFE8DDFF),
                ),
                child: Center(
                  child: Text(
                    patientInitials ?? 'JD',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3F1D8B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Security & Verified Strip (Figma 20:25658)
  Widget _buildSecurityStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBFDFB),
        border: Border.all(color: const Color(0xFF5EEAD4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_rounded, size: 18, color: Color(0xFF0F766E)),
              const SizedBox(width: 8),
              Text(
                _isEn ? 'Verified & End-to-End Encrypted' : 'Verificado y Cifrado de Extremo a Extremo',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF5EEAD4).withValues(alpha: 0.6)),
            ),
            child: const Text(
              'CR-7721-D',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Hero Panoramic X-Ray Document Card (Figma 20:25667)
  Widget _buildHeroXrayCard(BuildContext context, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECF6)),
        boxShadow: const [
          BoxShadow(color: Color(0x0C28006D), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual Graphic / Dental Panoramic X-Ray Canvas
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0B192C), Color(0xFF1E3E62), Color(0xFF000000)],
                ),
              ),
              child: Stack(
                children: [
                  // Stylized Dental Arch Archway Painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DentalArchPainter(),
                    ),
                  ),
                  // Overlay Badge: Scan Type
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CareIdDentalLogo(size: 14, color: Color(0xFF38BDF8)),
                          SizedBox(width: 6),
                          Text(
                            'Panoramic Arch OPG',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Fullscreen Expand Button
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const DocumentViewerScreen(
                              title: 'Panoramic Dental Arch X-Ray',
                              fileName: 'Dental_XRay.jpg',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.fullscreen_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  // Bottom Scrim Overlay
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.9),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Complete Dentition',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'OPG-2023-D11',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFE2E8F0)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Card Metadata Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, size: 12, color: Color(0xFF0284C7)),
                            SizedBox(width: 4),
                            Text(
                              'Care ID Vault',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Last accessed: Oct 18, 2023 • 11:20 AM',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Quick Actions Grid of 4 Buttons (Figma 20:25697)
  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'icon': Icons.download_rounded, 'label': _isEn ? 'Download' : 'Descargar'},
      {'icon': Icons.share_rounded, 'label': _isEn ? 'Share' : 'Compartir'},
      {'icon': Icons.print_rounded, 'label': _isEn ? 'Print' : 'Imprimir'},
      {'icon': Icons.upload_file_rounded, 'label': _isEn ? 'Export' : 'Exportar'},
    ];

    return Row(
      children: actions.map((act) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${act['label']} initiated for Dental Record'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE7ECF6)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(act['icon'] as IconData, size: 22, color: const Color(0xFF0284C7)),
                      const SizedBox(height: 6),
                      Text(
                        act['label'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF28006D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 5. Attending Provider Section (Figma 20:25723)
  Widget _buildAttendingProviderCard(String doctor, String facility) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_pin_rounded, size: 18, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Text(
                'Attending Provider',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF28006D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE0F2FE),
                  border: Border.all(color: const Color(0xFF7DD3FC), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'MV',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          doctor,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF0284C7)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      facility,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Dentist & Orthodontist',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('State Board Certification', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text('Lic. #OD- 7721', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Clinical Details Section (Figma 20:25755)
  Widget _buildClinicalDetailsSection(String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Text(
                'Clinical Details',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF28006D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDetailRow('Record Type', 'Dental Record'),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Examination Date', date),
          if (_extractNoteField('Tooth/Quadrant').isNotEmpty) ...[
            const Divider(height: 18, color: Color(0xFFF1F5F9)),
            _buildDetailRow('Tooth / Quadrant', _extractNoteField('Tooth/Quadrant')),
          ],
          if (_extractNoteField('Materials Used').isNotEmpty) ...[
            const Divider(height: 18, color: Color(0xFFF1F5F9)),
            _buildDetailRow('Materials', _extractNoteField('Materials Used')),
          ],
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Next Cleaning Due', 'Apr 05, 2024'),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          const Text(
            'Primary Diagnosis / Reason',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              record?.diagnosis?.isNotEmpty == true
                  ? record!.diagnosis!
                  : (_isEn ? 'No primary diagnosis recorded' : 'Sin diagnóstico registrado'),
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _extractNoteField(String key) {
    final notes = record?.clinicalNotes ?? '';
    final prefix = key + ':';
    final nl = String.fromCharCode(10);
    for (final line in notes.split(nl)) {
      if (line.startsWith(prefix)) {
        return line.substring(prefix.length).trim();
      }
    }
    return '';
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // 7. Tooth Arch Status Assessment
  Widget _buildToothArchStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 18, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Text(
                'Dental Arch & Periodontal Status',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF28006D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile('Periodontal Depth', '1 - 3 mm', 'Normal Depth', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile('Caries Risk', 'Low', 'No Cavities', const Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile('Gingival Index', 'Grade 0', 'Healthy Tissue', const Color(0xFF0284C7)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile('Wisdom Teeth', 'Erupted', 'Proper Alignment', const Color(0xFF0284C7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  // 8. Attachments Section (Figma 20:25796)
  Widget _buildAttachmentsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_file_rounded, size: 18, color: Color(0xFF0284C7)),
                  SizedBox(width: 8),
                  Text(
                    'Attachments (2 Files)',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF28006D),
                    ),
                  ),
                ],
              ),
              Text('2 Verified Items', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 12),
          _buildAttachmentTile(
            context,
            icon: Icons.picture_as_pdf_rounded,
            iconColor: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEE2E2),
            title: 'Dental X-Ray Observations.pdf',
            size: '1.8 MB • Oct 05, 2023',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DocumentViewerScreen(
                    title: 'Dental X-Ray Observations.pdf',
                    fileName: 'Dental_XRay_Observations.pdf',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildAttachmentTile(
            context,
            icon: Icons.image_rounded,
            iconColor: const Color(0xFF0284C7),
            bgColor: const Color(0xFFE0F2FE),
            title: 'Dental X-Ray.jpg',
            size: '3.6 MB • Oct 05, 2023',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DocumentViewerScreen(
                    title: 'Dental X-Ray.jpg',
                    fileName: 'Dental_XRay.jpg',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String size,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(size, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF0284C7)),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  // 9. Patient Notes Card (Figma 20:25833 & 20:25844)
  Widget _buildPatientNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, size: 18, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Text(
                'Clinical Observations & Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF28006D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              record?.clinicalNotes?.isNotEmpty == true
                  ? '"${record!.clinicalNotes!}"'
                  : (_isEn
                      ? '"No clinical observations or notes recorded for this entry."'
                      : '"No hay observaciones clínicas registradas para esta entrada."'),
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Plus Jakarta Sans',
                fontStyle: FontStyle.italic,
                height: 1.45,
                color: Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
              SizedBox(width: 4),
              Text(
                'Last updated: Oct 05, 2023 • Dr. Michael Vance',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 10. Bottom Action Bar
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7ECF6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading Care ID cryptographic PDF...')),
                );
              },
              icon: const Icon(Icons.download_rounded, color: Color(0xFF0284C7), size: 18),
              label: const Text(
                'Export PDF',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0284C7)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: 'Share Link',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Care ID Encrypted Share Link generated.')),
                );
              },
              backgroundColor: const Color(0xFF0284C7),
              leadingIcon: Icons.lock_outline_rounded,
                            padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for Dental Panoramic Arch graphic
class _DentalArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.7);
    final archPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw panoramic dental curve
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.8)
      ..quadraticBezierTo(center.dx, size.height * 0.15, size.width * 0.85, size.height * 0.8);
    canvas.drawPath(path, archPaint);

    // Draw stylized tooth markers along the curve
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    for (double t = 0.05; t <= 0.95; t += 0.065) {
      final x = (1 - t) * (1 - t) * (size.width * 0.15) + 2 * (1 - t) * t * center.dx + t * t * (size.width * 0.85);
      final y = (1 - t) * (1 - t) * (size.height * 0.8) + 2 * (1 - t) * t * (size.height * 0.15) + t * t * (size.height * 0.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 8, height: 12), const Radius.circular(3)),
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
