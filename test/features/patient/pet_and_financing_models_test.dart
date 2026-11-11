import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/features/patient/data/models/pet_models.dart';
import 'package:careid_patient_app/features/patient/data/models/financing_models.dart';
import 'package:careid_patient_app/features/patient/data/models/support_ticket_models.dart';

void main() {
  group('Pet Models & DTO Unit Tests', () {
    test('PetModel deserializes correctly from backend JSON', () {
      final json = {
        'id': 'pet-101',
        'name': 'Max',
        'species': 'Canine',
        'breed': 'Golden Retriever',
        'age': 3,
        'gender': 'Male',
        'microchipId': '985141002345678',
        'vaccinations': [
          {
            'id': 'vac-01',
            'petId': 'pet-101',
            'vaccineName': 'Rabies Core Booster',
            'administeredDate': '2023-09-14',
            'dueDate': '2024-09-14',
            'veterinarian': 'Dr. Amanda Bell, DVM',
            'clinicName': 'Metropolitan Veterinary Hospital',
            'batchNumber': 'DEF-2023-RAB-9912',
          }
        ]
      };

      final pet = PetModel.fromJson(json);
      expect(pet.id, 'pet-101');
      expect(pet.name, 'Max');
      expect(pet.species, 'Canine');
      expect(pet.breed, 'Golden Retriever');
      expect(pet.age, 3.0);
      expect(pet.vaccinations.length, 1);
      expect(pet.vaccinations.first.vaccineName, 'Rabies Core Booster');
      expect(pet.vaccinations.first.clinicName, 'Metropolitan Veterinary Hospital');
    });

    test('PetVaccinationModel serializes and deserializes cleanly', () {
      const vac = PetVaccinationModel(
        id: 'vac-02',
        petId: 'pet-101',
        vaccineName: 'DHPP 4-in-1',
        administeredDate: '2023-09-14',
        dueDate: '2024-09-14',
        batchNumber: 'ZOE-2023-DHPP-441',
      );

      final json = vac.toJson();
      expect(json['vaccineName'], 'DHPP 4-in-1');
      expect(json['batchNumber'], 'ZOE-2023-DHPP-441');
    });
  });

  group('Healthcare Financing Models Unit Tests', () {
    test('FinancingOptionModel parses valid tenures and limits', () {
      final json = {
        'id': 'opt-01',
        'name': 'Zero-Cost Care EMI',
        'partnerName': 'CareFinance Partners',
        'minAmount': 500.0,
        'maxAmount': 20000.0,
        'interestRate': 0.0,
        'availableTenures': [3, 6, 12, 18],
        'isActive': true,
      };

      final option = FinancingOptionModel.fromJson(json);
      expect(option.id, 'opt-01');
      expect(option.name, 'Zero-Cost Care EMI');
      expect(option.minAmount, 500.0);
      expect(option.maxAmount, 20000.0);
      expect(option.availableTenures, [3, 6, 12, 18]);
      expect(option.isActive, isTrue);
    });

    test('FinancingApplicationModel serializes request payload properly', () {
      const app = FinancingApplicationModel(
        id: 'app-991',
        optionId: 'opt-01',
        treatmentName: 'Comprehensive Dental Restoration',
        requestedAmount: 920.0,
        tenureMonths: 12,
        notes: 'Pre-approved 0% interest application',
      );

      final json = app.toJson();
      expect(json['optionId'], 'opt-01');
      expect(json['treatmentName'], 'Comprehensive Dental Restoration');
      expect(json['requestedAmount'], 920.0);
      expect(json['tenureMonths'], 12);
      expect(json['notes'], 'Pre-approved 0% interest application');
    });
  });

  group('Support Ticket Models Unit Tests', () {
    test('SupportTicketModel and SupportReplyModel parse structure', () {
      final json = {
        'id': 'TCK-2023-8841',
        'subject': 'Prescription PDF Download Issue',
        'description': 'Download times out on mobile network',
        'category': 'TECHNICAL',
        'priority': 'MEDIUM',
        'status': 'RESOLVED',
        'replies': [
          {
            'id': 'REP-01',
            'ticketId': 'TCK-2023-8841',
            'authorName': 'CareID Agent',
            'authorRole': 'SUPPORT',
            'message': 'Resolved file storage latency',
          }
        ]
      };

      final ticket = SupportTicketModel.fromJson(json);
      expect(ticket.id, 'TCK-2023-8841');
      expect(ticket.category, 'TECHNICAL');
      expect(ticket.status, 'RESOLVED');
      expect(ticket.replies.length, 1);
      expect(ticket.replies.first.authorRole, 'SUPPORT');
      expect(ticket.replies.first.message, 'Resolved file storage latency');
    });
  });
}

