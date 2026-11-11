import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/core/theme/app_colors.dart';
import 'package:careid_patient_app/core/theme/app_theme.dart';
import 'package:careid_patient_app/core/theme/app_spacing.dart';

void main() {
  group('Adversarial & Empirical Theme Tokens Verification', () {
    test('1. Exact hex value and bitmask equality for core palette', () {
      // Primary: #0A84FF (0xFF5B14B8)
      expect(AppColors.primary.value, 0xFF5B14B8);
      expect(AppColors.primary, const Color(0xFF5B14B8));
      expect(AppColors.primary.alpha, 255);
      expect(AppColors.primary.red, 91);
      expect(AppColors.primary.green, 20);
      expect(AppColors.primary.blue, 184);

      // Secondary: #00BFA5 (0xFF00BFA5)
      expect(AppColors.secondary.value, 0xFF00BFA5);
      expect(AppColors.secondary, const Color(0xFF00BFA5));
      expect(AppColors.secondary.alpha, 255);
      expect(AppColors.secondary.red, 0);
      expect(AppColors.secondary.green, 191);
      expect(AppColors.secondary.blue, 165);

      // Background: #F8FAFC (0xFFF8FAFC)
      expect(AppColors.background.value, 0xFFF8FAFC);
      expect(AppColors.background, const Color(0xFFF8FAFC));
      expect(AppColors.background.alpha, 255);
      expect(AppColors.background.red, 248);
      expect(AppColors.background.green, 250);
      expect(AppColors.background.blue, 252);
    });

    test('2. State variant colors integrity', () {
      // Primary Dark / Pressed: #0066CC
      expect(AppColors.primaryDark, const Color(0xFF4A0E99));
      expect(AppColors.primaryDark.value, 0xFF4A0E99);

      // Primary Disabled: #CBD5E1
      expect(AppColors.primaryDisabled, const Color(0xFFCBD5E1));
      expect(AppColors.primaryDisabled.value, 0xFFCBD5E1);

      // Button primary shadow color: 20% opacity #0A84FF (0x4D5B14B8)
      expect(
          AppSpacing.buttonPrimaryShadow.first.color, const Color(0x4D5B14B8));
    });

    test('3. Theme binding and immutability stress checks', () {
      final theme = AppTheme.lightTheme;

      // Color scheme bindings
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.colorScheme.secondary, equals(AppColors.secondary));
      expect(theme.colorScheme.surface, equals(AppColors.surface));
      expect(theme.colorScheme.background, equals(AppColors.background));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.background));

      // Elevated button theme shape and size
      final elevatedStyle = theme.elevatedButtonTheme.style;
      expect(elevatedStyle, isNotNull);

      final shape = elevatedStyle!.shape?.resolve({});
      expect(shape, isA<StadiumBorder>());

      final minSize = elevatedStyle.minimumSize?.resolve({});
      expect(minSize?.height, 56.0);

      final bgColor = elevatedStyle.backgroundColor?.resolve({});
      expect(bgColor, equals(AppColors.primary));
    });
  });
}
