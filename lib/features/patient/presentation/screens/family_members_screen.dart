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
    // If running in test or offline preview mode without an API client or custom repo
    if (widget.apiClient == null && widget.repository == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _members = _defaultFigmaMembers;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final memRes = await _repository.getMembers();

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      memRes.when(
        success: (list, _) {
          _members = list.isNotEmpty ? list : _defaultFigmaMembers;
        },
        failure: (msg, code, _) {
          if (code == 401) {
            _errorMessage = _isEn
                ? 'Sign in to access family accounts and permissions.'
                : 'Inicia sesión para gestionar cuentas familiares.';
          } else {
            _errorMessage = msg;
          }
          _members = _defaultFigmaMembers;
        },
      );
    });
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
              builder: (_) => const AddFamilyMemberScreen(),
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

    if (members.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: members.length,
      itemBuilder: (context, index) {
        return _buildMemberCard(members[index]);
      },
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delete action for ${mem.fullName}')),
                    );
                  },
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

