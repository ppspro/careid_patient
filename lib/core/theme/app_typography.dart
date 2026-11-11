import 'package:flutter/material.dart';

import 'app_colors.dart';

/// CareID Typography System
/// Matches the Figma font hierarchy, weights, and line heights.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto';

  /// Heading 1 - Screen titles (e.g., "Your Health All In One Place")
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.purpleDeep,
  );

  /// Heading 2 - Section titles
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// Heading 3 - Feature card titles (e.g., "Medical", "Dental", "Vision", "Pets")
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Subtitle / Lead Paragraph
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Body regular (Feature card descriptions, etc.)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Button text (Primary CTA)
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.textOnPrimary,
  );

  /// Button text (Secondary CTA)
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.tealPrimary,
  );

  /// Language toggle label
  static const TextStyle languageToggleActive = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
  );

  static const TextStyle languageToggleInactive = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // Common Semantic Aliases
  static const TextStyle titleLarge = heading1;
  static const TextStyle titleMedium = heading2;
  static const TextStyle titleSmall = heading3;
  static const TextStyle headlineLarge = heading1;
  static const TextStyle headlineMedium = heading1;
  static const TextStyle headlineSmall = heading2;
  static const TextStyle bodyLarge = subtitle;
  static const TextStyle bodyMedium = body;
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.textSecondary,
  );
  static const TextStyle labelLarge = buttonPrimary;
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyRegular = body;
  static const TextStyle caption = bodySmall;
  static const TextStyle buttonText = buttonPrimary;
}
