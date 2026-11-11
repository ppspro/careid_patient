/// CareID Family Members & Invitations Data Models
/// Grounded in OpenAPI 3.0.0 and Postman Collection for `12. Family Members & Relationships`
class FamilyInvitationDto {
  final String id;
  final String? inviteeName;
  final String inviteePhone;
  final String relationship;
  final String? relationshipType;
  final String status; // PENDING, ACCEPTED, REJECTED, EXPIRED
  final String? createdAt;

  const FamilyInvitationDto({
    required this.id,
    this.inviteeName,
    required this.inviteePhone,
    required this.relationship,
    this.relationshipType,
    this.status = 'PENDING',
    this.createdAt,
  });

  factory FamilyInvitationDto.fromJson(Map<String, dynamic> json) {
    return FamilyInvitationDto(
      id: json['id']?.toString() ?? json['consentId']?.toString() ?? '',
      inviteeName: json['inviteeName']?.toString() ?? json['name']?.toString(),
      inviteePhone: json['inviteePhone']?.toString() ?? json['phone']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? 'Family Member',
      relationshipType: json['relationshipType']?.toString() ?? json['relationship']?.toString(),
      status: (json['status']?.toString() ?? 'PENDING').toUpperCase(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'inviteePhone': inviteePhone,
    'relationship': relationship,
    if (inviteeName != null) 'inviteeName': inviteeName,
    if (relationshipType != null) 'relationshipType': relationshipType,
  };
}

class FamilyMemberDto {
  final String id;
  final String fullName;
  final String relationship;
  final String? phone;
  final String? bloodGroup;
  final String? avatarUrl;
  final int? age;
  final String? healthCardStatus;
  final String? insurancePlan;
  final String? consentStatus;
  final bool isVerified;

  String get name => fullName;

  const FamilyMemberDto({
    required this.id,
    required this.fullName,
    required this.relationship,
    this.phone,
    this.bloodGroup,
    this.avatarUrl,
    this.age,
    this.healthCardStatus = 'Active',
    this.insurancePlan = 'Global Care Plus',
    this.consentStatus = 'Full Access',
    this.isVerified = true,
  });

  factory FamilyMemberDto.fromJson(Map<String, dynamic> json) {
    return FamilyMemberDto(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? 'Family Member',
      relationship: json['relationship']?.toString() ?? 'Dependent',
      phone: json['phone']?.toString(),
      bloodGroup: json['bloodGroup']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      age: json['age'] is int ? json['age'] as int : int.tryParse(json['age']?.toString() ?? ''),
      healthCardStatus: json['healthCardStatus']?.toString() ?? 'Active',
      insurancePlan: json['insurancePlan']?.toString() ?? 'Global Care Plus',
      consentStatus: json['consentStatus']?.toString() ?? 'Full Access',
      isVerified: json['isVerified'] == null ? true : (json['isVerified'] == true || json['isVerified'].toString() == 'true'),
    );
  }
}
