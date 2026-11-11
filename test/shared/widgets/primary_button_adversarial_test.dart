import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/theme/app_colors.dart';
import 'package:careid_patient_app/shared/widgets/primary_button.dart';

void main() {
  Widget buildFrame({
    required Widget child,
    double? width,
    double? height,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        ),
      ),
    );
  }

  group('PrimaryButton Adversarial Stress Suite', () {
    testWidgets(
        '1. Loading State: rapid double-tap rejection (must never fire)',
        (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        buildFrame(
          child: PrimaryButton(
            text: 'Submit Form',
            isLoading: true,
            onPressed: () => tapCount++,
          ),
        ),
      );
      await tester.pump();

      // Ensure button is rendered in loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Form'), findsNothing);

      // Execute aggressive rapid taps
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));

      expect(tapCount, 0,
          reason: 'onPressed must never fire when isLoading is true');

      // InkWell onTap must be null
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });

    testWidgets('2. Dynamic State Transition: loading lock mid-interaction',
        (tester) async {
      int tapCount = 0;
      bool isLoading = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildFrame(
              child: PrimaryButton(
                text: 'Process Order',
                isLoading: isLoading,
                onPressed: () {
                  tapCount++;
                  setState(() {
                    isLoading = true;
                  });
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // First tap should fire and toggle isLoading
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump(); // trigger setState and re-render

      expect(tapCount, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Subsequent rapid double tap while loading
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));

      expect(tapCount, 1,
          reason: 'Double tap during loading must not increment tap count');
    });

    testWidgets('3. Disabled State: tap attempts must never fire',
        (tester) async {
      int tapCount = 0;

      // Case A: onPressed is null
      await tester.pumpWidget(
        buildFrame(
          child: const PrimaryButton(
            text: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final inkWellNull = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWellNull.onTap, isNull);
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();
      expect(tapCount, 0);

      // Case B: enabled = false with non-null callback
      await tester.pumpWidget(
        buildFrame(
          child: PrimaryButton(
            text: 'Disabled By Flag',
            enabled: false,
            onPressed: () => tapCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final inkWellFlag = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWellFlag.onTap, isNull);
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();
      expect(tapCount, 0);
    });

    testWidgets(
        '4. Extreme String Lengths: wrapping or ellipsis without RenderFlex overflow',
        (tester) async {
      // 500 characters of repeating text with spaces
      final longTextWithSpaces =
          'CareID Secure Patient Record Authentication Protocol ' * 10;

      // 500 characters unbroken single word (stress-test text layout)
      final unbrokenLongString = 'A' * 500;

      // Unbroken string with emojis and multi-byte unicode
      final unicodeLongString = '🛡️CareID🏥Verification🔑PatientVault🔒' * 20;

      for (final text in [
        longTextWithSpaces,
        unbrokenLongString,
        unicodeLongString
      ]) {
        await tester.pumpWidget(
          buildFrame(
            width:
                360.0, // standard Redmi 8A viewport width (720 physical / 2.0 DPR)
            child: PrimaryButton(
              text: text,
              onPressed: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must not throw RenderFlex overflow error
        expect(tester.takeException(), isNull,
            reason: 'RenderFlex overflow occurred on extreme string length');

        // Text widget must have ellipsis overflow configured
        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.overflow, TextOverflow.ellipsis);
        expect(textWidget.maxLines, 1);
      }
    });

    testWidgets(
        '5. Compact Width Bounds: 100dp, 200dp, 360dp without RenderFlex overflow',
        (tester) async {
      const testWidths = [100.0, 160.0, 200.0, 320.0, 360.0];

      for (final width in testWidths) {
        await tester.pumpWidget(
          buildFrame(
            width: width,
            child: PrimaryButton(
              text: 'Confirm Appointment Verification',
              onPressed: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull,
            reason: 'RenderFlex overflow occurred at width: $width');

        final containerFinder = find.byType(Container).first;
        final Size size = tester.getSize(containerFinder);
        expect(size.height, 56.0);
        expect(size.width, width);
      }
    });

    testWidgets('6. Compact Width Bounds with Leading and Trailing Icons',
        (tester) async {
      // Test at 200dp and 360dp with both icons and text
      for (final width in [200.0, 360.0]) {
        await tester.pumpWidget(
          buildFrame(
            width: width,
            child: PrimaryButton(
              text: 'Save Details',
              leadingIcon: Icons.check,
              trailingIcon: Icons.arrow_forward_ios,
              onPressed: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull,
            reason: 'RenderFlex overflow occurred with icons at width: $width');
        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      }
    });

    testWidgets(
        '6b. Adversarial Narrow Boundary: dual icons + label at 100dp constraint',
        (tester) async {
      await tester.pumpWidget(
        buildFrame(
          width: 100.0,
          child: PrimaryButton(
            text: 'Save',
            leadingIcon: Icons.check,
            trailingIcon: Icons.arrow_forward_ios,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason:
              'RenderFlex overflow occurred on narrow bounds with dual icons');
    });

    testWidgets('7. Exact Dimensions and Geometry Verification',
        (tester) async {
      await tester.pumpWidget(
        buildFrame(
          width: 360.0,
          child: PrimaryButton(
            text: 'Verify Identity',
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containerFinder = find.byType(Container).first;
      final Size size = tester.getSize(containerFinder);

      // Verify exact height is 56.0 dp
      expect(size.height, 56.0);

      // Verify Shape is StadiumBorder
      final Container container = tester.widget<Container>(containerFinder);
      final ShapeDecoration decoration =
          container.decoration! as ShapeDecoration;
      expect(decoration.shape, isA<StadiumBorder>());

      // Verify StadiumBorder renders on Material and InkWell inside PrimaryButton
      final Material material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.shape, isA<StadiumBorder>());

      final InkWell inkWell = tester.widget<InkWell>(
        find
            .descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(inkWell.customBorder, isA<StadiumBorder>());
    });

    testWidgets('8. Custom Height and Custom Radius overrides', (tester) async {
      await tester.pumpWidget(
        buildFrame(
          width: 300.0,
          child: PrimaryButton(
            text: 'Custom Geometry',
            height: 48.0,
            borderRadius: 12.0,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containerFinder = find.byType(Container).first;
      final Size size = tester.getSize(containerFinder);
      expect(size.height, 48.0);

      final Container container = tester.widget<Container>(containerFinder);
      final ShapeDecoration decoration =
          container.decoration! as ShapeDecoration;
      expect(decoration.shape, isA<RoundedRectangleBorder>());
      final border = decoration.shape as RoundedRectangleBorder;
      expect(border.borderRadius, BorderRadius.circular(12.0));
    });

    testWidgets('9. Pressed State Visual Transitions under Tap Down and Cancel',
        (tester) async {
      await tester.pumpWidget(
        buildFrame(
          child: PrimaryButton(
            isGradient: false,
            text: 'Tap Interaction',
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check default background
      Container container =
          tester.widget<Container>(find.byType(Container).first);
      ShapeDecoration decoration = container.decoration! as ShapeDecoration;
      expect(decoration.color, AppColors.primary);

      // Tap down
      final gesture = await tester.press(find.byType(PrimaryButton));
      await tester.pump();

      // Check pressed background color #0066CC
      container = tester.widget<Container>(find.byType(Container).first);
      decoration = container.decoration! as ShapeDecoration;
      expect(decoration.color, const Color(0xFF4A0E99));

      // Cancel gesture (drag away)
      await gesture.cancel();
      await tester.pumpAndSettle();

      // Reverts to default #0A84FF
      container = tester.widget<Container>(find.byType(Container).first);
      decoration = container.decoration! as ShapeDecoration;
      expect(decoration.color, AppColors.primary);
    });
  });
}
