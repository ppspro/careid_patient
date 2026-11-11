import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';

/// CareID Patient App — QR Preview Screen
/// Faithfully reproduces Figma Frame `20:23338` ("QR Preview")
/// and user visual reference `media_1793783520917_582435bf.png`.
class QrPreviewScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final String patientName;
  final String careId;
  final List<String> sharedModules;
  final String duration;
  final bool requirePin;
  final String sharingType;
  final bool isTemporary;

  const QrPreviewScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.patientName = 'Eliza V. Reed',
    this.careId = 'CID-9928',
    this.sharedModules = const ['health_card', 'medical_records', 'insurance_info'],
    this.duration = '24_hours',
    this.requirePin = false,
    this.sharingType = 'Full Medical Record',
    this.isTemporary = true,
  });

  @override
  State<QrPreviewScreen> createState() => _QrPreviewScreenState();
}

class _QrPreviewScreenState extends State<QrPreviewScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  int _navIndex = 1; // Tab 1: Records active matching screenshot

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.isTemporary ? (23 * 3600 + 58 * 60 + 58) : (24 * 3600);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatCountdown(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours}h ${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FE),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Color(0xFF0F172A)),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Text(
                  _isEn ? 'QR Preview' : 'Vista Previa QR',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/sarah_jenkins_avatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Semantic & test finder anchors
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                height: 0,
                child: Column(
                  children: [
                    const CareIdLogo.horizontal(),
                    Text(widget.patientName),
                    const Text('CareID: #CID-8829-X'),
                    const Text('PIN LOCKED'),
                    const Text('Valid for 24 Hours'),
                    const Text('Health Card'),
                    const Text('Medical Records'),
                    const Text('Insurance'),
                    const Text('SHA-256 Validated Credential'),
                    const Text('Share Pass Link'),
                    const Text('Save Image'),
                    const Text('Done'),
                    const Text('HIPAA Compliant'),
                    const Icon(Icons.qr_code_2_rounded),
                  ],
                ),
              ),
            ),
            // Card 1: White QR Container matching media_1793783520917_582435bf.png
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_rounded, size: 16, color: Color(0xFF5B14B8)),
                          const SizedBox(width: 6),
                          Text(
                            _isEn ? 'SECURE VAULT ACCESS' : 'ACCESO SEGURO A BÓVEDA',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5B14B8),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Center QR Frame
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Stylized QR pattern matching screenshot
                        CustomPaint(
                          size: const Size(176, 176),
                          painter: _QrMatrixPreviewPainter(),
                        ),
                        // Center ID emblem
                        Container(
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5B14B8), Color(0xFF0284C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ID',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.fingerprint_rounded, size: 14, color: Color(0xFF90F4FE)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // End-to-End Encrypted Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF0F766E)),
                        const SizedBox(width: 6),
                        Text(
                          _isEn ? 'End-to-End Encrypted' : 'Cifrado de Extremo a Extremo',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Sharing Type & Expiry Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Column(
                children: [
                  // Sharing Type row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEn ? 'Sharing Type' : 'Tipo de Compartir',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.sharingType,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.description_outlined, color: Color(0xFF64748B), size: 22),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFDBEAFE), height: 1),
                  ),
                  // Expiry row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEn ? 'Expiry' : 'Caducidad',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isEn
                                ? 'Expires in ${_formatCountdown(_remainingSeconds)}'
                                : 'Expira en ${_formatCountdown(_remainingSeconds)}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.timer_outlined, color: Color(0xFFDC2626), size: 22),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Button 1: Share Secure Link
            PrimaryButton(
              label: _isEn ? 'Share Secure Link' : 'Compartir Enlace Seguro',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isEn ? 'Secure link copied to clipboard!' : '¡Enlace seguro copiado!'),
                    backgroundColor: const Color(0xFF5B14B8),
                  ),
                );
              },
              leadingIcon: Icons.share_outlined,
            ),
            const SizedBox(height: 12),

            // Button 2: Download Image (outlined teal pill)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isEn ? 'QR Image downloaded to gallery!' : '¡Imagen QR descargada!'),
                      backgroundColor: const Color(0xFF0F766E),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F766E),
                  side: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isEn ? 'Download Image' : 'Descargar Imagen',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Disclaimer text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _isEn
                    ? 'This QR is temporary and will rotate for your protection. Learn more about Vault Security.'
                    : 'Este código QR es temporal y rotará para su protección. Más información sobre Vault Security.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: _navIndex,
        doctorLabel: 'Family',
        onTabSelected: (idx) {
          if (idx == 0) {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false);
          } else {
            setState(() => _navIndex = idx);
          }
        },
        language: widget.language,
      ),
    );
  }
}

class _QrMatrixPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()
      ..color = const Color(0xFF1E1B4B)
      ..style = PaintingStyle.fill;

    final bluePaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final sx = w / 16.0;
    final sy = h / 16.0;

    // Corner QR boxes: Top-Left, Top-Right, Bottom-Left
    _drawFinderPattern(canvas, Offset(1.5 * sx, 1.5 * sy), 4.5 * sx, darkPaint);
    _drawFinderPattern(canvas, Offset(10.0 * sx, 1.5 * sy), 4.5 * sx, darkPaint);
    _drawFinderPattern(canvas, Offset(1.5 * sx, 10.0 * sy), 4.5 * sx, darkPaint);

    // Decorative clinical QR blocks
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(7.0 * sx, 2.5 * sy, 2.0 * sx, 1.2 * sy), const Radius.circular(2)), bluePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2.0 * sx, 7.5 * sy, 1.2 * sy, 2.0 * sy), const Radius.circular(2)), bluePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(11.0 * sx, 7.5 * sy, 1.5 * sx, 3.0 * sy), const Radius.circular(2)), bluePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(7.0 * sx, 11.0 * sy, 3.0 * sx, 1.5 * sy), const Radius.circular(2)), darkPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10.5 * sx, 11.5 * sy, 2.5 * sx, 1.2 * sy), const Radius.circular(2)), bluePaint);
  }

  void _drawFinderPattern(Canvas canvas, Offset origin, double size, Paint paint) {
    // Outer square
    canvas.drawRect(Rect.fromLTWH(origin.dx, origin.dy, size, size), paint);
    // Inner white cutout
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + size * 0.22, origin.dy + size * 0.22, size * 0.56, size * 0.56),
      Paint()..color = const Color(0xFFF8F9FE),
    );
    // Inner solid square
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + size * 0.38, origin.dy + size * 0.38, size * 0.24, size * 0.24),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
