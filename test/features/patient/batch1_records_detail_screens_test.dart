import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/patient/data/models/medical_record_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/dental_record_detail_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/medical_record_detail_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/pet_record_detail_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/pet_records_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/record_detail_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/vision_record_detail_screen.dart';

void main() {
  group('Batch 1 — Health Records & Clinical Detail Screens Widget Tests', () {
    testWidgets('VisionRecordDetailScreen renders all Figma components and clinical data', (tester) async {
      const visionRecord = MedicalRecordDto(
        id: 'REC-VISION-01',
        title: 'Retinal Fundus OCT Examination',
        category: 'VISION',
        doctorName: 'Dr. Sarah Lin, MD',
        facilityName: 'VisionCare Eye Specialists',
        recordDate: 'Oct 18, 2023',
        status: 'ACTIVE',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: VisionRecordDetailScreen(
            record: visionRecord,
            patientInitials: 'JD',
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Header & Verification
      expect(find.text('Record Details'), findsOneWidget);
      expect(find.text('Verified & End-to-End Encrypted'), findsOneWidget);
      expect(find.text('CR-8942-V'), findsOneWidget);

      // Hero Card & Overlays
      expect(find.text('Retinal Fundus OCT Examination'), findsOneWidget);
      expect(find.text('Retinal Fundus OCT Scan'), findsOneWidget);
      expect(find.text('Diagnostic Grade HD'), findsOneWidget);

      // 4 Quick Actions
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Print'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);

      // Attending Provider
      expect(find.text('Attending Provider'), findsOneWidget);
      expect(find.text('Dr. Sarah Lin, MD'), findsOneWidget);
      expect(find.text('VisionCare Eye Specialists'), findsOneWidget);
      expect(find.text('Lic. #OD- 8896'), findsOneWidget);

      // Refraction Matrix
      expect(find.text('Visual Refraction & Acuity Assessment'), findsOneWidget);
      expect(find.text('OD (Right)'), findsOneWidget);
      expect(find.text('OS (Left)'), findsOneWidget);
      expect(find.text('20/20'), findsOneWidget);
      expect(find.text('20/25'), findsOneWidget);

      // Attachments & Notes
      expect(find.text('Attachments (2 Files)'), findsOneWidget);
      expect(find.text('Retinal_Scan_HighRes_OCT.pdf'), findsOneWidget);
      expect(find.text('Fundus_Color_Composite.jpg'), findsOneWidget);
      expect(find.text('Clinical Observations & Notes'), findsOneWidget);
      expect(find.text('Export PDF'), findsOneWidget);
      expect(find.text('Share Link'), findsOneWidget);
    });

    testWidgets('DentalRecordDetailScreen renders all Figma components and tooth arch data', (tester) async {
      const dentalRecord = MedicalRecordDto(
        id: 'REC-DENTAL-01',
        title: 'Dental Panoramic X-Ray & Exam',
        category: 'DENTAL',
        doctorName: 'Dr. Michael Vance, DDS',
        facilityName: 'Dental Care Specialists',
        recordDate: 'Oct 05, 2023',
        status: 'ACTIVE',
        clinicalNotes: 'Routine panoramic X-ray taken for annual check-up. No significant abnormalities noted.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: DentalRecordDetailScreen(
            record: dentalRecord,
            patientInitials: 'JD',
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Header & Verification
      expect(find.text('Record Details'), findsOneWidget);
      expect(find.text('Verified & End-to-End Encrypted'), findsOneWidget);
      expect(find.text('CR-7721-D'), findsOneWidget);

      // Hero Card
      expect(find.text('Dental Panoramic X-Ray & Exam'), findsOneWidget);
      expect(find.text('Panoramic Arch OPG'), findsOneWidget);
      expect(find.text('Complete Dentition'), findsOneWidget);

      // Attending Provider
      expect(find.text('Dr. Michael Vance, DDS'), findsOneWidget);
      expect(find.text('Dental Care Specialists'), findsOneWidget);
      expect(find.text('Lic. #OD- 7721'), findsOneWidget);

      // Tooth Arch & Periodontal Status
      expect(find.text('Dental Arch & Periodontal Status'), findsOneWidget);
      expect(find.text('Periodontal Depth'), findsOneWidget);
      expect(find.text('1 - 3 mm'), findsOneWidget);
      expect(find.text('Caries Risk'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);

      // Attachments & Notes
      expect(find.text('Dental X-Ray Observations.pdf'), findsOneWidget);
      expect(find.text('Dental X-Ray.jpg'), findsOneWidget);
      expect(find.textContaining('Routine panoramic X-ray taken for annual check-up'), findsOneWidget);
    });

    testWidgets('MedicalRecordDetailScreen renders all biomarker panels and consultation details', (tester) async {
      const medicalRecord = MedicalRecordDto(
        id: 'REC-MED-01',
        title: 'Comprehensive Metabolic & Lipid Panel',
        category: 'GENERAL',
        doctorName: 'Dr. Robert Chen, MD',
        facilityName: 'CareID Internal Medicine Center',
        recordDate: 'Oct 12, 2023',
        status: 'ACTIVE',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: MedicalRecordDetailScreen(
            record: medicalRecord,
            patientInitials: 'JD',
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Header & Verification
      expect(find.text('Record Details'), findsOneWidget);
      expect(find.text('CR-5582-M'), findsOneWidget);

      // Hero & Attending Doctor
      expect(find.text('Comprehensive Metabolic & Lipid Panel'), findsOneWidget);
      expect(find.text('Dr. Robert Chen, MD'), findsOneWidget);
      expect(find.text('CareID Internal Medicine Center'), findsOneWidget);

      // Biomarkers
      expect(find.text('Key Clinical Biomarkers'), findsOneWidget);
      expect(find.text('Total Cholesterol'), findsOneWidget);
      expect(find.text('185 mg/dL'), findsOneWidget);
      expect(find.text('Fasting Glucose'), findsOneWidget);
      expect(find.text('92 mg/dL'), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);
      expect(find.text('118/76 mmHg'), findsOneWidget);

      // Attachments
      expect(find.text('Comprehensive_Metabolic_Panel.pdf'), findsOneWidget);
      expect(find.text('Physician_Clinical_Summary.pdf'), findsOneWidget);
    });

    testWidgets('PetRecordsScreen renders pet passport, stats, category chips, and records list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PetRecordsScreen(
            language: 'en',
            patientInitials: 'JD',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Pet Header Profile
      expect(find.text('Pet Care Records'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
      expect(find.text('Canine • Male'), findsOneWidget);
      expect(find.text('Golden Retriever • 3 Years Old'), findsOneWidget);
      expect(find.text('Microchip #985141002345678'), findsOneWidget);
      expect(find.text('68 lbs'), findsOneWidget);
      expect(find.text('PET-9942'), findsOneWidget);

      // Filter Chips
      expect(find.text('All Records'), findsOneWidget);
      expect(find.text('Vaccines'), findsOneWidget);
      expect(find.text('Vet Visits'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);

      // Records in timeline
      expect(find.text('Rabies Core Annual Booster'), findsOneWidget);
      expect(find.text('DHPP 4-in-1 Comprehensive Vaccine'), findsOneWidget);
      expect(find.text('Dental Scaling & Oral Health Exam'), findsOneWidget);
      expect(find.text('Add Pet Health Record'), findsOneWidget);
    });

    testWidgets('PetRecordDetailScreen renders immunization certificate and vet vitals', (tester) async {
      final petData = {
        'id': 'PET-REC-01',
        'title': 'Rabies Core Annual Booster',
        'category': 'Vaccines',
        'date': 'Sep 14, 2023',
        'nextDue': 'Sep 14, 2024',
        'vetName': 'Dr. Amanda Bell, DVM',
        'clinic': 'Metropolitan Veterinary Hospital',
        'batch': 'DEF-2023-RAB-9912',
        'status': 'Compliant',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: PetRecordDetailScreen(
            recordData: petData,
            patientInitials: 'JD',
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Pet Record Detail'), findsOneWidget);
      expect(find.text('Microchip #985141002345678'), findsOneWidget);
      expect(find.text('PET-9942'), findsOneWidget);
      expect(find.text('Rabies Core Annual Booster'), findsOneWidget);
      expect(find.text('Dr. Amanda Bell, DVM'), findsOneWidget);
      expect(find.text('Metropolitan Veterinary Hospital'), findsOneWidget);
      expect(find.text('Wellness Vitals on Exam Date'), findsOneWidget);
      expect(find.text('68.4 lbs'), findsOneWidget);
      expect(find.text('101.4 °F'), findsOneWidget);
      expect(find.text('Rabies_Vaccination_Certificate.pdf'), findsOneWidget);
      expect(find.text('Export Certificate'), findsOneWidget);
    });

    testWidgets('RecordDetailScreen polymorphism routes cleanly based on category', (tester) async {
      // 1. Vision Category
      const visionRec = MedicalRecordDto(id: '1', title: 'Vision Test', category: 'VISION');
      await tester.pumpWidget(const MaterialApp(home: RecordDetailScreen(record: visionRec)));
      await tester.pump();
      expect(find.byType(VisionRecordDetailScreen), findsOneWidget);

      // 2. Dental Category
      const dentalRec = MedicalRecordDto(id: '2', title: 'Dental Test', category: 'DENTAL');
      await tester.pumpWidget(const MaterialApp(home: RecordDetailScreen(record: dentalRec)));
      await tester.pump();
      expect(find.byType(DentalRecordDetailScreen), findsOneWidget);

      // 3. Medical Category
      const medRec = MedicalRecordDto(id: '3', title: 'Med Test', category: 'GENERAL');
      await tester.pumpWidget(const MaterialApp(home: RecordDetailScreen(record: medRec)));
      await tester.pump();
      expect(find.byType(MedicalRecordDetailScreen), findsOneWidget);

      // 4. Pet Category
      const petRec = MedicalRecordDto(id: '4', title: 'Pet Test', category: 'PET_VACCINE');
      await tester.pumpWidget(const MaterialApp(home: RecordDetailScreen(record: petRec)));
      await tester.pump();
      expect(find.byType(PetRecordDetailScreen), findsOneWidget);
    });
  });
}

