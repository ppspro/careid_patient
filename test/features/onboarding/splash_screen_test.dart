import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/welcome_screen.dart';

void main() {
  testWidgets('SplashScreen renders logo, badge, and navigation elements',
      (WidgetTester tester) async {
    final tokenStorage = InMemoryTokenStorage();

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          tokenStorage: tokenStorage,
          displayDuration: const Duration(milliseconds: 300),
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify key brand elements
    expect(find.text('AES-256 · HIPAA Sovereign Vault'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance past display duration and allow fade transition
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    // Verifies transition to WelcomeScreen
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
