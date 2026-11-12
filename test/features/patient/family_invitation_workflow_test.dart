import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/patient/data/models/family_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/family_repository.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/add_family_member_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/family_members_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/accept_invitation_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/invitation_sent_screen.dart';

class MockFamilyRepository extends FamilyRepository {
  List<FamilyMemberDto> mockMembers = [];
  List<FamilyInvitationDto> mockInvitations = [];

  ApiResult<FamilyInvitationDto>? mockSendResult;
  ApiResult<FamilyInvitationDto>? mockResendResult;
  ApiResult<Map<String, dynamic>>? mockAcceptResult;
  ApiResult<Map<String, dynamic>>? mockCancelResult;
  ApiResult<Map<String, dynamic>>? mockRemoveMemberResult;

  int sendCount = 0;
  int resendCount = 0;
  int acceptCount = 0;
  int cancelCount = 0;
  int removeMemberCount = 0;
  int getMembersCount = 0;
  int getInvitationsCount = 0;

  @override
  Future<ApiResult<List<FamilyMemberDto>>> getMembers() async {
    getMembersCount++;
    return ApiSuccess(data: mockMembers);
  }

  @override
  Future<ApiResult<List<FamilyInvitationDto>>> getInvitations() async {
    getInvitationsCount++;
    return ApiSuccess(data: mockInvitations);
  }

  @override
  Future<ApiResult<FamilyInvitationDto>> sendInvitation(FamilyInvitationDto invitation) async {
    sendCount++;
    return mockSendResult ?? ApiSuccess(data: invitation);
  }

  @override
  Future<ApiResult<FamilyInvitationDto>> resendInvitation(String invitationId) async {
    resendCount++;
    return mockResendResult ??
        ApiSuccess(
          data: FamilyInvitationDto(
            id: invitationId,
            inviteeName: 'Test Invitee',
            inviteePhone: '+16505550009',
            relationship: 'Spouse',
            resendCount: 1,
            status: 'PENDING',
          ),
        );
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> acceptInvitation(String invitationId) async {
    acceptCount++;
    return mockAcceptResult ??
        const ApiSuccess(data: {'message': 'Invitation accepted', 'memberId': 'mem-new-123'});
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> cancelInvitation(String invitationId) async {
    cancelCount++;
    return mockCancelResult ??
        const ApiSuccess(data: {'message': 'Invitation cancelled'});
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> removeMember(String memberId) async {
    removeMemberCount++;
    return mockRemoveMemberResult ??
        const ApiSuccess(data: {'message': 'Member removed'});
  }
}

void main() {
  group('Family Member Invitation Workflow Tests (Phase 2.2)', () {
    late MockFamilyRepository mockRepo;
    late InMemoryTokenStorage mockStorage;

    setUp(() {
      mockRepo = MockFamilyRepository();
      mockStorage = InMemoryTokenStorage();
    });

    Widget wrap(Widget widget) {
      return MaterialApp(
        home: widget,
      );
    }

    testWidgets('AddFamilyMemberScreen blocks advancing with empty name or phone', (tester) async {
      await tester.pumpWidget(wrap(AddFamilyMemberScreen(repository: mockRepo)));
      await tester.pumpAndSettle();

      expect(find.text('Add Family Member'), findsOneWidget);
      expect(find.text('Continue to Permissions'), findsOneWidget);

      // Tap without filling fields
      await tester.tap(find.text('Continue to Permissions'));
      await tester.pump();

      expect(find.text('Please enter name and mobile number'), findsOneWidget);
      expect(mockRepo.sendCount, 0);
    });

    testWidgets('AddFamilyMemberScreen advances to Review and successfully sends invitation', (tester) async {
      const createdInvite = FamilyInvitationDto(
        id: 'inv-created-1',
        inviteeName: 'Eleanor Vance',
        inviteePhone: '+16505550008',
        relationship: 'Spouse',
        invitationToken: 'tok-abc-123-xyz',
        status: 'PENDING',
      );
      mockRepo.mockSendResult = const ApiSuccess(data: createdInvite);

      await tester.pumpWidget(wrap(AddFamilyMemberScreen(repository: mockRepo)));
      await tester.pumpAndSettle();

      // Enter Name and Phone in Step 0
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Eleanor Vance');
      await tester.enterText(textFields.at(1), '+16505550008');
      await tester.pump();

      // Advance to Step 1 (Permissions)
      await tester.tap(find.text('Continue to Permissions'));
      await tester.pumpAndSettle();
      expect(find.text('Healthcare Data Sharing Permissions'), findsOneWidget);

      // Advance to Step 2 (Review)
      await tester.tap(find.text('Review Invitation'));
      await tester.pumpAndSettle();
      expect(find.text('Review Linkage Invitation'), findsOneWidget);
      expect(find.text('Eleanor Vance'), findsOneWidget);
      expect(find.text('+16505550008'), findsOneWidget);

      // Tap Send Linkage Invitation
      await tester.tap(find.text('Send Linkage Invitation'));
      await tester.pumpAndSettle();

      expect(mockRepo.sendCount, 1);
      // Navigates to InvitationSentScreen
      expect(find.byType(InvitationSentScreen), findsOneWidget);
      expect(find.text('Invitation sent'), findsOneWidget);
      expect(find.text('Pending acceptance'), findsOneWidget);
    });

    testWidgets('AddFamilyMemberScreen displays error banner on duplicate invitation (400 Bad Request)', (tester) async {
      mockRepo.mockSendResult = const ApiFailure(
        message: 'A pending invitation already exists for this phone number. Cancel or resend it.',
        statusCode: 400,
      );

      await tester.pumpWidget(wrap(AddFamilyMemberScreen(repository: mockRepo)));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Eleanor Vance');
      await tester.enterText(textFields.at(1), '+16505550008');
      await tester.pump();

      await tester.tap(find.text('Continue to Permissions'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review Invitation'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Linkage Invitation'));
      await tester.pumpAndSettle();

      expect(mockRepo.sendCount, 1);
      // Should stay on review step and show error
      expect(find.byType(InvitationSentScreen), findsNothing);
      expect(find.text('A pending invitation already exists for this phone number. Cancel or resend it.'), findsAtLeast(1));
    });

    testWidgets('FamilyMembersScreen displays pending invitations and members with resend and cancel actions', (tester) async {
      const pendingInv = FamilyInvitationDto(
        id: 'inv-pending-1',
        inviteeName: 'Sarah Jenkins',
        inviteePhone: '+16505550004',
        relationship: 'Spouse',
        status: 'PENDING',
        resendCount: 1,
        invitationToken: 'tok-sarah-12345678',
      );

      const member = FamilyMemberDto(
        id: 'mem-1',
        fullName: 'Arthur Thompson',
        relationship: 'Father',
        isVerified: true,
        healthCardStatus: 'Active',
      );

      mockRepo.mockInvitations = [pendingInv];
      mockRepo.mockMembers = [member];

      await tester.pumpWidget(wrap(FamilyMembersScreen(repository: mockRepo)));
      await tester.pumpAndSettle();

      expect(find.text('Pending Invitations (1)'), findsOneWidget);
      expect(find.text('Linked Family Members (1)'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('Arthur Thompson'), findsOneWidget);
      expect(find.text('Resends: 1/5'), findsOneWidget);

      // Tap Resend
      await tester.tap(find.text('Resend (1/5)'));
      await tester.pumpAndSettle();
      expect(mockRepo.resendCount, 1);

      // Tap Cancel Invitation (IconButton with tooltip)
      await tester.tap(find.byTooltip('Cancel Invitation'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      // Confirm Cancel
      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel Invitation'));
      await tester.pumpAndSettle();
      expect(mockRepo.cancelCount, 1);
    });

    testWidgets('FamilyMembersScreen accept action calls acceptInvitation and reloads data', (tester) async {
      const pendingInv = FamilyInvitationDto(
        id: 'inv-to-accept-99',
        inviteeName: 'Oliver Vance',
        inviteePhone: '+16505550010',
        relationship: 'Child',
        status: 'PENDING',
      );

      mockRepo.mockInvitations = [pendingInv];
      mockRepo.mockMembers = [];

      await tester.pumpWidget(wrap(FamilyMembersScreen(repository: mockRepo)));
      await tester.pumpAndSettle();

      expect(find.text('Oliver Vance'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);

      // Tap Accept
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(mockRepo.acceptCount, 1);
      // Reloaded data
      expect(mockRepo.getMembersCount, greaterThanOrEqualTo(2));
    });

    testWidgets('AcceptInvitationScreen shows unauthenticated sign-in CTA when token is absent', (tester) async {
      await mockStorage.clear();

      await tester.pumpWidget(
        wrap(
          AcceptInvitationScreen(
            invitationId: 'inv-unauth-1',
            repository: mockRepo,
            tokenStorage: mockStorage,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign In Required'), findsOneWidget);
      expect(find.text('Sign In to CareID'), findsOneWidget);
    });

    testWidgets('AcceptInvitationScreen accepts invitation and renders success celebration', (tester) async {
      await mockStorage.saveTokens(accessToken: 'auth-token-123', refreshToken: 'ref-123');
      mockRepo.mockAcceptResult = const ApiSuccess(
        data: {'message': 'Invitation accepted', 'memberId': 'mem-uuid-456'},
      );

      await tester.pumpWidget(
        wrap(
          AcceptInvitationScreen(
            invitationId: 'inv-auth-accept-1',
            repository: mockRepo,
            tokenStorage: mockStorage,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accept Invitation & Connect'), findsOneWidget);

      await tester.tap(find.text('Accept Invitation & Connect'));
      await tester.pumpAndSettle();

      expect(mockRepo.acceptCount, 1);
      expect(find.text('Invitation Accepted!'), findsOneWidget);
      expect(find.text('View Family Dashboard'), findsOneWidget);
    });

    testWidgets('AcceptInvitationScreen handles expired or invalid invitation error', (tester) async {
      await mockStorage.saveTokens(accessToken: 'auth-token-123', refreshToken: 'ref-123');
      mockRepo.mockAcceptResult = const ApiFailure(
        message: 'This invitation has already been accepted or expired.',
        statusCode: 400,
      );

      await tester.pumpWidget(
        wrap(
          AcceptInvitationScreen(
            invitationId: 'inv-expired-1',
            repository: mockRepo,
            tokenStorage: mockStorage,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accept Invitation & Connect'), findsOneWidget);

      await tester.tap(find.text('Accept Invitation & Connect'));
      await tester.pumpAndSettle();

      expect(mockRepo.acceptCount, 1);
      expect(find.text('This invitation has already been accepted or expired.'), findsOneWidget);
      expect(find.text('Invitation Expired'), findsOneWidget);
    });
  });
}
