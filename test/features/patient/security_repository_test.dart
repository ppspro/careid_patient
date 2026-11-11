import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/patient/data/models/security_session_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/security_repository.dart';

void main() {
  group('SecurityRepository & UserSessionDto Unit Tests', () {
    test('UserSessionDto parses JSON correctly and derives device labels', () {
      final json = {
        'id': 'sess-123',
        'ipAddress': '192.168.1.50',
        'userAgent': 'Mozilla/5.0 (Linux; Android 10; Redmi 8A)',
        'createdAt': '2026-10-31T12:00:00.000Z',
      };

      final dto = UserSessionDto.fromJson(json, currentSessionId: 'sess-123');

      expect(dto.id, equals('sess-123'));
      expect(dto.ipAddress, equals('192.168.1.50'));
      expect(dto.deviceLabel, equals('Android Device'));
      expect(dto.isCurrent, isTrue);
      expect(dto.timeFormatted, isNotEmpty);
    });

    test('UserSessionDto handles unknown user agents gracefully', () {
      final json = {
        'id': 'sess-456',
        'ipAddress': '10.0.0.1',
        'userAgent': 'Unknown-Agent/1.0',
      };

      final dto = UserSessionDto.fromJson(json);

      expect(dto.id, equals('sess-456'));
      expect(dto.deviceLabel, equals('Secure Web / App Client'));
      expect(dto.isCurrent, isFalse);
    });

    test('ConsentAuditItemDto parses consent history JSON correctly', () {
      final json = {
        'id': 'audit-001',
        'action': 'RECORD_ACCESSED',
        'performedBy': 'Dr. Julian Vance, MD',
        'target': 'Comprehensive Medical Summary',
        'createdAt': '2026-10-31T10:30:00.000Z',
        'status': 'AUTHORIZED',
      };

      final dto = ConsentAuditItemDto.fromJson(json);

      expect(dto.id, equals('audit-001'));
      expect(dto.performedBy, equals('Dr. Julian Vance, MD'));
      expect(dto.status, equals('AUTHORIZED'));
      expect(dto.target, equals('Comprehensive Medical Summary'));
    });

    test('SecurityRepository returns ApiFailure when unauthenticated', () async {
      final storage = InMemoryTokenStorage();
      final client = ApiClient(baseUrl: 'https://test.local', tokenStorage: storage);
      final repo = SecurityRepository(apiClient: client, tokenStorage: storage);

      final result = await repo.getActiveSessions();

      expect(result.isFailure, isTrue);
      expect((result as ApiFailure).statusCode, equals(401));
    });
  });
}

