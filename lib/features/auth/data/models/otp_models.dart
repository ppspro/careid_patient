/// CareID Patient App — OTP Authentication DTOs
/// Matches the official OpenAPI specifications and NestJS Auth module DTOs:
/// - POST /api/v1/auth/otp/request
/// - POST /api/v1/auth/otp/verify
/// - POST /api/v1/auth/otp/resend

/// Request DTO for POST /api/v1/auth/otp/request
class RequestOtpDto {
  final String phone;

  const RequestOtpDto({required this.phone});

  /// Normalizes phone to E.164 (+1XXXXXXXXXX).
  static String normalizePhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('+')) {
      final digits = trimmed.substring(1).replaceAll(RegExp(r'\D'), '');
      return '+$digits';
    }
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+1$digits';
    return '+$digits';
  }

  static bool isValidPhone(String phone) {
    final normalized = normalizePhone(phone);
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return regex.hasMatch(normalized);
  }

  Map<String, dynamic> toJson() => {'phone': normalizePhone(phone)};

  @override
  String toString() {
    final norm = normalizePhone(phone);
    final masked = norm.length > 4
        ? '...${norm.substring(norm.length - 4)}'
        : '****';
    return 'RequestOtpDto(phone: $masked)';
  }
}

/// Response DTO for POST /api/v1/auth/otp/request
class RequestOtpResponseDto {
  final String challengeId;
  final String message;

  const RequestOtpResponseDto({
    required this.challengeId,
    required this.message,
  });

  factory RequestOtpResponseDto.fromJson(Map<String, dynamic> json) {
    // Handle nested data envelope if present
    final source =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return RequestOtpResponseDto(
      challengeId: source['challengeId']?.toString() ?? '',
      message:
          json['message']?.toString() ??
          source['message']?.toString() ??
          'OTP sent successfully',
    );
  }

  Map<String, dynamic> toJson() => {
    'challengeId': challengeId,
    'message': message,
  };
}

/// Request DTO for POST /api/v1/auth/otp/verify
class VerifyOtpDto {
  final String challengeId;
  final String otpCode;

  const VerifyOtpDto({required this.challengeId, required this.otpCode});

  /// Validates 6-digit numeric OTP code.
  static bool isValidOtpCode(String code) {
    return RegExp(r'^\d{6}$').hasMatch(code.trim());
  }

  /// Validates standard UUID format for challenge identifier.
  static bool isValidChallengeId(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(id.trim());
  }

  Map<String, dynamic> toJson() => {
    'challengeId': challengeId.trim(),
    'otpCode': otpCode.trim(),
  };

  @override
  String toString() {
    // Never expose the OTP code in string representations or logs
    return 'VerifyOtpDto(challengeId: $challengeId, otpCode: [PROTECTED])';
  }
}

/// Response DTO for POST /api/v1/auth/otp/verify
class VerifyOtpResponseDto {
  final String accessToken;
  final String refreshToken;
  final String expiresIn;

  const VerifyOtpResponseDto({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn = '15m',
  });

  factory VerifyOtpResponseDto.fromJson(Map<String, dynamic> json) {
    final source =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return VerifyOtpResponseDto(
      accessToken: source['accessToken']?.toString() ?? '',
      refreshToken: source['refreshToken']?.toString() ?? '',
      expiresIn: source['expiresIn']?.toString() ?? '15m',
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
  };

  @override
  String toString() {
    // Redact tokens to avoid leaking credentials in console logs
    return 'VerifyOtpResponseDto(expiresIn: $expiresIn, tokens: [REDACTED])';
  }
}

/// Request DTO for POST /api/v1/auth/otp/resend
class ResendOtpDto {
  final String challengeId;

  const ResendOtpDto({required this.challengeId});

  Map<String, dynamic> toJson() => {'challengeId': challengeId.trim()};

  @override
  String toString() => 'ResendOtpDto(challengeId: $challengeId)';
}

/// Response DTO for POST /api/v1/auth/otp/resend
class ResendOtpResponseDto {
  final String challengeId;
  final String message;

  const ResendOtpResponseDto({
    required this.challengeId,
    required this.message,
  });

  factory ResendOtpResponseDto.fromJson(Map<String, dynamic> json) {
    final source =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return ResendOtpResponseDto(
      challengeId: source['challengeId']?.toString() ?? '',
      message:
          json['message']?.toString() ??
          source['message']?.toString() ??
          'OTP resent successfully',
    );
  }

  Map<String, dynamic> toJson() => {
    'challengeId': challengeId,
    'message': message,
  };
}
