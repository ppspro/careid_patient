import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/features/patient/data/repositories/faq_repository.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(baseUrl: 'https://360api.vnvision.in');

  @override
  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    if (endpoint.contains('/cms/faqs')) {
      final category = queryParams?['category'];
      final json = [
        {
          'id': 'faq-001',
          'question': 'How is my medical data encrypted?',
          'answer': 'CareID encrypts all health data using 256-bit AES encryption at rest and TLS 1.3 in transit.',
          'category': 'SECURITY',
          'displayOrder': 1,
          'status': 'PUBLISHED',
        },
        {
          'id': 'faq-002',
          'question': 'Can I share my digital health pass with family members?',
          'answer': 'Yes, use the Family Sharing ecosystem in Profile to grant proxy view permissions.',
          'category': 'FAMILY',
          'displayOrder': 2,
          'status': 'PUBLISHED',
        }
      ];

      final filtered = category != null
          ? json.where((f) => f['category'] == category).toList()
          : json;

      return ApiSuccess(data: fromJson!(filtered));
    }

    return const ApiFailure(message: 'Not found', statusCode: 404);
  }
}

void main() {
  group('FaqRepository & FaqItemDto Tests', () {
    late FaqRepository repository;

    setUp(() {
      repository = FaqRepository(apiClient: _FakeApiClient());
    });

    test('getFaqs parses list of published FAQ items', () async {
      final res = await repository.getFaqs();
      expect(res.isSuccess, isTrue);
      final list = res.dataOrNull!;
      expect(list.length, 2);
      expect(list[0].id, 'faq-001');
      expect(list[0].question, 'How is my medical data encrypted?');
      expect(list[0].category, 'SECURITY');
      expect(list[0].displayOrder, 1);
      expect(list[1].id, 'faq-002');
      expect(list[1].category, 'FAMILY');
    });

    test('getFaqs filters by category when specified', () async {
      final res = await repository.getFaqs(category: 'SECURITY');
      expect(res.isSuccess, isTrue);
      final list = res.dataOrNull!;
      expect(list.length, 1);
      expect(list.first.category, 'SECURITY');
      expect(list.first.id, 'faq-001');
    });
  });
}

