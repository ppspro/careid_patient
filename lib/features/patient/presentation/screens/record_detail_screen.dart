import 'package:flutter/material.dart';

import '../../data/models/medical_record_models.dart';
import 'dental_record_detail_screen.dart';
import 'medical_record_detail_screen.dart';
import 'pet_record_detail_screen.dart';
import 'vision_record_detail_screen.dart';

/// CareID Patient App — Clinical Record Detail Screen Router
/// Polymorphic router that delegates to domain-specific Figma designs:
/// - Vision: `VisionRecordDetailScreen` (Figma 20:25410 & 20:32573, 390x2030)
/// - Dental: `DentalRecordDetailScreen` (Figma 20:25653, 390x1854)
/// - Medical/General: `MedicalRecordDetailScreen` (Figma 20:25209 & 20:24484, 390x1776)
/// - Pet/Vet: `PetRecordDetailScreen` (Figma 20:26229, 390x1776)
class RecordDetailScreen extends StatelessWidget {
  final MedicalRecordDto record;
  final String? patientInitials;
  final String language;

  const RecordDetailScreen({
    super.key,
    required this.record,
    this.patientInitials,
    this.language = 'en',
  });

  @override
  Widget build(BuildContext context) {
    final cat = record.category.toUpperCase();

    if (cat.contains('VISION') || cat.contains('EYE') || cat.contains('OPTOMETRY')) {
      return VisionRecordDetailScreen(
        record: record,
        patientInitials: patientInitials,
        language: language,
      );
    } else if (cat.contains('DENTAL') || cat.contains('TOOTH') || cat.contains('ORAL')) {
      return DentalRecordDetailScreen(
        record: record,
        patientInitials: patientInitials,
        language: language,
      );
    } else if (cat.contains('PET') || cat.contains('VET') || cat.contains('ANIMAL')) {
      return PetRecordDetailScreen(
        recordData: {
          'id': record.id,
          'title': record.title,
          'category': 'Vaccines',
          'date': record.recordDate ?? 'Sep 14, 2023',
          'nextDue': 'Sep 14, 2024',
          'vetName': record.doctorName ?? 'Dr. Amanda Bell, DVM',
          'clinic': record.facilityName ?? 'Metropolitan Veterinary Hospital',
          'batch': 'DEF-2023-RAB-9912',
          'status': 'Compliant',
        },
        patientInitials: patientInitials,
        language: language,
      );
    } else {
      return MedicalRecordDetailScreen(
        record: record,
        patientInitials: patientInitials,
        language: language,
      );
    }
  }
}
