import 'package:test/test.dart';

import '../../lib/core/config/app_config.dart';
import '../../lib/core/network/api_client.dart';

void main() {
  group('Live CareID Backend Integration Test', () {
    test('verifies live connectivity to GET /api/v1/health', () async {
      final client = ApiClient(baseUrl: AppConfig.apiBaseUrl);

      final result = await client.checkHealth();

      expect(
        result.isSuccess,
        isTrue,
        reason: 'Expected successful health check from ${AppConfig.apiBaseUrl}',
      );

      result.when(
        success: (data, message) {
          expect(data, isNotNull);
          expect(data['status'], equals('ok'));
          expect(data['service'], equals('HVAPI Backend'));
        },
        failure: (message, statusCode, error) {
          fail('Health probe failed: $message (code: $statusCode)');
        },
      );

      client.close();
    });
  });
}
