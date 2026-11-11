import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../shared/widgets/careid_logo.dart';
import 'document_viewer_screen.dart';

/// CareID Patient App — Pet Record Detail Screen
/// Faithfully reproduces Figma Frame `20:26229` ("Care ID - Pet Record Detail", 390x1776)
class PetRecordDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? recordData;
  final String? patientInitials;
  final String language;

  const PetRecordDetailScreen({
    super.key,
    this.recordData,
    this.patientInitials,
    this.language = 'en',
  });

  bool get _isEn => language == 'en';

  @override
  Widget build(BuildContext context) {
    final title = recordData?['title']?.toString() ?? 'Rabies Core Annual Booster';
    final vetName = recordData?['vetName']?.toString() ?? 'Dr. Amanda Bell, DVM';
    final clinic = recordData?['clinic']?.toString() ?? 'Metropolitan Veterinary Hospital';
    final date = recordData?['date']?.toString() ?? 'Sep 14, 2023';
    final nextDue = recordData?['nextDue']?.toString() ?? 'Sep 14, 2024';
    final batch = recordData?['batch']?.toString() ?? 'DEF-2023-RAB-9912';

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
                    _buildHeroCertificateCard(context, title, batch, nextDue),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: 16),
                    _buildAttendingVetCard(vetName, clinic),
                    const SizedBox(height: 16),
                    _buildClinicalDetailsSection(date, nextDue, batch),
                    const SizedBox(height: 16),
                    _buildPhysicalVitalsMatrix(),
                    const SizedBox(height: 16),
                    _buildAttachmentsSection(context),
                    const SizedBox(height: 16),
                    _buildVetNotesCard(),
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

  // 1. Top App Bar
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
                _isEn ? 'Pet Record Detail' : 'Detalle de Registro',
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

  // 2. Security & Animal Health Strip
  Widget _buildSecurityStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_rounded, size: 18, color: Color(0xFF15803D)),
              SizedBox(width: 8),
              Text(
                'Microchip #985141002345678',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: const Text(
              'PET-9942',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                color: Color(0xFF15803D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Hero Immunization Certificate Card
  Widget _buildHeroCertificateCard(BuildContext context, String title, String batch, String nextDue) {
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
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4C1D95)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PetShieldPainter(),
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
                          Icon(Icons.pets_rounded, size: 14, color: Color(0xFF56F5F8)),
                          SizedBox(width: 6),
                          Text(
                            'Official Immunization Certificate',
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
                              title: 'Rabies Vaccination Certificate',
                              fileName: 'Rabies_Certificate.pdf',
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
                              Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'USDA Approved Batch',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Batch: $batch',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFE2E8F0)),
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
                            Icon(Icons.pets_rounded, size: 12, color: Color(0xFF5B14B8)),
                            SizedBox(width: 4),
                            Text(
                              'Pet Passport',
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
                  Text(
                    'Expires: $nextDue • Care ID Animal Health Registry',
                    style: const TextStyle(
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

  // 4. Quick Actions Grid
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
                      content: Text('${act['label']} initiated for Pet Immunization Certificate'),
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
                      Icon(act['icon'] as IconData, size: 22, color: const Color(0xFF7C3AED)),
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

  // 5. Attending Veterinarian Section
  Widget _buildAttendingVetCard(String vetName, String clinic) {
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
              Icon(Icons.person_pin_rounded, size: 18, color: Color(0xFF7C3AED)),
              SizedBox(width: 8),
              Text(
                'Attending Veterinarian',
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
                  color: const Color(0xFFF5F3FF),
                  border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'AB',
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
                          vetName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      clinic,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Small Animal Medicine & Surgery',
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
                Text('State Veterinary Medical Board', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text('Lic. #DVM- 8914', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Clinical Details Section
  Widget _buildClinicalDetailsSection(String date, String nextDue, String batch) {
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
              Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF7C3AED)),
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
          _buildDetailRow('Record Type', 'Core Immunization & Wellness'),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Administered Date', date),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Next Booster Due', nextDue),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Vaccine Manufacturer', 'Zoetis Defensor 3'),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Dosage & Route', '1.0 mL Subcutaneous (Right Hind)'),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Rabies Tag Serial', 'TX-2023-9941'),
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

  // 7. Physical Vitals Matrix
  Widget _buildPhysicalVitalsMatrix() {
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
              Icon(Icons.monitor_heart_rounded, size: 18, color: Color(0xFF7C3AED)),
              SizedBox(width: 8),
              Text(
                'Wellness Vitals on Exam Date',
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
                child: _buildVitalTile('Weight', '68.4 lbs', 'Healthy Body Condition', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVitalTile('Temperature', '101.4 °F', 'Normal Range', const Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVitalTile('Heart Rate', '90 bpm', 'Steady & Clear', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVitalTile('Respiratory', '22 bpm', 'Eupneic Respiration', const Color(0xFF10B981)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalTile(String title, String value, String subtitle, Color color) {
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
            style: TextStyle(fontSize: 15, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
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
                  Icon(Icons.attach_file_rounded, size: 18, color: Color(0xFF7C3AED)),
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
            title: 'Rabies_Vaccination_Certificate.pdf',
            size: '1.2 MB • Sep 14, 2023',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DocumentViewerScreen(
                    title: 'Rabies_Vaccination_Certificate.pdf',
                    fileName: 'Rabies_Vaccination_Certificate.pdf',
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
            bgColor: const Color(0xFFF5F3FF),
            title: 'Annual_Wellness_Exam_Report.pdf',
            size: '1.6 MB • Sep 14, 2023',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DocumentViewerScreen(
                    title: 'Annual_Wellness_Exam_Report.pdf',
                    fileName: 'Annual_Wellness_Exam_Report.pdf',
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
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF7C3AED)),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  // 9. Vet Notes Card
  Widget _buildVetNotesCard() {
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
              Icon(Icons.notes_rounded, size: 18, color: Color(0xFF7C3AED)),
              SizedBox(width: 8),
              Text(
                'Veterinary Clinical Observations',
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
            child: const Text(
              '"Physical examination unremarkable. Temperature 101.4°F, heart rate 90 bpm, respiratory rate 22 bpm. Mucous membranes pink and moist. Eyes, ears, and teeth in excellent condition. 3-year Rabies vaccine administered with zero adverse reaction. Patient is healthy and approved for normal activity."',
              style: TextStyle(
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
                'Last updated: Sep 14, 2023 • Dr. Amanda Bell, DVM',
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
                  const SnackBar(content: Text('Downloading Pet Vaccination Certificate PDF...')),
                );
              },
              icon: const Icon(Icons.download_rounded, color: Color(0xFF7C3AED), size: 18),
              label: const Text(
                'Export Certificate',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C3AED),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF7C3AED)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: 'Share Passport',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Care ID Pet Passport Share Link generated.')),
                );
              },
              leadingIcon: Icons.share_rounded,
              height: 48,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for Pet Shield Badge
class _PetShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final shieldPaint = Paint()
      ..color = const Color(0xFF56F5F8).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(center.dx, center.dy - 50)
      ..lineTo(center.dx + 45, center.dy - 30)
      ..lineTo(center.dx + 45, center.dy + 15)
      ..quadraticBezierTo(center.dx, center.dy + 60, center.dx, center.dy + 60)
      ..quadraticBezierTo(center.dx, center.dy + 60, center.dx - 45, center.dy + 15)
      ..lineTo(center.dx - 45, center.dy - 30)
      ..close();

    canvas.drawPath(path, shieldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
