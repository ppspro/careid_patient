import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Language Toggle Pill (EN / ESP)
/// Matches Figma frame node 20:19868 (Top right language selector).
class LanguageToggle extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageToggle({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = currentLanguage.toUpperCase() == 'EN';

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMedium, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItem(
            text: 'EN',
            isActive: isEn,
            onTap: () => onLanguageChanged('en'),
          ),
          _buildItem(
            text: 'ESP',
            isActive: !isEn,
            onTap: () => onLanguageChanged('es'),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purpleDark : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: isActive
              ? AppTypography.languageToggleActive
              : AppTypography.languageToggleInactive,
        ),
      ),
    );
  }
}
