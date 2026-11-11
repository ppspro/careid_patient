import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// CareID Patient App — Approved Dental Brand Logo & Icon Widget
/// Faithfully reproduces the official CareID Dental Tooth brand icon from
/// `CAREID-AIO-FIGMA` (Patient App Canvas `17:55` — Dental Records Frame `20:21111`,
/// Health Records Landing Card Frame `20:25279`, and Upload Flow Frame `20:21497`).
///
/// Features an anatomical dual-cusp molar crown with rounded root bifurcation,
/// replacing incorrect generic band-aid (healing_outlined) and health safety icons.
class CareIdDentalLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool hasBackground;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CareIdDentalLogo({
    super.key,
    this.size = 24.0,
    this.color,
    this.hasBackground = false,
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.padding = EdgeInsets.zero,
  });

  /// Factory for category cards and badge headers with soft cyan background
  const CareIdDentalLogo.badge({
    super.key,
    this.size = 20.0,
    this.color,
    this.hasBackground = true,
    this.backgroundColor,
    this.borderRadius = 10.0,
    this.padding = const EdgeInsets.all(8.0),
  });

  /// Factory for watermark background accents (Figma 20:25280)
  const CareIdDentalLogo.watermark({
    super.key,
    this.size = 54.0,
    this.color,
    this.hasBackground = false,
    this.backgroundColor,
    this.borderRadius = 0.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.dentalIcon;
    final effectiveBg = backgroundColor ?? const Color(0xFFE0F2FE);

    final Widget toothIcon = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: DentalToothPainter(color: effectiveColor),
      ),
    );

    if (hasBackground) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: toothIcon,
      );
    }

    return toothIcon;
  }
}

/// Precision CustomPainter rendering the approved CareID molar tooth vector
class DentalToothPainter extends CustomPainter {
  final Color color;

  const DentalToothPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Scale and translate the authentic dental molar path
    final path = Path();

    // Start at top central groove
    path.moveTo(w * 0.50, h * 0.18);

    // Left crown cusp (upper curve)
    path.cubicTo(
      w * 0.40, h * 0.06,
      w * 0.20, h * 0.06,
      w * 0.12, h * 0.22,
    );

    // Upper left shoulder down to upper flank
    path.cubicTo(
      w * 0.06, h * 0.35,
      w * 0.08, h * 0.52,
      w * 0.16, h * 0.65,
    );

    // Left root taper towards tip
    path.cubicTo(
      w * 0.20, h * 0.76,
      w * 0.22, h * 0.90,
      w * 0.28, h * 0.94,
    );

    // Left root tip rounded bottom
    path.cubicTo(
      w * 0.33, h * 0.96,
      w * 0.36, h * 0.88,
      w * 0.38, h * 0.78,
    );

    // Bifurcation arch between left and right root
    path.cubicTo(
      w * 0.42, h * 0.62,
      w * 0.58, h * 0.62,
      w * 0.62, h * 0.78,
    );

    // Right root tip rounded bottom
    path.cubicTo(
      w * 0.64, h * 0.88,
      w * 0.67, h * 0.96,
      w * 0.72, h * 0.94,
    );

    // Right root flank curving up
    path.cubicTo(
      w * 0.78, h * 0.90,
      w * 0.80, h * 0.76,
      w * 0.84, h * 0.65,
    );

    // Upper right flank and shoulder
    path.cubicTo(
      w * 0.92, h * 0.52,
      w * 0.94, h * 0.35,
      w * 0.88, h * 0.22,
    );

    // Right crown cusp (upper curve)
    path.cubicTo(
      w * 0.80, h * 0.06,
      w * 0.60, h * 0.06,
      w * 0.50, h * 0.18,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DentalToothPainter oldDelegate) => oldDelegate.color != color;
}

