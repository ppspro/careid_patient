import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/network/api_result.dart';
import 'package:careid_patient_app/features/patient/data/models/family_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/family_repository.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/family_dashboard_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/family_members_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/add_family_member_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/invitation_sent_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';

class FakeFamilyRepository extends FamilyRepository {
  final List<FamilyMemberDto> dummyMembers;
  final List<FamilyInvitationDto> dummyInvitations;

  FakeFamilyRepository({
    this.dummyMembers = const [
      FamilyMemberDto(
        id: 'mem-001',
        fullName: 'Robert Jenkins',
        relationship: 'Father',
        phone: '+1 (555) 234-5678',
      ),
      FamilyMemberDto(
        id: 'mem-002',
        fullName: 'Lucas Jenkins',
        relationship: 'Son',
        phone: '+1 (555) 345-6789',
      ),
    ],
    this.dummyInvitations = const [
      FamilyInvitationDto(
        id: 'inv-001',
        inviteeName: 'Eleanor Jenkins',
        inviteePhone: '+1 (555) 987-6543',
        relationship: 'Mother',
        status: 'PENDING',
      ),
    ],
  });

  @override
  Future<ApiResult<List<FamilyMemberDto>>> getMembers() async {
    return ApiSuccess(data: dummyMembers);
  }

  @override
  Future<ApiResult<List<FamilyInvitationDto>>> getInvitations() async {
    return ApiSuccess(data: dummyInvitations);
  }

  @override
  Future<ApiResult<FamilyInvitationDto>> sendInvitation(FamilyInvitationDto dto) async {
    return ApiSuccess(data: dto);
  }
}

void main() {
  group('Family Ecosystem & Dependent Management Suite', () {
    late FakeFamilyRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeFamilyRepository();
    });

    testWidgets('FamilyDashboardScreen renders header, ecosystem hero card and quick actions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: FamilyDashboardScreen(
            repository: fakeRepo,
            showBottomNav: false,
          ),
        ),
      );

      // Pump frames to resolve async calls
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);

      // Hero Bento Card text
      expect(find.text('Family Ecosystem'), findsOneWidget);
      expect(find.text('HIPAA LINKED VAULT'), findsOneWidget);

      // Quick Management section
      expect(find.text('Quick Management'), findsOneWidget);
      expect(find.text('Add Family Member'), findsOneWidget);
      expect(find.text('Family Member Directory'), findsOneWidget);
      expect(find.text('Data Sharing Permissions'), findsOneWidget);

      // Connected members metric count
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('FamilyMembersScreen renders search input, horizontal chips and member cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: FamilyMembersScreen(
            repository: fakeRepo,
          ),
        ),
      );

      // Pump frames to resolve async calls
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Header title
      expect(find.text('Family Management'), findsOneWidget);

      // Search field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search family members...'), findsOneWidget);

      // Filter chips
      expect(find.text('All'), findsOneWidget);

      // Member Card renders
      expect(find.text('Robert Jenkins'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Lucas Jenkins'), 200, scrollable: find.byType(Scrollable).last);
      expect(find.text('Lucas Jenkins'), findsOneWidget);
      expect(find.text('View Details'), findsWidgets);

      // FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('InvitationSentScreen renders success symbol, title and confirmation copy', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: InvitationSentScreen(
            memberName: 'Sarah Jenkins',
            relationship: 'Spouse',
            emailOrPhone: '+1 (555) 234-5678',
          ),
        ),
      );

      await tester.pump();

      // Header branding
      expect(find.byType(CareIdLogo), findsOneWidget);

      // Success hero copy
      expect(find.text('Invitation sent'), findsOneWidget);
      expect(find.text('Pending acceptance'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
    });

    testWidgets('AddFamilyMemberScreen renders 3-step progress track and form fields', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: AddFamilyMemberScreen(
            repository: fakeRepo,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Add Family Member'), findsOneWidget);
      expect(find.textContaining('Step 1 of 3'), findsOneWidget);
      expect(find.text('Member Information'), findsOneWidget);
      expect(find.text('Full Legal Name *'), findsOneWidget);
      expect(find.text('Relationship to Primary Patient'), findsOneWidget);
    });
  });
}
