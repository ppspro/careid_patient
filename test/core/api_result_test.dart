import 'package:test/test.dart';

import 'package:careid_patient_app/core/network/api_result.dart';

void main() {
  group('ApiResult Pattern Matching and State', () {
    test('ApiSuccess provides data and matches success handler', () {
      const result = ApiSuccess<String>(
        data: 'patient-data',
        message: 'Loaded successfully',
        statusCode: 200,
      );

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals('patient-data'));

      final value = result.when(
        success: (data, message) => 'SUCCESS: $data, $message',
        failure: (message, statusCode, error) => 'FAILURE',
      );

      expect(value, equals('SUCCESS: patient-data, Loaded successfully'));
    });

    test('ApiFailure captures error and matches failure handler', () {
      const result = ApiFailure<String>(
        message: 'Invalid phone format',
        statusCode: 422,
      );

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);

      final value = result.when(
        success: (data, message) => 'SUCCESS',
        failure: (message, statusCode, error) => 'ERR: $message ($statusCode)',
      );

      expect(value, equals('ERR: Invalid phone format (422)'));
    });
  });
}
