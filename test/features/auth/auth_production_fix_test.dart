import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/auth/data/repositories/auth_repository.dart';
import 'package:careid_patient_app/features/auth/presentation/screens/login_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/patient_main_navigation_shell.dart';

class MockHttpClientWithCounter extends http.BaseClient {
  int verifyCalls = 0;
  final bool simulateFirst401;

  MockHttpClientWithCounter({this.simulateFirst401 = false});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url.toString();

    if (uri.contains('/auth/otp/request')) {
      final body = jsonEncode({
        'success': true,
        'statusCode': 200,
        'message': 'Operation executed successfully',
        'data': {
          'challengeId': 'test-challenge-uuid-1234',
          'message': 'OTP sent successfully',
        },
      });
      return http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (uri.contains('/auth/otp/verify')) {
      verifyCalls++;
      if (simulateFirst401 && verifyCalls == 1) {
        final body = jsonEncode({
          'success': false,
          'statusCode': 401,
          'error': 'UnauthorizedException',
          'message': 'Invalid OTP code',
        });
        return http.StreamedResponse(
          Stream.value(utf8.encode(body)),
          401,
          headers: {'content-type': 'application/json'},
        );
      }

      final body = jsonEncode({
        'success': true,
        'statusCode': 200,
        'message': 'Operation executed successfully',
        'data': {
          'accessToken': 'jwt_access_token_123',
          'refreshToken': 'jwt_refresh_token_456',
          'expiresIn': '15m',
        },
      });
      return http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (uri.contains('/patients/me')) {
      final body = jsonEncode({
        'success': true,
        'statusCode': 200,
        'data': {
          'id': 'patient-uuid',
          'firstName': 'Sarah',
          'lastName': 'Jenkins',
          'phone': '+16505550004',
          'patientNumber': 'CID-8472-9102-4821',
          'bloodGroup': 'O+',
          'status': 'ACTIVE',
        },
      });
      return http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    return http.StreamedResponse(Stream.value([]), 404);
  }
}

void main() {
  group('CareID Authentication Investigation & Production Fix Verification', () {
    test('AppTokenStorage handles in-memory and persistent token lifecycle',
        () async {
      final storage = InMemoryTokenStorage();
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);

      await storage.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );
      expect(await storage.getAccessToken(), equals('access_123'));
      expect(await storage.getRefreshToken(), equals('refresh_456'));

      await storage.clear();
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });

    testWidgets(
        'First OTP 401 displays clear error banner, clears cells, and second OTP 200 succeeds',
        (tester) async {
      final mockHttp = MockHttpClientWithCounter(simulateFirst401: true);
      final tokenStorage = InMemoryTokenStorage();
      final apiClient = ApiClient(
        httpClient: mockHttp,
        tokenStorage: tokenStorage,
      );
      final authRepo = AuthRepository(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            apiClient: apiClient,
            authRepository: authRepo,
          ),
        ),
      );

      // 1. Enter phone and dispatch OTP
      await tester.enterText(find.byType(TextFormField), '6505550004');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();

      expect(find.text('Enter 6-Digit Code'), findsOneWidget);

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));

      // 2. First verification: type 6 digits (triggers first verify, mocked to return 401)
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
      }
      await tester.pumpAndSettle();

      expect(mockHttp.verifyCalls, equals(1));
      expect(find.textContaining('Invalid verification code'), findsOneWidget);

      // Cells are cleared after 401
      for (int i = 0; i < 6; i++) {
        final field = tester.widget<TextField>(textFields.at(i));
        expect(field.controller?.text ?? '', isEmpty);
      }

      // 3. Second verification: re-enter 6 digits (mocked to return 200)
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
      }
      await tester.pumpAndSettle();

      expect(mockHttp.verifyCalls, equals(2));
      // Authenticated session established
      expect(await tokenStorage.getAccessToken(), equals('jwt_access_token_123'));
      expect(find.byType(PatientMainNavigationShell), findsOneWidget);
    });

    testWidgets('Entering fewer than 6 digits does NOT trigger verifyOtp',
        (tester) async {
      final mockHttp = MockHttpClientWithCounter();
      final apiClient = ApiClient(httpClient: mockHttp);
      final authRepo = AuthRepository(apiClient: apiClient);

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            apiClient: apiClient,
            authRepository: authRepo,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '6505550004');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      // Enter only 5 digits
      for (int i = 0; i < 5; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
      }
      await tester.pump();

      expect(mockHttp.verifyCalls, equals(0));
    });
  });
}
