import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/shared/widgets/primary_button.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: child,
        ),
      ),
    );
  }

  group('PrimaryButton Widget Tests - Figma Node 17:55 Compliance', () {
    testWidgets(
        '1. Default State: renders with correct height, full width, #0A84FF background, and white text',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Get Started',
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find button and text
      expect(find.text('Get Started'), findsOneWidget);

      // Verify dimensions
      final containerFinder = find.byType(Container).first;
      final Size size = tester.getSize(containerFinder);
      expect(size.height, 56.0);
      expect(size.width, 800.0); // Full screen/viewport width

      // Verify ShapeDecoration & Background Color
      final Container container = tester.widget<Container>(containerFinder);
      final ShapeDecoration decoration =
          container.decoration! as ShapeDecoration;
      expect(decoration.gradient, isNotNull);
      final LinearGradient gradient = decoration.gradient! as LinearGradient;
      expect(gradient.colors, [const Color(0xFFA44CFF), const Color(0xFF5B14B8)]);
      expect(decoration.shape, isA<StadiumBorder>());

      // Verify Blue Glow Shadow
      expect(decoration.shadows, isNotNull);
      expect(decoration.shadows!.length, 1);
      final BoxShadow shadow = decoration.shadows!.first;
      expect(shadow.color, const Color(0x4D5B14B8));
      expect(shadow.blurRadius, 12.0);
      expect(shadow.offset, const Offset(0, 4));

      // Verify Text Styling
      final Text textWidget = tester.widget<Text>(find.text('Get Started'));
      expect(textWidget.style?.fontFamily, 'Plus Jakarta Sans');
      expect(textWidget.style?.fontSize, 16.0);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
      expect(textWidget.style?.color, Colors.white);

      // Verify Tap Interaction
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets(
        '2. Disabled State: background #CBD5E1, white text, no shadow, and non-interactive when onPressed is null',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrimaryButton(
            text: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containerFinder = find.byType(Container).first;
      final Container container = tester.widget<Container>(containerFinder);
      final ShapeDecoration decoration =
          container.decoration! as ShapeDecoration;

      // Verify Disabled Color & Shadow
      expect(decoration.color, const Color(0xFFCBD5E1));
      expect(decoration.shadows, isNull);

      // Verify Non-interactive: InkWell.onTap is null
      final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });

    testWidgets(
        '3. Loading State: shows centered white spinner, hides text, and blocks user interaction',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Save Changes',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      // Verify CircularProgressIndicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final progressIndicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator));
      expect(progressIndicator.strokeWidth, 2.5);
      expect(progressIndicator.valueColor?.value, Colors.white);

      // Verify spinner size is 24x24
      final sizedBoxFinder = find
          .ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(SizedBox),
          )
          .first;
      final SizedBox sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, 24.0);
      expect(sizedBox.height, 24.0);

      // Verify Label text is not shown during loading
      expect(find.text('Save Changes'), findsNothing);

      // Verify non-interactive: InkWell.onTap is null
      final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);

      // Attempt tap
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets(
        '4. Pressed State: transitions background to #0066CC on tap down',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Press Me',
            isGradient: false,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially default #5B14B8
      Container container =
          tester.widget<Container>(find.byType(Container).first);
      ShapeDecoration decoration = container.decoration! as ShapeDecoration;
      expect(decoration.color, const Color(0xFF5B14B8));

      // Press down (gesture without release)
      final gesture = await tester.press(find.byType(PrimaryButton));
      await tester.pump();

      // Check pressed background color #4A0E99
      container = tester.widget<Container>(find.byType(Container).first);
      decoration = container.decoration! as ShapeDecoration;
      expect(decoration.color, const Color(0xFF4A0E99));

      // Release gesture
      await gesture.up();
      await tester.pumpAndSettle();

      // Reverts back to default #5B14B8
      container = tester.widget<Container>(find.byType(Container).first);
      decoration = container.decoration! as ShapeDecoration;
      expect(decoration.color, const Color(0xFF5B14B8));
    });

    testWidgets(
        '5. Leading and Trailing Icon Support: renders icons correctly with proper spacing',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Add Family Member',
            leadingIcon: Icons.add,
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(find.text('Add Family Member'), findsOneWidget);
    });

    testWidgets(
        '6. Backward Compatibility: supports legacy label, text, icon, and custom width overrides',
        (tester) async {
      // Test label parameter
      final btnLabel = PrimaryButton(
        label: 'Label Text',
        onPressed: () {},
      );
      expect(btnLabel.label, 'Label Text');
      expect(btnLabel.text, 'Label Text');

      // Test text parameter
      final btnText = PrimaryButton(
        text: 'Direct Text',
        onPressed: () {},
      );
      expect(btnText.label, 'Direct Text');
      expect(btnText.text, 'Direct Text');

      // Test custom width & isFullWidth = false
      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Custom Width',
            width: 220.0,
            isFullWidth: false,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Size customSize = tester.getSize(find.byType(Container).first);
      expect(customSize.width, 220.0);
      expect(customSize.height, 56.0);
    });

    testWidgets(
        '7. Purple Gradient Variant: renders with #A44CFF to #5B14B8 gradient and purple glow shadow',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton.gradient(
            text: 'Continue',
            width: 112,
            height: 44,
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);

      final containerFinder = find.byType(Container).first;
      final Size size = tester.getSize(containerFinder);
      expect(size.height, 44.0);
      expect(size.width, 112.0);

      final Container container = tester.widget<Container>(containerFinder);
      final ShapeDecoration decoration =
          container.decoration! as ShapeDecoration;
      expect(decoration.gradient, isNotNull);
      final LinearGradient gradient = decoration.gradient! as LinearGradient;
      expect(gradient.colors, [const Color(0xFFA44CFF), const Color(0xFF5B14B8)]);

      expect(decoration.shadows, isNotNull);
      final BoxShadow shadow = decoration.shadows!.first;
      expect(shadow.color, const Color(0x4D5B14B8));

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
