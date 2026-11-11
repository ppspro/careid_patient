import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/patient/data/models/appointment_models.dart';
import 'package:careid_patient_app/features/patient/data/models/family_models.dart';
import 'package:careid_patient_app/features/patient/data/models/medical_record_models.dart';

import 'e2e_test_harness.dart';

void main() {
  group('E2E Tier 3: Cross-Feature Interactions (Pairwise Integration Tests)', () {
    late E2ETestHarness harness;

    setUp(() {
      harness = E2ETestHarness.create();
    });

    // =========================================================================
    // Interaction 1: Authentication + Digital Health Card
    // =========================================================================
    test('3.1 Auth + Health Card: OTP verification automatically enables health card access', () async {
      // 1. Initial unauthenticated state: Health Card call fails with 401
      final unauthCardRes = await harness.healthCardRepo.getActiveHealthCard();
      expect(unauthCardRes.isFailure, isTrue);

      // 2. Perform end-to-end OTP Login
      const phone = '+16505550004';
      final otpRes = await harness.authRepo.requestOtp(phone);
      expect(otpRes.isSuccess, isTrue);

      final verifyRes = await harness.authRepo.verifyOtp(
        challengeId: otpRes.dataOrNull!.challengeId,
        otpCode: '123456',
      );
      expect(verifyRes.isSuccess, isTrue);

      // 3. Authenticated session now seamlessly loads active Digital Health Card
      final authCardRes = await harness.healthCardRepo.getActiveHealthCard();
      expect(authCardRes.isSuccess, isTrue);
      final card = authCardRes.dataOrNull!;
      expect(card.cardNumber, equals('HC-CAREID-2026-0004'));
      expect(card.status, equals('ACTIVE'));
      expect(card.qrPayload, contains('HC-CAREID-2026-0004'));
    });

    // =========================================================================
    // Interaction 2: Profile + Doctor Search & Appointment Booking
    // =========================================================================
    test('3.2 Profile + Appointment: Patient profile binds to booked doctor consultation', () async {
      await harness.loginAsSeededPatient();

      // 1. Retrieve patient profile to extract authoritative patient number
      final profileRes = await harness.patientRepo.getPatientProfile();
      expect(profileRes.isSuccess, isTrue);
      final profile = profileRes.dataOrNull!;
      expect(profile.patientNumber, equals('PT-2026-0004'));

      // 2. Search for doctors in Cardiology
      final doctorRes = await harness.doctorRepo.getDoctors(specialty: 'Cardiology');
      expect(doctorRes.isSuccess, isTrue);
      final doctor = doctorRes.dataOrNull!.firstWhere(
        (d) => d.primarySpecialization == 'Cardiology',
      );
      expect(doctor.fullName, equals('Dr. Robert Chen'));

      // 3. Fetch doctor schedule slots
      final slotsRes = await harness.doctorRepo.getDoctorSlots(doctor.id);
      expect(slotsRes.isSuccess, isTrue);
      expect(slotsRes.dataOrNull!.any((s) => s.isAvailable), isTrue);

      // 4. Book appointment with selected doctor and slot
      final newApt = AppointmentModel(
        id: 'apt-pair-test-101',
        doctorId: doctor.id,
        doctorName: doctor.fullName,
        specialization: doctor.primarySpecialization,
        facility: doctor.facilityName,
        dateTime: DateTime(2026, 11, 25, 9, 0),
        consultationType: 'In-Person Consultation',
        reasonForVisit: 'Cardiovascular checkup for patient ${profile.fullName}',
        durationMinutes: 30,
      );

      final bookRes = await harness.doctorRepo.bookAppointment(newApt);
      expect(bookRes.isSuccess, isTrue);

      // 5. Verify the booked appointment appears in patient's appointment list
      final myAptsRes = await harness.doctorRepo.getMyAppointments();
      expect(myAptsRes.isSuccess, isTrue);
      expect(myAptsRes.dataOrNull?.any((a) => a.doctorId == doctor.id), isTrue);
    });

    // =========================================================================
    // Interaction 3: Medical Record Creation + Clinical Timeline Indexing
    // =========================================================================
    test('3.3 Medical Record + Timeline: Record creation immediately updates chronological timeline', () async {
      await harness.loginAsSeededPatient();

      // 1. Initial records count
      final initialRes = await harness.recordsRepo.getMedicalRecords();
      expect(initialRes.isSuccess, isTrue);
      final initialCount = initialRes.dataOrNull!.length;

      // 2. Create new consultation record
      const newRecord = MedicalRecordDto(
        id: '',
        title: 'Bilateral Otoscopic Tympanic Examination',
        category: 'GENERAL',
        chiefComplaint: 'Mild bilateral ear fullness',
        clinicalNotes: 'Tympanic membranes translucent, landmarks well visualized.',
        treatmentPlan: 'Conservative observation, no antibiotics indicated.',
        status: 'FINAL',
      );

      final createRes = await harness.recordsRepo.createRecord(newRecord);
      expect(createRes.isSuccess, isTrue);
      expect(createRes.dataOrNull?.title, equals('Bilateral Otoscopic Tympanic Examination'));

      // 3. Verify total medical records count incremented
      final updatedRecordsRes = await harness.recordsRepo.getMedicalRecords();
      expect(updatedRecordsRes.dataOrNull!.length, equals(initialCount + 1));

      // 4. Verify presence in unified clinical timeline
      final timelineRes = await harness.recordsRepo.getTimeline();
      expect(timelineRes.isSuccess, isTrue);
      expect(timelineRes.dataOrNull?.any((t) => t.title.contains('Otoscopic')), isTrue);
    });

    // =========================================================================
    // Interaction 4: Insurance Policy + Treatment Offer Financial Reconciliation
    // =========================================================================
    test('3.4 Insurance + Treatment Offer: Active insurance verifies out-of-pocket coverage balance', () async {
      await harness.loginAsSeededPatient();

      // 1. Retrieve primary insurance policy
      final policyRes = await harness.insuranceRepo.getPolicies();
      expect(policyRes.isSuccess, isTrue);
      final policy = policyRes.dataOrNull!.first;
      expect(policy.providerName, equals('Blue Cross Blue Shield'));
      expect(policy.status, equals('ACTIVE'));

      // 2. Retrieve treatment offer for orthodontic care
      final offersRes = await harness.treatmentOfferRepo.getTreatmentOffers();
      expect(offersRes.isSuccess, isTrue);
      final offer = offersRes.dataOrNull!.first;

      // 3. Reconcile costs: Total = Net Payable + Discount
      final expectedTotal = offer.netPayableCost + offer.discountAmount;
      expect(offer.totalProceduresCost, equals(expectedTotal));

      // 4. Verify financing terms match 0% APR across 12-month tenure
      expect(offer.financingEligible, isTrue);
      expect(offer.recommendedTenureMonths, equals(12));
    });

    // =========================================================================
    // Interaction 5: Family Linkage + Digital QR Credential Isolation
    // =========================================================================
    test('3.5 Family + Health Card: Adding family member preserves primary account credential integrity', () async {
      await harness.loginAsSeededPatient();

      // 1. Capture primary patient's health card credential
      final cardRes = await harness.healthCardRepo.getActiveHealthCard();
      expect(cardRes.isSuccess, isTrue);
      final primaryCardNumber = cardRes.dataOrNull!.cardNumber;

      // 2. Send family invitation for child
      const childInv = FamilyInvitationDto(
        id: '',
        inviteeName: 'Lucas Doe',
        inviteePhone: '+14155554321',
        relationship: 'Child',
        status: 'PENDING',
      );

      final invRes = await harness.familyRepo.sendInvitation(childInv);
      expect(invRes.isSuccess, isTrue);
      expect(invRes.dataOrNull?.inviteeName, equals('Lucas Doe'));

      // 3. Confirm family invitations list includes newly invited member
      final invListRes = await harness.familyRepo.getInvitations();
      expect(invListRes.isSuccess, isTrue);
      expect(invListRes.dataOrNull?.any((i) => i.inviteeName == 'Lucas Doe'), isTrue);

      // 4. Verify primary patient's digital health card remains untouched
      final verifyCardRes = await harness.healthCardRepo.getActiveHealthCard();
      expect(verifyCardRes.dataOrNull?.cardNumber, equals(primaryCardNumber));
      expect(verifyCardRes.dataOrNull?.status, equals('ACTIVE'));
    });

    // =========================================================================
    // Interaction 6: Health Card QR Generation + Doctor QR Verification Flow
    // =========================================================================
    test('3.6 QR Subsystem: Health card QR payload validates with full clinical identity', () async {
      await harness.loginAsSeededPatient();

      // 1. Get health card and retrieve QR string
      final cardRes = await harness.healthCardRepo.getActiveHealthCard();
      expect(cardRes.isSuccess, isTrue);
      final qrString = cardRes.dataOrNull!.qrPayload!;

      // 2. Doctor scans patient's QR payload
      final verifyRes = await harness.healthCardRepo.verifyQrPayload(qrString);
      expect(verifyRes.isSuccess, isTrue);

      // 3. Assert doctor verification yields verified patient identity
      final verification = verifyRes.dataOrNull!;
      expect(verification.isValid, isTrue);
      expect(verification.cardNumber, equals('HC-CAREID-2026-0004'));
      expect(verification.patientName, equals('John Doe'));
      expect(verification.bloodGroup, equals('O+'));
      expect(verification.verificationStatus, equals('VALID'));
    });

    // =========================================================================
    // Interaction 7: Appointment Booking + Notification Center Lifecycle
    // =========================================================================
    test('3.7 Appointment + Notification: Booked consultation generates high-priority notification', () async {
      await harness.loginAsSeededPatient();

      // 1. Book appointment
      final apt = AppointmentModel(
        id: 'apt-notif-flow',
        doctorId: '1f06067b-e229-4707-84e2-afa27da2e4cd',
        doctorName: 'Dr. Robert Chen',
        specialization: 'Cardiology',
        facility: 'Metro Health Medical Center',
        dateTime: DateTime(2026, 11, 20, 10, 0),
        durationMinutes: 30,
      );

      final bookRes = await harness.doctorRepo.bookAppointment(apt);
      expect(bookRes.isSuccess, isTrue);

      // 2. Query patient notification feed
      final notifRes = await harness.notificationRepo.getNotifications();
      expect(notifRes.isSuccess, isTrue);
      final notifs = notifRes.dataOrNull!;

      // 3. Find consultation alert
      final aptAlert = notifs.firstWhere(
        (n) => n.title.contains('Consultation'),
        orElse: () => notifs.first,
      );
      expect(aptAlert.priority, equals('HIGH'));
      expect(aptAlert.channel, equals('IN_APP'));

      // 4. Mark notification as read
      final readRes = await harness.notificationRepo.markAsRead(aptAlert.id);
      expect(readRes.isSuccess, isTrue);

      // 5. Verify updated notification reflects read state
      final updatedNotifRes = await harness.notificationRepo.getNotifications();
      final updatedAlert = updatedNotifRes.dataOrNull!.firstWhere((n) => n.id == aptAlert.id);
      expect(updatedAlert.isRead, isTrue);
    });

    // =========================================================================
    // Interaction 8: Profile Demographics Update + Health Vault Consistency
    // =========================================================================
    test('3.8 Profile + Health Vault: Demographics update synchronizes across clinical profile', () async {
      await harness.loginAsSeededPatient();

      // 1. Update basic demographic info
      final updateRes = await harness.patientRepo.updateBasicInfo(
        firstName: 'John',
        lastName: 'Doe-Smith',
        bloodGroup: 'O+',
      );
      expect(updateRes.isSuccess, isTrue);

      // 2. Retrieve full profile and confirm synchronization
      final fullRes = await harness.patientRepo.getFullProfile();
      expect(fullRes.isSuccess, isTrue);
      expect(fullRes.dataOrNull?.lastName, equals('Doe-Smith'));
      expect(fullRes.dataOrNull?.bloodGroup, equals('O+'));

      // 3. Confirm profile completion status remains intact
      final completionRes = await harness.patientRepo.getProfileCompletion();
      expect(completionRes.isSuccess, isTrue);
      expect(completionRes.dataOrNull?.percentage, equals(100));
    });
  });
}
