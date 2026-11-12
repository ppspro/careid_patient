import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/patient/data/models/digital_health_card_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/digital_health_card_repository.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/health_card_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/qr_dashboard_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/qr_preview_screen.dart';

class MockUniversalQrApiClient extends ApiClient {
  MockUniversalQrApiClient() : super(tokenStorage: InMemoryTokenStorage());

  @override
  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic json)? fromJson,
  }) async {
    if (endpoint == '/api/v1/qr') {
      final json = [
        {
          'id': 'qr-uuid-001',
          'token': 'HVQR-9596203EE8FF1D57',
          'entityId': 'HC-CAREID-2026-0004',
          'entityType': 'HEALTH_CARD',
          'ownerId': '787e5187-7859-4320-bb1a-465a57dd086a',
          'status': 'ACTIVE',
          'issuedAt': '2026-11-05T08:14:59.725Z',
          'expiresAt': '2027-11-05T08:14:59.723Z',
        }
      ];
      return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
    }

    if (endpoint == '/api/v1/health-cards') {
      final json = {
        'id': 'card-uuid-001',
        'cardNumber': 'HC-CAREID-2026-0004',
        'status': 'ACTIVE',
        'issuedAt': '2026-10-28T07:40:44.438Z',
        'expiresAt': '2030-12-31T00:00:00.000Z',
      };
      return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
    }

    if (endpoint == '/api/v1/patients/me') {
      final json = {
        'id': '787e5187-7859-4320-bb1a-465a57dd086a',
        'firstName': 'Marcus',
        'lastName': 'Doe',
        'patientNumber': 'PT-1004',
        'dateOfBirth': '1988-06-14',
        'bloodGroup': 'O+',
        'allergies': ['Penicillin'],
      };
      return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
    }

    if (endpoint == '/api/v1/insurance/policies') {
      return ApiSuccess(data: fromJson != null ? fromJson(<dynamic>[]) : <dynamic>[] as T);
    }

    return const ApiFailure(message: 'Not found', statusCode: 404);
  }

  @override
  Future<ApiResult<T>> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic json)? fromJson,
  }) async {
    if (endpoint == '/api/v1/health-cards/verify-qr') {
      final payload = (body as Map?)?['qrPayload']?.toString() ?? '';
      if (payload.contains('HC-CAREID-2026-0004') || payload.contains('HV360-')) {
        final json = {
          'isValid': true,
          'status': 'VERIFIED',
          'cardNumber': 'HC-CAREID-2026-0004',
          'patientDetails': {
            'patientNumber': 'PT-1004',
            'firstName': 'Marcus',
            'lastName': 'Doe',
            'dateOfBirth': '1988-06-14',
            'bloodGroup': 'O+',
          },
        };
        return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
      }
      return const ApiFailure(message: 'Invalid card number', statusCode: 404);
    }

    if (endpoint == '/api/v1/qr/verify') {
      final token = (body as Map?)?['token']?.toString() ?? '';
      if (token == 'HVQR-9596203EE8FF1D57') {
        final json = {
          'isValid': true,
          'status': 'VALID',
          'entityType': 'HEALTH_CARD',
          'entityId': 'HC-CAREID-2026-0004',
          'ownerId': '787e5187-7859-4320-bb1a-465a57dd086a',
        };
        return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
      }
      return const ApiFailure(message: 'Invalid or non-existing QR token', statusCode: 404);
    }

    if (endpoint == '/api/v1/qr') {
      final json = {
        'id': 'qr-uuid-002',
        'token': 'HVQR-A1B2C3D4E5F67890',
        'entityId': 'HC-CAREID-2026-0004',
        'entityType': 'HEALTH_CARD',
        'ownerId': '787e5187-7859-4320-bb1a-465a57dd086a',
        'status': 'ACTIVE',
      };
      return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
    }

    if (endpoint.contains('/rotate')) {
      final json = {
        'id': 'qr-uuid-001',
        'token': 'HVQR-ROTATED-999999',
        'entityId': 'HC-CAREID-2026-0004',
        'entityType': 'HEALTH_CARD',
        'ownerId': '787e5187-7859-4320-bb1a-465a57dd086a',
        'status': 'ACTIVE',
      };
      return ApiSuccess(data: fromJson != null ? fromJson(json) : json as T);
    }

    return const ApiFailure(message: 'Not found', statusCode: 404);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Universal Canonical QR Contract — Payload Models & Serializer Tests', () {
    test('UniversalCardQrPayload serializes canonical json contract accurately', () {
      const payload = UniversalCardQrPayload(
        version: '1.0',
        type: 'CAREID_HEALTH_CARD',
        token: 'HVQR-9596203EE8FF1D57',
        cardNumber: 'HC-CAREID-2026-0004',
        patientId: '787e5187-7859-4320-bb1a-465a57dd086a',
        issuedAt: '2026-11-05T08:14:59.725Z',
        expiresAt: '2027-11-05T08:14:59.723Z',
      );

      final map = payload.toJson();
      expect(map['v'], equals('1.0'));
      expect(map['type'], equals('CAREID_HEALTH_CARD'));
      expect(map['token'], equals('HVQR-9596203EE8FF1D57'));
      expect(map['cardNumber'], equals('HC-CAREID-2026-0004'));
      expect(map['patientId'], equals('787e5187-7859-4320-bb1a-465a57dd086a'));

      // Validate JSON round-trip
      final encoded = jsonEncode(map);
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      expect(decoded['token'], equals('HVQR-9596203EE8FF1D57'));
    });

    test('EnterpriseQrDto parses live backend response format', () {
      final json = {
        'id': 'bc494668-6b72-494f-bfe1-91fbf13aa27c',
        'token': 'HVQR-9596203EE8FF1D57',
        'entityId': 'entity-uuid-12345',
        'entityType': 'HEALTH_CARD',
        'ownerId': '787e5187-7859-4320-bb1a-465a57dd086a',
        'status': 'ACTIVE',
        'signature': '7fa8771d72546d239a84f60abcb9c2ce076ef320138ec8616f66d677063bfcdf',
      };

      final dto = EnterpriseQrDto.fromJson(json);
      expect(dto.id, equals('bc494668-6b72-494f-bfe1-91fbf13aa27c'));
      expect(dto.token, equals('HVQR-9596203EE8FF1D57'));
      expect(dto.entityType, equals('HEALTH_CARD'));
      expect(dto.status, equals('ACTIVE'));
    });
  });

  group('Universal Health Card Repository — Dual Verification & Rotation Tests', () {
    late DigitalHealthCardRepository repo;
    late MockUniversalQrApiClient mockClient;

    setUp(() async {
      mockClient = MockUniversalQrApiClient();
      await mockClient.tokenStorage!.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );
      repo = DigitalHealthCardRepository(apiClient: mockClient);
    });

    test('getOrGenerateCardQrToken finds existing active token', () async {
      final res = await repo.getOrGenerateCardQrToken(
        cardId: 'card-uuid-001',
        cardNumber: 'HC-CAREID-2026-0004',
      );

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.token, equals('HVQR-9596203EE8FF1D57'));
    });

    test('rotateCardQrToken successfully rotates active token', () async {
      final res = await repo.rotateCardQrToken(qrId: 'qr-uuid-001');

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.token, equals('HVQR-ROTATED-999999'));
    });

    test('verifyQrPayload dual-verifies via Enterprise QR Token (HVQR-...)', () async {
      final res = await repo.verifyQrPayload('HVQR-9596203EE8FF1D57');

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.isValid, isTrue);
      expect(res.dataOrNull?.cardNumber, equals('HC-CAREID-2026-0004'));
    });

    test('verifyQrPayload dual-verifies via Card Number (HC-CAREID-...)', () async {
      final res = await repo.verifyQrPayload('HC-CAREID-2026-0004');

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.isValid, isTrue);
      expect(res.dataOrNull?.firstName, equals('Marcus'));
    });

    test('verifyQrPayload dual-verifies canonical JSON payload', () async {
      final canonicalPayload = jsonEncode({
        'v': '1.0',
        'type': 'CAREID_HEALTH_CARD',
        'token': 'HVQR-9596203EE8FF1D57',
        'cardNumber': 'HC-CAREID-2026-0004',
      });

      final res = await repo.verifyQrPayload(canonicalPayload);

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.isValid, isTrue);
    });
  });

  group('HealthCardScreen — Real Scannable QrImageView Widget Tests', () {
    late MockUniversalQrApiClient mockClient;

    setUp(() async {
      mockClient = MockUniversalQrApiClient();
      await mockClient.tokenStorage!.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );
    });

    testWidgets('HealthCardScreen renders real QrImageView instead of static icon', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: HealthCardScreen(apiClient: mockClient),
        ),
      );
      await tester.pumpAndSettle();

      // QrImageView must be present in the widget tree
      expect(find.byType(QrImageView), findsAtLeastNWidgets(1));

      // Tapping the QR box opens the enlarged scannable modal dialog
      await tester.tap(find.byType(QrImageView).first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('CareID Health QR'), findsOneWidget);
      expect(find.text('Refresh QR Token'), findsOneWidget);

      // Two QrImageView instances now exist (one on card, one in modal dialog)
      expect(find.byType(QrImageView), findsNWidgets(2));
    });
  });

  group('QrPreviewScreen & QrDashboardScreen — High Contrast Scannability Tests', () {
    late MockUniversalQrApiClient mockClient;

    setUp(() async {
      mockClient = MockUniversalQrApiClient();
      await mockClient.tokenStorage!.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );
    });

    testWidgets('QrPreviewScreen renders real QrImageView encoding active token', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QrPreviewScreen(
            qrToken: 'HVQR-9596203EE8FF1D57',
            careId: 'CID-9928',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('QrDashboardScreen renders real purple QrImageView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QrDashboardScreen(apiClient: mockClient),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
    });
  });
}
