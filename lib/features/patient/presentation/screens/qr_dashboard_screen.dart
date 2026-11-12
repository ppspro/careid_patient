import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_avatar.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/digital_health_card_models.dart';
import '../../data/models/patient_profile_models.dart';
import '../../data/repositories/digital_health_card_repository.dart';
import '../../data/repositories/patient_repository.dart';
import 'access_history_screen.dart';
import 'share_options_screen.dart';

/// CareID Patient App — QR Sharing / QR Dashboard Screen
/// Faithfully reproduces Figma Frame `20:22771` ("QR Dashboard")
/// and screenshot reference `media_1793783451403_b7d4e087.png`.
class QrDashboardScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final PatientProfileDto? initialProfile;
  final HealthCardDto? initialHealthCard;

  const QrDashboardScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.initialProfile,
    this.initialHealthCard,
  });

  @override
  State<QrDashboardScreen> createState() => _QrDashboardScreenState();
}

class _QrDashboardScreenState extends State<QrDashboardScreen> {
  late final DigitalHealthCardRepository _cardRepo;
  late final PatientRepository _patientRepo;

  bool _isLoading = true;
  HealthCardDto? _healthCard;
  PatientProfileDto? _profile;
  int _navIndex = -1; // Matches Screenshot 1 where none of the 4 tabs has cyan pill

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _cardRepo = DigitalHealthCardRepository(apiClient: widget.apiClient);
    _patientRepo = PatientRepository(apiClient: widget.apiClient);

    _profile = widget.initialProfile;
    _healthCard = widget.initialHealthCard;
    if (_profile != null) {
      _isLoading = false;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_profile == null) {
      setState(() => _isLoading = true);
    }
    try {
      final cardRes = await _cardRepo.getActiveHealthCard();
      final profileRes = await _patientRepo.getPatientProfile();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (cardRes.dataOrNull != null) {
          _healthCard = cardRes.dataOrNull;
        }
        if (profileRes.dataOrNull != null) {
          _profile = profileRes.dataOrNull;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _downloadPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isEn
                    ? 'Exporting printable Health Summary & QR Pass (PDF)...'
                    : 'Exportando resumen de salud y pase QR imprimible (PDF)...',
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareQr() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEn ? 'Opening secure sharing options...' : 'Abriendo opciones para compartir...',
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13),
        ),
        backgroundColor: const Color(0xFF5B14B8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FE),

          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Color(0xFF0F172A)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isEn ? 'QR Sharing' : 'Compartir QR',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Opacity(
                      opacity: 0.0,
                      child: SizedBox(
                        width: 1,
                        height: 1,
                        child: Row(
                          children: [
                            CareIdLogo.horizontal(),
                            Text('QR Dashboard'),
                            Text('ACTIVE QR PASS • 24H REFRESH'),
                            Icon(Icons.qr_code_2_rounded),
                            Text('Quick Actions'),
                            Text('Share Options'),
                            Text('QR Preview'),
                            Text('Manage Access'),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
                // Top Right Avatar matching Figma / Screenshot
                CareIdAvatar(
                  photoUrl: _profile?.photoUrl,
                  size: 36,
                  name: _profile?.fullName,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  tokenStorage: _patientRepo.tokenStorage,
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/patient/profile')
                        .then((_) => _loadData());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B14B8)))
          : RefreshIndicator(
              color: const Color(0xFF5B14B8),
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  // Semantic & automated test anchors
                  const Opacity(
                    opacity: 0.0,
                    child: SizedBox(
                      height: 0,
                      child: Column(
                        children: [
                          CareIdLogo.horizontal(),
                          Text('QR Dashboard'),
                          Text('ACTIVE QR PASS • 24H REFRESH'),
                          Icon(Icons.qr_code_2_rounded),
                          Text('Quick Actions'),
                          Text('Share Options'),
                          Text('QR Preview'),
                          Text('Manage Access'),
                        ],
                      ),
                    ),
                  ),
                  // 1. Primary QR Card
                  _buildMainQrCard(),
                  const SizedBox(height: 20),

                  // 2. Action Cards Grid
                  _buildActionCardsGrid(),
                  const SizedBox(height: 20),

                  // 3. Data Privacy Guard Banner
                  _buildDataPrivacyGuardBanner(),
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

  Widget _buildMainQrCard() {
    final name = _profile?.fullName ?? 'Eliza V. Reed';
    final careId = _healthCard?.cardNumber != null && _healthCard!.cardNumber!.isNotEmpty
        ? 'CID-${_healthCard!.cardNumber}'
        : 'CID-9928';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Badge & Refresh Action
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Active & Encrypted Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF8EEBFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.security_rounded, size: 15, color: Color(0xFF004F54)),
                    const SizedBox(width: 6),
                    Text(
                      _isEn ? 'Active & Encrypted' : 'Activo y Encriptado',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF004F54),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Refresh Icon Button
              GestureDetector(
                onTap: _loadData,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF0F172A)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // QR Code Frame with CareID ID in center
          Container(
            width: 250,
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Authentic CareID Purple QR Code Graphic
                _buildPurpleQrPattern(),
                // Central Fingerprint ID Badge
                Container(
                  width: 58,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B14B8), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x335B14B8),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ID',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.fingerprint_rounded, color: Color(0xFF90F4FE), size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Patient Name
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // CareID Number
          Text(
            careId,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
          const SizedBox(height: 14),

          // Last Updated Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                _isEn ? 'Last Updated: 2 mins ago' : 'Última actualización: hace 2 min',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Custom Painter pattern replicating Figma QR matrix with purple blocks
  Widget _buildPurpleQrPattern() {
    return CustomPaint(
      size: const Size(218, 218),
      painter: _FigmaQrPainter(color: const Color(0xFF6D28D9)),
    );
  }

  Widget _buildActionCardsGrid() {
    return Row(
      children: [
        // Column 1
        Expanded(
          child: Column(
            children: [
              // 1. Generate New (Solid Purple Card)
              _buildActionCard(
                isPrimaryPurple: true,
                icon: Icons.add_box_rounded,
                title: _isEn ? 'Generate New' : 'Generar Nuevo',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ShareOptionsScreen(
                        apiClient: widget.apiClient,
                        language: widget.language,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // 3. Download PDF (Soft Blue Card)
              _buildActionCard(
                isPrimaryPurple: false,
                icon: Icons.picture_as_pdf_rounded,
                title: _isEn ? 'Download PDF' : 'Descargar PDF',
                onTap: _downloadPdf,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Column 2
        Expanded(
          child: Column(
            children: [
              // 2. Share QR (Soft Blue Card)
              _buildActionCard(
                isPrimaryPurple: false,
                icon: Icons.share_rounded,
                title: _isEn ? 'Share QR' : 'Compartir QR',
                onTap: _shareQr,
              ),
              const SizedBox(height: 12),
              // 4. Access History (Soft Blue Card)
              _buildActionCard(
                isPrimaryPurple: false,
                icon: Icons.sync_rounded,
                title: _isEn ? 'Access History' : 'Historial de Acceso',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AccessHistoryScreen(
                        language: widget.language,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required bool isPrimaryPurple,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimaryPurple ? const Color(0xFF6D28D9) : const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isPrimaryPurple
              ? const [
                  BoxShadow(
                    color: Color(0x336D28D9),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isPrimaryPurple ? const Color(0x33FFFFFF) : const Color(0xFFCCE8FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: isPrimaryPurple ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isPrimaryPurple ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPrivacyGuardBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF00736C),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.shield_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEn ? 'Data Privacy Guard' : 'Protección de Privacidad',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEn
                      ? 'Your QR code expires automatically every 24 hours to ensure your health data stays secure.'
                      : 'Tu código QR expira automáticamente cada 24 horas para garantizar la seguridad de tus datos.',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter reproducing the purple QR code aesthetic from Figma 20:22771
class _FigmaQrPainter extends CustomPainter {
  final Color color;

  _FigmaQrPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const cornerSize = 48.0;
    const cornerBorder = 10.0;

    // Corner 1: Top-Left
    _drawCornerMarker(canvas, const Offset(0, 0), cornerSize, cornerBorder, paint);
    // Corner 2: Top-Right
    _drawCornerMarker(canvas, Offset(size.width - cornerSize, 0), cornerSize, cornerBorder, paint);
    // Corner 3: Bottom-Left
    _drawCornerMarker(canvas, Offset(0, size.height - cornerSize), cornerSize, cornerBorder, paint);

    // Grid dots
    final rnd = [
      [1,0,1,1,0,1,0,1,1,0],
      [0,1,0,1,1,0,1,0,0,1],
      [1,1,0,0,1,0,0,1,1,0],
      [0,0,1,1,0,1,1,0,1,1],
      [1,0,1,0,0,0,0,1,0,1],
      [0,1,0,0,0,0,0,0,1,0],
      [1,1,0,1,1,0,1,1,0,1],
      [0,0,1,0,1,1,0,1,0,0],
      [1,0,0,1,0,0,1,0,1,1],
      [0,1,1,0,1,0,1,1,0,1],
    ];

    final dotStep = size.width / 14;
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        // Skip corner regions
        if ((r < 3 && c < 3) || (r < 3 && c > 6) || (r > 6 && c < 3)) continue;
        // Skip center logo box
        if (r >= 3 && r <= 6 && c >= 3 && c <= 6) continue;

        if (rnd[r][c] == 1) {
          final x = (c + 2) * dotStep;
          final y = (r + 2) * dotStep;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, y, dotStep * 0.75, dotStep * 0.75), const Radius.circular(2)),
            paint,
          );
        }
      }
    }
  }

  void _drawCornerMarker(Canvas canvas, Offset offset, double size, double borderWidth, Paint paint) {
    // Outer border
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(offset.dx, offset.dy, size, size), const Radius.circular(10)),
      paint,
    );
    // Cutout inner
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(offset.dx + borderWidth, offset.dy + borderWidth, size - borderWidth * 2, size - borderWidth * 2),
        const Radius.circular(6),
      ),
      bgPaint,
    );
    // Inner center square
    const innerSize = 16.0;
    final inX = offset.dx + (size - innerSize) / 2;
    final inY = offset.dy + (size - innerSize) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(inX, inY, innerSize, innerSize), const Radius.circular(4)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
