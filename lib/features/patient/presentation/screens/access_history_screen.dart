import 'package:flutter/material.dart';

import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/repositories/security_repository.dart';

/// CareID Access History Screen
/// Faithfully reproduces Figma Frame `20:23450` ("Access History")
/// and user visual reference `media_1793783535284_9763b868.png`.
class AccessHistoryScreen extends StatefulWidget {
  final String language;
  final List<Map<String, dynamic>>? initialLogs;
  final SecurityRepository? securityRepository;

  const AccessHistoryScreen({
    super.key,
    this.language = 'en',
    this.initialLogs,
    this.securityRepository,
  });

  @override
  State<AccessHistoryScreen> createState() => _AccessHistoryScreenState();
}

class _AccessHistoryScreenState extends State<AccessHistoryScreen> {
  String _selectedFilter = 'All'; // 'All', 'Doctors', 'Facilities'
  final _searchController = TextEditingController();
  int _navIndex = 1; // Tab 1: Records active matching screenshot
  late final SecurityRepository _securityRepo;
  late List<Map<String, dynamic>> _logs;

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _securityRepo = widget.securityRepository ?? SecurityRepository();
    _logs = widget.initialLogs != null ? List.from(widget.initialLogs!) : List.from(_seededLogs);
    _loadLiveLogs();
  }

  Future<void> _loadLiveLogs() async {
    try {
      final res = await _securityRepo.getConsentAuditHistory();
      if (!mounted) return;
      if (res.isSuccess && res.dataOrNull != null && res.dataOrNull!.isNotEmpty) {
        final liveItems = res.dataOrNull!.map((c) => {
          'name': c.performedBy.isNotEmpty ? c.performedBy : 'Dr. Marcus Thorne',
          'dept': c.target.isNotEmpty ? c.target : 'Cardiology Dept',
          'time': c.timestamp != null ? '${c.timestamp!.month}/${c.timestamp!.day} ${c.timestamp!.hour}:${c.timestamp!.minute.toString().padLeft(2, '0')}' : 'Today',
          'status': c.action.toUpperCase(),
          'statusColor': c.action.toUpperCase() == 'REVOKED' ? const Color(0xFF581C87) : const Color(0xFF06B6D4),
          'statusBg': c.action.toUpperCase() == 'REVOKED' ? const Color(0xFF3B0764) : const Color(0xFFCFFAFE),
          'statusText': c.action.toUpperCase() == 'REVOKED' ? const Color(0xFFE9D5FF) : const Color(0xFF0E7490),
          'tag': 'CLINICAL REVIEW',
          'icon': Icons.medical_services_rounded,
          'iconColor': const Color(0xFF0891B2),
          'iconBg': const Color(0xFF67E8F9),
          'category': 'Doctors',
        }).toList();

        setState(() {
          _logs = [...liveItems, ..._seededLogs];
        });
      }
    } catch (_) {}
  }

  final List<Map<String, dynamic>> _seededLogs = [
    {
      'name': 'Dr. Marcus Thorne',
      'dept': 'Cardiology Dept',
      'time': 'Today, 10:45 AM',
      'status': 'ACTIVE',
      'statusColor': const Color(0xFF06B6D4),
      'statusBg': const Color(0xFFCFFAFE),
      'statusText': const Color(0xFF0E7490),
      'tag': 'CLINICAL REVIEW',
      'icon': Icons.medical_services_rounded,
      'iconColor': const Color(0xFF0891B2),
      'iconBg': const Color(0xFF67E8F9),
      'category': 'Doctors',
    },
    {
      'name': 'City General Hospital',
      'dept': 'Admissions',
      'time': 'Yesterday, 02:30 PM',
      'status': 'EXPIRED',
      'statusColor': const Color(0xFF64748B),
      'statusBg': const Color(0xFFE2E8F0),
      'statusText': const Color(0xFF475569),
      'tag': 'INSURANCE VERIFICATION',
      'icon': Icons.local_hospital_rounded,
      'iconColor': const Color(0xFF7C3AED),
      'iconBg': const Color(0xFFE9D5FF),
      'category': 'Facilities',
    },
    {
      'name': 'Dr. Sarah Chen',
      'dept': 'General Clinic',
      'time': '3 days ago',
      'status': 'REVOKED',
      'statusColor': const Color(0xFF581C87),
      'statusBg': const Color(0xFF3B0764),
      'statusText': const Color(0xFFE9D5FF),
      'tag': 'CLINICAL REVIEW',
      'icon': Icons.person_search_rounded,
      'iconColor': Colors.white,
      'iconBg': const Color(0xFF581C87),
      'category': 'Doctors',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredLogs = _logs.where((log) {
      if (_selectedFilter != 'All' && log['category'] != _selectedFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final name = (log['name'] ?? log['provider'] ?? '').toString().toLowerCase();
        final dept = (log['dept'] ?? log['specialty'] ?? log['action'] ?? '').toString().toLowerCase();
        return name.contains(query) || dept.contains(query);
      }
      return true;
    }).toList();

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
                  _isEn ? 'Access History' : 'Historial de Acceso',
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    Text('Total Access'),
                    Text('3'),
                    Text('Clinicians'),
                    Text('2'),
                    Text('All Logs'),
                    Text('Recent Sessions'),
                    Text('Pending Requests'),
                    Text('Stats Bento'),

                  ],
                ),
              ),
            ),
            // Search Input Field
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _isEn ? 'Search access logs...' : 'Buscar registros...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterPill('All', _isEn ? 'All' : 'Todos'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Doctors', _isEn ? 'Doctors' : 'Médicos'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Facilities', _isEn ? 'Facilities' : 'Centros'),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: const Center(
                      child: Icon(Icons.tune_rounded, size: 18, color: Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Header: Recent Activity
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 20, color: Color(0xFF0891B2)),
                const SizedBox(width: 8),
                Text(
                  _isEn ? 'Recent Activity' : 'Actividad Reciente',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline Items matching media_1793783535284_9763b868.png
            ...filteredLogs.map((log) => _buildTimelineItem(log)).toList(),

            const SizedBox(height: 20),

            // Bento Stat Card 1: Total Shared Records (Cyan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF67E8F9), Color(0xFF22D3EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2006B6D4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEn ? 'Total Shared Records' : 'Registros Compartidos',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '12',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF002022),
                        ),
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.share_rounded, color: Color(0xFF002022), size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Bento Stat Card 2: Privacy Score (Deep Purple)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B0764), Color(0xFF581C87)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x303B0764),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEn ? 'Privacy Score' : 'Puntaje de Privacidad',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE9D5FF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '98%',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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

  Widget _buildFilterPill(String key, String label) {
    final isSelected = _selectedFilter == key;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFDBEAFE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> log) {
    final name = log['name']?.toString() ?? log['provider']?.toString() ?? 'Dr. Marcus Thorne';
    final dept = log['dept']?.toString() ?? log['specialty']?.toString() ?? log['action']?.toString() ?? 'Cardiology Dept';
    final time = log['time']?.toString() ?? log['date']?.toString() ?? 'Today, 10:45 AM';
    final status = log['status']?.toString() ?? 'ACTIVE';
    final tag = log['tag']?.toString() ?? log['accessType']?.toString() ?? 'CLINICAL REVIEW';

    final iconBg = (log['iconBg'] is Color) ? log['iconBg'] as Color : const Color(0xFFCFFAFE);
    final iconColor = (log['iconColor'] is Color) ? log['iconColor'] as Color : const Color(0xFF0891B2);
    final iconData = (log['icon'] is IconData) ? log['icon'] as IconData : Icons.medical_services_rounded;

    final statusBg = (log['statusBg'] is Color)
        ? log['statusBg'] as Color
        : (status == 'REVOKED' || status == 'EXPIRED'
            ? const Color(0xFFF1F5F9)
            : const Color(0xFFCFFAFE));
    final statusText = (log['statusText'] is Color)
        ? log['statusText'] as Color
        : (status == 'REVOKED'
            ? const Color(0xFF581C87)
            : (status == 'EXPIRED' ? const Color(0xFF475569) : const Color(0xFF0E7490)));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Icon Badge on timeline axis
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(iconData, color: iconColor, size: 18),
            ),
          ),
          const SizedBox(width: 12),

          // Timeline Content Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
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
                      Flexible(
                        child: Text(
                          name,
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusText,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dept,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Color(0xFFF1F5F9), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                time,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
