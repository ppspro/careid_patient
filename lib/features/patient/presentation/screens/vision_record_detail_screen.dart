import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/medical_record_models.dart';
import 'document_viewer_screen.dart';

/// CareID Patient App — Vision Record Detail Screen
/// Faithfully reproduces Figma Frame `20:25410` & `20:32573` ("Care ID - Vision Record Detail", 390x2030)
class VisionRecordDetailScreen extends StatelessWidget {
  final MedicalRecordDto? record;
  final String? patientInitials;
  final String language;

  const VisionRecordDetailScreen({
    super.key,
    this.record,
    this.patientInitials,
    this.language = 'en',
  });

  bool get _isEn => language == 'en';

  @override
  Widget build(BuildContext context) {
    final title = record?.title.isNotEmpty == true ? record!.title : (_isEn ? 'Vision Record Detail' : 'Detalle de Registro Visual');
    final doctor = record?.doctorName?.isNotEmpty == true
        ? record!.doctorName!
        : (_isEn ? 'Attending Optometrist not specified' : 'Optometrista no especificado');
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
                    _buildHeroOctCard(context, title),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: 16),
                    _buildAttendingProviderCard(doctor, facility),
                    const SizedBox(height: 16),
                    _buildClinicalDetailsSection(date),
                    const SizedBox(height: 16),
                    _buildRefractionMatrix(),
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

  // 1. Top App Bar (Figma 20:25641 / 20:25368)
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

  // 2. Security & Verified Strip (Figma 20:25414)
  Widget _buildSecurityStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBFDFB),
        borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF5EEAD4).withValues(alpha: 0.6)),
            ),
            child: const Text(
              'CR-8942-V',
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

  // 3. Hero Panoramic / OCT Scan Document Card (Figma 20:25423)
  Widget _buildHeroOctCard(BuildContext context, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECF6)),
        boxShadow: const [
          BoxShadow(color: Color(0x0C28006D), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual Graphic / OCT Scan Canvas
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF312E81)],
                ),
              ),
              child: Stack(
                children: [
                  // Stylized Retinal Grid / Rings
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RetinalOctPainter(),
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
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.remove_red_eye_rounded, size: 14, color: Color(0xFF56F5F8)),
                          SizedBox(width: 6),
                          Text(
                            'Retinal Fundus OCT Scan',
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
                              title: 'Retinal Fundus OCT HighRes Scan',
                              fileName: 'Retinal_Scan_OCT.pdf',
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
                            color: const Color(0xFF10B981).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Diagnostic Grade HD',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Scan ID: OCT-2023-V9',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFE2E8F0),
                          ),
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
                          color: const Color(0xFF5B14B8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, size: 12, color: Color(0xFF5B14B8)),
                            SizedBox(width: 4),
                            Text(
                              'Care ID Vault',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5B14B8),
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

  // 4. Quick Actions Grid of 4 Buttons (Figma 20:25453)
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
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${act['label']} initiated for Vision Record'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE7ECF6)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(act['icon'] as IconData, size: 22, color: const Color(0xFF5B14B8)),
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

  // 5. Attending Provider Section (Figma 20:25479)
  Widget _buildAttendingProviderCard(String doctor, String facility) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_pin_rounded, size: 18, color: Color(0xFF5B14B8)),
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
                  color: const Color(0xFFEEF2FF),
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'SL',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
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
                      'Optometry & Retinal Diagnostics',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4F46E5),
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'State Board Certification',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                Text(
                  'Lic. #OD- 8896',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Clinical Details Section (Figma 20:25511)
  Widget _buildClinicalDetailsSection(String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF5B14B8)),
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
          _buildDetailRow('Record Type', 'Vision Record'),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Examination Date', date),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Next Follow-up', 'Apr 18, 2024'),
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
              borderRadius: BorderRadius.circular(8),
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

  // 7. Refraction Matrix (OD / OS Table)
  Widget _buildRefractionMatrix() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.remove_red_eye_outlined, size: 18, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text(
                'Visual Refraction & Acuity Assessment',
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
          Table(
            border: TableBorder.all(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(8)),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Eye', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Sphere', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Cyl', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Axis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Acuity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
              TableRow(
                children: [
                  const Padding(padding: EdgeInsets.all(8), child: Text('OD (Right)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(_extractOdField('SPH', '-1.75'), style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(_extractOdField('CYL', '-0.50'), style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(_extractOdField('Axis', '090°'), style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(_extractOdField('Acuity', '20/20'), style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                ],
              ),
              TableRow(
                children: [
                  const Padding(padding: EdgeInsets.all(8), child: Text('OS (Left)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(_extractOsField('SPH', '-2.00'), style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(_extractOsField('CYL', '-0.75'), style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(_extractOsField('Axis', '085°'), style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(_extractOsField('Acuity', '20/25'), style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _extractOdField(String key, String fallback) {
    final notes = record?.clinicalNotes ?? '';
    final nl = String.fromCharCode(10);
    for (final line in notes.split(nl)) {
      if (line.startsWith('Refraction OD:')) {
        final parts = line.split('|');
        for (final p in parts) {
          final trimmed = p.trim();
          if (trimmed.startsWith(key)) {
            return trimmed.substring(key.length).trim();
          }
        }
      }
    }
    return fallback;
  }

  String _extractOsField(String key, String fallback) {
    final notes = record?.clinicalNotes ?? '';
    final nl = String.fromCharCode(10);
    for (final line in notes.split(nl)) {
      if (line.startsWith('Refraction OS:')) {
        final parts = line.split('|');
        for (final p in parts) {
          final trimmed = p.trim();
          if (trimmed.startsWith(key)) {
            return trimmed.substring(key.length).trim();
          }
        }
      }
    }
    return fallback;
  }

  // 8. Attachments Section (Figma 20:25552)
  Widget _buildAttachmentsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                  Icon(Icons.attach_file_rounded, size: 18, color: Color(0xFF5B14B8)),
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
            title: 'Retinal_Scan_HighRes_OCT.pdf',
            size: '2.4 MB • Oct 18, 2023',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DocumentViewerScreen(
                    title: 'Retinal_Scan_HighRes_OCT.pdf',
                    fileName: 'Retinal_Scan_HighRes_OCT.pdf',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildAttachmentTile(
            context,
            icon: Icons.image_rounded,
            iconColor: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFDBEAFE),
            title: 'Fundus_Color_Composite.jpg',
            size: '4.8 MB • Oct 18, 2023',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DocumentViewerScreen(
                    title: 'Fundus_Color_Composite.jpg',
                    fileName: 'Fundus_Color_Composite.jpg',
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
        borderRadius: BorderRadius.circular(12),
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
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF5B14B8)),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  // 9. Patient Notes Card (Figma 20:25589)
  Widget _buildPatientNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, size: 18, color: Color(0xFF5B14B8)),
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
              borderRadius: BorderRadius.circular(10),
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
                'Last updated: Oct 18, 2023 • Dr. Sarah Lin',
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
              icon: const Icon(Icons.download_rounded, color: Color(0xFF5B14B8), size: 18),
              label: const Text(
                'Export PDF',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5B14B8),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5B14B8)),
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
              leadingIcon: Icons.lock_outline_rounded,
              height: 48,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for Retinal OCT / Fundus rings
class _RetinalOctPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final paint = Paint()
      ..color = const Color(0xFF56F5F8).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw concentric target rings
    for (double r = 25; r <= 85; r += 20) {
      canvas.drawCircle(center, r, paint);
    }

    // Crosshairs
    final crossPaint = Paint()
      ..color = const Color(0xFF56F5F8).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(Offset(center.dx - 90, center.dy), Offset(center.dx + 90, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 90), Offset(center.dx, center.dy + 90), crossPaint);

    // Glowing Macular Core
    final corePaint = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
