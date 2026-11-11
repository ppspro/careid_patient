import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../models/support_ticket_models.dart';

/// Repository for Support Tickets & Helpdesk (Folder 25 in Postman Collection)
class SupportRepository {
  final ApiClient _apiClient;

  SupportRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// POST /api/v1/support/tickets - Create a new support ticket
  Future<ApiResult<SupportTicketModel>> createTicket({
    required String subject,
    required String description,
    String category = 'TECHNICAL',
    String priority = 'MEDIUM',
  }) async {
    final body = {
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
    };

    return _apiClient.post<SupportTicketModel>(
      ApiEndpoints.supportTickets,
      body: body,
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
          return SupportTicketModel.fromJson(data as Map<String, dynamic>);
        }
        throw Exception('Invalid support ticket response structure');
      },
    );
  }

  /// GET /api/v1/support/tickets - List support tickets for current patient
  Future<ApiResult<List<SupportTicketModel>>> getTickets({
    String? status,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (category != null) 'category': category,
    };

    final queryString = Uri(queryParameters: queryParams).query;
    final url = '${ApiEndpoints.supportTickets}?$queryString';

    return _apiClient.get<List<SupportTicketModel>>(
      url,
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map((e) => SupportTicketModel.fromJson(e))
              .toList();
        } else if (json is Map<String, dynamic> && json['data'] is List) {
          return (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => SupportTicketModel.fromJson(e))
              .toList();
        }
        return [];
      },
    );
  }

  /// GET /api/v1/support/tickets/:id - Get support ticket details by ID
  Future<ApiResult<SupportTicketModel>> getTicketById(String id) async {
    return _apiClient.get<SupportTicketModel>(
      ApiEndpoints.supportTicketById(id),
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
          return SupportTicketModel.fromJson(data as Map<String, dynamic>);
        }
        throw Exception('Invalid ticket details response');
      },
    );
  }

  /// POST /api/v1/support/tickets/:id/reply - Add message reply to support ticket
  Future<ApiResult<SupportReplyModel>> replyToTicket(String id, String message) async {
    return _apiClient.post<SupportReplyModel>(
      ApiEndpoints.supportTicketReply(id),
      body: {'message': message},
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
          return SupportReplyModel.fromJson(data as Map<String, dynamic>);
        }
        throw Exception('Invalid reply response structure');
      },
    );
  }

  /// GET /api/v1/support/tickets/:id/replies - Get all replies for a ticket
  Future<ApiResult<List<SupportReplyModel>>> getReplies(String id) async {
    return _apiClient.get<List<SupportReplyModel>>(
      ApiEndpoints.supportTicketReplies(id),
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map((e) => SupportReplyModel.fromJson(e))
              .toList();
        } else if (json is Map<String, dynamic> && json['data'] is List) {
          return (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => SupportReplyModel.fromJson(e))
              .toList();
        }
        return [];
      },
    );
  }
}

