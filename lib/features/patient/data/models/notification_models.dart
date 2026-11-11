/// CareID Patient App — Notification Models
/// Grounded in OpenAPI 3.0.0 `/api/v1/notifications` and Figma Node 20:23812

class NotificationModel {
  final String id;
  final String? recipientPhone;
  final String title;
  final String message;
  final String notificationType;
  final String priority;
  final String channel;
  final String status;
  final DateTime sentAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    this.recipientPhone,
    required this.title,
    required this.message,
    this.notificationType = 'PATIENT',
    this.priority = 'NORMAL',
    this.channel = 'IN_APP',
    this.status = 'SENT',
    required this.sentAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final statusStr = json['status']?.toString().toUpperCase() ?? 'SENT';
    final read = statusStr == 'READ' || json['isRead'] == true;

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      recipientPhone: json['recipientPhone']?.toString(),
      title: json['title']?.toString() ?? 'CareID Notification',
      message: json['message']?.toString() ?? '',
      notificationType: json['notificationType']?.toString().toUpperCase() ?? 'PATIENT',
      priority: json['priority']?.toString().toUpperCase() ?? 'NORMAL',
      channel: json['channel']?.toString().toUpperCase() ?? 'IN_APP',
      status: statusStr,
      sentAt: parseDate(json['sentAt'] ?? json['createdAt']),
      isRead: read,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipientPhone': recipientPhone,
    'title': title,
    'message': message,
    'notificationType': notificationType,
    'priority': priority,
    'channel': channel,
    'status': status,
    'sentAt': sentAt.toIso8601String(),
    'isRead': isRead,
  };
}

