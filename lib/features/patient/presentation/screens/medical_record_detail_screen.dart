import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/medical_record_models.dart';
import 'document_viewer_screen.dart';

/// CareID Patient App — Medical Record Detail Screen
/// Faithfully reproduces Figma Frame `20:25209` & `20:24484` ("Medical Record Detail", 390x1776)
class MedicalRecordDetailScreen extends StatelessWidget {
  final MedicalRecordDto? record;
  final String? patientInitials;
  final String language;

  const MedicalRecordDetailScreen({
    super.key,
    this.record,
    this.patientInitials,
    this.language = 'en',
  });

  bool get _isEn => language == 'en';

  @override
  Widget build(BuildContext context) {
    final title = record?.title.isNotEmpty == true ? record!.title : (_isEn ? 'Metabolic & Clinical Consultation' : 'Consulta Metabólica y Clínica');
    final doctor = record?.doctorName?.isNotEmpty == true
        ? record!.doctorName!
        : (_isEn ? 'Attending Physician not specified' : 'Médico tratante no especificado');
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
                    _buildHeroMedicalCard(context, title),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: 16),
                    _buildAttendingProviderCard(doctor, facility),
                    const SizedBox(height: 16),
                    _buildClinicalDetailsSection(date),
                    const SizedBox(height: 16),
                    _buildBiomarkerPanels(),
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

  // 1. Top App Bar (Figma 20:25368)
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

  // 2. Security & Verified Strip
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
              'CR-5582-M',
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

  // 3. Hero Diagnostic & Consultation Document Card
  Widget _buildHeroMedicalCard(BuildContext context, String title) {
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
            // Graphic Canvas
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E1065), Color(0xFF4C1D95), Color(0xFF5B14B8)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MedicalEcgPainter(),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.biotech_rounded, size: 14, color: Color(0xFF56F5F8)),
                          SizedBox(width: 6),
                          Text(
                            'Metabolic & Lab Biomarkers',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const DocumentViewerScreen(
                              title: 'Comprehensive Metabolic Panel',
                              fileName: 'Metabolic_Panel.pdf',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.fullscreen_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
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
                                'CLIA Certified Lab',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Lab ID: CMP-892-TX',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFE2E8F0)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Metadata Header
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
                    'Last accessed: Oct 12, 2023 • 09:30 AM',
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

  // 4. Quick Actions Grid of 4 Buttons
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
                      content: Text('${act['label']} initiated for Medical Record'),
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

  // 5. Attending Provider Section
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
                  color: const Color(0xFFF3E8FF),
                  border: Border.all(color: const Color(0xFFD8B4FE), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'RC',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7C3AED),
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
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF7C3AED)),
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
                      'Internal Medicine & Diagnostics',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7C3AED),
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
                Text('State Board Certification', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text('Lic. #MD- 4421', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Clinical Details Section
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
          _buildDetailRow('Record Type', 'Medical Consultation & Labs'),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Examination Date', date),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Next Follow-up', 'Jan 12, 2024'),
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

  // 7. Biomarker Panels (Figma Bento Grid 20:24494)
  Widget _buildBiomarkerPanels() {
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
              Icon(Icons.insights_rounded, size: 18, color: Color(0xFF7C3AED)),
              SizedBox(width: 8),
              Text(
                'Key Clinical Biomarkers',
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
                child: _buildBiomarkerTile('Total Cholesterol', '185 mg/dL', 'Normal (< 200)', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBiomarkerTile('HDL Cholesterol', '54 mg/dL', 'Optimal (> 50)', const Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBiomarkerTile('LDL Cholesterol', '108 mg/dL', 'Desirable (< 129)', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBiomarkerTile('Fasting Glucose', '92 mg/dL', 'Normal (70-99)', const Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBiomarkerTile('Blood Pressure', '118/76 mmHg', 'Optimal BP', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBiomarkerTile('HbA1c', '5.4%', 'Non-diabetic (< 5.7%)', const Color(0xFF10B981)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiomarkerTile(String title, String value, String refRange, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(refRange, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  // 8. Attachments Section
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
            title: 'Comprehensive_Metabolic_Panel.pdf',
            size: '2.1 MB • Oct 12, 2023',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DocumentViewerScreen(
                    title: 'Comprehensive_Metabolic_Panel.pdf',
                    fileName: 'Comprehensive_Metabolic_Panel.pdf',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildAttachmentTile(
            context,
            icon: Icons.picture_as_pdf_rounded,
            iconColor: const Color(0xFF7C3AED),
            bgColor: const Color(0xFFF3E8FF),
            title: 'Physician_Clinical_Summary.pdf',
            size: '1.4 MB • Oct 12, 2023',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DocumentViewerScreen(
                    title: 'Physician_Clinical_Summary.pdf',
                    fileName: 'Physician_Clinical_Summary.pdf',
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

  // 9. Patient Notes Card
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
                'Last updated: Oct 12, 2023 • Dr. Robert Chen',
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

/// Custom painter for ECG / Pulse wave line
class _MedicalEcgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF56F5F8).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    final y = size.height * 0.55;
    path.moveTo(0, y);
    path.lineTo(size.width * 0.25, y);
    path.lineTo(size.width * 0.30, y - 10);
    path.lineTo(size.width * 0.35, y + 15);
    path.lineTo(size.width * 0.40, y - 45);
    path.lineTo(size.width * 0.45, y + 30);
    path.lineTo(size.width * 0.50, y - 8);
    path.lineTo(size.width * 0.55, y);
    path.lineTo(size.width * 0.70, y);
    path.lineTo(size.width * 0.75, y - 25);
    path.lineTo(size.width * 0.80, y + 20);
    path.lineTo(size.width * 0.85, y);
    path.lineTo(size.width, y);

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
