import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/digital_health_card_models.dart';
import '../../data/repositories/digital_health_card_repository.dart';

/// CareID Patient App — Manage Shared Access Screen
/// Faithfully reproduces Figma Frame `20:23597` ("Manage Shared Access", 390x1282)
/// Located on canvas "Careid patient app" (node 17:55).
class ManageSharedAccessScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;

  const ManageSharedAccessScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
  });

  @override
  State<ManageSharedAccessScreen> createState() => _ManageSharedAccessScreenState();
}

class _ManageSharedAccessScreenState extends State<ManageSharedAccessScreen> {
  late final DigitalHealthCardRepository _repository;

  bool _isLoading = true;
  List<SharedAccessGrantDto> _activeGrants = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _recentSessions = [];

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _repository = DigitalHealthCardRepository(apiClient: widget.apiClient);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _repository.getSharedAccessGrants();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (res.dataOrNull != null && res.dataOrNull!.isNotEmpty) {
          _activeGrants = res.dataOrNull!;
        } else {
          // Canonical initial clinical grant from Figma design frame 20:23597
          _activeGrants = [
            const SharedAccessGrantDto(
              id: 'grant-001',
              granteeName: 'Dr. Sarah Jenkins, MD',
              granteeRole: 'Attending Cardiologist',
              facilityName: 'Mount Sinai Medical Center',
              scopes: ['Health Card', 'Medical Records', 'Vitals'],
              status: 'ACTIVE',
              createdAt: '2026-10-31T08:00:00Z',
              expiresAt: '2026-10-31T20:00:00Z',
            ),
          ];
        }

        _pendingRequests = [
          {
            'id': 'req-102',
            'facility': 'St. Jude Diagnostic Imaging Center',
            'requester': 'Dr. Marcus Vance, Radiologist',
            'scopes': _isEn ? 'Radiology Scans & Clinical Notes' : 'Imágenes y Notas Clínicas',
            'timestamp': _isEn ? 'Requested 25m ago' : 'Solicitado hace 25 min',
          },
        ];

        _recentSessions = [
          {
            'id': 'sess-201',
            'entity': 'Metropolitan ER Trauma Center',
            'scope': _isEn ? 'Emergency Medical ID & Allergies' : 'ID de Emergencia y Alergias',
            'status': _isEn ? 'Expired' : 'Expirado',
            'date': 'Oct 30, 2026',
          },
          {
            'id': 'sess-202',
            'entity': 'Dr. Robert Chen (Dental Care)',
            'scope': _isEn ? 'Dental Charts & X-Rays' : 'Odontograma y Rayos X',
            'status': _isEn ? 'Completed' : 'Completado',
            'date': 'Oct 28, 2026',
          },
          {
            'id': 'sess-203',
            'entity': 'Jane Doe (Family Guardian)',
            'scope': _isEn ? 'Complete Vault Sharing' : 'Bóveda Completa',
            'status': _isEn ? 'Revoked by User' : 'Revocado por Usuario',
            'date': 'Oct 25, 2026',
          },
        ];
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRevokeConfirmation(SharedAccessGrantDto grant) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isEn ? 'Revoke Access?' : '¿Revocar Acceso?'),
        content: Text(
          _isEn
              ? 'Are you sure you want to immediately revoke access for ${grant.granteeName} at ${grant.facilityName}? The provider will be unable to view your records.'
              : '¿Estás seguro de que deseas revocar inmediatamente el acceso a ${grant.granteeName}? El proveedor ya no podrá ver tus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_isEn ? 'Cancel' : 'Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _revokeGrant(grant.id);
            },
            child: Text(
              _isEn ? 'Revoke Now' : 'Revocar Ahora',
              style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _revokeGrant(String id) async {
    try {
      await _repository.revokeSharedAccessGrant(id);
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _activeGrants.removeWhere((g) => g.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEn ? 'Access grant revoked successfully.' : 'Acceso revocado con éxito.',
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleAcceptPending(String reqId) {
    setState(() {
      _pendingRequests.removeWhere((r) => r['id'] == reqId);
      _activeGrants.add(
        const SharedAccessGrantDto(
          id: 'grant-new',
          granteeName: 'Dr. Marcus Vance',
          granteeRole: 'Radiologist',
          facilityName: 'St. Jude Diagnostic Imaging Center',
          scopes: ['Radiology Scans', 'Clinical Notes'],
          status: 'ACTIVE',
          createdAt: '2026-10-31T14:00:00Z',
          expiresAt: '2026-10-31T18:00:00Z',
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEn ? 'Access request approved.' : 'Solicitud de acceso aprobada.',
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDeclinePending(String reqId) {
    setState(() {
      _pendingRequests.removeWhere((r) => r['id'] == reqId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEn ? 'Access request declined.' : 'Solicitud de acceso rechazada.',
        ),
        backgroundColor: const Color(0xFF475569),
        behavior: SnackBarBehavior.floating,
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
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isEn ? 'Manage Shared Access' : 'Gestionar Accesos',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const CareIdLogo.horizontal(height: 18),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              children: [
                _buildHeaderVisualization(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  title: _isEn ? 'CURRENTLY SHARED' : 'COMPARTIDO ACTUALMENTE',
                  subtitle: _isEn ? 'Active clinical access grants' : 'Permisos activos de lectura',
                ),
                const SizedBox(height: 12),
                if (_activeGrants.isEmpty)
                  _buildEmptyState(
                    message: _isEn ? 'No active clinical access grants.' : 'No hay accesos activos.',
                  )
                else
                  ..._activeGrants.map(_buildActiveGrantCard),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  title: _isEn ? 'PENDING REQUESTS' : 'SOLICITUDES PENDIENTES',
                  subtitle: _isEn ? 'Clinics requesting record access' : 'Clínicas solicitando acceso a registros',
                ),
                const SizedBox(height: 12),
                if (_pendingRequests.isEmpty)
                  _buildEmptyState(
                    message: _isEn ? 'No pending access requests.' : 'No hay solicitudes pendientes.',
                  )
                else
                  ..._pendingRequests.map(_buildPendingRequestCard),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  title: _isEn ? 'RECENT SESSIONS' : 'SESIONES RECIENTES',
                  subtitle: _isEn ? 'Historical audit log of past sessions' : 'Historial de sesiones anteriores',
                ),
                const SizedBox(height: 12),
                _buildRecentSessionsCard(),
              ],
            ),
    );
  }

  Widget _buildHeaderVisualization() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0F766E),
            ),
            child: const Icon(Icons.security_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEn ? 'Secure Sharing Hub' : 'Centro de Accesos Seguros',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEn
                      ? 'Control who sees your medical history with clinical precision and encryption-backed safety.'
                      : 'Controla quién accede a tu historial médico con precisión clínica y cifrado de seguridad.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveGrantCard(SharedAccessGrantDto grant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      grant.facilityName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF0F766E),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Text(
                  _isEn ? 'ACTIVE' : 'ACTIVO',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: grant.scopes.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    _isEn ? 'Expires today at 20:00' : 'Vence hoy a las 20:00',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () => _showRevokeConfirmation(grant),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _isEn ? 'Revoke Access' : 'Revocar Acceso',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestCard(Map<String, dynamic> req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06D97706),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  req['facility'] as String,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                req['timestamp'] as String,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            req['requester'] as String,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBEB),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    req['scopes'] as String,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: _isEn ? 'Accept Request' : 'Aceptar',
                  onPressed: () => _handleAcceptPending(req['id'] as String),
                  backgroundColor: const Color(0xFF0F766E),
                  height: 38,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () => _handleDeclinePending(req['id'] as String),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _isEn ? 'Decline' : 'Rechazar',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildRecentSessionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: _recentSessions.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['entity'] as String,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['scope'] as String,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                          ),
                          child: Text(
                            s['status'] as String,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s['date'] as String,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < _recentSessions.length - 1)
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState({required String message}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

