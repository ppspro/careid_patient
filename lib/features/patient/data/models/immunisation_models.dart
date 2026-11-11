/// Immunisation models grounded in Postman folder `11. Immunisation Management`

class VaccineDto {
  final String id;
  final String name;
  final String? code;
  final String? manufacturer;
  final String? targetGroup;
  final double? minAgeMonths;
  final double? maxAgeMonths;
  final double? totalDosesRequired;
  final double? minIntervalDays;
  final String? description;
  final List<String> contraindications;
  final bool isActive;
  final String? createdAt;

  const VaccineDto({
    required this.id,
    required this.name,
    this.code,
    this.manufacturer,
    this.targetGroup,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.totalDosesRequired,
    this.minIntervalDays,
    this.description,
    this.contraindications = const [],
    this.isActive = true,
    this.createdAt,
  });

  factory VaccineDto.fromJson(Map<String, dynamic> json) {
    final rawContra = json['contraindications'];
    final List<String> contra = [];
    if (rawContra is List) {
      for (final c in rawContra) {
        if (c != null) contra.add(c.toString());
      }
    }

    return VaccineDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Vaccine',
      code: json['code']?.toString(),
      manufacturer: json['manufacturer']?.toString(),
      targetGroup: json['targetGroup']?.toString(),
      minAgeMonths: (json['minAgeMonths'] as num?)?.toDouble(),
      maxAgeMonths: (json['maxAgeMonths'] as num?)?.toDouble(),
      totalDosesRequired: (json['totalDosesRequired'] as num?)?.toDouble(),
      minIntervalDays: (json['minIntervalDays'] as num?)?.toDouble(),
      description: json['description']?.toString(),
      contraindications: contra,
      isActive: json['isActive'] == true || json['isActive'] == null,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (code != null) 'code': code,
    if (manufacturer != null) 'manufacturer': manufacturer,
    if (targetGroup != null) 'targetGroup': targetGroup,
    if (minAgeMonths != null) 'minAgeMonths': minAgeMonths,
    if (maxAgeMonths != null) 'maxAgeMonths': maxAgeMonths,
    if (totalDosesRequired != null) 'totalDosesRequired': totalDosesRequired,
    if (minIntervalDays != null) 'minIntervalDays': minIntervalDays,
    if (description != null) 'description': description,
    'contraindications': contraindications,
    'isActive': isActive,
    if (createdAt != null) 'createdAt': createdAt,
  };

  int get requiredDoses => (totalDosesRequired ?? 1).toInt();
}

class PatientVaccinationRecordDto {
  final String id;
  final String? patientProfileId;
  final String? vaccineId;
  final String? scheduleId;
  final double? doseNumber;
  final String? status;
  final String? dueDate;
  final String? administeredDate;
  final String? administeredBy;
  final String? facilityName;
  final String? batchNumber;
  final String? lotNumber;
  final String? notes;
  final VaccineDto? vaccine;

  const PatientVaccinationRecordDto({
    required this.id,
    this.patientProfileId,
    this.vaccineId,
    this.scheduleId,
    this.doseNumber,
    this.status,
    this.dueDate,
    this.administeredDate,
    this.administeredBy,
    this.facilityName,
    this.batchNumber,
    this.lotNumber,
    this.notes,
    this.vaccine,
  });

  factory PatientVaccinationRecordDto.fromJson(Map<String, dynamic> json) {
    VaccineDto? v;
    if (json['vaccine'] is Map<String, dynamic>) {
      v = VaccineDto.fromJson(json['vaccine'] as Map<String, dynamic>);
    }

    return PatientVaccinationRecordDto(
      id: json['id']?.toString() ?? '',
      patientProfileId: json['patientProfileId']?.toString(),
      vaccineId: json['vaccineId']?.toString(),
      scheduleId: json['scheduleId']?.toString(),
      doseNumber: (json['doseNumber'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? 'COMPLETED',
      dueDate: json['dueDate']?.toString(),
      administeredDate: json['administeredDate']?.toString(),
      administeredBy: json['administeredBy']?.toString(),
      facilityName: json['facilityName']?.toString(),
      batchNumber: json['batchNumber']?.toString(),
      lotNumber: json['lotNumber']?.toString(),
      notes: json['notes']?.toString(),
      vaccine: v,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (patientProfileId != null) 'patientProfileId': patientProfileId,
    if (vaccineId != null) 'vaccineId': vaccineId,
    if (scheduleId != null) 'scheduleId': scheduleId,
    if (doseNumber != null) 'doseNumber': doseNumber,
    if (status != null) 'status': status,
    if (dueDate != null) 'dueDate': dueDate,
    if (administeredDate != null) 'administeredDate': administeredDate,
    if (administeredBy != null) 'administeredBy': administeredBy,
    if (facilityName != null) 'facilityName': facilityName,
    if (batchNumber != null) 'batchNumber': batchNumber,
    if (lotNumber != null) 'lotNumber': lotNumber,
    if (notes != null) 'notes': notes,
    if (vaccine != null) 'vaccine': vaccine!.toJson(),
  };

  String get displayName => vaccine?.name ?? 'Immunisation Record';
  int get currentDose => (doseNumber ?? 1).toInt();
}

