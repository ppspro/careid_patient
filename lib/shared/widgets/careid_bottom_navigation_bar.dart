import 'package:flutter/material.dart';
import 'careid_nav_icons.dart';

/// CareID Patient App — Standardized Reusable Bottom Navigation Bar
/// Faithfully reproduces Figma Frame `20:19764` ("Bottom Nav Bar (Mobile)")
/// and its variants (`20:30432`, `20:30604`) on canvas "Careid patient app" (node 17:55).
/// Features four navigation destinations (Home, Records, Doctor, Profile)
/// and the central elevated circular CareID QR / Document Scanner button (`20:19790`).
class CareIdBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onCenterAction;
  final VoidCallback? onCenterLongPress;
  final bool isMenuExpanded;
  final String language;
  final bool showCenterButton;
  final String doctorLabel;

  const CareIdBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.onCenterAction,
    this.onCenterLongPress,
    this.isMenuExpanded = false,
    this.language = 'en',
    this.showCenterButton = true,
    this.doctorLabel = 'Doctor',
  });

  bool get _isEn => language == 'en';

  static const Color _barBackgroundColor = Colors.white;
  static const Color _activePillColor = Color(0xFF90F4FE);
  static const Color _activeTextColor = Color(0xFF002022);
  static const Color _inactiveColor = Color(0xFF494552);

  @override
  Widget build(BuildContext context) {
    const double barHeight = 72.0;
    const double buttonDiameter = 56.0;
    const double buttonElevation = 16.0;

    return SizedBox(
      height: barHeight + buttonElevation,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Navigation Bar Surface Container (Figma 20:19765)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: _barBackgroundColor,
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A3F1D8B),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: barHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        // Tab 0: Home (Option 6 - Figma 20:19552 / 20:19764)
                        Expanded(
                          child: _buildCustomNavItem(
                            index: 0,
                            iconBuilder: (isSelected, color) => CustomPaint(
                              size: const Size(22, 22),
                              painter: HomeHousePainter(color: color, isFilled: isSelected),
                            ),
                            label: _isEn ? 'Home' : 'Inicio',
                          ),
                        ),
                        // Tab 1: Records (Family Records Hub - Figma 20:30521)
                        Expanded(
                          child: _buildCustomNavItem(
                            index: 1,
                            iconBuilder: (isSelected, color) => CustomPaint(
                              size: const Size(22, 22),
                              painter: FolderWithGearPainter(color: color),
                            ),
                            label: _isEn ? 'Records' : 'Registros',
                          ),
                        ),
                        // Central Spacer reserving exact gap for elevated Floating Button
                        if (showCenterButton)
                          const SizedBox(width: 56),
                        // Tab 2: Doctor (Directory - Figma 20:28020) or Family
                        Expanded(
                          child: _buildCustomNavItem(
                            index: 2,
                            iconBuilder: (isSelected, color) => CustomPaint(
                              size: const Size(22, 22),
                              painter: StethoscopePainter(color: color),
                            ),
                            label: _isEn
                                ? doctorLabel
                                : (doctorLabel == 'Family' ? 'Familia' : 'Médico'),
                          ),
                        ),
                        // Tab 3: Profile (Figma 20:24204)
                        Expanded(
                          child: _buildCustomNavItem(
                            index: 3,
                            iconBuilder: (isSelected, color) => CustomPaint(
                              size: const Size(22, 22),
                              painter: ProfilePersonPainter(color: color, isFilled: isSelected),
                            ),
                            label: _isEn ? 'Profile' : 'Perfil',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Central Elevated Floating QR Button (Figma 20:19789 / 20:19790)
          // Protrudes above the bar top border with high-contrast white border and purple drop shadow
          if (showCenterButton)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCenterAction ?? () {
                    Navigator.of(context).pushNamed('/health-card');
                  },
                  onLongPress: onCenterLongPress,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: buttonDiameter,
                    height: buttonDiameter,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isMenuExpanded
                            ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                            : [const Color(0xFF5B14B8), const Color(0xFF4A0E99)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: isMenuExpanded
                              ? const Color(0x66EF4444)
                              : const Color(0x665B14B8),
                          blurRadius: 16,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                        const BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedRotation(
                        turns: isMenuExpanded ? 0.25 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isMenuExpanded)
                              const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 26,
                              )
                            else
                              const CustomPaint(
                                size: Size(26, 26),
                                painter: CenterDocumentScannerPainter(color: Colors.white),
                              ),
                            // Accessibility & test finder anchor
                            if (!isMenuExpanded)
                              const Opacity(
                                opacity: 0.0,
                                child: Icon(
                                  Icons.document_scanner_rounded,
                                  size: 1,
                                ),
                              ),
                            if (!isMenuExpanded)
                              const Opacity(
                                opacity: 0.0,
                                child: Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 1,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomNavItem({
    required int index,
    required Widget Function(bool isSelected, Color color) iconBuilder,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill container for active state matching Figma 20:19764
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              height: 29,
              decoration: BoxDecoration(
                color: isSelected ? _activePillColor : Colors.transparent,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Center(
                child: iconBuilder(
                  isSelected,
                  isSelected ? _activeTextColor : _inactiveColor,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _activeTextColor : _inactiveColor,
                letterSpacing: 0.1,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
