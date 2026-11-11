import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/patient/data/models/referral_models.dart';
import 'package:careid_patient_app/features/patient/data/repositories/referral_repository.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/referrals_screen.dart';

void main() {
  group('CareID Clinical Referrals Suite (Folder 11)', () {
    test('ReferralDto JSON serialization & deserialization', () {
      final json = {
        'id': 'ref-test-01',
        'patientId': 'patient-01',
        'receivingFacilityId': 'fac-01',
        'receivingFacilityName': 'General Medical Center',
        'receivingDoctorId': 'doc-01',
        'receivingDoctorName': 'Dr. Alexander Bell, MD',
        'specialty': 'Neurology',
        'priority': 'URGENT',
        'status': 'IN_PROGRESS',
        'reasonForReferral': 'Recurring migraine evaluation',
        'clinicalSummary': 'MRI requested',
        'createdAt': '2026-11-04T10:00:00.000Z',
      };

      final dto = ReferralDto.fromJson(json);
      expect(dto.id, 'ref-test-01');
      expect(dto.receivingDoctorName, 'Dr. Alexander Bell, MD');
      expect(dto.priority, ReferralPriority.urgent);
      expect(dto.status, ReferralStatus.inProgress);

      final outJson = dto.toJson();
      expect(outJson['specialty'], 'Neurology');
      expect(outJson['priority'], 'URGENT');
    });

    test('ReferralRepository fallback and in-memory insertion', () async {
      final repo = ReferralRepository();
      final res = await repo.getReferrals();
      expect(res.isSuccess, true);
      expect(res.dataOrNull!.isNotEmpty, true);

      const newRef = ReferralDto(
        id: 'ref-new-99',
        patientId: 'patient-99',
        receivingFacilityId: 'fac-99',
        receivingDoctorId: 'doc-99',
        receivingDoctorName: 'Dr. Jane Smith',
        specialty: 'Dermatology',
      );

      final createRes = await repo.createReferral(newRef);
      expect(createRes.isSuccess, true);

      final getRes = await repo.getReferralById('ref-new-99');
      expect(getRes.isSuccess, true);
      expect(getRes.dataOrNull?.receivingDoctorName, 'Dr. Jane Smith');
    });

    testWidgets('ReferralsScreen renders header, banner, filter chips, and cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ReferralsScreen(language: 'en'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header
      expect(find.text('Clinical Referrals & Coordination'), findsOneWidget);
      expect(find.text('Active Care Referrals'), findsOneWidget);

      // Filter chips
      expect(find.text('All Referrals'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Seeded Referral Card
      expect(find.text('Dr. Sarah Jenkins, MD'), findsOneWidget);
      expect(find.text('Cardiovascular Care'), findsOneWidget);
      expect(find.text('CareID Encrypted Referral'), findsAtLeastNWidgets(1));
    });
  });
}

