import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = AppTokenStorage();

  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenStorage: tokenStorage,
  );

  final defaultRoute = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  final effectiveInitialRoute = (defaultRoute.isNotEmpty && defaultRoute != '/')
      ? defaultRoute
      : '/splash';

  runApp(
    CareIdPatientApp(
      apiClient: apiClient,
      initialRoute: effectiveInitialRoute,
    ),
  );
}
