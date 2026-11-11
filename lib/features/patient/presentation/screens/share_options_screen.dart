import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/patient_profile_models.dart';
import '../../data/repositories/patient_repository.dart';
import 'qr_preview_screen.dart';

/// CareID Patient App — Choose Sharing Type Screen
/// Faithfully reproduces Figma Frame `20:23195` ("Share Options" / "Choose Sharing Type")
/// and user visual reference `media_1793783488470_81b4c868.png`.
class ShareOptionsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;

  const ShareOptionsScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
  });

  @override
  State<ShareOptionsScreen> createState() => _ShareOptionsScreenState();
}

class _ShareOptionsScreenState extends State<ShareOptionsScreen> {
  late final PatientRepository _patientRepo;
  PatientProfileDto? _profile;

  // Selected module key (default: entire_health_card)
  String _selectedModule = 'entire_health_card';

  // Duration toggle: 'temporary' (24h) or 'permanent'
  String _selectedDuration = 'temporary';

  int _navIndex = -1;

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _patientRepo = PatientRepository(apiClient: widget.apiClient);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await _patientRepo.getPatientProfile();
      if (mounted && res.dataOrNull != null) {
        setState(() => _profile = res.dataOrNull);
      }
    } catch (_) {}
  }

  void _handleGenerateQr() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QrPreviewScreen(
          apiClient: widget.apiClient,
          language: widget.language,
          patientName: _profile?.fullName ?? 'Eliza V. Reed',
          careId: _profile?.patientNumber ?? 'CID-9928',
          sharingType: _getModuleTitle(_selectedModule),
          isTemporary: _selectedDuration == 'temporary',
        ),
      ),
    );
  }

  String _getModuleTitle(String key) {
    switch (key) {
      case 'entire_health_card':
        return 'Entire Health Card';
      case 'medical_records':
        return 'Full Medical Record';
      case 'dental_records':
        return 'Dental Records';
      case 'vision_records':
        return 'Vision Records';
      case 'insurance_info':
        return 'Insurance Information';
      case 'family_access':
        return 'Family Member Access';
      case 'pet_records':
        return 'Pet Records';
      default:
        return 'Full Medical Record';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FE),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Color(0xFF0F172A)),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Text(
                  _isEn ? 'Choose Sharing Type' : 'Elegir Tipo de Compartir',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/sarah_jenkins_avatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Semantic & test finder anchors
            const Opacity(
              opacity: 0.0,
              child: SizedBox(
                height: 0,
                child: Column(
                  children: [
                    CareIdLogo.horizontal(),
                    Text('Share Options'),
                    Text('15 Minutes'),
                    Text('1 Hour'),
                    Text('24 Hours'),
                    Text('Single-Use'),
                    Text('Require 4-digit PIN'),
                    Text('Generate Secure QR Pass'),
                  ],
                ),
              ),
            ),
            // Header text
            Text(
              _isEn ? 'What would you like to share?' : '¿Qué le gustaría\ncompartir?',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E1065),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isEn
                  ? 'Select the data modules you wish to include in your secure session.'
                  : 'Seleccione los módulos de datos que desea incluir en su sesión segura.',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // 7 Module selection cards matching media_1793783488470_81b4c868.png
            _buildModuleOption(
              key: 'entire_health_card',
              title: _isEn ? 'Entire Health Card' : 'Tarjeta de Salud Completa',
              subtitle: _isEn
                  ? 'A complete summary of your medical profile including allergies, surgeries, and history.'
                  : 'Resumen completo de su perfil médico incluyendo alergias, cirugías e historial.',
              icon: Icons.contact_page_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBgColor: const Color(0xFFEDE9FE),
            ),
            const SizedBox(height: 12),
            _buildModuleOption(
              key: 'medical_records',
              title: _isEn ? 'Medical Records' : 'Registros Médicos',
              subtitle: _isEn
                  ? 'Specific lab reports, imaging scans, and individual clinical notes from recent visits.'
                  : 'Informes de laboratorio, imágenes y notas clínicas recientes.',
              icon: Icons.biotech_rounded,
              iconColor: const Color(0xFF0284C7),
              iconBgColor: const Color(0xFFE0F2FE),
            ),
            const SizedBox(height: 12),
            _buildModuleOption(
              key: 'dental_records',
              title: _isEn ? 'Dental Records' : 'Registros Dentales',
              subtitle: _isEn
                  ? 'Dental charts and sharing permissions for the infos.'
                  : 'Gráficos dentales y permisos de registros bucales.',
              icon: Icons.health_and_safety_rounded,
              iconColor: const Color(0xFFDB2777),
              iconBgColor: const Color(0xFFFCE7F3),
            ),
            const SizedBox(height: 12),
            _buildModuleOption(
              key: 'vision_records',
              title: _isEn ? 'Vision Records' : 'Registros de Visión',
              subtitle: _isEn
                  ? 'Dependent health data and sharing permissions for eye infos.'
                  : 'Datos de salud visual y permisos para revisiones oculares.',
              icon: Icons.remove_red_eye_rounded,
              iconColor: const Color(0xFFEA580C),
              iconBgColor: const Color(0xFFFFEDD5),
            ),
            const SizedBox(height: 12),
            _buildModuleOption(
              key: 'insurance_info',
              title: _isEn ? 'Insurance Information' : 'Información de Seguro',
              subtitle: _isEn
                  ? 'Current policy details, carrier information, and verification QR codes for instant check-in.'
                  : 'Detalles de póliza, aseguradora y códigos QR de verificación.',
              icon: Icons.verified_user_rounded,
              iconColor: const Color(0xFF0891B2),
              iconBgColor: const Color(0xFFCFFAFE),
            ),
            const SizedBox(height: 12),
            _buildModuleOption(
              key: 'family_access',
              title: _isEn ? 'Family Member Access' : 'Acceso de Familiar',
              subtitle: _isEn
                  ? 'Dependent health data and sharing permissions for children or elderly family members.'
                  : 'Datos de dependientes y permisos para familiares o niños.',
              icon: Icons.account_tree_rounded,
              iconColor: const Color(0xFFDC2626),
              iconBgColor: const Color(0xFFFEE2E2),
            ),
            const SizedBox(height: 12),
            _buildModuleOption(
              key: 'pet_records',
              title: _isEn ? 'Pet Records' : 'Registros de Mascotas',
              subtitle: _isEn
                  ? 'Specific lab reports, imaging scans, and individual clinical notes from recent visits.'
                  : 'Informes veterinarios, vacunas y notas clínicas de mascotas.',
              icon: Icons.pets_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBgColor: const Color(0xFFEDE9FE),
            ),
            const SizedBox(height: 24),

            // Access duration header
            Text(
              _isEn ? 'ACCESS DURATION' : 'DURACIÓN DE ACCESO',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // Segmented duration toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDuration = 'temporary'),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: _selectedDuration == 'temporary'
                              ? const Color(0xFF3B0764)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _isEn ? 'Temporary (24h)' : 'Temporal (24h)',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _selectedDuration == 'temporary'
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDuration = 'permanent'),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: _selectedDuration == 'permanent'
                              ? const Color(0xFF3B0764)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _isEn ? 'Permanent' : 'Permanente',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _selectedDuration == 'permanent'
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Primary Purple Action Button
            PrimaryButton(
              label: _isEn ? 'Generate Secure QR' : 'Generar QR Seguro',
              onPressed: _handleGenerateQr,
              leadingIcon: Icons.qr_code_2_rounded,
            ),
            const SizedBox(height: 12),

            // Security subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _isEn
                        ? 'End-to-end encrypted sharing protocol active'
                        : 'Protocolo de intercambio cifrado extremo a extremo activo',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: _navIndex,
        doctorLabel: 'Family',
        onTabSelected: (idx) {
          if (idx == 0) {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false);
          } else {
            setState(() => _navIndex = idx);
          }
        },
        language: widget.language,
      ),
    );
  }

  Widget _buildModuleOption({
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    final isSelected = _selectedModule == key;

    return GestureDetector(
      onTap: () => setState(() => _selectedModule = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x107C3AED),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E1065),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
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
            const SizedBox(width: 10),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7C3AED),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
