import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careid_patient_app/features/patient/data/models/appointment_models.dart';
import 'package:careid_patient_app/features/patient/presentation/dialogs/cancel_appointment_dialog.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/family_records_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/invitation_sent_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/medication_reminder_detail_screen.dart';
import 'package:careid_patient_app/features/patient/presentation/screens/treatment_offer_details_screen.dart';

void main() {
  group('Newly Added Figma Screens & Dialogs Tests (Canvas 17:55)', () {
    testWidgets('1. CancelAppointmentDialog (20:30384) renders warning, metadata, and buttons',
        (tester) async {
      final sampleApt = AppointmentModel(
        id: 'apt-001',
        doctorId: 'doc-001',
        doctorName: 'Dr. Sarah Jenkins',
        specialization: 'Cardiovascular Specialist',
        facility: 'Mount Sinai Heart Center',
        dateTime: DateTime(2023, 11, 16, 9, 45),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CancelAppointmentDialog.show(
                    context,
                    appointment: sampleApt,
                    remainingCancellations: 2,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Appointment?'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Dr. Sarah Jenkins'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Mount Sinai Heart Center'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('3 or more cancellations'),
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel Appointment (2) Remaining'), findsOneWidget);
      expect(find.text('Keep Appointment'), findsOneWidget);
      expect(find.text('CareID HIPAA Protected Patient Action'), findsOneWidget);

      await tester.tap(find.text('Keep Appointment'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel Appointment?'), findsNothing);
    });

    testWidgets('2. FamilyRecordsScreen (20:30521) renders 3 record category cards and navigation',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FamilyRecordsScreen(showBottomNav: true),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('CARE ID VERIFIED DIRECTORY'), findsOneWidget);
      expect(find.text('My Health Records'), findsOneWidget);
      expect(find.text('Family Health Records'), findsOneWidget);
      expect(find.text('Pet Records'), findsOneWidget);
      expect(find.text('Records'), findsWidgets);
    });

    testWidgets('3. InvitationSentScreen (20:19138) renders member summary card and timeline steps',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InvitationSentScreen(
            memberName: 'Eleanor Vance',
            relationship: 'Spouse',
            emailOrPhone: '+1 (555) 019-2831',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Invitation sent'), findsOneWidget);
      expect(find.text('Eleanor Vance'), findsOneWidget);
      expect(find.textContaining('+1 (555) 019-2831'), findsOneWidget);
      expect(find.text('Back to Family Dashboard'), findsOneWidget);
    });

    testWidgets('4. MedicationReminderDetailScreen (20:24101) renders prescription card and pharmacy info',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MedicationReminderDetailScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Prescription Reminder'), findsOneWidget);
      expect(find.text('Atorvastatin 20mg'), findsOneWidget);
      expect(find.textContaining('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.textContaining('12/06'), findsOneWidget);
      expect(find.text('City Health Apothecary'), findsOneWidget);
      expect(find.text('Mark as Collected'), findsOneWidget);
    });

    testWidgets('5. TreatmentOfferDetailsScreen (20:26922) renders cost breakdown and transitions to accepted/declined',
        (tester) async {
      final sampleOffer = {
        'title': 'Comprehensive Dental Restoration & Scaling',
        'standardPrice': 1450.0,
        'careIdPrice': 920.0,
        'savings': 530.0,
        'monthlyRate': 76.67,
        'tenure': 12,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: TreatmentOfferDetailsScreen(offer: sampleOffer),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Offer Details'), findsOneWidget);
      expect(find.text('Comprehensive Dental Restoration & Scaling'), findsOneWidget);
      expect(find.text('Cost Breakdown'), findsOneWidget);

      final acceptBtn = find.text('Accept Offer & Lock In Rate');
      await tester.scrollUntilVisible(acceptBtn, 300);
      await tester.pumpAndSettle();
      expect(acceptBtn, findsOneWidget);

      await tester.tap(acceptBtn);
      await tester.pumpAndSettle();

      expect(find.text('Offer Accepted!'), findsOneWidget);
      expect(find.text('View Digital Health Card'), findsOneWidget);
    });
  });
}
