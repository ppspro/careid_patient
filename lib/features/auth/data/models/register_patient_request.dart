/// CareID Patient App — Patient Registration Request Model
/// Represents the data required to initialize registration in Step 1.
/// Matches OpenAPI POST /api/v1/patients/register payload contract.
class RegisterPatientRequest {
  final String fullName;
  final String phone;
  final String email;

  const RegisterPatientRequest({
    required this.fullName,
    required this.phone,
    required this.email,
  });

  /// Normalizes a phone string into E.164 format (+1XXXXXXXXXX).
  static String normalizePhone(
    String rawPhone, {
    String defaultCountryCode = '+1',
  }) {
    // Remove all non-digits except a leading '+'
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('+')) {
      final digits = trimmed.substring(1).replaceAll(RegExp(r'\D'), '');
      return '+$digits';
    }

    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '$defaultCountryCode$digits';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+$digits';
    }
    return '+$digits';
  }

  /// Validates standard email pattern.
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validates E.164 phone pattern (e.g. +14155552671).
  static bool isValidPhone(String phone) {
    final normalized = normalizePhone(phone);
    final phoneRegex = RegExp(r'^\+[1-9]\d{7,14}$');
    return phoneRegex.hasMatch(normalized);
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName.trim(),
      'phone': normalizePhone(phone),
      'email': email.trim().toLowerCase(),
    };
  }

  @override
  String toString() {
    // Mask sensitive details to prevent leaking in logs
    final maskedPhone = phone.length > 4
        ? '...${phone.substring(phone.length - 4)}'
        : '****';
    return 'RegisterPatientRequest(name: $fullName, phone: $maskedPhone)';
  }
}
