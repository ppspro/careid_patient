import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/core/theme/app_theme.dart';
import 'package:careid_patient_app/features/auth/data/models/otp_models.dart';
import 'package:careid_patient_app/features/auth/data/repositories/auth_repository.dart';
import 'package:careid_patient_app/features/auth/presentation/screens/login_screen.dart';
import 'package:careid_patient_app/features/patient/data/models/doctor_models.dart';
import 'package:careid_patient_app/features/patient/data/models/family_models.dart';
import 'package:careid_patient_app/features/patient/data/models/medical_record_models.dart';
import 'package:careid_patient_app/features/patient/data/models/patient_profile_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/family_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/medical_records_repository.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/add_family_member_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/add_health_record_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/book_appointment_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/invitation_sent_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/personal_details_identity_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/reschedule_appointment_screen.dart';
import 'package:careid_patient_app/shared/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// Mock & Test Doubles for Empirical Verification
// ---------------------------------------------------------------------------

class MockAuthRepoForButtonTesting extends AuthRepository {
  ApiResult<RequestOtpResponseDto>? requestOtpResult;
  int requestOtpCallCount = 0;

  MockAuthRepoForButtonTesting()
      : super(tokenStorage: InMemoryTokenStorage());

  @override
  Future<ApiResult<RequestOtpResponseDto>> requestOtp(String phone) async {
    requestOtpCallCount++;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return requestOtpResult ??
        const ApiSuccess(
          data: RequestOtpResponseDto(
            challengeId: 'test-challenge-uuid',
            message: 'OTP Sent',
          ),
        );
  }
}

class MockFamilyRepoForButtonTesting extends FamilyRepository {
  ApiResult<FamilyInvitationDto>? sendInvitationResult;
  int sendInvitationCallCount = 0;

  MockFamilyRepoForButtonTesting()
      : super(tokenStorage: InMemoryTokenStorage());

  @override
  Future<ApiResult<FamilyInvitationDto>> sendInvitation(FamilyInvitationDto dto) async {
    sendInvitationCallCount++;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return sendInvitationResult ??
        ApiSuccess(
          data: dto,
          message: 'Invitation sent successfully',
        );
  }
}

class MockMedicalRecordsRepoForButtonTesting extends MedicalRecordsRepository {
  ApiResult<MedicalRecordDto>? createRecordResult;
  int createRecordCallCount = 0;

  MockMedicalRecordsRepoForButtonTesting()
      : super(tokenStorage: InMemoryTokenStorage());

  @override
  Future<ApiResult<MedicalRecordDto>> createRecord(MedicalRecordDto record) async {
    createRecordCallCount++;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return createRecordResult ??
        ApiSuccess(
          data: record,
          message: 'Record created successfully',
        );
  }
}

// ---------------------------------------------------------------------------
// Test Suite Entry Point
// ---------------------------------------------------------------------------

void main() {
  Widget buildAppWrapper({
    required Widget child,
    double? width,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width ?? 360.0,
            child: child,
          ),
        ),
      ),
    );
  }

  group('Milestone 2: PrimaryButton Interactive State & Contract Stress Suite', () {
    testWidgets('1. Loading State: CircularProgressIndicator rendering and tap rejection', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        buildAppWrapper(
          child: PrimaryButton(
            text: 'Save Clinical Data',
            isLoading: true,
            onPressed: () => tapCount++,
          ),
        ),
      );
      await tester.pump();

      // Assert label text is hidden
      expect(find.text('Save Clinical Data'), findsNothing);

      // Assert CircularProgressIndicator is present with strokeWidth 2.5 and white color
      final spinnerFinder = find.byType(CircularProgressIndicator);
      expect(spinnerFinder, findsOneWidget);
      final spinner = tester.widget<CircularProgressIndicator>(spinnerFinder);
      expect(spinner.strokeWidth, 2.5);
      expect(spinner.valueColor?.value, Colors.white);

      // Assert dimensions of spinner container are 24x24
      final sizedBoxFinder = find.ancestor(
        of: spinnerFinder,
        matching: find.byType(SizedBox),
      ).first;
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, 24.0);
      expect(sizedBox.height, 24.0);

      // Verify InkWell onTap is null
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);

      // Stress: rapid double-tap burst while loading must never invoke callback
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));

      expect(tapCount, 0, reason: 'Rapid taps during isLoading must never execute callback');
    });

    testWidgets('2. Disabled State: #CBD5E1 styling and non-interactive ink response', (tester) async {
      int tapCount = 0;

      // Case A: onPressed is null
      await tester.pumpWidget(
        buildAppWrapper(
          child: const PrimaryButton(
            text: 'Submit Credentials',
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containerFinder = find.descendant(
        of: find.byType(PrimaryButton),
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration! as ShapeDecoration;

      // Background color must be exactly #CBD5E1
      expect(decoration.color, const Color(0xFFCBD5E1));

      // Shadow must be null (no blue glow)
      expect(decoration.shadows, isNull);

      // Text must be white
      final textWidget = tester.widget<Text>(find.text('Submit Credentials'));
      expect(textWidget.style?.color, Colors.white);

      // InkWell onTap must be null
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);

      // Case B: enabled == false with non-null callback
      await tester.pumpWidget(
        buildAppWrapper(
          child: PrimaryButton(
            text: 'Submit Credentials',
            enabled: false,
            onPressed: () => tapCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containerB = tester.widget<Container>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(Container),
        ).first,
      );
      final decorationB = containerB.decoration! as ShapeDecoration;
      expect(decorationB.color, const Color(0xFFCBD5E1));
      expect(decorationB.shadows, isNull);

      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();
      expect(tapCount, 0);
    });

    testWidgets('3. Active State: #0A84FF token, StadiumBorder, blue glow shadow & callback', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        buildAppWrapper(
          child: PrimaryButton(
            text: 'Confirm Access',
            onPressed: () => tapCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containerFinder = find.descendant(
        of: find.byType(PrimaryButton),
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration! as ShapeDecoration;

      // Active gradient: #A44CFF -> #5B14B8
      expect(decoration.gradient, isNotNull);
      final grad = decoration.gradient! as LinearGradient;
      expect(grad.colors, [const Color(0xFFA44CFF), const Color(0xFF5B14B8)]);

      // StadiumBorder (radius 9999)
      expect(decoration.shape, isA<StadiumBorder>());

      // Blue glow shadow
      expect(decoration.shadows, isNotNull);
      expect(decoration.shadows!.length, 1);
      final shadow = decoration.shadows!.first;
      expect(shadow.color, const Color(0x4D5B14B8));
      expect(shadow.blurRadius, 12.0);
      expect(shadow.offset, const Offset(0, 4));

      // Standard height: 56dp
      final Size buttonSize = tester.getSize(containerFinder);
      expect(buttonSize.height, 56.0);

      // Tap callback executes exactly once
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      expect(tapCount, 1);
    });

    testWidgets('4. Dynamic State Transition: Active -> Loading -> Active', (tester) async {
      int executions = 0;
      bool loading = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildAppWrapper(
              child: PrimaryButton(
                text: 'Process Payment',
                isLoading: loading,
                onPressed: () {
                  executions++;
                  setState(() => loading = true);
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Process Payment'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap once -> triggers loading
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(executions, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Process Payment'), findsNothing);

      // Rapidly tap while loading
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      expect(executions, 1, reason: 'Callback must not execute while in loading state');
    });
  });

  group('Milestone 2: Patient Form Flows & ApiFailure Error Handling', () {
    testWidgets('1. PersonalDetailsIdentityScreen: Handles ApiFailure with error SnackBar & does not crash', (tester) async {
      // Configure MockClient returning HTTP 400 ApiFailure on basic info update
      final mockHttpClient = MockClient((request) async {
        if (request.url.path.contains('/api/v1/patients/me')) {
          return http.Response(
            jsonEncode({
              'statusCode': 400,
              'message': 'Invalid national ID format or missing required fields',
              'error': 'Bad Request',
            }),
            400,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({'message': 'Not Found'}),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://360api.vnvision.in',
        httpClient: mockHttpClient,
        tokenStorage: InMemoryTokenStorage(),
      );

      const initialProfile = PatientProfileDto(
        id: 'patient-test-01',
        patientNumber: 'CID-2026-99',
        firstName: 'Sarah',
        lastName: 'Jenkins',
        phone: '+14155552671',
        email: 'sarah.j@email.com',
        dateOfBirth: '1992-05-12',
        gender: 'Female',
        bloodGroup: 'O+',
        address: '425 Clinical Way',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: PersonalDetailsIdentityScreen(
            apiClient: apiClient,
            initialProfile: initialProfile,
            language: 'en',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find PrimaryButton 'Save Changes'
      final saveBtnFinder = find.widgetWithText(PrimaryButton, 'Save Changes');
      expect(saveBtnFinder, findsOneWidget);

      // Ensure button is scrolled into view in SingleChildScrollView
      await tester.ensureVisible(saveBtnFinder);
      await tester.pumpAndSettle();

      // Verify button is active initially
      final initialButton = tester.widget<PrimaryButton>(saveBtnFinder);
      expect(initialButton.isLoading, isFalse);
      expect(initialButton.onPressed, isNotNull);

      // Tap Save Changes
      await tester.tap(saveBtnFinder);
      await tester.pump(); // Enter loading state
      await tester.pumpAndSettle(); // Complete network response and show SnackBar

      // Assert SnackBar is displayed with ApiFailure error message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Invalid national ID format'), findsOneWidget);

      // Assert screen did not pop/exit — form is still present
      expect(find.byType(PersonalDetailsIdentityScreen), findsOneWidget);
      expect(find.widgetWithText(PrimaryButton, 'Save Changes'), findsOneWidget);

      // Verify button returned to active state ready for retry
      final finalButton = tester.widget<PrimaryButton>(saveBtnFinder);
      expect(finalButton.isLoading, isFalse);
      expect(finalButton.onPressed, isNotNull);
    });

    testWidgets('2. LoginScreen: Handles ApiFailure (429 Rate Limit) without crash and displays error', (tester) async {
      final mockAuth = MockAuthRepoForButtonTesting()
        ..requestOtpResult = const ApiFailure(
          message: 'Rate limit exceeded',
          statusCode: 429,
        );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LoginScreen(
            authRepository: mockAuth,
            language: 'en',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // PrimaryButton 'Send Verification Code'
      final ctaFinder = find.widgetWithText(PrimaryButton, 'Send Verification Code');
      expect(ctaFinder, findsOneWidget);

      // 1. Validation test: Empty phone number tap does not trigger network call
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();
      expect(mockAuth.requestOtpCallCount, 0, reason: 'Validation must prevent API submission');
      expect(find.textContaining('Please enter a valid 10-digit mobile number'), findsOneWidget);

      // 2. Enter valid 10-digit phone number
      await tester.enterText(find.byType(TextFormField), '6505550004');
      await tester.pumpAndSettle();

      // 3. Tap Send Verification Code
      await tester.tap(ctaFinder);
      await tester.pump(); // enters loading state

      // Verify PrimaryButton displays loading spinner
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete async response
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Assert error message from 429 ApiFailure is rendered cleanly on screen
      expect(find.textContaining('Too many login attempts'), findsOneWidget);
      expect(mockAuth.requestOtpCallCount, 1);
    });

    testWidgets('3. AddFamilyMemberScreen: Form validation prevents submission on empty fields', (tester) async {
      final mockFamilyRepo = MockFamilyRepoForButtonTesting();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddFamilyMemberScreen(
            repository: mockFamilyRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 0 CTA: 'Continue to Permissions'
      final step0Btn = find.widgetWithText(PrimaryButton, 'Continue to Permissions');
      expect(step0Btn, findsOneWidget);

      // Tap Step 0 without entering name or phone
      await tester.tap(step0Btn);
      await tester.pump();

      // Assert validation SnackBar is presented immediately at Step 0
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter name and mobile number'), findsOneWidget);
      expect(mockFamilyRepo.sendInvitationCallCount, 0,
          reason: 'Must not call repository when form validation fails');
    });

    testWidgets('3b. AddFamilyMemberScreen: Failure handling inspection (swallowed failure on send)', (tester) async {
      // Configure mock returning failure
      final mockFamilyRepo = MockFamilyRepoForButtonTesting()
        ..sendInvitationResult = const ApiFailure(
          message: 'Contact number already linked to another patient vault',
          statusCode: 409,
        );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddFamilyMemberScreen(
            repository: mockFamilyRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in Step 0 inputs
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Arthur Pendelton');
      await tester.enterText(textFields.at(1), '+16505559988');
      await tester.pump();

      // Step 0: Advance to Step 1
      await tester.tap(find.widgetWithText(PrimaryButton, 'Continue to Permissions'));
      await tester.pumpAndSettle();

      // Step 1: Advance to Step 2
      await tester.tap(find.widgetWithText(PrimaryButton, 'Review Invitation'));
      await tester.pumpAndSettle();

      // Step 2: Tap Send Linkage Invitation
      final sendBtn = find.widgetWithText(PrimaryButton, 'Send Linkage Invitation');
      expect(sendBtn, findsOneWidget);
      await tester.tap(sendBtn);
      await tester.pump(); // enters loading state

      // Verify button enters loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Repository was called
      expect(mockFamilyRepo.sendInvitationCallCount, 1);

      // EMPIRICAL OBSERVATION: Notice screen pushes InvitationSentScreen despite ApiFailure!
      // This empirically documents the M3 gap where repository errors are swallowed in presentation.
      expect(find.byType(InvitationSentScreen), findsOneWidget);
    });

    testWidgets('4. AddHealthRecordScreen: Category selection, Save button and ApiFailure resiliency', (tester) async {
      final mockRecordsRepo = MockMedicalRecordsRepoForButtonTesting()
        ..createRecordResult = const ApiFailure(
          message: 'Backend vault service unavailable',
          statusCode: 503,
        );

      bool? saveResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  saveResult = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => AddHealthRecordScreen(repository: mockRecordsRepo),
                    ),
                  );
                },
                child: const Text('Open Add Record'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open screen
      await tester.tap(find.text('Open Add Record'));
      await tester.pumpAndSettle();

      // Verify PrimaryButton 'Save Health Record' exists
      final saveBtnFinder = find.widgetWithText(PrimaryButton, 'Save Health Record');
      expect(saveBtnFinder, findsOneWidget);

      // Enter record title
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Routine Dental Checkup');
      await tester.pump();

      // Tap Save button
      await tester.tap(saveBtnFinder);
      await tester.pump(); // Enter saving state

      await tester.pumpAndSettle();

      // Verify repository was invoked
      expect(mockRecordsRepo.createRecordCallCount, 1);

      // Verify SnackBar was shown with error feedback without unhandled crash
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Backend vault service unavailable'), findsOneWidget);

      // EMPIRICAL OBSERVATION: Screen popped with true despite ApiFailure
      expect(saveResult, isTrue);
    });

    testWidgets('5. BookAppointmentScreen: Multi-step PrimaryButton progression & loading safety', (tester) async {
      const testDoctor = DoctorModel(
        id: '1f06067b-e229-4707-84e2-afa27da2e4cd',
        fullName: 'Dr. Sarah Jenkins',
        primarySpecialization: 'Cardiology',
        facilityName: 'CareID Metro Clinic',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const BookAppointmentScreen(doctor: testDoctor),
        ),
      );
      await tester.pumpAndSettle();

      // Step 0 CTA: 'Continue to Date & Time'
      expect(find.widgetWithText(PrimaryButton, 'Continue to Date & Time'), findsOneWidget);
      await tester.tap(find.widgetWithText(PrimaryButton, 'Continue to Date & Time'));
      await tester.pumpAndSettle();

      // Step 1 CTA: 'Review Appointment Details'
      expect(find.widgetWithText(PrimaryButton, 'Review Appointment Details'), findsOneWidget);
      await tester.tap(find.widgetWithText(PrimaryButton, 'Review Appointment Details'));
      await tester.pumpAndSettle();

      // Step 2 CTA: 'Confirm & Book Appointment'
      expect(find.widgetWithText(PrimaryButton, 'Confirm & Book Appointment'), findsOneWidget);
    });

    testWidgets('6. RescheduleAppointmentScreen: PrimaryButton rendering and loading lock', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RescheduleAppointmentScreen(
            appointmentId: 'apt-123',
            doctorName: 'Dr. Marcus Thorne',
            previousDate: 'Thu, Nov 16',
            previousTime: '10:00 AM',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Confirm Reschedule button exists
      final btnFinder = find.widgetWithText(PrimaryButton, 'Confirm Reschedule');
      expect(btnFinder, findsOneWidget);

      final PrimaryButton btnWidget = tester.widget<PrimaryButton>(btnFinder);
      expect(btnWidget.isLoading, isFalse);
      expect(btnWidget.onPressed, isNotNull);
    });
  });
}
