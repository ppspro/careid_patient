import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/auth/data/models/registration_context.dart';
import 'package:careid_patient_app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/full_kiosk_pass_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/health_card_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/home_screen.dart';
import 'package:careid_patient_app/shared/widgets/careid_logo.dart';
import 'package:careid_patient_app/shared/widgets/wallet_badges.dart';

void main() {
  group('CareID Figma Asset Fidelity & Defect Rectification Tests', () {
    const dummyContext = RegistrationContext(
      fullName: 'Sarah Jenkins',
      phone: '+1 (555) 234-5678',
      email: 'sarah@example.com',
      bloodGroup: 'O+',
      emergencyContactPhone: '+1 (555) 987-6543',
    );

    testWidgets('1. Home - Option 6 (20:19552) renders complete CareID logo without cropping', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(registrationContext: dummyContext),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify CareIdLogo exists in app bar with isHorizontal: true
      final logoFinder = find.byType(CareIdLogo);
      expect(logoFinder, findsOneWidget);

      final CareIdLogo logoWidget = tester.widget(logoFinder);
      expect(logoWidget.isHorizontal, isTrue);
      expect(logoWidget.showWordmark, isTrue);

      // Verify horizontal logo asset is rendered
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsWidgets);

      bool foundHorizontalLogo = false;
      for (final element in imageFinder.evaluate()) {
        final Image image = element.widget as Image;
        if (image.image is AssetImage) {
          final AssetImage asset = image.image as AssetImage;
          if (asset.assetName == 'assets/images/careid_logo_horizontal.png') {
            foundHorizontalLogo = true;
            break;
          }
        }
      }
      expect(foundHorizontalLogo, isTrue, reason: 'Complete horizontal CareID logo must be rendered');
    });

    testWidgets('2. Smart Digital Health Card (20:19873) renders authentic Apple Wallet and Google Wallet buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: HealthCardScreen(registrationContext: dummyContext),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Apple Wallet and Google Wallet buttons are present
      expect(find.byType(AppleWalletButton), findsOneWidget);
      expect(find.byType(GoogleWalletButton), findsOneWidget);
      expect(find.text('Add to Apple Wallet'), findsOneWidget);
      expect(find.text('Add to Google Wallet'), findsOneWidget);
    });

    testWidgets('3. Full Kiosk Pass (20:32906) renders authentic Apple Wallet and Google Pay buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: FullKioskPassScreen(
            doctorName: 'Dr. Sarah Jenkins, MD',
            specialty: 'Cardiology & Internal Medicine',
            dateTime: 'Thursday, Nov 16 • 09:30 AM',
            location: '1190 5th Ave, Suite 400, New York, NY 10029',
            patientName: 'Sarah Jenkins',
            careIdNumber: 'CID #8472-9901',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppleWalletButton), findsOneWidget);
      expect(find.byType(GoogleWalletButton), findsOneWidget);
      expect(find.text('Apple Wallet'), findsOneWidget);
      expect(find.text('Google Pay'), findsOneWidget);
    });

    testWidgets('4. Splash Screen (20:25191) renders authentic patient artwork and CareID logo', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(
            displayDuration: Duration(seconds: 10),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CareIdLogo), findsOneWidget);

      // Verify authentic patient graphic is rendered
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsWidgets);

      bool foundPatientGraphic = false;
      for (final element in imageFinder.evaluate()) {
        final Image image = element.widget as Image;
        if (image.image is AssetImage) {
          final AssetImage asset = image.image as AssetImage;
          if (asset.assetName == 'assets/images/careid_splash_graphic.png') {
            foundPatientGraphic = true;
            break;
          }
        }
      }
      expect(foundPatientGraphic, isTrue, reason: 'Authentic patient artwork must be rendered on splash screen');
    });
  });
}
