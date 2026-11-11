/// CareID Patient App — Doctor & Provider Models
/// Grounded in OpenAPI 3.0.0 `/api/v1/doctors` specifications

class DoctorModel {
  final String id;
  final String? userId;
  final String fullName;
  final String? gender;
  final String primarySpecialization;
  final List<String> secondarySpecializations;
  final int yearsOfExperience;
  final String? medicalCouncil;
  final String? registrationNumber;
  final String? licenseNumber;
  final String? providerIdentifier;
  final String facilityName;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final List<String> languages;
  final String? bio;
  final String? photoAsset;

  const DoctorModel({
    required this.id,
    this.userId,
    required this.fullName,
    this.gender,
    required this.primarySpecialization,
    this.secondarySpecializations = const [],
    this.yearsOfExperience = 0,
    this.medicalCouncil,
    this.registrationNumber,
    this.licenseNumber,
    this.providerIdentifier,
    this.facilityName = 'Mount Sinai Medical Center',
    this.rating = 4.9,
    this.reviewCount = 128,
    this.isVerified = true,
    this.languages = const ['English', 'Spanish'],
    this.bio,
    this.photoAsset,
  });

  static const List<DoctorModel> seededDoctors = [
    DoctorModel(
      id: 'doc-1',
      fullName: 'Dr. Sarah Jenkins',
      primarySpecialization: 'Internal Medicine',
      secondarySpecializations: ['Preventive Care', 'Cardiovascular Screening'],
      yearsOfExperience: 14,
      facilityName: 'Mount Sinai Medical Center',
      rating: 4.9,
      reviewCount: 128,
      isVerified: true,
      languages: ['English', 'Spanish'],
      bio: 'Dr. Sarah Jenkins is an attending physician specializing in comprehensive health assessments, cardiovascular risk reduction, and preventive medicine with over 14 years of active clinical practice.',
      licenseNumber: 'NY-55193',
      medicalCouncil: 'New York State Board of Medicine',
      photoAsset: 'assets/images/doctor_sarah_jenkins.png',
    ),
    DoctorModel(
      id: 'doc-2',
      fullName: 'Dr. Robert Chen, DDS',
      primarySpecialization: 'Dental Surgery',
      secondarySpecializations: ['Cosmetic Dentistry', 'Endodontics', 'Oral Health'],
      yearsOfExperience: 11,
      facilityName: 'CareID Dental Pavilion',
      rating: 4.8,
      reviewCount: 94,
      isVerified: true,
      languages: ['English', 'Mandarin'],
      bio: 'Dr. Robert Chen provides restorative, preventive, and surgical dental care with specialized expertise in minimally invasive periodontal therapy and dental aesthetics.',
      licenseNumber: 'NY-44218',
      medicalCouncil: 'American Dental Association',
      photoAsset: null,
    ),
    DoctorModel(
      id: 'doc-3',
      fullName: 'Dr. Emily Vance, OD',
      primarySpecialization: 'Optometry & Vision',
      secondarySpecializations: ['Corneal Topography', 'Refractive Care', 'Pediatric Vision'],
      yearsOfExperience: 9,
      facilityName: 'Apex Eye & Vision Center',
      rating: 4.9,
      reviewCount: 112,
      isVerified: true,
      languages: ['English'],
      bio: 'Dr. Emily Vance specializes in comprehensive eye examinations, corneal diagnostics, advanced refractive care, and diabetic retinopathy screening.',
      licenseNumber: 'NY-33891',
      medicalCouncil: 'State Board of Optometry',
      photoAsset: null,
    ),
  ];

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return const [];
    }

    final experience = json['yearsOfExperience'];
    int expYears = 0;
    if (experience is int) {
      expYears = experience;
    } else if (experience is num) {
      expYears = experience.toInt();
    } else if (experience != null) {
      expYears = int.tryParse(experience.toString()) ?? 0;
    }

    return DoctorModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      fullName: json['fullName']?.toString() ?? 'CareID Doctor',
      gender: json['gender']?.toString(),
      primarySpecialization: json['primarySpecialization']?.toString() ?? 'General Practice',
      secondarySpecializations: parseList(json['secondarySpecializations']),
      yearsOfExperience: expYears,
      medicalCouncil: json['medicalCouncil']?.toString(),
      registrationNumber: json['registrationNumber']?.toString(),
      licenseNumber: json['licenseNumber']?.toString(),
      providerIdentifier: json['providerIdentifier']?.toString(),
      facilityName: json['facilityName']?.toString() ?? 'Mount Sinai Medical Center',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.9,
      reviewCount: (json['reviewCount'] is int) ? json['reviewCount'] as int : 128,
      isVerified: json['isVerified'] != false,
      languages: json['languages'] != null ? parseList(json['languages']) : const ['English', 'Spanish'],
      bio: json['bio']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'fullName': fullName,
    'gender': gender,
    'primarySpecialization': primarySpecialization,
    'secondarySpecializations': secondarySpecializations,
    'yearsOfExperience': yearsOfExperience,
    'medicalCouncil': medicalCouncil,
    'registrationNumber': registrationNumber,
    'licenseNumber': licenseNumber,
    'providerIdentifier': providerIdentifier,
    'facilityName': facilityName,
    'rating': rating,
    'reviewCount': reviewCount,
    'isVerified': isVerified,
    'languages': languages,
    'bio': bio,
  };
}

class DoctorScheduleSlotModel {
  final String id;
  final String doctorId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  const DoctorScheduleSlotModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  factory DoctorScheduleSlotModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleSlotModel(
      id: json['id']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '',
      dayOfWeek: json['dayOfWeek']?.toString() ?? 'Monday',
      startTime: json['startTime']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? '17:00',
      isAvailable: json['isAvailable'] != false,
    );
  }
}

