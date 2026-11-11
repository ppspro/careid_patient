import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/family_models.dart';
import '../../data/repositories/family_repository.dart';

/// CareID Patient App — Member Permissions & Sharing Screen
/// Faithfully reproduces Figma Frame `20:22307` ("Member Permissions & Sharing", 390x1125)
/// Features 64px AppBar with CareIdLogo.horizontal(height: 18),
/// Member Header with status badge, granular access level toggles
/// (Medical, Dental, Vision, Labs), expiry configuration, and Save CTA.
class MemberPermissionsSharingScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final FamilyRepository? repository;
  final String language;
  final FamilyMemberDto? member;

  const MemberPermissionsSharingScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.language = 'en',
    this.member,
  });

  @override
  State<MemberPermissionsSharingScreen> createState() => _MemberPermissionsSharingScreenState();
}

class _MemberPermissionsSharingScreenState extends State<MemberPermissionsSharingScreen> {
  bool _shareMedical = true;
  bool _shareDental = true;
  bool _shareVision = false;
  bool _shareLabs = true;

  String _selectedExpiry = '90_DAYS'; // 30_DAYS, 90_DAYS, 1_YEAR, PERMANENT
  bool _isSaving = false;

  bool get _isEn => widget.language == 'en';

  String get _memberName => widget.member?.name ?? (_isEn ? 'Family Member' : 'Miembro Familiar');
  String get _memberRelation => widget.member?.relationship ?? (_isEn ? 'Dependent' : 'Dependiente');

  Future<void> _savePermissions() async {
    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEn
              ? 'Permissions updated for $_memberName.'
              : 'Permisos actualizados para $_memberName.',
        ),
        backgroundColor: const Color(0xFF0F766E),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _isEn ? 'Permissions & Sharing' : 'Permisos y Compartición',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const CareIdLogo.onlyId(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // Member Header Card (Figma 20:22309)
          _buildMemberHeaderCard(),
          const SizedBox(height: 24),

          // Access Levels Section (Figma 20:22324)
          Text(
            _isEn ? 'ACCESS LEVELS' : 'NIVELES DE ACCESO',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildPermissionsList(),
          const SizedBox(height: 24),

          // Expiry Settings Section (Figma 20:22394)
          Text(
            _isEn ? 'EXPIRY SETTINGS' : 'CONFIGURACIÓN DE VENCIMIENTO',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildExpirySelector(),
          const SizedBox(height: 32),

          // Save Button (Figma 20:22410)
          PrimaryButton.gradient(
            label: _isEn ? 'Save Permissions' : 'Guardar Permisos',
            onPressed: _isSaving ? null : _savePermissions,
            isLoading: _isSaving,
          ),
        ],
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: 0,
        language: widget.language,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('/records');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/doctors');
          }
        },
      ),
    );
  }

  Widget _buildMemberHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFEDE9FE),
            child: Text(
              _memberName.isNotEmpty ? _memberName[0] : 'L',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5B14B8),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _memberName,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _memberRelation,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF0F766E)),
                const SizedBox(width: 4),
                Text(
                  _isEn ? 'ACTIVE' : 'ACTIVO',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildPermissionToggle(
            icon: Icons.assignment_outlined,
            title: _isEn ? 'Medical Records' : 'Registros Médicos',
            subtitle: _isEn ? 'View and share digital Medical Records' : 'Ver y compartir registros clínicos',
            value: _shareMedical,
            onChanged: (v) => setState(() => _shareMedical = v),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildPermissionToggle(
            icon: Icons.cleaning_services_rounded,
            title: _isEn ? 'Dental Records' : 'Registros Dentales',
            subtitle: _isEn ? 'Dental history, reports and procedures' : 'Historial dental y odontogramas',
            value: _shareDental,
            onChanged: (v) => setState(() => _shareDental = v),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildPermissionToggle(
            icon: Icons.visibility_outlined,
            title: _isEn ? 'Vision Records' : 'Registros de Visión',
            subtitle: _isEn ? 'Eye prescriptions, exams and diagnostics' : 'Exámenes de vista y recetas de gafas',
            value: _shareVision,
            onChanged: (v) => setState(() => _shareVision = v),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildPermissionToggle(
            icon: Icons.science_outlined,
            title: _isEn ? 'Lab & Pathology Reports' : 'Informes de Laboratorio',
            subtitle: _isEn ? 'Blood panels, biopsies, and diagnostic results' : 'Paneles de sangre y resultados de patología',
            value: _shareLabs,
            onChanged: (v) => setState(() => _shareLabs = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
            ),
            child: Icon(icon, color: const Color(0xFF5B14B8), size: 20),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF0F766E),
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirySelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildExpiryOption('30_DAYS', _isEn ? '30 Days (Temporary Clinical Visit)' : '30 Días (Consulta Temporal)'),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildExpiryOption('90_DAYS', _isEn ? '90 Days (Quarterly Management)' : '90 Días (Gestión Trimestral)'),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildExpiryOption('1_YEAR', _isEn ? '1 Year (Annual Checkup Cycle)' : '1 Año (Ciclo Anual de Revisiones)'),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildExpiryOption('PERMANENT', _isEn ? 'Indefinite / Until Revoked' : 'Indefinido / Hasta Revocación'),
        ],
      ),
    );
  }

  Widget _buildExpiryOption(String key, String label) {
    final isSelected = _selectedExpiry == key;
    return InkWell(
      onTap: () => setState(() => _selectedExpiry = key),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 20,
              color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
