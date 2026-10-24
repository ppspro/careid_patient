import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// CareID Official Brand Logo Widget
/// Renders the CareID healthcare cloud symbol (cross, tooth, eye, health card, lock)
/// and the CareID wordmark with the signature fingerprint inside the letter 'D'.
class CareIdLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const CareIdLogo({super.key, this.size = 120.0, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cloud & Medical Ecosystem Graphic
        CustomPaint(
          size: Size(size, size * 0.65),
          painter: _CareIdCloudPainter(),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: size * 0.28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
              children: const [
                TextSpan(
                  text: 'Care',
                  style: TextStyle(color: Color(0xFF0F2547)),
                ),
                TextSpan(
                  text: 'ID',
                  style: TextStyle(
                    color: AppColors.purplePrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CareIdCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw Cloud Outline Path
    final cloudPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cloudFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cloudPath = Path();
    // Start bottom left
    cloudPath.moveTo(w * 0.22, h * 0.88);
    // Bottom curve to right
    cloudPath.lineTo(w * 0.78, h * 0.88);
    // Right lobe
    cloudPath.arcToPoint(
      Offset(w * 0.88, h * 0.62),
      radius: Radius.circular(w * 0.18),
      clockwise: false,
    );
    // Top right lobe
    cloudPath.arcToPoint(
      Offset(w * 0.68, h * 0.22),
      radius: Radius.circular(w * 0.22),
      clockwise: false,
    );
    // Center top dome
    cloudPath.arcToPoint(
      Offset(w * 0.34, h * 0.24),
      radius: Radius.circular(w * 0.25),
      clockwise: false,
    );
    // Left top lobe
    cloudPath.arcToPoint(
      Offset(w * 0.14, h * 0.60),
      radius: Radius.circular(w * 0.20),
      clockwise: false,
    );
    // Left bottom closure
    cloudPath.arcToPoint(
      Offset(w * 0.22, h * 0.88),
      radius: Radius.circular(w * 0.16),
      clockwise: false,
    );
    cloudPath.close();

    canvas.drawPath(cloudPath, cloudFillPaint);
    canvas.drawPath(cloudPath, cloudPaint);

    // Draw Inside Elements:
    // 1. Red Medical Cross (Top-Left)
    final crossPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    final crossCenterX = w * 0.36;
    final crossCenterY = h * 0.38;
    final crossSize = w * 0.08;
    final armThick = crossSize * 0.35;
    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(crossCenterX, crossCenterY),
          width: crossSize,
          height: armThick,
        ),
        const Radius.circular(2),
      ),
      crossPaint,
    );
    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(crossCenterX, crossCenterY),
          width: armThick,
          height: crossSize,
        ),
        const Radius.circular(2),
      ),
      crossPaint,
    );

    // 2. Cyan Tooth Icon (Top-Center)
    final dentalPaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.fill;
    final toothX = w * 0.50;
    final toothY = h * 0.36;
    canvas.drawCircle(Offset(toothX, toothY), w * 0.035, dentalPaint);

    // 3. Orange Vision Eye (Top-Right)
    final visionPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final eyeX = w * 0.64;
    final eyeY = h * 0.38;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(eyeX, eyeY),
        width: w * 0.08,
        height: h * 0.08,
      ),
      visionPaint,
    );
    canvas.drawCircle(
      Offset(eyeX, eyeY),
      w * 0.018,
      Paint()..color = const Color(0xFFF97316),
    );

    // 4. Center ID Card with Profile & Lines
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.62),
        width: w * 0.44,
        height: h * 0.32,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = const Color(0xFFE0F2FE)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = const Color(0xFF0284C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Profile silhouette on card
    final profilePaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawCircle(Offset(w * 0.40, h * 0.58), w * 0.03, profilePaint);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.40, h * 0.68),
        width: w * 0.08,
        height: h * 0.08,
      ),
      3.14,
      3.14,
      true,
      profilePaint,
    );

    // Text lines on card
    final linePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.48, h * 0.57),
      Offset(w * 0.64, h * 0.57),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.48, h * 0.63),
      Offset(w * 0.62, h * 0.63),
      linePaint,
    );

    // 5. Cyan Security Padlock (Right side of card)
    final lockPaint = Paint()..color = const Color(0xFF0284C7);
    final lockX = w * 0.60;
    final lockY = h * 0.68;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(lockX, lockY + 2),
          width: w * 0.06,
          height: h * 0.08,
        ),
        const Radius.circular(2),
      ),
      lockPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(lockX, lockY - 2),
        width: w * 0.04,
        height: h * 0.06,
      ),
      3.14,
      3.14,
      false,
      Paint()
        ..color = const Color(0xFF0284C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
