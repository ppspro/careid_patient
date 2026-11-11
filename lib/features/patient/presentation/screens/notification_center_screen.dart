import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/notification_models.dart';
import '../../data/repositories/notification_repository.dart';
import 'medication_reminder_detail_screen.dart';

/// CareID Patient App — Notification Center Screen
/// Aligned strictly with Figma Frame `20:23812` ("Notification Center", 390x1459)
class NotificationCenterScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final NotificationRepository? repository;
  final String language;
  final bool showBottomNav;

  const NotificationCenterScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.language = 'en',
    this.showBottomNav = false,
  });

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  late final NotificationRepository _repository;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Medications',
    'Appointments',
    'Records',
    'Security',
    'Care Team',
  ];

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? NotificationRepository(apiClient: widget.apiClient);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final result = await _repository.getNotifications();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _notifications = result.dataOrNull ?? [];
      });
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

  Future<void> _handleMarkRead(NotificationModel item) async {
    await _repository.markAsRead(item.id);
    await _loadNotifications();
    if (mounted) {
      final isMed = item.title.toLowerCase().contains('prescript') ||
          item.title.toLowerCase().contains('medic') ||
          item.message.toLowerCase().contains('prescript') ||
          item.message.toLowerCase().contains('medic');
      if (isMed) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const MedicationReminderDetailScreen(),
          ),
        );
      }
    }
  }

  Future<void> _handleMarkAllRead() async {
    await _repository.markAllAsRead(_notifications);
    await _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEn ? 'All notifications marked as read' : 'Todas marcadas como leídas')),
      );
    }
  }

  List<NotificationModel> _getFilteredNotifications() {
    if (_selectedCategory == 'All') return _notifications;
    final catLower = _selectedCategory.toLowerCase();
    return _notifications.where((n) {
      final type = n.notificationType.toLowerCase();
      final title = n.title.toLowerCase();
      final body = n.message.toLowerCase();

      if (catLower == 'medications') {
        return type.contains('medic') || title.contains('medic') || body.contains('prescript') || body.contains('dose');
      }
      if (catLower == 'appointments') {
        return type.contains('appoint') || title.contains('appoint') || body.contains('clinic') || body.contains('consult');
      }
      if (catLower == 'records') {
        return type.contains('record') || title.contains('vault') || body.contains('ecg') || body.contains('lab');
      }
      if (catLower == 'security') {
        return type.contains('sec') || type.contains('auth') || title.contains('device') || body.contains('login');
      }
      if (catLower == 'care team') {
        return type.contains('care') || title.contains('dr.') || body.contains('doctor');
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredNotifications();

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
          TextButton(
            onPressed: _handleMarkAllRead,
            child: Text(
              _isEn ? 'Mark all read' : 'Marcar leídas',
              style: const TextStyle(
                color: Color(0xFF5B14B8),
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Category Filters (Figma Node 20:23814)
          _buildFilterBar(),

          // 2. Notification List & Sections
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B14B8)))
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: const Color(0xFF5B14B8),
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(filtered[index]);
                          },
                        ),
                      ),
          ),

          // 3. Bottom Navigation Bar (if enabled)
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

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final isEmergency = item.notificationType == 'EMERGENCY' || item.priority == 'HIGH';
    final isRecord = item.notificationType.contains('RECORD');
    final isConsent = item.notificationType.contains('CONSENT');
    final isReminder = item.notificationType.contains('REMIND');

    Color iconColor;
    Color iconBg;
    IconData icon;

    if (isEmergency) {
      iconColor = const Color(0xFFDC2626);
      iconBg = const Color(0xFFFEE2E2);
      icon = Icons.warning_amber_rounded;
    } else if (isRecord) {
      iconColor = const Color(0xFF5B14B8);
      iconBg = const Color(0xFFEDE9FE);
      icon = Icons.folder_shared_outlined;
    } else if (isConsent) {
      iconColor = const Color(0xFF0F766E);
      iconBg = const Color(0xFFCCFBF1);
      icon = Icons.verified_user_outlined;
    } else if (isReminder) {
      iconColor = const Color(0xFFD97706);
      iconBg = const Color(0xFFFEF3C7);
      icon = Icons.alarm_outlined;
    } else {
      iconColor = const Color(0xFF5B14B8);
      iconBg = const Color(0xFFEDE9FE);
      icon = Icons.notifications_none_outlined;
    }

    final timeAgo = _formatTimeAgo(item.sentAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFC4B5FD),
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleMarkRead(item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
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
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                                fontSize: 14,
                                color: const Color(0xFF0F172A),
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.isRead ? const Color(0xFF64748B) : const Color(0xFF334155),
                          fontFamily: 'Plus Jakarta Sans',
                          height: 1.3,
                        ),
                      ),
                      if (item.priority == 'HIGH') ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ACTION REQUIRED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFDC2626),
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 32, color: Color(0xFF5B14B8)),
          ),
          const SizedBox(height: 16),
          Text(
            _isEn ? 'No Notifications Yet' : 'Sin notificaciones',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isEn
                ? 'Your clinical updates, reminders, and alerts will appear here.'
                : 'Tus actualizaciones y alertas médicas aparecerán aquí.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontFamily: 'Plus Jakarta Sans',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
