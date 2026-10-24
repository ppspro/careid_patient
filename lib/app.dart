import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart';

/// Root Application Widget for CareID Patient App
class CareIdPatientApp extends StatelessWidget {
  final ApiClient? apiClient;

  const CareIdPatientApp({super.key, this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: WelcomeScreen(apiClient: apiClient),
    );
  }
}
