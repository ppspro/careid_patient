/// Facility model grounded in Postman folder `09. Facilities & Branches`
class FacilityDepartmentDto {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final String? departmentHead;

  const FacilityDepartmentDto({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.departmentHead,
  });

  factory FacilityDepartmentDto.fromJson(Map<String, dynamic> json) {
    return FacilityDepartmentDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Clinical Department',
      code: json['code']?.toString(),
      description: json['description']?.toString(),
      departmentHead: json['departmentHead']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (code != null) 'code': code,
    if (description != null) 'description': description,
    if (departmentHead != null) 'departmentHead': departmentHead,
  };
}

class FacilityDto {
  final String id;
  final String name;
  final String? legalName;
  final String? facilityCode;
  final String? facilityType;
  final String? ownershipType;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? country;
  final String? phone;
  final String? emergencyPhone;
  final String? email;
  final String? verificationStatus;
  final List<FacilityDepartmentDto> departments;

  const FacilityDto({
    required this.id,
    required this.name,
    this.legalName,
    this.facilityCode,
    this.facilityType,
    this.ownershipType,
    this.streetAddress,
    this.city,
    this.state,
    this.country,
    this.phone,
    this.emergencyPhone,
    this.email,
    this.verificationStatus,
    this.departments = const [],
  });

  factory FacilityDto.fromJson(Map<String, dynamic> json) {
    final rawDepts = json['departments'];
    final List<FacilityDepartmentDto> depts = [];
    if (rawDepts is List) {
      for (final d in rawDepts) {
        if (d is Map<String, dynamic>) {
          depts.add(FacilityDepartmentDto.fromJson(d));
        }
      }
    }

    return FacilityDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Medical Facility',
      legalName: json['legalName']?.toString(),
      facilityCode: json['facilityCode']?.toString(),
      facilityType: json['facilityType']?.toString() ?? 'HOSPITAL',
      ownershipType: json['ownershipType']?.toString(),
      streetAddress: json['streetAddress']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      phone: json['phone']?.toString(),
      emergencyPhone: json['emergencyPhone']?.toString(),
      email: json['email']?.toString(),
      verificationStatus: json['verificationStatus']?.toString() ?? 'VERIFIED',
      departments: depts,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (legalName != null) 'legalName': legalName,
    if (facilityCode != null) 'facilityCode': facilityCode,
    if (facilityType != null) 'facilityType': facilityType,
    if (ownershipType != null) 'ownershipType': ownershipType,
    if (streetAddress != null) 'streetAddress': streetAddress,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (country != null) 'country': country,
    if (phone != null) 'phone': phone,
    if (emergencyPhone != null) 'emergencyPhone': emergencyPhone,
    if (email != null) 'email': email,
    if (verificationStatus != null) 'verificationStatus': verificationStatus,
    'departments': departments.map((d) => d.toJson()).toList(),
  };

  String get fullAddress {
    final parts = [streetAddress, city, state, country].where((p) => p != null && p.trim().isNotEmpty).toList();
    if (parts.isEmpty) return 'Springfield, US';
    return parts.join(', ');
  }

  bool get isHospital => (facilityType ?? '').toUpperCase().contains('HOSPITAL');
  bool get isDiagnosticCenter => (facilityType ?? '').toUpperCase().contains('DIAGNOSTIC');
}

