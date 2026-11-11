import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../models/notification_models.dart';

/// CareID Patient App — Notification Repository
/// Connects to `/api/v1/notifications`
class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // In-memory status tracker for read notifications during session
  static final Set<String> _readNotificationIds = {};

  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    try {
      final result = await _apiClient.get<List<NotificationModel>>(
        ApiEndpoints.notifications,
        requiresAuth: true,
        fromJson: (json) {
          final list = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => NotificationModel.fromJson(e))
                .toList();
          }
          return <NotificationModel>[];
        },
      );

      final liveList = result.dataOrNull ?? [];

      // Apply read status to live notifications
      final mapped = liveList.map((n) {
        if (_readNotificationIds.contains(n.id)) {
          return NotificationModel(
            id: n.id,
            recipientPhone: n.recipientPhone,
            title: n.title,
            message: n.message,
            notificationType: n.notificationType,
            priority: n.priority,
            channel: n.channel,
            status: 'READ',
            sentAt: n.sentAt,
            isRead: true,
          );
        }
        return n;
      }).toList();

      return ApiSuccess(data: mapped);
    } catch (_) {
      return const ApiSuccess(data: []);
    }
  }

  Future<ApiResult<bool>> markAsRead(String id) async {
    _readNotificationIds.add(id);
    try {
      await _apiClient.put<dynamic>(
        ApiEndpoints.notificationMarkRead(id),
        requiresAuth: true,
      );
      return const ApiSuccess(data: true);
    } catch (_) {
      return const ApiSuccess(data: true);
    }
  }

  Future<void> markAllAsRead(List<NotificationModel> list) async {
    for (final item in list) {
      _readNotificationIds.add(item.id);
    }
  }
}

