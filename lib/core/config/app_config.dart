/// CareID Application Configuration
/// Provides environment-specific settings and central API base URLs.
class AppConfig {
  AppConfig._();

  /// Default API base URL for CareID backend.
  /// Strictly points to the approved production-staging environment.
  static const String defaultApiBaseUrl = 'https://360api.vnvision.in';

  /// Active base URL. Can be overridden via environment declaration.
  static const String apiBaseUrl = String.fromEnvironment(
    'CAREID_API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );

  /// Application Name
  static const String appName = 'CareID Patient';

  /// Application Version
  static const String appVersion = '1.0.0';

  /// Network request timeout
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Supported locales
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'es'];
}
