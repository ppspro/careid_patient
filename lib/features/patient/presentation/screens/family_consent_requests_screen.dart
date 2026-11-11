import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/digital_health_card_models.dart';
import '../../data/repositories/family_repository.dart';

/// CareID Patient App — Family Consent & Requests Screen
/// Faithfully reproduces Figma Frame `20:22157` ("Family Consent & Requests", 390x1175)
/// Features 64px AppBar with CareIdLogo.horizontal(height: 18),
/// 3-tab request system (Pending, Approved, Expired), bento cards with
/// one-tap Approve/Decline actions grounded in GET/PATCH /api/v1/family/consents.
class FamilyConsentRequestsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final FamilyRepository? repository;
  final String language;
  final List<SharedAccessGrantDto>? initialGrants;

  const FamilyConsentRequestsScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.language = 'en',
    this.initialGrants,
  });

  @override
  State<FamilyConsentRequestsScreen> createState() => _FamilyConsentRequestsScreenState();
}

class _FamilyConsentRequestsScreenState extends State<FamilyConsentRequestsScreen> {
  late final FamilyRepository _repository;
  int _selectedTab = 0; // 0: Pending, 1: Approved, 2: Expired
  bool _isLoading = false;
  List<SharedAccessGrantDto> _grants = [];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FamilyRepository(apiClient: widget.apiClient);
    if (widget.initialGrants != null) {
      _grants = List.from(widget.initialGrants!);
    } else {
      _loadConsents();
    }
  }

  bool get _isEn => widget.language == 'en';

  Future<void> _loadConsents() async {
    setState(() {
      _isLoading = true;
    });

    final res = await _repository.getConsents();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      res.when(
        success: (list, _) {
          _grants = list;
        },
        failure: (msg, _, __) {
          _grants = const [];
        },
      );
    });
  }

  Future<void> _updateConsentStatus(String consentId, String newStatus) async {
    setState(() => _isLoading = true);
    await _repository.updateConsent(consentId: consentId, status: newStatus);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      final idx = _grants.indexWhere((g) => g.id == consentId);
      if (idx != -1) {
        final current = _grants[idx];
        _grants[idx] = SharedAccessGrantDto(
          id: current.id,
          granteeName: current.granteeName,
          granteeRole: current.granteeRole,
          facilityName: current.facilityName,
          scopes: current.scopes,
          status: newStatus,
          createdAt: current.createdAt,
          expiresAt: current.expiresAt,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'ACTIVE'
              ? (_isEn ? 'Access granted successfully.' : 'Acceso otorgado con éxito.')
              : (_isEn ? 'Access request declined.' : 'Solicitud de acceso rechazada.'),
        ),
        backgroundColor: newStatus == 'ACTIVE' ? const Color(0xFF0F766E) : const Color(0xFFDC2626),
      ),
    );
  }

  List<SharedAccessGrantDto> get _filteredGrants {
    if (_selectedTab == 0) {
      return _grants.where((g) => g.status == 'PENDING').toList();
    } else if (_selectedTab == 1) {
      return _grants.where((g) => g.status == 'ACTIVE').toList();
    } else {
      return _grants.where((g) => g.status == 'EXPIRED' || g.status == 'REVOKED' || g.status == 'REJECTED').toList();
    }
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
                      _isEn ? 'Consent & Requests' : 'Consentimientos y Solicitudes',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B14B8)))
          : RefreshIndicator(
              onRefresh: _loadConsents,
              color: const Color(0xFF5B14B8),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  // Title and subtitle section
                  Text(
                    _isEn ? 'Manage Access' : 'Gestionar Acceso',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isEn
                        ? 'Review and manage healthcare data sharing permissions.'
                        : 'Revisa y gestiona los permisos de intercambio de datos clínicos.',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Send New Request Action Card
                  _buildSendRequestCard(),
                  const SizedBox(height: 20),

                  // 3-Tab System
                  _buildTabSystem(),
                  const SizedBox(height: 16),

                  // Request Cards Grid (Bento Style)
                  if (_filteredGrants.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filteredGrants.map(_buildConsentCard),
                ],
              ),
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

  Widget _buildSendRequestCard() {
    return Material(
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEn
                    ? 'Scan healthcare provider QR to initiate request.'
                    : 'Escanea el QR del proveedor para iniciar la solicitud.',
              ),
              backgroundColor: const Color(0xFF0F172A),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            gradient: const LinearGradient(
              colors: [Color(0xFFEDE9FE), Color(0xFFF8FAFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF5B14B8),
                ),
                child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEn ? 'Send New Request' : 'Enviar Nueva Solicitud',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEn
                          ? 'Authorize a clinic, hospital or family member'
                          : 'Autoriza una clínica, hospital o familiar',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
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

  Widget _buildTabSystem() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabItem(0, _isEn ? 'Pending' : 'Pendientes'),
            const SizedBox(width: 24),
            _buildTabItem(1, _isEn ? 'Approved' : 'Aprobados'),
            const SizedBox(width: 24),
            _buildTabItem(2, _isEn ? 'Expired / Revoked' : 'Expirados'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: 32,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5B14B8) : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentCard(SharedAccessGrantDto grant) {
    final isPending = grant.status == 'PENDING';
    final isActive = grant.status == 'ACTIVE';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Requester Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEDE9FE),
                child: Text(
                  grant.granteeName.isNotEmpty ? grant.granteeName[0] : 'C',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5B14B8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grant.granteeName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${grant.granteeRole} • ${grant.facilityName}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFEF3C7)
                      : isActive
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFF1F5F9),
                ),
                child: Text(
                  grant.status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isPending
                        ? const Color(0xFFB45309)
                        : isActive
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Access Requested Bento Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEn ? 'ACCESS REQUESTED' : 'ACCESO SOLICITADO',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: grant.scopes.map((scope) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        scope,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Expiry and Action Buttons
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${grant.expiresAt.substring(0, 10)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              if (isPending)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _updateConsentStatus(grant.id, 'REJECTED'),
                      child: Text(
                        _isEn ? 'Decline' : 'Rechazar',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    PrimaryButton(
                      label: _isEn ? 'Approve' : 'Aprobar',
                      onPressed: () => _updateConsentStatus(grant.id, 'ACTIVE'),
                      backgroundColor: const Color(0xFF0F766E),
                      isFullWidth: false,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.folder_shared_outlined, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            _isEn ? 'No requests in this category' : 'No hay solicitudes en esta categoría',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isEn
                ? 'Clinical access requests from hospitals or doctors will appear here.'
                : 'Las solicitudes de acceso clínico aparecerán aquí.',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF94A3B8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
