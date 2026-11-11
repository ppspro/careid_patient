import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../models/faq_models.dart';

/// CareID CMS FAQ Repository
/// Grounded in Postman folder `15. CMS Content Management`
class FaqRepository {
  final ApiClient _apiClient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FaqRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Retrieves list of published FAQs, optionally filtered by category
  /// GET /api/v1/cms/faqs
  Future<ApiResult<List<FaqItemDto>>> getFaqs({String? category}) async {
    _isLoading = true;
    try {
      final queryParams = <String, String>{};
      if (category != null && category.trim().isNotEmpty) {
        queryParams['category'] = category.trim();
      }

      return await _apiClient.get<List<FaqItemDto>>(
        ApiEndpoints.cmsFaqs,
        requiresAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (dynamic json) {
          final list = (json is Map<String, dynamic> && json.containsKey('data'))
              ? json['data']
              : json;
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => FaqItemDto.fromJson(e))
                .toList();
          }
          return <FaqItemDto>[];
        },
      );
    } finally {
      _isLoading = false;
    }
  }
}

