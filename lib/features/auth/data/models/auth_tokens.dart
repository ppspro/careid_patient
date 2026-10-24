/// Models representing JWT tokens and auth sessions from CareID API
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn = 3600,
    this.tokenType = 'Bearer',
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken:
          json['accessToken'] as String? ??
          json['access_token'] as String? ??
          '',
      refreshToken:
          json['refreshToken'] as String? ??
          json['refresh_token'] as String? ??
          '',
      expiresIn:
          json['expiresIn'] as int? ?? json['expires_in'] as int? ?? 3600,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'tokenType': tokenType,
    };
  }
}
