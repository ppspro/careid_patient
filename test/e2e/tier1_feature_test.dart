import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/core/constants/api_endpoints.dart';
import 'package:careid_patient_app/features/patient/data/models/appointment_models.dart';
import 'package:careid_patient_app/features/patient/data/models/family_models.dart';
import 'package:careid_patient_app/features/patient/data/models/medical_record_models.dart';

import 'e2e_test_harness.dart';

void main() {
  group('E2E Tier 1: Feature Coverage (Isolation Happy-Path Tests)', () {
    late E2ETestHarness harness;

    setUp(() {
      harness = E2ETestHarness.create();
    });

    // =========================================================================
    // 1. Authentication & Session Feature
    // =========================================================================
    group('1. Authentication Feature Tests', () {
      const seededPhone = '+16505550004';
      const validOtp = '123456';

      test('1.1 requestOtp successfully dispatches OTP to seeded patient phone', () async {
        final res = await harness.authRepo.requestOtp(seededPhone);
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.challengeId, equals('ch-test-12345'));
        expect(res.dataOrNull?.message, contains('OTP sent'));
      });

      test('1.2 verifyOtp validates OTP and issues JWT tokens to TokenStorage', () async {
        final otpRes = await harness.authRepo.requestOtp(seededPhone);
        final challengeId = otpRes.dataOrNull!.challengeId;

        final verifyRes = await harness.authRepo.verifyOtp(
          challengeId: challengeId,
          otpCode: validOtp,
        );

        expect(verifyRes.isSuccess, isTrue);
        final tokens = verifyRes.dataOrNull!;
        expect(tokens.accessToken.isNotEmpty, isTrue);
        expect(tokens.refreshToken.isNotEmpty, isTrue);

        final stored = await harness.tokenStorage.getAccessToken();
        expect(stored, equals(tokens.accessToken));
      });

      test('1.3 tokenRefresh rotates access token using valid refresh token', () async {
        await harness.loginAsSeededPatient();
        final currentRefresh = await harness.tokenStorage.getRefreshToken();
        expect(currentRefresh, isNotNull);

        final refreshRes = await harness.apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.tokenRefresh,
          body: {'refreshToken': currentRefresh!},
          fromJson: (j) => j as Map<String, dynamic>,
        );
        expect(refreshRes.isSuccess, isTrue);
        expect(refreshRes.dataOrNull?['accessToken'], contains('refreshed'));
      });

      test('1.4 getCurrentUser retrieves authenticated patient user identity & roles', () async {
        await harness.loginAsSeededPatient();
        final meRes = await harness.authRepo.getCurrentUser();
        expect(meRes.isSuccess, isTrue);
        final user = meRes.dataOrNull!;
        expect(user['phone'], equals(seededPhone));
        expect((user['roles'] as List), contains('PATIENT'));
      });

      test('1.5 logout terminates session and purges local TokenStorage', () async {
        await harness.loginAsSeededPatient();
        expect(await harness.tokenStorage.getAccessToken(), isNotNull);

        final logoutRes = await harness.authRepo.logout();
        expect(logoutRes.isSuccess, isTrue);
        expect(await harness.tokenStorage.getAccessToken(), isNull);
        expect(await harness.tokenStorage.getRefreshToken(), isNull);
      });
    });

    // =========================================================================
    // 2. Patient Profile & Demographics Feature
    // =========================================================================
    group('2. Patient Profile Feature Tests', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('2.1 getPatientProfile retrieves current patient profile', () async {
        final res = await harness.patientRepo.getPatientProfile();
        expect(res.isSuccess, isTrue);
        final profile = res.dataOrNull!;
        expect(profile.fullName, equals('John Doe'));
        expect(profile.bloodGroup, equals('O+'));
        expect(profile.status, equals('ACTIVE'));
      });

      test('2.2 getFullProfile retrieves extended clinical demographics & emergency contact', () async {
        final res = await harness.patientRepo.getFullProfile();
        expect(res.isSuccess, isTrue);
        final profile = res.dataOrNull!;
        expect(profile.allergies, contains('Penicillin'));
        expect(profile.conditions, contains('Asthma'));
        expect(profile.emergencyContactName, equals('Jane Doe'));
        expect(profile.emergencyContactRelationship, equals('Spouse'));
      });

      test('2.3 updateBasicInfo modifies demographic records', () async {
        final patchRes = await harness.patientRepo.updateBasicInfo(
          firstName: 'Jonathan',
          lastName: 'Doe',
        );
        expect(patchRes.isSuccess, isTrue);
        expect(patchRes.dataOrNull?['firstName'], equals('Jonathan'));
      });

      test('2.4 getProfileCompletion calculates profile completion status', () async {
        final completionRes = await harness.patientRepo.getProfileCompletion();
        expect(completionRes.isSuccess, isTrue);
        expect(completionRes.dataOrNull?.percentage, equals(100));
        expect(completionRes.dataOrNull?.completedSteps, equals(6));
      });

      test('2.5 initializeDraft starts onboarding registration cycle', () async {
        final draftRes = await harness.onboardingRepo.initializeDraft();
        expect(draftRes.isSuccess, isTrue);
        expect(draftRes.dataOrNull?['status'], equals('DRAFT'));
        expect(draftRes.dataOrNull?['patientNumber'], equals('PT-2026-0004'));
      });
    });

    // =========================================================================
    // 3. Digital Health Card Feature
    // =========================================================================
    group('3. Digital Health Card Feature Tests', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('3.1 getActiveHealthCard returns valid digital health card credential', () async {
        final res = await harness.healthCardRepo.getActiveHealthCard();
        expect(res.isSuccess, isTrue);
        final card = res.dataOrNull!;
        expect(card.cardNumber, startsWith('HC-CAREID-'));
        expect(card.status, equals('ACTIVE'));
      });

      test('3.2 issueHealthCard issues or re-issues digital health credential', () async {
        final res = await harness.healthCardRepo.issueHealthCard(reason: 'Initial card issuance');
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.cardNumber, isNotEmpty);
      });

      test('3.3 healthCardStatus confirms active non-emergency flag baseline', () async {
        final res = await harness.healthCardRepo.getActiveHealthCard();
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.status, equals('ACTIVE'));
        expect(res.dataOrNull?.emergencyFlag, isFalse);
      });

      test('3.4 qrPayload contains verifiable format signature', () async {
        final res = await harness.healthCardRepo.getActiveHealthCard();
        expect(res.isSuccess, isTrue);
        final qrPayload = res.dataOrNull?.qrPayload;
        expect(qrPayload, isNotNull);
        expect(qrPayload!, contains('HC-CAREID-2026-0004'));
      });

      test('3.5 healthCardExpiresAt confirms long-lived validity date', () async {
        final res = await harness.healthCardRepo.getActiveHealthCard();
        expect(res.isSuccess, isTrue);
        final expiresAt = res.dataOrNull?.expiresAt;
        expect(expiresAt, isNotNull);
        final expiryDate = DateTime.parse(expiresAt!);
        expect(expiryDate.isAfter(DateTime(2026, 1, 1)), isTrue);
      });
    });

    // =========================================================================
    // 4. QR Verification Feature
    // =========================================================================
    group('4. QR Verification Feature Tests', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('4.1 verifyQrPayload validates genuine CareID health card QR', () async {
        final res = await harness.healthCardRepo.verifyQrPayload('HC-CAREID-2026-0004|PATIENT|SIG');
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.isValid, isTrue);
        expect(res.dataOrNull?.cardNumber, equals('HC-CAREID-2026-0004'));
      });

      test('4.2 verifyQrPayload extracts patient demographic summary', () async {
        final res = await harness.healthCardRepo.verifyQrPayload('HC-CAREID-2026-0004|PATIENT|SIG');
        expect(res.isSuccess, isTrue);
        final dto = res.dataOrNull!;
        expect(dto.patientName, equals('John Doe'));
        expect(dto.bloodGroup, equals('O+'));
        expect(dto.patientNumber, equals('PT-2026-0004'));
      });

      test('4.3 verifyQrPayload accepts clinic check-in pass format', () async {
        final res = await harness.healthCardRepo.verifyQrPayload('CAREID-PASS-CHECKIN-8899');
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.isValid, isTrue);
      });

      test('4.4 verifyQrPayload accepts doctor scan verification token', () async {
        final res = await harness.healthCardRepo.verifyQrPayload('CAREID-DOCTOR-SCAN-TOKEN-1122');
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.isValid, isTrue);
      });

      test('4.5 verifyQrPayload cleanly rejects invalid or corrupted QR payload', () async {
        final res = await harness.healthCardRepo.verifyQrPayload('INVALID_RANDOM_GARBAGE_PAYLOAD');
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.isValid, isFalse);
        expect(res.dataOrNull?.message, contains('Unrecognized'));
      });
    });

    // =========================================================================
    // 5. Medical Records Feature
    // =========================================================================
    group('5. Medical Records Feature Tests', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('5.1 getMedicalRecords fetches comprehensive clinical records', () async {
        final res = await harness.recordsRepo.getMedicalRecords();
        expect(res.isSuccess, isTrue);
        final list = res.dataOrNull!;
        expect(list.length, greaterThanOrEqualTo(3));
        expect(list.any((r) => r.category == 'GENERAL'), isTrue);
        expect(list.any((r) => r.category == 'DENTAL'), isTrue);
        expect(list.any((r) => r.category == 'VISION'), isTrue);
      });

      test('5.2 getRecordById loads single record with complete notes', () async {
        final res = await harness.recordsRepo.getRecordById('rec-001');
        expect(res.isSuccess, isTrue);
        final rec = res.dataOrNull!;
        expect(rec.id, equals('rec-001'));
        expect(rec.title, contains('Cardiovascular'));
        expect(rec.clinicalNotes, isNotEmpty);
      });

      test('5.3 searchRecords queries health vault records by keyword', () async {
        final res = await harness.recordsRepo.searchRecords('Cardiovascular');
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.isNotEmpty, isTrue);
        expect(res.dataOrNull?.first.title, contains('Cardiovascular'));
      });

      test('5.4 getTimeline returns chronological medical timeline events', () async {
        final res = await harness.recordsRepo.getTimeline();
        expect(res.isSuccess, isTrue);
        final timeline = res.dataOrNull!;
        expect(timeline.isNotEmpty, isTrue);
        expect(timeline.first.title, isNotEmpty);
      });

      test('5.5 createRecord creates and saves new consultation record into vault', () async {
        const newRecord = MedicalRecordDto(
          id: '',
          title: 'Post-Operative Orthopedic Followup',
          category: 'GENERAL',
          chiefComplaint: 'Post-operative mobility evaluation',
          clinicalNotes: 'Knee extension satisfactory, wound healing clean.',
          treatmentPlan: 'Physical therapy 2x weekly.',
          status: 'FINAL',
        );

        final createRes = await harness.recordsRepo.createRecord(newRecord);
        expect(createRes.isSuccess, isTrue);
        expect(createRes.dataOrNull?.title, equals('Post-Operative Orthopedic Followup'));

        final listRes = await harness.recordsRepo.getMedicalRecords();
        expect(listRes.dataOrNull?.any((r) => r.title == 'Post-Operative Orthopedic Followup'), isTrue);
      });
    });

    // =========================================================================
    // 6. Appointments & Consultations Feature
    // =========================================================================
    group('6. Appointments Feature Tests', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('6.1 getDoctors lists available practitioners with specialties and ratings', () async {
        final res = await harness.doctorRepo.getDoctors();
        expect(res.isSuccess, isTrue);
        final doctors = res.dataOrNull!;
        expect(doctors.isNotEmpty, isTrue);
        expect(doctors.any((d) => d.primarySpecialization == 'Cardiology'), isTrue);
        expect(doctors.first.rating, greaterThan(4.0));
      });

      test('6.2 getDoctorSlots returns available time slots for doctor', () async {
        final res = await harness.doctorRepo.getDoctorSlots('1f06067b-e229-4707-84e2-afa27da2e4cd');
        expect(res.isSuccess, isTrue);
        final slots = res.dataOrNull!;
        expect(slots.isNotEmpty, isTrue);
        expect(slots.first.isAvailable, isTrue);
      });

      test('6.3 bookAppointment reserves consultation slot and returns booked appointment', () async {
        final apt = AppointmentModel(
          id: 'apt-test-book',
          doctorId: '1f06067b-e229-4707-84e2-afa27da2e4cd',
          doctorName: 'Dr. Robert Chen',
          specialization: 'Cardiology',
          facility: 'Metro Health Medical Center',
          dateTime: DateTime(2026, 11, 25, 9, 0),
          consultationType: 'In-Person Consultation',
          reasonForVisit: 'Pre-procedural assessment',
          durationMinutes: 30,
        );

        final res = await harness.doctorRepo.bookAppointment(apt);
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.doctorId, equals(apt.doctorId));
      });

      test('6.4 getMyAppointments retrieves current list of scheduled appointments', () async {
        final res = await harness.doctorRepo.getMyAppointments();
        expect(res.isSuccess, isTrue);
        final list = res.dataOrNull!;
        expect(list.isNotEmpty, isTrue);
        expect(list.first.doctorName, contains('Dr. Robert Chen'));
        expect(list.first.status, equals(AppointmentStatus.upcoming));
      });

      test('6.5 cancelAppointment cancels scheduled consultation successfully', () async {
        final cancelRes = await harness.doctorRepo.cancelAppointment(
          'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380e55',
          reason: 'Patient schedule conflict',
        );
        expect(cancelRes.isSuccess, isTrue);
        expect(cancelRes.dataOrNull, isTrue);
      });
    });

    // =========================================================================
    // 7. Insurance & Treatment Offers Feature
    // =========================================================================
    group('7. Insurance & Treatment Offers Feature Tests', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('7.1 getPolicies fetches active patient insurance policies', () async {
        final res = await harness.insuranceRepo.getPolicies();
        expect(res.isSuccess, isTrue);
        final policies = res.dataOrNull!;
        expect(policies.isNotEmpty, isTrue);
        expect(policies.first.providerName, equals('Blue Cross Blue Shield'));
        expect(policies.first.policyNumber, equals('POL-998877'));
      });

      test('7.2 getPolicyById retrieves specific policy details', () async {
        final res = await harness.insuranceRepo.getPolicyById('pol-001');
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.groupNumber, equals('GRP-5544'));
        expect(res.dataOrNull?.status, equals('ACTIVE'));
      });

      test('7.3 getTreatmentOffers lists clinical treatment packages', () async {
        final res = await harness.treatmentOfferRepo.getTreatmentOffers();
        expect(res.isSuccess, isTrue);
        final offers = res.dataOrNull!;
        expect(offers.isNotEmpty, isTrue);
        expect(offers.first.clinicalIndication, contains('Orthodontic'));
      });

      test('7.4 getTreatmentOfferById retrieves treatment financial breakdown', () async {
        final res = await harness.treatmentOfferRepo.getTreatmentOfferById('offer-001');
        expect(res.isSuccess, isTrue);
        final offer = res.dataOrNull!;
        expect(offer.totalProceduresCost, equals(2400.0));
        expect(offer.discountAmount, equals(600.0));
        expect(offer.netPayableCost, equals(1800.0));
      });

      test('7.5 treatment financing parameters confirm 0% financing eligibility', () async {
        final res = await harness.treatmentOfferRepo.getTreatmentOfferById('offer-001');
        expect(res.isSuccess, isTrue);
        final offer = res.dataOrNull!;
        expect(offer.financingEligible, isTrue);
        expect(offer.recommendedTenureMonths, equals(12));
      });
    });

    // =========================================================================
    // 8. Family Members & Relationships Feature
    // =========================================================================
    group('8. Family Members Feature Tests', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('8.1 getInvitations returns pending family linkage invitations', () async {
        final res = await harness.familyRepo.getInvitations();
        expect(res.isSuccess, isTrue);
        final invs = res.dataOrNull!;
        expect(invs.isNotEmpty, isTrue);
        expect(invs.first.inviteeName, equals('Jane Doe'));
        expect(invs.first.relationship, equals('Spouse'));
      });

      test('8.2 sendInvitation dispatches new family account linkage invitation', () async {
        const newInv = FamilyInvitationDto(
          id: '',
          inviteeName: 'Alice Doe',
          inviteePhone: '+14155559876',
          relationship: 'Child',
          status: 'PENDING',
        );

        final res = await harness.familyRepo.sendInvitation(newInv);
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.inviteeName, equals('Alice Doe'));
        expect(res.dataOrNull?.relationship, equals('Child'));
      });

      test('8.3 FamilyInvitationDto serializes and parses accurately', () {
        final json = {
          'id': 'inv-test-99',
          'inviteeName': 'Robert Doe',
          'inviteePhone': '+14155557766',
          'relationship': 'Parent',
          'status': 'PENDING',
        };
        final dto = FamilyInvitationDto.fromJson(json);
        expect(dto.id, equals('inv-test-99'));
        expect(dto.relationship, equals('Parent'));
        expect(dto.toJson()['inviteeName'], equals('Robert Doe'));
      });

      test('8.4 FamilyMemberDto model captures relationship and status', () {
        final json = {
          'id': 'fm-001',
          'fullName': 'Alice Doe',
          'relationship': 'Child',
          'phone': '+14155559876',
          'bloodGroup': 'O+',
          'isVerified': true,
        };
        final member = FamilyMemberDto.fromJson(json);
        expect(member.fullName, equals('Alice Doe'));
        expect(member.isVerified, isTrue);
        expect(member.bloodGroup, equals('O+'));
      });

      test('8.5 family member list contains active registered members', () async {
        final res = await harness.familyRepo.getInvitations();
        expect(res.isSuccess, isTrue);
        expect(res.dataOrNull?.every((i) => i.inviteePhone.isNotEmpty), isTrue);
      });
    });

    // =========================================================================
    // 9. Notifications Feature
    // =========================================================================
    group('9. Notifications Feature Tests', () {
      setUp(() async {
        await harness.loginAsSeededPatient();
      });

      test('9.1 getNotifications retrieves patient notification inbox', () async {
        final res = await harness.notificationRepo.getNotifications();
        expect(res.isSuccess, isTrue);
        final list = res.dataOrNull!;
        expect(list.length, greaterThanOrEqualTo(2));
        expect(list.any((n) => n.title.contains('Consultation')), isTrue);
      });

      test('9.2 filterUnreadNotifications isolates unread alerts', () async {
        final res = await harness.notificationRepo.getNotifications();
        expect(res.isSuccess, isTrue);
        final list = res.dataOrNull!;
        final unread = list.where((n) => !n.isRead).toList();
        expect(unread.isNotEmpty, isTrue);
        expect(unread.first.isRead, isFalse);
      });

      test('9.3 markAsRead updates notification state to read', () async {
        final readRes = await harness.notificationRepo.markAsRead('notif-001');
        expect(readRes.isSuccess, isTrue);
        expect(readRes.dataOrNull, isTrue);

        final listRes = await harness.notificationRepo.getNotifications();
        final notif = listRes.dataOrNull?.firstWhere((n) => n.id == 'notif-001');
        expect(notif?.isRead, isTrue);
      });

      test('9.4 notification channel & priority parsing', () async {
        final res = await harness.notificationRepo.getNotifications();
        expect(res.isSuccess, isTrue);
        final notif = res.dataOrNull!.firstWhere((n) => n.id == 'notif-001');
        expect(notif.channel, equals('IN_APP'));
        expect(notif.priority, equals('HIGH'));
      });

      test('9.5 markAllAsRead marks all notifications as read', () async {
        final listRes = await harness.notificationRepo.getNotifications();
        expect(listRes.isSuccess, isTrue);
        final list = listRes.dataOrNull!;

        await harness.notificationRepo.markAllAsRead(list);

        final updatedRes = await harness.notificationRepo.getNotifications();
        expect(updatedRes.dataOrNull?.every((n) => n.isRead), isTrue);
      });
    });
  });
}
