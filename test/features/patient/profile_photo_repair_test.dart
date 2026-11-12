import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:careid_patient_app/core/config/app_config.dart';
import 'package:careid_patient_app/core/constants/api_endpoints.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/patient/data/repositories/patient_repository.dart';
import 'package:careid_patient_app/shared/widgets/careid_avatar.dart';

void main() {
  group('Patient Profile Photo Multipart & API Repair Tests', () {
    late TokenStorage fakeStorage;

    setUp(() {
      fakeStorage = InMemoryTokenStorage();
      fakeStorage.saveTokens(
        accessToken: 'valid-test-access-token-xyz',
        refreshToken: 'valid-test-refresh-token-xyz',
      );
    });

    test('uploadProfilePhotoFile sends multipart POST with field name "file" and receives relative photoUrl', () async {
      String? capturedPath;
      String? capturedAuthHeader;
      String? capturedContentType;
      String? capturedBodyString;
      int capturedByteLength = 0;

      final mockClient = MockClient.streaming((request, stream) async {
        capturedPath = request.url.path;
        capturedAuthHeader = request.headers['Authorization'];
        capturedContentType = request.headers['content-type'];

        final bodyBytes = await stream.toBytes();
        capturedByteLength = bodyBytes.length;
        capturedBodyString = utf8.decode(bodyBytes, allowMalformed: true);

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'statusCode': 200,
            'message': 'Operation executed successfully',
            'data': {
              'photoUrl': '/api/v1/patients/me/photo/file/patient-test-12345.png',
              'message': 'Profile photo updated successfully',
            },
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        tokenStorage: fakeStorage,
        baseUrl: AppConfig.apiBaseUrl,
      );

      final repo = PatientRepository(
        apiClient: apiClient,
        tokenStorage: fakeStorage,
      );

      final dummyBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      final result = await repo.uploadProfilePhotoFile(
        bytes: dummyBytes,
        fileName: 'profile_test.png',
      );

      expect(result.isSuccess, isTrue);
      expect(capturedPath, equals(ApiEndpoints.patientPhoto));
      expect(capturedAuthHeader, equals('Bearer valid-test-access-token-xyz'));
      expect(capturedContentType, contains('multipart/form-data'));
      expect(capturedBodyString, contains('name="file"'));
      expect(capturedBodyString, contains('filename="profile_test.png"'));
      expect(capturedByteLength, greaterThan(8));
      expect(result.dataOrNull?['photoUrl'], equals('/api/v1/patients/me/photo/file/patient-test-12345.png'));
    });

    test('uploadProfilePhotoFile handles backend 400 rejection gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'statusCode': 400,
            'error': 'BadRequestException',
            'message': 'Only image files (jpg, jpeg, png, webp) are allowed',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        tokenStorage: fakeStorage,
        baseUrl: AppConfig.apiBaseUrl,
      );

      final repo = PatientRepository(
        apiClient: apiClient,
        tokenStorage: fakeStorage,
      );

      final result = await repo.uploadProfilePhotoFile(
        bytes: [1, 2, 3],
        fileName: 'document.pdf',
      );

      expect(result.isSuccess, isFalse);
      expect(result.messageOrNull, contains('Only image files'));
    });

    test('deleteProfilePhoto sends DELETE request with Bearer token', () async {
      String? capturedMethod;
      String? capturedPath;
      String? capturedAuthHeader;

      final mockClient = MockClient((request) async {
        capturedMethod = request.method;
        capturedPath = request.url.path;
        capturedAuthHeader = request.headers['Authorization'];

        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'message': 'Profile photo removed successfully',
            'data': null,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        tokenStorage: fakeStorage,
        baseUrl: AppConfig.apiBaseUrl,
      );

      final repo = PatientRepository(
        apiClient: apiClient,
        tokenStorage: fakeStorage,
      );

      final result = await repo.deleteProfilePhoto();

      expect(result.isSuccess, isTrue);
      expect(capturedMethod, equals('DELETE'));
      expect(capturedPath, equals(ApiEndpoints.patientPhoto));
      expect(capturedAuthHeader, equals('Bearer valid-test-access-token-xyz'));
    });
  });

  group('CareIdAvatar Widget Tests', () {
    testWidgets('renders initials fallback when photoUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CareIdAvatar(
              photoUrl: null,
              name: 'John Doe',
              size: 96,
              fallbackAsset: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('renders initials fallback when photoUrl is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CareIdAvatar(
              photoUrl: '   ',
              name: 'Sarah Jenkins',
              size: 105,
              fallbackAsset: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('SJ'), findsOneWidget);
    });

    testWidgets('widget accepts tokenStorage and handles relative URL resolution', (tester) async {
      final fakeStorage = InMemoryTokenStorage();
      await fakeStorage.saveTokens(
        accessToken: 'secure-token-123',
        refreshToken: 'refresh-token-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CareIdAvatar(
              photoUrl: '/api/v1/patients/me/photo/file/patient-avatar.png',
              size: 96,
              name: 'Alice Cooper',
              tokenStorage: fakeStorage,
              cacheBuster: '1794464557642',
            ),
          ),
        ),
      );

      // Verify the widget mounts cleanly without throwing URI or layout exceptions
      expect(tester.takeException(), isNull);
    });
  });
}
