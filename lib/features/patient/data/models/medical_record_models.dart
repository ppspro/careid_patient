/// CareID Medical Records Data Models
/// Grounded in OpenAPI 3.0.0 and Postman Collection for `08. Medical Records`
class MedicalRecordDto {
  final String id;
  final String? patientProfileId;
  final String title;
  final String category; // GENERAL, DENTAL, VISION
  final String? chiefComplaint;
  final String? clinicalNotes;
  final String? treatmentPlan;
  final String? diagnosis;
  final String? doctorName;
  final String? facilityName;
  final String? recordDate;
  final List<String> attachments;
  final String status;

  const MedicalRecordDto({
    required this.id,
    this.patientProfileId,
    required this.title,
    this.category = 'GENERAL',
    this.chiefComplaint,
    this.clinicalNotes,
    this.treatmentPlan,
    this.diagnosis,
    this.doctorName,
    this.facilityName,
    this.recordDate,
    this.attachments = const [],
    this.status = 'ACTIVE',
  });

  factory MedicalRecordDto.fromJson(Map<String, dynamic> json) {
    return MedicalRecordDto(
      id: json['id']?.toString() ?? '',
      patientProfileId: json['patientProfileId']?.toString(),
      title: json['title']?.toString() ?? 'Medical Record',
      category: (json['category']?.toString() ?? 'GENERAL').toUpperCase(),
      chiefComplaint: json['chiefComplaint']?.toString(),
      clinicalNotes: json['clinicalNotes']?.toString(),
      treatmentPlan: json['treatmentPlan']?.toString(),
      diagnosis: json['diagnosis']?.toString() ??
          ((json['diagnoses'] as List?)?.isNotEmpty == true
              ? (json['diagnoses'][0] is Map ? json['diagnoses'][0]['description']?.toString() : null)
              : null),
      doctorName: json['doctorName']?.toString() ?? json['doctor']?['name']?.toString(),
      facilityName: json['facilityName']?.toString() ?? json['facility']?['name']?.toString(),
      recordDate: json['recordDate']?.toString() ?? json['createdAt']?.toString(),
      attachments: (json['attachments'] as List?)
              ?.map((e) => e is Map ? (e['url'] ?? e['storageUrl'] ?? e['fileName'] ?? e['name'] ?? '').toString() : e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'chiefComplaint': chiefComplaint,
    'clinicalNotes': clinicalNotes,
    'treatmentPlan': treatmentPlan,
    'diagnosis': diagnosis,
    'status': status,
  };
}

/// Unified timeline entry combining medical records and document attachments
class MedicalTimelineItemDto {
  final String id;
  final String eventType; // MEDICAL_RECORD, ATTACHMENT, ENCOUNTER
  final String title;
  final String? category;
  final String date;
  final String? status;

  const MedicalTimelineItemDto({
    required this.id,
    required this.eventType,
    required this.title,
    this.category,
    required this.date,
    this.status,
  });

  factory MedicalTimelineItemDto.fromJson(Map<String, dynamic> json) {
    return MedicalTimelineItemDto(
      id: json['id']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? 'MEDICAL_RECORD',
      title: json['title']?.toString() ?? 'Clinical Event',
      category: json['category']?.toString(),
      date: json['date']?.toString() ?? json['createdAt']?.toString() ?? '',
      status: json['status']?.toString(),
    );
  }
}

