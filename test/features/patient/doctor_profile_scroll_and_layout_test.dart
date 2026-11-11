import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/features/patient/data/models/doctor_models.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/doctor_profile_screen.dart';

void main() {
  const testDoctor = DoctorModel(
    id: 'doc-test-01',
    fullName: 'Dr. Sarah Jenkins, MD, FACC',
    primarySpecialization: 'Cardiology & Internal Medicine',
    secondarySpecializations: ['Preventive Medicine', 'Cardiovascular Screening', 'Hypertension'],
    facilityName: 'Mount Sinai Medical Center',
    yearsOfExperience: 14,
    rating: 4.9,
    reviewCount: 128,
    isVerified: true,
    languages: ['English', 'Spanish'],
    bio: 'Dr. Sarah Jenkins is an attending physician specializing in cardiovascular risk reduction.',
  );

  group('DoctorProfileScreen Comprehensive Layout & Scrolling Suite', () {
    testWidgets('Doctor Profile renders all Figma 20:28961 sections and scrolls without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorProfileScreen(doctor: testDoctor),
        ),
      );

      await tester.pumpAndSettle();

      // Top sections
      expect(find.text('Doctors Directory'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins, MD, FACC'), findsOneWidget);
      expect(find.text('Cardiology & Internal Medicine'), findsOneWidget);
      expect(find.text('Mount Sinai Medical Center'), findsWidgets);
      expect(find.text('Care ID Vault Connected • End-to-End Encrypted Access'), findsOneWidget);

      // Connection context
      expect(find.text('Your Care Connection'), findsOneWidget);
      expect(find.text('Last Consultation'), findsOneWidget);
      expect(find.text('Synced Records'), findsOneWidget);

      // Scroll down until Submit is in viewport
      await tester.scrollUntilVisible(
        find.text('Submit'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Clinical Specializations & Practice'), findsOneWidget);
      expect(find.text('Preventive Medicine'), findsOneWidget);
      expect(find.text('Hospital Affiliation & Department'), findsOneWidget);
      expect(find.text('Languages Supported'), findsOneWidget);
      expect(find.text('Practice & Facility Showcase'), findsOneWidget);
      expect(find.text('Diagnostic Wing'), findsOneWidget);
      expect(find.text('Consultation Suite 4B'), findsOneWidget);
      expect(find.text('Strong → Care ID Trust Standard'), findsOneWidget);
      expect(find.text('Rate this doctor'), findsOneWidget);
      expect(find.text('1 = Poor · 5 = Excellent'), findsOneWidget);

      // Verify persistent bottom buttons are always visible on screen
      expect(find.text('Book Consultation'), findsOneWidget);
      expect(find.text('Message Team'), findsOneWidget);
      expect(find.text('Call Practice'), findsOneWidget);

      // Interactive rating test
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Thank you! Your verified feedback has been recorded into the Care ID Trust network.'), findsOneWidget);
    });

    testWidgets('Doctor Profile adapts seamlessly on compact Android screen (320x568)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorProfileScreen(doctor: testDoctor),
        ),
      );

      await tester.pumpAndSettle();

      // Top elements visible
      expect(find.text('Doctors Directory'), findsOneWidget);
      expect(find.text('Book Consultation'), findsOneWidget);

      // Scroll to bottom without RenderFlex errors
      await tester.scrollUntilVisible(
        find.text('Submit'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Rate this doctor'), findsOneWidget);
    });
  });
}
