/// CareID Family Members & Invitations Data Models
/// Grounded in OpenAPI 3.0.0 and Postman Collection for `12. Family Members & Relationships`
class FamilyInvitationDto {
  final String id;
  final String? inviteeName;
  final String inviteePhone;
  final String relationship;
  final String? relationshipType;
  final String status; // PENDING, ACCEPTED, REJECTED, EXPIRED, CANCELLED
  final String? invitationToken;
  final int resendCount;
  final String? expiresAt;
  final String? acceptedAt;
  final String? rejectedAt;
  final String? cancelledAt;
  final String? createdAt;

  const FamilyInvitationDto({
    required this.id,
    this.inviteeName,
    required this.inviteePhone,
    required this.relationship,
    this.relationshipType,
    this.status = 'PENDING',
    this.invitationToken,
    this.resendCount = 0,
    this.expiresAt,
    this.acceptedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.createdAt,
  });

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isAccepted => status.toUpperCase() == 'ACCEPTED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get isExpired => status.toUpperCase() == 'EXPIRED';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';
  bool get canResend => isPending && resendCount < 5;

  factory FamilyInvitationDto.fromJson(Map<String, dynamic> json) {
    return FamilyInvitationDto(
      id: json['id']?.toString() ?? json['consentId']?.toString() ?? '',
      inviteeName: json['inviteeName']?.toString() ?? json['name']?.toString(),
      inviteePhone: json['inviteePhone']?.toString() ?? json['phone']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? 'Family Member',
      relationshipType: json['relationshipType']?.toString() ?? json['relationship']?.toString(),
      status: (json['status']?.toString() ?? 'PENDING').toUpperCase(),
      invitationToken: json['invitationToken']?.toString(),
      resendCount: json['resendCount'] is int
          ? json['resendCount'] as int
          : int.tryParse(json['resendCount']?.toString() ?? '0') ?? 0,
      expiresAt: json['expiresAt']?.toString(),
      acceptedAt: json['acceptedAt']?.toString(),
      rejectedAt: json['rejectedAt']?.toString(),
      cancelledAt: json['cancelledAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'inviteePhone': inviteePhone,
    'relationship': relationship,
    if (inviteeName != null && inviteeName!.isNotEmpty) 'inviteeName': inviteeName,
    if (relationshipType != null && relationshipType!.isNotEmpty) 'relationshipType': relationshipType,
    if (expiresAt != null && expiresAt!.isNotEmpty) 'expiresAt': expiresAt,
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
