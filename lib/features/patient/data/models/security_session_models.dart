/// Model representing an active authenticated user session from `GET /api/v1/auth/sessions`
class UserSessionDto {
  final String id;
  final String ipAddress;
  final String userAgent;
  final DateTime? createdAt;
  final bool isCurrent;

  const UserSessionDto({
    required this.id,
    required this.ipAddress,
    required this.userAgent,
    this.createdAt,
    this.isCurrent = false,
  });

  factory UserSessionDto.fromJson(Map<String, dynamic> json, {String? currentSessionId}) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    final id = json['id']?.toString() ?? '';
    return UserSessionDto(
      id: id,
      ipAddress: json['ipAddress']?.toString() ?? 'Unknown IP',
      userAgent: json['userAgent']?.toString() ?? 'Mobile Client',
      createdAt: parsedDate,
      isCurrent: currentSessionId != null && id == currentSessionId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  /// Derive user-friendly device/client label
  String get deviceLabel {
    final ua = userAgent.toLowerCase();
    if (ua.contains('android')) return 'Android Device';
    if (ua.contains('iphone') || ua.contains('ipad')) return 'iOS Device';
    if (ua.contains('macintosh') || ua.contains('mac os')) return 'macOS Workstation';
    if (ua.contains('windows')) return 'Windows PC';
    if (ua.contains('linux')) return 'Linux System';
    if (ua.contains('postman')) return 'Postman API Client';
    if (ua.contains('python')) return 'CareID Automated Service';
    return 'Secure Web / App Client';
  }

  String get timeFormatted {
    if (createdAt == null) return 'Active now';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${createdAt!.month}/${createdAt!.day}/${createdAt!.year}';
  }
}

/// Model representing a clinical access or consent audit log event
class ConsentAuditItemDto {
  final String id;
  final String action;
  final String performedBy;
  final String target;
  final DateTime? timestamp;
  final String status;

  const ConsentAuditItemDto({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.target,
    this.timestamp,
    required this.status,
  });

  factory ConsentAuditItemDto.fromJson(Map<String, dynamic> json) {
    DateTime? parsed;
    if (json['createdAt'] != null || json['timestamp'] != null) {
      try {
        parsed = DateTime.parse((json['createdAt'] ?? json['timestamp']).toString());
      } catch (_) {}
    }

    return ConsentAuditItemDto(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? 'RECORD_ACCESSED',
      performedBy: json['performedBy']?.toString() ?? json['inviteeName']?.toString() ?? 'Authorized Clinician',
      target: json['target']?.toString() ?? 'Medical Summary',
      timestamp: parsed,
      status: json['status']?.toString() ?? 'SUCCESS',
    );
  }
}

