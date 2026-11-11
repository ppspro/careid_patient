import 'package:flutter/material.dart';

/// Authentic Apple Wallet Badge Button
/// Faithfully reproduces Figma Frame `20:19923` and `20:33017` ("Add to Apple Wallet")
class AppleWalletButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double height;
  final String label;

  const AppleWalletButton({
    super.key,
    this.onPressed,
    this.height = 54,
    this.label = 'Add to Apple Wallet',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomPaint(
                  size: Size(18, 22),
                  painter: AppleLogoPainter(color: Colors.white),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Authentic Google Wallet / Google Pay Badge Button
/// Faithfully reproduces Figma Frame `20:19928` ("Add to Google Wallet")
/// and `20:33023` ("Add to Google Pay", `Google_Pay_Logo.svg` 20:19930 / 20:33025)
class GoogleWalletButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double height;
  final String label;
  final bool isLightStyle;

  const GoogleWalletButton({
    super.key,
    this.onPressed,
    this.height = 54,
    this.label = 'Add to Google Wallet',
    this.isLightStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isLightStyle ? Colors.white : Colors.black;
    final textColor = isLightStyle ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isLightStyle ? const Color(0xFFD1D5DB) : Colors.white24;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          splashColor: isLightStyle ? Colors.black12 : Colors.white24,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Authentic Google 4-Color 'G' Logo
                const CustomPaint(
                  size: Size(20, 20),
                  painter: GoogleGLogoPainter(),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Official Apple App Store Download Badge
class AppStoreBadge extends StatelessWidget {
  final VoidCallback? onPressed;
  final double height;

  const AppStoreBadge({
    super.key,
    this.onPressed,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Download on the App Store',
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA6A6A6), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: Size(16, 20),
                  painter: AppleLogoPainter(color: Colors.white),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Download on the',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'App Store',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Official Google Play Store Download Badge
class GooglePlayBadge extends StatelessWidget {
  final VoidCallback? onPressed;
  final double height;

  const GooglePlayBadge({
    super.key,
    this.onPressed,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'GET IT ON Google Play',
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA6A6A6), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: Size(18, 20),
                  painter: GooglePlayTrianglePainter(),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GET IT ON',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Google Play',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Vector Apple Logo Painter (Leaf and Bitten Apple)
class AppleLogoPainter extends CustomPainter {
  final Color color;
  const AppleLogoPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // 1. Apple Leaf
    final leaf = Path();
    leaf.moveTo(w * 0.54, h * 0.22);
    leaf.cubicTo(w * 0.54, h * 0.12, w * 0.65, h * 0.02, w * 0.74, h * 0.02);
    leaf.cubicTo(w * 0.74, h * 0.13, w * 0.64, h * 0.24, w * 0.54, h * 0.22);
    canvas.drawPath(leaf, paint);

    // 2. Apple Body with Bite
    final body = Path();
    body.moveTo(w * 0.50, h * 0.32);
    body.cubicTo(w * 0.60, h * 0.28, w * 0.75, h * 0.34, w * 0.83, h * 0.44);
    // Bite arc
    body.cubicTo(w * 0.73, h * 0.50, w * 0.73, h * 0.66, w * 0.83, h * 0.72);
    body.cubicTo(w * 0.78, h * 0.85, w * 0.70, h * 0.98, w * 0.58, h * 0.98);
    // Bottom notch
    body.cubicTo(w * 0.53, h * 0.98, w * 0.47, h * 0.93, w * 0.41, h * 0.93);
    body.cubicTo(w * 0.35, h * 0.93, w * 0.29, h * 0.98, w * 0.23, h * 0.98);
    // Left curve
    body.cubicTo(w * 0.12, h * 0.85, w * 0.04, h * 0.64, w * 0.16, h * 0.46);
    body.cubicTo(w * 0.23, h * 0.34, w * 0.36, h * 0.28, w * 0.46, h * 0.32);
    // Top notch
    body.cubicTo(w * 0.48, h * 0.33, w * 0.49, h * 0.33, w * 0.50, h * 0.32);
    body.close();

    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant AppleLogoPainter oldDelegate) => oldDelegate.color != color;
}

/// Vector Google 4-Color 'G' Painter
class GoogleGLogoPainter extends CustomPainter {
  const GoogleGLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.42;
    final arcRadius = radius - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: arcRadius);

    Paint arcPaint(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    // Red arc (top)
    canvas.drawArc(rect, -2.4, 1.6, false, arcPaint(const Color(0xFFEA4335)));
    // Yellow arc (left)
    canvas.drawArc(rect, -3.1415, 1.25, false, arcPaint(const Color(0xFFFBBC05)));
    // Green arc (bottom)
    canvas.drawArc(rect, 0.7, 1.65, false, arcPaint(const Color(0xFF34A853)));
    // Blue arc (right)
    canvas.drawArc(rect, -0.75, 1.45, false, arcPaint(const Color(0xFF4285F4)));

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final barRect = Rect.fromLTWH(
      center.dx - radius * 0.05,
      center.dy - strokeWidth / 2,
      radius * 1.05,
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector Google Play Triangle Painter
class GooglePlayTrianglePainter extends CustomPainter {
  const GooglePlayTrianglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base Blue Polygon
    final bluePath = Path()
      ..moveTo(0, h * 0.05)
      ..lineTo(w * 0.58, h * 0.50)
      ..lineTo(0, h * 0.95)
      ..close();
    canvas.drawPath(
      bluePath,
      Paint()
        ..color = const Color(0xFF00D2FF)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    // Top Green Polygon
    final greenPath = Path()
      ..moveTo(0, h * 0.05)
      ..lineTo(w * 0.72, h * 0.62)
      ..lineTo(w * 0.58, h * 0.50)
      ..close();
    canvas.drawPath(
      greenPath,
      Paint()
        ..color = const Color(0xFF00F076)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    // Bottom Red Polygon
    final redPath = Path()
      ..moveTo(0, h * 0.95)
      ..lineTo(w * 0.58, h * 0.50)
      ..lineTo(w * 0.72, h * 0.38)
      ..close();
    canvas.drawPath(
      redPath,
      Paint()
        ..color = const Color(0xFFFF3A44)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    // Right Yellow Triangle
    final yellowPath = Path()
      ..moveTo(w * 0.58, h * 0.50)
      ..lineTo(w * 0.98, h * 0.50)
      ..lineTo(w * 0.72, h * 0.38)
      ..close();
    canvas.drawPath(
      yellowPath,
      Paint()
        ..color = const Color(0xFFFFE000)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
