import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Stethoscope CustomPainter matching exact Figma vector in frame 20:19764 and approved reference
class StethoscopePainter extends CustomPainter {
  final Color color;
  const StethoscopePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final sx = w / 24.0;
    final sy = h / 24.0;

    // 1. Left earpiece (inward nub) & tube: (8.0, 4.0) -> (6.0, 4.0) -> (6.0, 9.0)
    final leftPath = Path()
      ..moveTo(8.0 * sx, 4.0 * sy)
      ..lineTo(6.0 * sx, 4.0 * sy)
      ..lineTo(6.0 * sx, 9.0 * sy);
    canvas.drawPath(leftPath, strokePaint);

    // 2. Right earpiece (inward nub) & tube: (12.0, 4.0) -> (14.0, 4.0) -> (14.0, 9.0)
    final rightPath = Path()
      ..moveTo(12.0 * sx, 4.0 * sy)
      ..lineTo(14.0 * sx, 4.0 * sy)
      ..lineTo(14.0 * sx, 9.0 * sy);
    canvas.drawPath(rightPath, strokePaint);

    // 3. U-shaped tube connecting earpieces smoothly dipping down
    final uPath = Path()
      ..moveTo(6.0 * sx, 9.0 * sy)
      ..cubicTo(
        6.0 * sx, 14.5 * sy,
        14.0 * sx, 14.5 * sy,
        14.0 * sx, 9.0 * sy,
      );
    canvas.drawPath(uPath, strokePaint);

    // 4. Lower stem tube curving down, right, and up in a loop to the chestpiece
    final stemPath = Path()
      ..moveTo(10.0 * sx, 13.1 * sy)
      ..lineTo(10.0 * sx, 15.0 * sy)
      ..cubicTo(
        10.0 * sx, 19.5 * sy,
        18.0 * sx, 19.5 * sy,
        18.0 * sx, 14.5 * sy,
      )
      ..lineTo(18.0 * sx, 13.0 * sy);
    canvas.drawPath(stemPath, strokePaint);

    // 5. Chestpiece / Bell (solid circle on right)
    canvas.drawCircle(Offset(18.0 * sx, 11.2 * sy), 2.6 * sx, fillPaint);
  }

  @override
  bool shouldRepaint(covariant StethoscopePainter oldDelegate) => oldDelegate.color != color;
}

/// Folder with Gear CustomPainter matching exact Figma vector in frame 20:19764
class FolderWithGearPainter extends CustomPainter {
  final Color color;
  const FolderWithGearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final sx = w / 24.0;
    final sy = h / 24.0;

    // Folder outline path (leaving cutout for gear at bottom right)
    final folderPath = Path()
      // Top tab
      ..moveTo(4.0 * sx, 7.0 * sy)
      ..lineTo(4.0 * sx, 5.5 * sy)
      ..arcToPoint(Offset(5.5 * sx, 4.0 * sy), radius: Radius.circular(1.5 * sx))
      ..lineTo(9.0 * sx, 4.0 * sy)
      ..lineTo(10.5 * sx, 6.0 * sy)
      ..lineTo(18.5 * sx, 6.0 * sy)
      ..arcToPoint(Offset(20.0 * sx, 7.5 * sy), radius: Radius.circular(1.5 * sx))
      ..lineTo(20.0 * sx, 11.0 * sy)
      // Bottom & left sides
      ..moveTo(4.0 * sx, 7.0 * sy)
      ..lineTo(4.0 * sx, 18.5 * sy)
      ..arcToPoint(Offset(5.5 * sx, 20.0 * sy), radius: Radius.circular(1.5 * sx))
      ..lineTo(11.5 * sx, 20.0 * sy);

    canvas.drawPath(folderPath, strokePaint);

    // Gear (settings cog) at (16.5, 16.0)
    final cx = 16.5 * sx;
    final cy = 16.0 * sy;
    final rOuter = 4.2 * sx;

    // Central gear ring
    canvas.drawCircle(
      Offset(cx, cy),
      2.6 * sx,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // 6 gear teeth
    final toothPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final angle = i * (math.pi / 3.0);
      final x1 = cx + math.cos(angle) * 2.2 * sx;
      final y1 = cy + math.sin(angle) * 2.2 * sy;
      final x2 = cx + math.cos(angle) * (rOuter + 0.3 * sx);
      final y2 = cy + math.sin(angle) * (rOuter + 0.3 * sy);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), toothPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FolderWithGearPainter oldDelegate) => oldDelegate.color != color;
}

/// House with door CustomPainter matching exact Figma active Home icon
class HomeHousePainter extends CustomPainter {
  final Color color;
  final bool isFilled;
  const HomeHousePainter({required this.color, this.isFilled = true});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 24.0;
    final sy = h / 24.0;

    if (isFilled) {
      // Solid pitched roof and house body with rectangular door opening
      final housePath = Path()
        ..moveTo(12.0 * sx, 3.5 * sy)
        ..lineTo(20.0 * sx, 10.0 * sy)
        ..lineTo(20.0 * sx, 20.0 * sy)
        ..lineTo(14.5 * sx, 20.0 * sy)
        ..lineTo(14.5 * sx, 13.5 * sy)
        ..lineTo(9.5 * sx, 13.5 * sy)
        ..lineTo(9.5 * sx, 20.0 * sy)
        ..lineTo(4.0 * sx, 20.0 * sy)
        ..lineTo(4.0 * sx, 10.0 * sy)
        ..close();

      canvas.drawPath(
        housePath,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    } else {
      final outlinePath = Path()
        ..moveTo(12.0 * sx, 4.0 * sy)
        ..lineTo(19.5 * sx, 10.0 * sy)
        ..lineTo(19.5 * sx, 19.5 * sy)
        ..lineTo(4.5 * sx, 19.5 * sy)
        ..lineTo(4.5 * sx, 10.0 * sy)
        ..close();

      canvas.drawPath(
        outlinePath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Door outline
      canvas.drawRect(
        Rect.fromLTRB(10.0 * sx, 14.0 * sy, 14.0 * sx, 19.5 * sy),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HomeHousePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

/// Outline Person CustomPainter matching exact Figma Profile icon
class ProfilePersonPainter extends CustomPainter {
  final Color color;
  final bool isFilled;
  const ProfilePersonPainter({required this.color, this.isFilled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 24.0;
    final sy = h / 24.0;

    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Head circle
    canvas.drawCircle(Offset(12.0 * sx, 7.5 * sy), 3.2 * sx, paint);

    // Shoulders / torso
    final bodyPath = Path()
      ..moveTo(5.0 * sx, 19.5 * sy)
      ..arcToPoint(
        Offset(8.5 * sx, 14.0 * sy),
        radius: Radius.circular(5.0 * sx),
        clockwise: true,
      )
      ..lineTo(15.5 * sx, 14.0 * sy)
      ..arcToPoint(
        Offset(19.0 * sx, 19.5 * sy),
        radius: Radius.circular(5.0 * sx),
        clockwise: true,
      )
      ..close();

    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant ProfilePersonPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

/// Exact CareID Central Scanner & Vault Icon matching Figma Frame 20:19790 and live screenshot
class CenterDocumentScannerPainter extends CustomPainter {
  final Color color;
  const CenterDocumentScannerPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final w = size.width;
    final h = size.height;

    final sx = w / 24.0;
    final sy = h / 24.0;

    // 1. Four corner brackets [ ]
    // Top-Left corner
    final tl = Path()
      ..moveTo(3.5 * sx, 7.5 * sy)
      ..lineTo(3.5 * sx, 3.5 * sy)
      ..lineTo(7.5 * sx, 3.5 * sy);
    canvas.drawPath(tl, strokePaint);

    // Top-Right corner
    final tr = Path()
      ..moveTo(16.5 * sx, 3.5 * sy)
      ..lineTo(20.5 * sx, 3.5 * sy)
      ..lineTo(20.5 * sx, 7.5 * sy);
    canvas.drawPath(tr, strokePaint);

    // Bottom-Left corner
    final bl = Path()
      ..moveTo(3.5 * sx, 16.5 * sy)
      ..lineTo(3.5 * sx, 20.5 * sy)
      ..lineTo(7.5 * sx, 20.5 * sy);
    canvas.drawPath(bl, strokePaint);

    // Bottom-Right corner
    final br = Path()
      ..moveTo(16.5 * sx, 20.5 * sy)
      ..lineTo(20.5 * sx, 20.5 * sy)
      ..lineTo(20.5 * sx, 16.5 * sy);
    canvas.drawPath(br, strokePaint);

    // 2. Central Document Card (rounded rectangle outline)
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(12.0 * sx, 12.0 * sy),
        width: 10.0 * sx,
        height: 12.5 * sy,
      ),
      Radius.circular(1.8 * sx),
    );
    canvas.drawRRect(cardRect, strokePaint..strokeWidth = 2.0);

    // 3. Three horizontal document content lines
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(9.2 * sx, 9.6 * sy), Offset(14.8 * sx, 9.6 * sy), linePaint);
    canvas.drawLine(Offset(9.2 * sx, 12.0 * sy), Offset(14.8 * sx, 12.0 * sy), linePaint);
    canvas.drawLine(Offset(9.2 * sx, 14.4 * sy), Offset(14.8 * sx, 14.4 * sy), linePaint);
  }

  @override
  bool shouldRepaint(covariant CenterDocumentScannerPainter oldDelegate) => oldDelegate.color != color;
}
