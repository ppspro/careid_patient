import 'package:test/test.dart';

import 'package:careid_patient_app/features/patient/data/models/family_models.dart';
import 'package:careid_patient_app/features/patient/data/models/insurance_policy_models.dart';
import 'package:careid_patient_app/features/patient/data/models/medical_record_models.dart';
import 'package:careid_patient_app/features/patient/data/models/patient_profile_models.dart';

void main() {
  group('Patient Module Models & DTO Tests', () {
    test('PatientProfileDto parses correctly from JSON', () {
      final json = {
        'id': 'p-123',
        'patientNumber': 'PT-2026-0001',
        'firstName': 'John',
        'lastName': 'Doe',
        'phone': '+16505550004',
        'email': 'john.doe@example.com',
        'dateOfBirth': '1990-01-01',
        'gender': 'Male',
        'bloodGroup': 'O+',
        'knownAllergies': ['Penicillin', 'Peanuts'],
        'chronicConditions': ['Asthma'],
        'status': 'ACTIVE',
      };

      final profile = PatientProfileDto.fromJson(json);

      expect(profile.id, equals('p-123'));
      expect(profile.fullName, equals('John Doe'));
      expect(profile.bloodGroup, equals('O+'));
      expect(profile.allergies.length, equals(2));
      expect(profile.conditions, contains('Asthma'));
      expect(profile.isProfileComplete, isTrue);
    });

    test('MedicalRecordDto serialization and JSON parsing', () {
      const record = MedicalRecordDto(
        id: 'rec-1',
        title: 'Annual Dental Cleaning',
        category: 'DENTAL',
        chiefComplaint: 'Routine prophylactic checkup',
        clinicalNotes: 'Teeth healthy, no caries detected',
        treatmentPlan: 'Maintain twice-daily brushing',
      );

      final json = record.toJson();
      expect(json['title'], equals('Annual Dental Cleaning'));
      expect(json['category'], equals('DENTAL'));

      final parsed = MedicalRecordDto.fromJson({
        'id': 'rec-1',
        ...json,
      });

      expect(parsed.id, equals('rec-1'));
      expect(parsed.category, equals('DENTAL'));
    });

    test('InsurancePolicyDto parses and serializes correctly', () {
      const policy = InsurancePolicyDto(
        id: 'pol-1',
        providerName: 'State Life Health Insurance',
        policyNumber: 'POL-998877',
        groupNumber: 'GRP-100',
        status: 'ACTIVE',
      );

      final json = policy.toJson();
      expect(json['providerName'], equals('State Life Health Insurance'));
      expect(json['policyNumber'], equals('POL-998877'));
      expect(json['groupNumber'], equals('GRP-100'));

      final parsed = InsurancePolicyDto.fromJson({'id': 'pol-1', ...json});
      expect(parsed.providerName, equals('State Life Health Insurance'));
      expect(parsed.status, equals('ACTIVE'));
    });

    test('FamilyInvitationDto parses correctly from JSON', () {
      final json = {
        'id': 'inv-1',
        'inviteeName': 'Jane Doe',
        'inviteePhone': '+14155559876',
        'relationship': 'Spouse',
        'status': 'PENDING',
      };

      final inv = FamilyInvitationDto.fromJson(json);
      expect(inv.id, equals('inv-1'));
      expect(inv.inviteeName, equals('Jane Doe'));
      expect(inv.relationship, equals('Spouse'));
      expect(inv.status, equals('PENDING'));
    });
  });
}

