/// Support Tickets & Helpdesk Models
/// Grounded strictly in the CareID Postman Collection (Folder 25. Support Tickets & Helpdesk)

class SupportReplyModel {
  final String id;
  final String ticketId;
  final String? authorId;
  final String? authorName;
  final String? authorRole;
  final String message;
  final String? createdAt;

  const SupportReplyModel({
    required this.id,
    required this.ticketId,
    this.authorId,
    this.authorName,
    this.authorRole,
    required this.message,
    this.createdAt,
  });

  factory SupportReplyModel.fromJson(Map<String, dynamic> json) {
    return SupportReplyModel(
      id: json['id']?.toString() ?? '',
      ticketId: json['ticketId']?.toString() ?? '',
      authorId: json['authorId']?.toString(),
      authorName: json['authorName']?.toString() ?? 'Support Agent',
      authorRole: json['authorRole']?.toString() ?? 'SUPPORT',
      message: json['message']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (authorId != null) 'authorId': authorId,
    };
  }
}

class SupportTicketModel {
  final String id;
  final String? patientId;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String? assignedTo;
  final String? createdAt;
  final String? updatedAt;
  final List<SupportReplyModel> replies;

  const SupportTicketModel({
    required this.id,
    this.patientId,
    required this.subject,
    required this.description,
    this.category = 'TECHNICAL',
    this.priority = 'MEDIUM',
    this.status = 'OPEN',
    this.assignedTo,
    this.createdAt,
    this.updatedAt,
    this.replies = const [],
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'];
    List<SupportReplyModel> replyList = [];
    if (rawReplies is List) {
      replyList = rawReplies
          .whereType<Map<String, dynamic>>()
          .map((r) => SupportReplyModel.fromJson(r))
          .toList();
    }

    return SupportTicketModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString(),
      subject: json['subject']?.toString() ?? 'Support Request',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'TECHNICAL',
      priority: json['priority']?.toString() ?? 'MEDIUM',
      status: json['status']?.toString() ?? 'OPEN',
      assignedTo: json['assignedTo']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      replies: replyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
    };
  }
}

