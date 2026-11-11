import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/auth/data/models/otp_models.dart';
import 'package:careid_patient_app/features/auth/data/repositories/auth_repository.dart';
import 'package:careid_patient_app/features/auth/presentation/screens/login_screen.dart';
import 'package:careid_patient_app/features/patient/data/models/patient_profile_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/patient_repository.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/patient_main_navigation_shell.dart';

class MockPatientRepository extends PatientRepository {
  @override
  Future<ApiResult<PatientProfileDto>> getPatientProfile() async {
    return const ApiSuccess(
      data: PatientProfileDto(
        id: 'mock-id',
        firstName: 'John',
        lastName: 'Doe',
        bloodGroup: 'O+',
      ),
    );
  }
}

class MockAuthRepository extends AuthRepository {
  ApiResult<RequestOtpResponseDto>? requestOtpResult;
  ApiResult<VerifyOtpResponseDto>? verifyOtpResult;
  ApiResult<ResendOtpResponseDto>? resendOtpResult;

  String? lastRequestedPhone;
  String? lastVerifiedChallengeId;
  String? lastVerifiedCode;

  MockAuthRepository({TokenStorage? tokenStorage})
      : super(tokenStorage: tokenStorage ?? InMemoryTokenStorage());

  @override
  Future<ApiResult<RequestOtpResponseDto>> requestOtp(String phone) async {
    lastRequestedPhone = phone;
    return requestOtpResult ??
        const ApiSuccess(
          data: RequestOtpResponseDto(
            challengeId: 'test-challenge-1234',
            message: 'Verification code sent',
          ),
        );
  }

  @override
  Future<ApiResult<VerifyOtpResponseDto>> verifyOtp({
    required String challengeId,
    required String otpCode,
  }) async {
    lastVerifiedChallengeId = challengeId;
    lastVerifiedCode = otpCode;
    final res = verifyOtpResult ??
        const ApiSuccess(
          data: VerifyOtpResponseDto(
            accessToken: 'mock-jwt-access-token',
            refreshToken: 'mock-jwt-refresh-token',
          ),
        );
    if (res.isSuccess) {
      await tokenStorage.saveTokens(
        accessToken: res.dataOrNull!.accessToken,
        refreshToken: res.dataOrNull!.refreshToken,
      );
    }
    return res;
  }
}

void main() {
  group('LoginScreen Widget & Integration Tests (Figma 20:24965)', () {
    testWidgets('renders phone input and send code button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(language: 'en'),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('shows validation error when entering short phone number', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(language: 'en'),
        ),
      );

      // Enter short phone
      await tester.enterText(find.byType(TextFormField), '12345');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pump();

      expect(find.text('Please enter a valid 10-digit mobile number.'), findsOneWidget);
    });

    testWidgets('language toggle updates strings to Spanish', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(language: 'es'),
        ),
      );

      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
      expect(find.text('Número de Teléfono'), findsOneWidget);
      expect(find.text('Enviar Código'), findsOneWidget);
    });

    testWidgets('submitting phone requests OTP and switches to 6-digit OTP view', (tester) async {
      final mockAuth = MockAuthRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            authRepository: mockAuth,
            patientRepository: MockPatientRepository(),
            language: 'en',
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '6505550004');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(mockAuth.lastRequestedPhone, equals('+16505550004'));
      expect(find.text('Enter 6-Digit Code'), findsOneWidget);
      expect(find.text('Verify & Sign In'), findsOneWidget);
      expect(find.text('Paste Code'), findsOneWidget);
      expect(find.text('Change Phone'), findsOneWidget);
    });

    testWidgets('handles rate limiting (429) gracefully on OTP request', (tester) async {
      final mockAuth = MockAuthRepository()
        ..requestOtpResult = const ApiFailure(
          message: 'Too many requests',
          statusCode: 429,
        );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            authRepository: mockAuth,
            patientRepository: MockPatientRepository(),
            language: 'en',
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '6505550004');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.textContaining('Too many login attempts'), findsOneWidget);
      expect(find.text('Enter 6-Digit Code'), findsNothing);
    });

    testWidgets('entering 6-digit OTP code triggers verifyOtp and navigates to Home', (tester) async {
      final tokenStorage = InMemoryTokenStorage();
      final mockAuth = MockAuthRepository(tokenStorage: tokenStorage);

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            authRepository: mockAuth,
            patientRepository: MockPatientRepository(),
            language: 'en',
          ),
        ),
      );

      // 1. Enter Phone
      await tester.enterText(find.byType(TextFormField), '6505550004');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();

      // 2. Enter 6 digits
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));

      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(mockAuth.lastVerifiedCode, equals('123456'));
      expect(mockAuth.lastVerifiedChallengeId, equals('test-challenge-1234'));

      // Check token storage saved token
      final token = await tokenStorage.getAccessToken();
      expect(token, equals('mock-jwt-access-token'));

      // Check navigation to patient main shell
      expect(find.byType(PatientMainNavigationShell), findsOneWidget);
    });

    testWidgets('invalid OTP (401) displays error banner and clears fields', (tester) async {
      final mockAuth = MockAuthRepository()
        ..verifyOtpResult = const ApiFailure(
          message: 'Invalid verification code',
          statusCode: 401,
        );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            authRepository: mockAuth,
            patientRepository: MockPatientRepository(),
            language: 'en',
          ),
        ),
      );

      // Enter phone
      await tester.enterText(find.byType(TextFormField), '6505550004');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();

      // Enter invalid OTP
      final textFields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '0');
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(mockAuth.lastVerifiedCode, equals('000000'));
      expect(find.text('Invalid verification code. Please check the code and try again.'), findsOneWidget);
      expect(find.byType(PatientMainNavigationShell), findsNothing);
    });

    testWidgets('country picker opens bottom sheet and updates country code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(language: 'en'),
        ),
      );

      // Tap country code selector
      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();

      expect(find.text('Select Country Code'), findsOneWidget);
      expect(find.text('India'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);

      // Select India
      await tester.tap(find.text('India'));
      await tester.pumpAndSettle();

      expect(find.text('+91'), findsOneWidget);
    });
  });
}
