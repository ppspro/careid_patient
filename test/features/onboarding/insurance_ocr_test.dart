import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/auth/data/models/registration_context.dart';
import 'package:careid_patient_app/features/onboarding/data/models/insurance_models.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/add_insurance_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/insurance_screen.dart';

void main() {
  const testContext = RegistrationContext(
    fullName: 'Sarah Jenkins',
    phone: '+14155552671',
    email: 'sarah.j@email.com',
    bloodGroup: 'O+',
    careIdNumber: 'CID-8472-9102-4821',
  );

  group('Insurance OCR Models & Presentation Tests', () {
    test('InsuranceOcrScanDto serializes and validates correctly', () {
      const dto = InsuranceOcrScanDto(imageUrl: 'https://storage.careid.health/cards/ins-1.jpg');
      final json = dto.toJson();

      expect(json['imageUrl'], equals('https://storage.careid.health/cards/ins-1.jpg'));
      expect(InsuranceOcrScanDto.isValidImageUrl('https://storage.careid.health/cards/ins-1.jpg'), isTrue);
      expect(InsuranceOcrScanDto.isValidImageUrl('invalid-url'), isFalse);
      expect(InsuranceOcrScanDto.isValidImageUrl(null), isFalse);

      final parsed = InsuranceOcrScanDto.fromJson(json);
      expect(parsed.imageUrl, equals(dto.imageUrl));
    });

    testWidgets('AddInsuranceScreen renders Open Camera scanner trigger', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddInsuranceScreen(
            registrationContext: testContext,
            language: 'en',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add your insurance'), findsOneWidget);
      expect(find.text('Scan Insurance Card'), findsOneWidget);
      expect(find.text('Open Camera'), findsOneWidget);
      expect(find.text('Insurance Details'), findsOneWidget);
      expect(find.text("I'll do this later"), findsOneWidget);
    });

    testWidgets('InsuranceScreen renders document scanner trigger and policy tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InsuranceScreen(
            registrationContext: testContext,
            language: 'en',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Insurance Platform'), findsOneWidget);
      expect(find.byIcon(Icons.document_scanner_outlined), findsOneWidget);
      expect(find.text('Policies'), findsOneWidget);
      expect(find.text('Claims'), findsOneWidget);
      expect(find.text('Add Policy'), findsOneWidget);
    });
  });
}

