import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/family_models.dart';
import '../../data/repositories/family_repository.dart';
import 'add_family_member_screen.dart';
import 'family_consent_requests_screen.dart';
import 'family_members_screen.dart';
import 'member_permissions_sharing_screen.dart';
import 'patient_profile_screen.dart';
import 'shared_medical_records_screen.dart';

/// CareID Patient App — Family Dashboard Screen
/// Faithfully reproduces Figma Frame `20:21675` ("Family Dashboard", 390x1545.5)
/// Features the "Family Ecosystem" Hero Card, Quick Management grid,
/// Recent Activity List, and CareID Bottom Navigation Bar.
class FamilyDashboardScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final FamilyRepository? repository;
  final String language;
  final String? patientInitials;
  final bool showBottomNav;

  const FamilyDashboardScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.language = 'en',
    this.patientInitials,
    this.showBottomNav = true,
  });

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  late final FamilyRepository _repository;
  List<FamilyMemberDto> _members = [];
  List<FamilyInvitationDto> _invitations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FamilyRepository(apiClient: widget.apiClient);
    _loadFamilyData();
  }

  bool get _isEn => widget.language == 'en';

  Future<void> _loadFamilyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final memRes = await _repository.getMembers();
    final invRes = await _repository.getInvitations();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      memRes.when(
        success: (list, _) => _members = list,
        failure: (msg, code, _) {
          if (code == 401) {
            _errorMessage = _isEn
                ? 'Sign in to access family accounts and permissions.'
                : 'Inicia sesión para gestionar cuentas familiares.';
          } else {
            _errorMessage = msg;
          }
        },
      );

      invRes.when(
        success: (list, _) => _invitations = list,
        failure: (_, __, ___) => _invitations = [],
      );
    });
  }

  void _onBottomNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/records');
    } else if (index == 2) {
      Navigator.of(context).pushNamed('/doctors');
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PatientProfileScreen(
            apiClient: widget.apiClient,
            language: widget.language,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar (Figma Node 20:21810, 390x64)
            _buildTopAppBar(),

            // 2. Scrollable Dashboard Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF5B14B8)),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF5B14B8),
                      onRefresh: _loadFamilyData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_errorMessage != null) _buildErrorBanner(),

                            // 3. Section - Family Overview Bento Card (Figma 20:21677)
                            _buildFamilyEcosystemHeroCard(),
                            const SizedBox(height: 20),

                            // 4. Section - Quick Management Grid (Figma 20:21711)
                            _buildQuickManagementSection(),
                            const SizedBox(height: 24),

                            // 5. Section - Recent Activity List (Figma 20:21733)
                            _buildRecentActivitySection(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
            ),

            // 6. Bottom Navigation Bar (Figma Node 20:21779)
            if (widget.showBottomNav)
              CareIdBottomNavigationBar(
                currentIndex: 1, // Records & Family tab
                onTabSelected: _onBottomNavSelected,
                language: widget.language,
              ),
          ],
        ),
      ),
    );
  }

  // 1. Top App Bar (Figma 20:21810)
  Widget _buildTopAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7ECF6), width: 1)),
        boxShadow: [
          BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF28006D)),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isEn ? 'Family Management' : 'Gestión Familiar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF28006D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CareIdLogo.onlyId(height: 18),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEDE9FE),
                  border: Border.all(color: const Color(0xFFC4B5FD)),
                ),
                child: Center(
                  child: Text(
                    widget.patientInitials ?? 'JD',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B14B8),
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

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Hero Bento Card: "Family Ecosystem" (Figma 20:21677)
  Widget _buildFamilyEcosystemHeroCard() {
    final memberCount = _members.length;
    final pendingCount = _invitations.where((i) => i.status.toUpperCase() == 'PENDING').length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF28006D), Color(0xFF4A148C), Color(0xFF5B14B8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2828006D),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Background Rings
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'HIPAA LINKED VAULT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.hub_outlined, color: Colors.white70, size: 24),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isEn ? 'Family Ecosystem' : 'Ecosistema Familiar',
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isEn
                      ? 'Securely manage and monitor the health data of your loved ones in one centralized clinical vault.'
                      : 'Gestiona y supervisa los datos de salud de tus seres queridos en un repositorio clínico unificado.',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildEcosystemMetric(
                        label: _isEn ? 'Connected' : 'Conectados',
                        value: '$memberCount',
                        subtext: _isEn ? 'Active members' : 'Miembros activos',
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => FamilyConsentRequestsScreen(
                                apiClient: widget.apiClient,
                                language: widget.language,
                              ),
                            ),
                          ).then((_) => _loadFamilyData());
                        },
                        child: _buildEcosystemMetric(
                          label: _isEn ? 'Pending' : 'Pendientes',
                          value: '$pendingCount',
                          subtext: _isEn ? 'Consent requests' : 'Solicitudes',
                        ),
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(
                      child: _buildEcosystemMetric(
                        label: _isEn ? 'Security' : 'Seguridad',
                        value: 'AES-256',
                        subtext: _isEn ? 'Key rotated' : 'Encriptado',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcosystemMetric({
    required String label,
    required String value,
    required String subtext,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
        Text(
          subtext,
          style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  // 4. Quick Management Grid (Figma 20:21711)
  Widget _buildQuickManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEn ? 'Quick Management' : 'Gestión Rápida',
          style: const TextStyle(
            fontSize: 17,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionRow(
          icon: Icons.person_add_alt_1_rounded,
          iconColor: const Color(0xFF5B14B8),
          bgColor: const Color(0xFFEDE9FE),
          title: _isEn ? 'Add Family Member' : 'Agregar Familiar',
          subtitle: _isEn ? 'Send secure digital invitation' : 'Enviar invitación digital segura',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AddFamilyMemberScreen(),
              ),
            ).then((_) => _loadFamilyData());
          },
        ),
        const SizedBox(height: 10),
        _buildActionRow(
          icon: Icons.people_outline_rounded,
          iconColor: const Color(0xFF0284C7),
          bgColor: const Color(0xFFE0F2FE),
          title: _isEn ? 'Family Member Directory' : 'Directorio de Familiares',
          subtitle: _isEn
              ? 'View all ${_members.length} connected dependents and cards'
              : 'Ver los ${_members.length} miembros y tarjetas',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FamilyMembersScreen(
                  apiClient: widget.apiClient,
                  language: widget.language,
                ),
              ),
            ).then((_) => _loadFamilyData());
          },
        ),
        const SizedBox(height: 10),
        _buildActionRow(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF10B981),
          bgColor: const Color(0xFFD1FAE5),
          title: _isEn ? 'Data Sharing Permissions' : 'Permisos de Datos Compartidos',
          subtitle: _isEn ? 'Manage medical records access scopes' : 'Gestionar acceso a registros médicos',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MemberPermissionsSharingScreen(
                  apiClient: widget.apiClient,
                  language: widget.language,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildActionRow(
          icon: Icons.history_edu_rounded,
          iconColor: const Color(0xFF0F766E),
          bgColor: const Color(0xFFCCFBF1),
          title: _isEn ? 'Shared Medical Records' : 'Registros Médicos Compartidos',
          subtitle: _isEn ? 'Access clinical history of authorized family' : 'Historial clínico de familiares autorizados',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SharedMedicalRecordsScreen(
                  apiClient: widget.apiClient,
                  language: widget.language,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildActionRow(
          icon: Icons.mark_email_unread_outlined,
          iconColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFEF3C7),
          title: _isEn ? 'Consent & Access Requests' : 'Consentimientos y Solicitudes',
          subtitle: _isEn ? 'Review doctor & clinic authorizations' : 'Revisar autorizaciones de doctores y clínicas',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FamilyConsentRequestsScreen(
                  apiClient: widget.apiClient,
                  language: widget.language,
                ),
              ),
            ).then((_) => _loadFamilyData());
          },
        ),
      ],
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7ECF6)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Recent Activity List (Figma 20:21733)
  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isEn ? 'Recent Family Activity' : 'Actividad Familiar Reciente',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FamilyMembersScreen(
                      apiClient: widget.apiClient,
                      language: widget.language,
                    ),
                  ),
                );
              },
              child: Text(
                _isEn ? 'View all' : 'Ver todos',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5B14B8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_members.isEmpty && _invitations.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7ECF6)),
            ),
            child: Center(
              child: Text(
                _isEn
                    ? 'No recent family activity recorded. Link family members to track shared updates.'
                    : 'Sin actividad familiar registrada. Vincula miembros para ver novedades.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Plus Jakarta Sans'),
              ),
            ),
          )
        else ...[
          ..._members.take(3).map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildActivityCard(
              icon: Icons.verified_user_outlined,
              iconColor: const Color(0xFF10B981),
              bgColor: const Color(0xFFD1FAE5),
              title: '${m.fullName} (${m.relationship})',
              description: _isEn
                  ? 'Active digital health pass and linked vault synchronization.'
                  : 'Pase de salud activo y sincronización de expediente vinculada.',
              timeAgo: 'Active',
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
    required String timeAgo,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

