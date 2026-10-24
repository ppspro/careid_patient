/// CareID Onboarding Insurance Models & DTOs
/// Grounded strictly in the OpenAPI 3.0.0 specification from https://360api.vnvision.in/docs
/// and the authoritative Postman collection (Health-Vault-360-API.postman_collection.json).
///
/// Corresponds to:
/// - POST /api/v1/patients/onboarding/insurance (Step 4: Save Primary/Secondary Insurance Link)
/// - PUT /api/v1/patients/onboarding/insurance (Step 4: Update Insurance Details)
/// - POST /api/v1/insurance/onboard (Save insurance details during 6-step patient onboarding)
/// - POST /api/v1/insurance/ocr/scan (Scan insurance card image via OCR extraction)
/// - POST /api/v1/insurance/ocr/confirm (Confirm extracted OCR data to create insurance policy)

class OnboardInsuranceDto {
  final String providerName;
  final String policyNumber;
  final String? groupNumber;
  final String? coverageDetails;

  const OnboardInsuranceDto({
    required this.providerName,
    required this.policyNumber,
    this.groupNumber,
    this.coverageDetails,
  });

  /// Factory constructor parsing from backend JSON response
  factory OnboardInsuranceDto.fromJson(Map<String, dynamic> json) {
    return OnboardInsuranceDto(
      providerName: (json['providerName'] as String?)?.trim() ?? '',
      policyNumber: (json['policyNumber'] as String?)?.trim() ?? '',
      groupNumber: (json['groupNumber'] as String?)?.trim(),
      coverageDetails: (json['coverageDetails'] as String?)?.trim(),
    );
  }

  /// Serializes into the exact payload expected by:
  /// POST /api/v1/patients/onboarding/insurance & POST /api/v1/insurance/onboard
  Map<String, dynamic> toJson() {
    final effectiveCoverage = _computeCoverageDetails();
    return {
      'providerName': providerName.trim(),
      'policyNumber': policyNumber.trim(),
      if (effectiveCoverage != null && effectiveCoverage.isNotEmpty)
        'coverageDetails': effectiveCoverage,
    };
  }

  /// Helper to merge groupNumber into coverageDetails if coverageDetails is not provided
  String? _computeCoverageDetails() {
    if (coverageDetails != null && coverageDetails!.trim().isNotEmpty) {
      return coverageDetails!.trim();
    }
    if (groupNumber != null && groupNumber!.trim().isNotEmpty) {
      return 'Group: ${groupNumber!.trim()}';
    }
    return null;
  }

  OnboardInsuranceDto copyWith({
    String? providerName,
    String? policyNumber,
    String? groupNumber,
    String? coverageDetails,
  }) {
    return OnboardInsuranceDto(
      providerName: providerName ?? this.providerName,
      policyNumber: policyNumber ?? this.policyNumber,
      groupNumber: groupNumber ?? this.groupNumber,
      coverageDetails: coverageDetails ?? this.coverageDetails,
    );
  }

  /// Validates provider name according to field rules (minimum 2 characters, non-empty)
  static bool isValidProviderName(String? name) {
    if (name == null) return false;
    final trimmed = name.trim();
    return trimmed.length >= 2;
  }

  /// Validates policy/member number (minimum 3 characters, alphanumeric with optional hyphens)
  static bool isValidPolicyNumber(String? policyNum) {
    if (policyNum == null) return false;
    final trimmed = policyNum.trim();
    if (trimmed.length < 3) return false;
    final regex = RegExp(r'^[a-zA-Z0-9\-_./#]+$');
    return regex.hasMatch(trimmed);
  }

  /// Validates optional group number (if provided, must be at least 2 alphanumeric chars)
  static bool isValidGroupNumber(String? groupNum) {
    if (groupNum == null || groupNum.trim().isEmpty) return true;
    final trimmed = groupNum.trim();
    final regex = RegExp(r'^[a-zA-Z0-9\-_./#]+$');
    return trimmed.length >= 2 && regex.hasMatch(trimmed);
  }

  /// Returns null if all required fields are valid; otherwise returns a user-friendly error message.
  String? validate() {
    if (!isValidProviderName(providerName)) {
      return 'Please enter a valid insurance provider name.';
    }
    if (!isValidPolicyNumber(policyNumber)) {
      return 'Please enter a valid member ID or policy number.';
    }
    if (!isValidGroupNumber(groupNumber)) {
      return 'Group number format is invalid.';
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardInsuranceDto &&
          runtimeType == other.runtimeType &&
          providerName == other.providerName &&
          policyNumber == other.policyNumber &&
          groupNumber == other.groupNumber &&
          coverageDetails == other.coverageDetails;

  @override
  int get hashCode =>
      providerName.hashCode ^
      policyNumber.hashCode ^
      (groupNumber?.hashCode ?? 0) ^
      (coverageDetails?.hashCode ?? 0);

  @override
  String toString() {
    return 'OnboardInsuranceDto(providerName: $providerName, policyNumber: $policyNumber, groupNumber: $groupNumber, coverageDetails: $coverageDetails)';
  }
}

/// Representation of an insurance card scan captured by camera/picker
class InsuranceCardScanResult {
  final String? localImagePath;
  final String? scannedProvider;
  final String? scannedMemberId;
  final String? scannedGroupNumber;
  final double confidence;
  final bool isSuccessful;

  const InsuranceCardScanResult({
    this.localImagePath,
    this.scannedProvider,
    this.scannedMemberId,
    this.scannedGroupNumber,
    this.confidence = 0.0,
    this.isSuccessful = false,
  });

  /// Converts scanned result into OnboardInsuranceDto
  OnboardInsuranceDto toInsuranceDto() {
    return OnboardInsuranceDto(
      providerName: scannedProvider ?? '',
      policyNumber: scannedMemberId ?? '',
      groupNumber: scannedGroupNumber,
    );
  }
}

/// DTO for POST /api/v1/insurance/ocr/scan
class InsuranceOcrScanDto {
  final String imageUrl;

  const InsuranceOcrScanDto({required this.imageUrl});

  factory InsuranceOcrScanDto.fromJson(Map<String, dynamic> json) {
    return InsuranceOcrScanDto(imageUrl: json['imageUrl'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'imageUrl': imageUrl};

  static bool isValidImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }
}

/// DTO for POST /api/v1/insurance/ocr/confirm
class InsuranceOcrConfirmDto {
  final String ocrId;
  final OnboardInsuranceDto confirmedData;

  const InsuranceOcrConfirmDto({
    required this.ocrId,
    required this.confirmedData,
  });

  factory InsuranceOcrConfirmDto.fromJson(Map<String, dynamic> json) {
    return InsuranceOcrConfirmDto(
      ocrId: json['ocrId'] as String? ?? '',
      confirmedData: OnboardInsuranceDto.fromJson(
        json['confirmedData'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'ocrId': ocrId, 'confirmedData': confirmedData.toJson()};
  }
}
