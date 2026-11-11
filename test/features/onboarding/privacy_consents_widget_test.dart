import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/auth/data/models/registration_context.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/privacy_consents_screen.dart';

void main() {
  testWidgets('PrivacyConsentsScreen renders without throwing exceptions',
      (WidgetTester tester) async {
    const context = RegistrationContext(
      fullName: 'Jane Doe',
      phone: '+14155552671',
      email: 'jane.doe@example.com',
      onboardingStep: 5,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyConsentsScreen(
          registrationContext: context,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Your privacy & consents'), findsOneWidget);
    expect(find.text('REQUIRED CONSENTS'), findsOneWidget);
    expect(find.text('Terms of Service'), findsWidgets);
    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.text('Agree & Continue'), findsOneWidget);
  });
}
