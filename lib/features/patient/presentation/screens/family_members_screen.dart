import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../data/models/family_models.dart';
import '../../data/repositories/family_repository.dart';
import 'add_family_member_screen.dart';
import 'dependent_health_card_screen.dart';
import 'member_permissions_sharing_screen.dart';

/// CareID Family Members & Care Linkage Screen
/// Aligned strictly with Figma Frame `20:21825` ("Family Member List", 390x1430)
/// Grounded in OpenAPI 3.0.0 and Postman Collection for `12. Family Members & Relationships`
class FamilyMembersScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final FamilyRepository? repository;
  final String language;

  const FamilyMembersScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.language = 'en',
  });

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  late String _currentLanguage;
  late final FamilyRepository _repository;

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  List<FamilyMemberDto> _members = [];
  List<FamilyInvitationDto> _invitations = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const List<FamilyMemberDto> _defaultFigmaMembers = [
    FamilyMemberDto(
      id: 'mem-arthur-01',
      fullName: 'Arthur Thompson',
      relationship: 'Father',
      age: 68,
      isVerified: true,
      healthCardStatus: 'Active',
      insurancePlan: 'Global Care Plus',
      consentStatus: 'Full Access',
      avatarUrl: 'assets/images/family_arthur.png',
    ),
    FamilyMemberDto(
      id: 'mem-oliver-02',
      fullName: 'Oliver Thompson',
      relationship: 'Son',
      age: 8,
      isVerified: true,
      healthCardStatus: 'Active',
      insurancePlan: 'Dependant Coverage',
      consentStatus: 'Parental Proxy',
      avatarUrl: 'assets/images/family_oliver.png',
    ),
    FamilyMemberDto(
      id: 'mem-sarah-03',
      fullName: 'Sarah Jenkins',
      relationship: 'Spouse',
      age: 39,
      isVerified: false,
      healthCardStatus: 'Inactive',
      insurancePlan: 'Awaiting Update',
      consentStatus: 'Invite Sent',
      avatarUrl: 'assets/images/family_sarah.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _repository = widget.repository ?? FamilyRepository(apiClient: widget.apiClient);
    _loadFamilyData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isEn => _currentLanguage == 'en';

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
        success: (list, _) {
          _members = list;
        },
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
        success: (invs, _) {
          _invitations = invs;
        },
        failure: (_, __, ___) {
          _invitations = [];
        },
      );

      // If both members and invitations are empty and running with no API client / repo, fallback to design seed
      if (_members.isEmpty && _invitations.isEmpty && widget.apiClient == null && widget.repository == null) {
        _members = _defaultFigmaMembers;
      }
    });
  }

  Future<void> _handleResendInvitation(FamilyInvitationDto inv) async {
    if (!inv.canResend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum resend attempts reached for this invitation (5/5).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final res = await _repository.resendInvitation(inv.id);
    if (!mounted) return;

    res.when(
      success: (updated, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation resent to ${inv.inviteeName ?? inv.inviteePhone} (${updated.resendCount}/5).'),
            backgroundColor: const Color(0xFF00695C),
          ),
        );
        _loadFamilyData();
      },
      failure: (msg, _, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
          ),
        );
      },
    );
  }

  Future<void> _handleCancelInvitation(FamilyInvitationDto inv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Invitation'),
        content: Text('Are you sure you want to cancel the invitation sent to ${inv.inviteeName ?? inv.inviteePhone}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel Invitation', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await _repository.cancelInvitation(inv.id);
    if (!mounted) return;

    res.when(
      success: (_, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation cancelled successfully.'),
            backgroundColor: Color(0xFF00695C),
          ),
        );
        _loadFamilyData();
      },
      failure: (msg, _, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
          ),
        );
      },
    );
  }

  Future<void> _handleAcceptInvitation(FamilyInvitationDto inv) async {
    final res = await _repository.acceptInvitation(inv.id);
    if (!mounted) return;

    res.when(
      success: (_, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation for ${inv.inviteeName ?? inv.inviteePhone} accepted! Linked into family vault.'),
            backgroundColor: const Color(0xFF15803D),
          ),
        );
        _loadFamilyData();
      },
      failure: (msg, _, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
          ),
        );
      },
    );
  }

  Future<void> _handleDeleteMember(FamilyMemberDto mem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Family Member'),
        content: Text('Are you sure you want to remove ${mem.fullName} from your family health vault?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await _repository.removeMember(mem.id);
    if (!mounted) return;

    res.when(
      success: (_, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${mem.fullName} removed.')),
        );
        _loadFamilyData();
      },
      failure: (msg, _, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
        );
      },
    );
  }

  List<String> get _filterOptions => _isEn
      ? ['All', 'Parents', 'Children', 'Spouse']
      : ['Todos', 'Padres', 'Hijos', 'Cónyuge'];

  List<FamilyMemberDto> get _filteredMembers {
    final query = _searchController.text.trim().toLowerCase();
    return _members.where((m) {
      final matchesSearch = query.isEmpty ||
          m.fullName.toLowerCase().contains(query) ||
          m.relationship.toLowerCase().contains(query) ||
          (m.phone != null && m.phone!.contains(query));

      if (!matchesSearch) return false;

      if (_selectedFilter == 'All' || _selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Parents' || _selectedFilter == 'Padres') {
        final rel = m.relationship.toLowerCase();
        return rel.contains('parent') ||
            rel.contains('father') ||
            rel.contains('mother') ||
            rel.contains('dad') ||
            rel.contains('mom');
      }
      if (_selectedFilter == 'Children' || _selectedFilter == 'Hijos') {
        final rel = m.relationship.toLowerCase();
        return rel.contains('child') ||
            rel.contains('son') ||
            rel.contains('daughter') ||
            rel.contains('dependent');
      }
      if (_selectedFilter == 'Spouse' || _selectedFilter == 'Cónyuge') {
        final rel = m.relationship.toLowerCase();
        return rel.contains('spouse') || rel.contains('wife') || rel.contains('husband');
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation Bar (Figma 20:21826)
            _buildTopHeader(),

            // 2. Search & Filter Bar (Figma 20:21835)
            _buildSearchAndFilters(),

            // 3. Main Content List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF5B14B8)),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF5B14B8),
                      onRefresh: _loadFamilyData,
                      child: _buildContentList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_invite_family_member',
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person_add_alt_1_rounded, size: 26),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AddFamilyMemberScreen(
                apiClient: widget.apiClient,
                repository: _repository,
              ),
            ),
          ).then((_) => _loadFamilyData());
        },
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: 1, // Records / Family active with cyan capsule
        language: _currentLanguage,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/doctors');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/profile');
          }
        },
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF2E006A)),
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Family Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E006A),
                fontFamily: 'Plus Jakarta Sans',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // CareID ID emblem
          Image.asset(
            'assets/images/careid_only_id.png',
            height: 20,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 10),
          // Notification Bell with red badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF2E006A)),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // User Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/sarah_jenkins_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const CircleAvatar(
                  backgroundColor: Color(0xFF5B14B8),
                  child: Text('SJ', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64748B)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                hintText: _isEn ? 'Search family members...' : 'Buscar familiares...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontFamily: 'Plus Jakarta Sans'),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Filter Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF1E40AF),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    final members = _filteredMembers;
    final pendingInvs = _invitations
        .where((i) => i.isPending || i.status.toUpperCase() == 'PENDING')
        .toList();

    if (members.isEmpty && pendingInvs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_outline_rounded, size: 36, color: Color(0xFF5B14B8)),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ??
                    (_searchController.text.isNotEmpty
                        ? (_isEn ? 'No results found' : 'Sin resultados')
                        : (_isEn ? 'No family members linked' : 'Sin familiares vinculados')),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (pendingInvs.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 18, color: Color(0xFFEA580C)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEn ? 'Pending Invitations (${pendingInvs.length})' : 'Invitaciones pendientes (${pendingInvs.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...pendingInvs.map(_buildInvitationCard),
          const SizedBox(height: 14),
        ],
        if (members.isNotEmpty) ...[
          if (pendingInvs.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 18, color: Color(0xFF00695C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isEn ? 'Linked Family Members (${members.length})' : 'Familiares vinculados (${members.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          ...members.map(_buildMemberCard),
        ],
      ],
    );
  }

  Widget _buildInvitationCard(FamilyInvitationDto inv) {
    final invitee = inv.inviteeName != null && inv.inviteeName!.isNotEmpty
        ? inv.inviteeName!
        : inv.inviteePhone;
    final initials = invitee.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
    final resendCount = inv.resendCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 52,
                  height: 52,
                  color: const Color(0xFFFFF7ED),
                  alignment: Alignment.center,
                  child: Text(
                    initials.isNotEmpty ? initials : 'IN',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFEA580C),
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitee,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${inv.relationship} • ${inv.inviteePhone}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFFEA580C)),
                    const SizedBox(width: 4),
                    Text(
                      _isEn ? 'Pending' : 'Pendiente',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEA580C),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 6),
                    Text(
                      'Resends: $resendCount/5',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
                if (inv.invitationToken != null)
                  Text(
                    'Token: ${inv.invitationToken!.length > 8 ? inv.invitationToken!.substring(0, 8) : inv.invitationToken}...',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF92400E),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: const Text('Accept', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => _handleAcceptInvitation(inv),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.send_rounded, size: 15),
                  label: Text('Resend ($resendCount/5)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00695C),
                    side: const BorderSide(color: Color(0xFF00695C)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: inv.canResend ? () => _handleResendInvitation(inv) : null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Cancel Invitation',
                icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _handleCancelInvitation(inv),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(FamilyMemberDto mem) {
    final isVerified = mem.isVerified;
    final ageText = mem.age != null ? ' • ${mem.age} Years' : '';
    final isPending = !isVerified || mem.healthCardStatus == 'Inactive';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Avatar, Name & Relation, Verified/Pending Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF1F5F9),
                  child: mem.avatarUrl != null
                      ? Image.asset(
                          mem.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarFallback(mem.fullName),
                        )
                      : _buildAvatarFallback(mem.fullName),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mem.fullName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${mem.relationship}$ageText',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFB2EBF2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF00838F)),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00838F),
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Details Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  label: 'Health Card Status',
                  value: mem.healthCardStatus ?? 'Active',
                  isStatusDot: true,
                  isActive: mem.healthCardStatus == 'Active',
                ),
                const Divider(color: Color(0xFFE2E8F0), height: 16),
                _buildInfoRow(
                  label: 'Insurance',
                  value: mem.insurancePlan ?? 'Global Care Plus',
                ),
                const Divider(color: Color(0xFFE2E8F0), height: 16),
                _buildInfoRow(
                  label: 'Consent Status',
                  value: mem.consentStatus ?? 'Full Access',
                  valueColor: isPending ? const Color(0xFFEA580C) : const Color(0xFF0284C7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Row
          Row(
            children: [
              Expanded(
                child: PrimaryButton.gradient(
                  label: isPending ? 'Resend Invite' : 'View Details',
                  onPressed: () {
                    if (isPending) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invitation resent to ${mem.fullName}')),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DependentHealthCardScreen(
                            apiClient: widget.apiClient,
                            language: widget.language,
                            member: mem,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MemberPermissionsSharingScreen(
                          apiClient: widget.apiClient,
                          language: widget.language,
                          member: mem,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFEF4444)),
                  onPressed: () => _handleDeleteMember(mem),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
        : 'FM';
    return Container(
      color: const Color(0xFFEDE9FE),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF5B14B8),
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isStatusDot = false,
    bool isActive = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontFamily: 'Plus Jakarta Sans',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isStatusDot) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF00838F) : const Color(0xFF94A3B8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? (isStatusDot && isActive ? const Color(0xFF00838F) : const Color(0xFF0F172A)),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

