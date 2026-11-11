import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/theme/app_colors.dart';
import 'package:careid_patient_app/core/theme/app_spacing.dart';
import 'package:careid_patient_app/core/theme/app_theme.dart';

void main() {
  group('Theme Tokens & Design System Verification (Figma Node 17:55)', () {
    test('AppColors tokens adhere to approved Figma medical palette', () {
      // Primary & Secondary Brand Tokens
      expect(AppColors.primary, const Color(0xFF5B14B8));
      expect(AppColors.primaryDark, const Color(0xFF4A0E99));
      expect(AppColors.primaryDisabled, const Color(0xFFCBD5E1));
      expect(AppColors.secondary, const Color(0xFF00BFA5));

      // Backgrounds
      expect(AppColors.background, const Color(0xFFF8FAFC));
      expect(AppColors.backgroundLight, const Color(0xFFF8FAFC));
      expect(AppColors.surface, const Color(0xFFFFFFFF));

      // Primary Gradient
      expect(
        AppColors.primaryGradient.colors,
        const [Color(0xFFA44CFF), Color(0xFF5B14B8)],
      );
      expect(AppColors.primaryGradient.begin, Alignment.topCenter);
      expect(AppColors.primaryGradient.end, Alignment.bottomCenter);

      // Legacy constants retained for backwards compatibility
      expect(AppColors.purplePrimary, const Color(0xFF5B14B8));
      expect(AppColors.purpleDeep, const Color(0xFF2E1065));
      expect(AppColors.aquaHighlight, const Color(0xFF00BFA5));
    });

    test('AppSpacing buttonPrimaryShadow uses blue glow token', () {
      expect(AppSpacing.buttonPrimaryShadow.length, 1);
      final shadow = AppSpacing.buttonPrimaryShadow.first;
      expect(shadow.color, const Color(0x4D5B14B8));
      expect(shadow.blurRadius, 16.0);
      expect(shadow.offset, const Offset(0, 6));
    });

    test(
        'AppTheme.lightTheme is wired with approved Figma color scheme & button standards',
        () {
      final theme = AppTheme.lightTheme;

      // Primary & Background Color bindings
      expect(theme.primaryColor, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);

      // ColorScheme bindings
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.background, AppColors.background);

      // ElevatedButtonThemeData bindings
      final buttonStyle = theme.elevatedButtonTheme.style;
      expect(buttonStyle, isNotNull);

      // Button background: #0A84FF
      final resolvedBg = buttonStyle!.backgroundColor?.resolve({});
      expect(resolvedBg, AppColors.primary);

      // Button shape: StadiumBorder (radius 9999)
      final resolvedShape = buttonStyle.shape?.resolve({});
      expect(resolvedShape, isA<StadiumBorder>());

      // Button height: 56.0
      final resolvedMinSize = buttonStyle.minimumSize?.resolve({});
      expect(resolvedMinSize?.height, 56.0);

      // Button text color: white
      final resolvedFg = buttonStyle.foregroundColor?.resolve({});
      expect(resolvedFg, AppColors.textOnPrimary);
    });
  });
}
