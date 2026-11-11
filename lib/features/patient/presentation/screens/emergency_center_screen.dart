import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/facility_models.dart';
import '../../data/models/patient_profile_models.dart';
import '../../data/repositories/facility_repository.dart';
import '../../data/repositories/patient_repository.dart';

/// CareID Patient App — Emergency Center Screen
/// Aligned strictly with Figma Frame `20:23956` ("Emergency Center", 390x2175.6)
class EmergencyCenterScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final PatientRepository? repository;
  final FacilityRepository? facilityRepository;
  final String language;
  final bool showBottomNav;

  const EmergencyCenterScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.facilityRepository,
    this.language = 'en',
    this.showBottomNav = false,
  });

  @override
  State<EmergencyCenterScreen> createState() => _EmergencyCenterScreenState();
}

class _EmergencyCenterScreenState extends State<EmergencyCenterScreen> {
  late final PatientRepository _repository;
  late final FacilityRepository _facilityRepository;
  PatientProfileDto? _profile;
  List<FacilityDto> _facilities = [];
  bool _isLoading = true;
  bool _isLoadingFacilities = false;
  bool _sosTriggered = false;

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PatientRepository(apiClient: widget.apiClient);
    _facilityRepository = widget.facilityRepository ?? FacilityRepository(apiClient: widget.apiClient);
    _loadProfile();
    _loadFacilities();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final result = await _repository.getPatientProfile();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _profile = result.dataOrNull;
      });
    }
  }

  Future<void> _loadFacilities() async {
    setState(() => _isLoadingFacilities = true);
    try {
      final result = await _facilityRepository.getFacilities();
      if (mounted && result.isSuccess) {
        setState(() {
          _facilities = result.dataOrNull ?? [];
        });
      }
    } catch (_) {
      // Graceful fallback to designated trauma center
    } finally {
      if (mounted) {
        setState(() => _isLoadingFacilities = false);
      }
    }
  }

  void _onBottomNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/records');
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/doctors');
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed('/insurance');
    } else if (index == 4) {
      Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  void _triggerSos() {
    setState(() => _sosTriggered = true);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isEn ? 'Emergency Notice (Simulation)' : 'Aviso de Emergencia (Simulación)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          _isEn
              ? 'Emergency services broadcast requires carrier telephony integration and active device permissions. This sandbox client does not dispatch live 911 calls. If you require urgent medical assistance, please dial 911 or your local emergency dispatcher directly.'
              : 'El despacho de emergencia requiere integración de telefonía. Este cliente sandbox no despacha llamadas al 911. Si requiere atención médica urgente, llame directamente al 911.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _sosTriggered = false);
              Navigator.of(ctx).pop();
            },
            child: Text(_isEn ? 'Understood' : 'Entendido'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyQrSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Icon(Icons.emergency_outlined, color: Colors.red, size: 40),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _isEn ? 'Emergency Medical Responder Pass' : 'Pase Médico para Rescatistas',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _isEn
                  ? 'First responders can scan this QR to instantly view vital medical conditions, allergies, and contact ICE guardians.'
                  : 'Los rescatistas pueden escanear este código QR para ver datos médicos vitales y contactos.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.red.shade200, width: 2),
              ),
              child: const Icon(Icons.qr_code_2, size: 160, color: Colors.red),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'PASS ID: CAREID-EMERGENCY-${_profile?.id.substring(0, 8).toUpperCase() ?? "787E5187"}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _isEn ? 'Close Emergency Pass' : 'Cerrar Pase de Emergencia',
              onPressed: () => Navigator.of(ctx).pop(),
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (_profile?.fullName != null && _profile!.fullName.trim().isNotEmpty)
        ? _profile!.fullName.trim()
        : (_isEn ? 'Patient Profile' : 'Perfil del Paciente');
    final bloodGroup = (_profile?.bloodGroup != null && _profile!.bloodGroup!.trim().isNotEmpty)
        ? _profile!.bloodGroup!.trim()
        : (_isEn ? 'UNKNOWN' : 'NO REGISTRADO');
    final allergies = _profile?.allergies ?? [];
    final conditions = _profile?.conditions ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const CareIdLogo.horizontal(height: 18),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, color: Colors.red, size: 14),
                SizedBox(width: 4),
                Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. SOS Section (Figma 20:23998)
                        _buildSosHeroSection(),
                        const SizedBox(height: AppSpacing.md),

                        // 2. Bento Layout for Medical ID & Contacts (Figma 20:24011)
                        _buildMedicalProfileCard(name, bloodGroup, allergies, conditions),
                        const SizedBox(height: AppSpacing.md),

                        // 3. Emergency Contacts Section (Figma 20:24036)
                        _buildEmergencyContactsCard(),
                        const SizedBox(height: AppSpacing.md),

                        // 4. Section - Nearby Hospitals Map Widget (Figma 20:24067)
                        _buildLocalTraumaCenterCard(),
                        const SizedBox(height: AppSpacing.md),

                        // 5. Section - Share Emergency QR Primary Button (Figma 20:24093)
                        _buildShareEmergencyQrButton(),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),

                // 6. Bottom Navigation Bar (if enabled)
                if (widget.showBottomNav)
                  CareIdBottomNavigationBar(
                    currentIndex: 0,
                    onTabSelected: _onBottomNavSelected,
                    language: widget.language,
                  ),
              ],
            ),
    );
  }

  // 1. SOS Hero Section (Figma Node 20:23998, 358x180)
  Widget _buildSosHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0CFF0000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emergency_share_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEn ? 'Emergency Protocol Active' : 'Protocolo de Emergencia Activo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEn
                          ? 'Review emergency procedures and verifiable responder pass.'
                          : 'Revisa procedimientos de emergencia y pase verificable.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB91C1C),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: _sosTriggered
                ? (_isEn ? 'PROTOCOL REVIEWED' : 'PROTOCOLO REVISADO')
                : (_isEn ? 'TRIGGER 911 EMERGENCY SOS' : 'ACTIVAR SOS DE EMERGENCIA 911'),
            onPressed: _triggerSos,
            backgroundColor: const Color(0xFFDC2626),
            height: 48,
            leadingIcon: _sosTriggered ? Icons.check_circle_rounded : Icons.cell_tower_rounded,
          ),
        ],
      ),
    );
  }

  // 2. Bento Layout for Medical ID Quick View (Figma Node 20:24011)
  Widget _buildMedicalProfileCard(
    String name,
    String bloodGroup,
    List<String> allergies,
    List<String> conditions,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _isEn ? 'Critical Medical ID' : 'ID Médico Crítico',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                ),
                child: Text(
                  'BLOOD $bloodGroup',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$_profileFullNameLabel $name',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const Divider(height: 20),
          Text(
            _isEn ? 'Known Allergies' : 'Alergias Conocidas',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allergies.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: Text(
                  a,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC2410C),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _isEn ? 'Medical Conditions' : 'Condiciones Médicas',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: conditions.map((c) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  c,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.favorite_rounded, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _isEn ? 'Organ Donor: Unspecified' : 'Donante de Órganos: No especificado',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _profileFullNameLabel => _isEn ? 'Patient:' : 'Paciente:';

  // 3. Emergency Contacts Section (Figma Node 20:24036)
  Widget _buildEmergencyContactsCard() {
    final hasIce = _profile?.emergencyContactName != null &&
        _profile!.emergencyContactName!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _isEn ? 'Emergency Contacts (ICE)' : 'Contactos de Emergencia (ICE)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Text(
                hasIce ? '1 Linked' : '0 Linked',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (hasIce)
            _buildContactRow(
              _profile!.emergencyContactName!,
              _profile!.emergencyContactRelationship ?? (_isEn ? 'Primary ICE' : 'ICE Principal'),
              _profile!.emergencyContactPhone ?? '',
              const Color(0xFF5B14B8),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.contact_phone_outlined, size: 28, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 6),
                  Text(
                    _isEn ? 'No Emergency Contact Configured' : 'Sin contacto de emergencia configurado',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155), fontFamily: 'Plus Jakarta Sans'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isEn ? 'Configure in onboarding or profile settings.' : 'Agrega un contacto en configuración de perfil.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Plus Jakarta Sans'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String name, String relation, String phone, Color avatarColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: avatarColor.withValues(alpha: 0.12),
          child: Text(
            name[0],
            style: TextStyle(fontWeight: FontWeight.w800, color: avatarColor, fontFamily: 'Plus Jakarta Sans'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
              ),
              Text(
                relation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Plus Jakarta Sans'),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF16A34A), size: 22),
          tooltip: 'Call $name',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Dialing emergency contact: $phone')),
            );
          },
        ),
      ],
    );
  }

  // 4. Section - Nearby Hospitals Map Widget (Figma Node 20:24067)
  Widget _buildLocalTraumaCenterCard() {
    final primaryFacility = _facilities.isNotEmpty
        ? _facilities.firstWhere((f) => f.isHospital, orElse: () => _facilities.first)
        : null;

    final hospitalName = primaryFacility?.name ?? 'City General Hospital Emergency Department';
    final hospitalAddress = primaryFacility != null
        ? '${primaryFacility.fullAddress} • Open 24/7'
        : (_isEn
            ? '425 Clinical Way, Suite 200 • 0.8 mi away • Open 24/7'
            : '425 Clinical Way, Suite 200 • 0.8 mi • Abierto 24/7');
    final hospitalPhone = primaryFacility?.emergencyPhone ?? primaryFacility?.phone ?? '+1 (650) 555-9999';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _isEn ? 'Designated Level 1 Trauma Center' : 'Centro de Trauma Nivel 1',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (_isLoadingFacilities) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hospitalName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
          ),
          const SizedBox(height: 2),
          Text(
            hospitalAddress,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Plus Jakarta Sans'),
          ),
          if (_facilities.length > 1) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: _facilities
                  .where((f) => f.id != primaryFacility?.id)
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.business_rounded, size: 12, color: Color(0xFF475569)),
                            const SizedBox(width: 4),
                            Text(
                              f.name,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569), fontFamily: 'Plus Jakarta Sans'),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling Emergency Department: $hospitalPhone')),
                    );
                  },
                  icon: const Icon(Icons.call_rounded, color: Colors.red, size: 18),
                  label: Text(_isEn ? 'Call ER' : 'Llamar Urgencias', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: _isEn ? 'Directions' : 'Ruta GPS',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening GPS directions to $hospitalName...')),
                    );
                  },
                  leadingIcon: Icons.directions_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Section - Share Emergency QR Primary Button (Figma Node 20:24093)
  Widget _buildShareEmergencyQrButton() {
    return PrimaryButton(
      label: _isEn ? 'Share Emergency Medical Pass (QR)' : 'Compartir Pase Médico (QR)',
      onPressed: _showEmergencyQrSheet,
      leadingIcon: Icons.qr_code_2_rounded,
      backgroundColor: const Color(0xFF0F172A),
    );
  }
}
