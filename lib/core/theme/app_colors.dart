import 'package:flutter/material.dart';

/// CareID Color Palette and Design Tokens
/// Extracted directly from CareID Figma design specifications.
class AppColors {
  AppColors._();

  // Screen & Surface Backgrounds
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC);

  // Brand Purples (Primary Identity)
  static const Color purpleDeep = Color(0xFF2E1065); // Heading & key accents
  static const Color purplePrimary = Color(0xFF7C3AED); // Primary button start
  static const Color purpleDark = Color(0xFF6D28D9); // Primary button end
  static const Color purpleLight = Color(0xFFF3E8FF); // Medical/Pet icon bg
  static const Color purpleBorder = Color(0xFFE9D5FF);

  // Gradient for Primary CTA Button
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  );

  // Service Category Accents
  // 1. Medical
  static const Color medicalIcon = Color(0xFF7C3AED);
  static const Color medicalBg = Color(0xFFF3E8FF);

  // 2. Dental
  static const Color dentalIcon = Color(0xFF0284C7);
  static const Color dentalBg = Color(0xFFE0F2FE);

  // 3. Vision
  static const Color visionIcon = Color(0xFF4F46E5);
  static const Color visionBg = Color(0xFFEEF2FF);

  // 4. Pets
  static const Color petsIcon = Color(0xFF7C3AED);
  static const Color petsBg = Color(0xFFF5F3FF);

  // Secondary Button (Teal / Cyan Accents)
  static const Color tealPrimary = Color(0xFF0F766E);
  static const Color tealBorder = Color(0xFF5EEAD4);
  static const Color tealBg = Color(0xFFF0FDFA);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & Divider Colors
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderMedium = Color(0xFFE2E8F0);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
