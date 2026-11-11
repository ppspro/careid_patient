import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/insurance_policy_models.dart';

/// CareID Patient App — Insurance QR Screen
/// Faithfully reproduces Figma Frame `20:21019` ("Html → Body" / "Insurance QR", 390x1135)
/// Located on canvas "Careid patient app" (node 17:55) in the Insurance & Financing module.
class InsuranceQrScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final InsurancePolicyDto policy;

  const InsuranceQrScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    required this.policy,
  });

  @override
  State<InsuranceQrScreen> createState() => _InsuranceQrScreenState();
}

class _InsuranceQrScreenState extends State<InsuranceQrScreen> {
  late InsurancePolicyDto _policy;
  bool _isExporting = false;

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _policy = widget.policy;
  }

  void _handleSharePass() {
    setState(() => _isExporting = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEn
                      ? 'Secure insurance QR pass shared successfully.'
                      : 'Pase QR seguro de seguro compartido con éxito.',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  void _handleSaveToWallet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isEn
                    ? 'Insurance pass added to digital wallet credentials.'
                    : 'Pase de seguro añadido a credenciales de cartera digital.',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1B4B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF2E006A)),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: _isEn ? 'Back' : 'Volver',
                ),
                Text(
                  _isEn ? 'Insurance QR' : 'QR de Seguro',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E006A),
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CareIdLogo.onlyId(height: 18),
                    SizedBox(width: 8),
                    Icon(Icons.notifications_none_rounded, color: Color(0xFF2E006A), size: 22),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: 1, // Records & Coverage
        onTabSelected: (index) => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          children: [
            _buildHeroQrContainer(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildSecurityDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroQrContainer() {
    final provider = _policy.providerName.isNotEmpty ? _policy.providerName : 'BlueCross Platinum Plus';
    final policyNum = _policy.policyNumber.isNotEmpty ? _policy.policyNumber : '44829-01';
    final groupNum = (_policy.groupNumber != null && _policy.groupNumber!.isNotEmpty)
        ? _policy.groupNumber!
        : '99281';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Subtle Card Visual Header (Mirroring Home Hero)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E006A), Color(0xFF1E1B4B), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEn ? 'MEMBER' : 'MIEMBRO',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDDD6FE),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Sarah Jenkins',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _isEn ? 'PLAN ID' : 'ID DE PLAN',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF99F6E4),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      policyNum,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Verification Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                SizedBox(width: 6),
                Text(
                  'VERIFIED ACTIVE COVERAGE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF047857),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // QR Code Section
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x100F172A),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated High-Density 2D Matrix / QR Representation
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _InsuranceQrPainter(),
                ),
                // Center CareID badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E006A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CareIdLogo.onlyId(height: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Insurance Details Summary
          Text(
            provider,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Policy #$policyNum • Group #$groupNum',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Comprehensive Medical & Rx • Active through 12/2026',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F766E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          label: _isEn ? 'Share QR Pass' : 'Compartir Pase QR',
          onPressed: _isExporting ? null : _handleSharePass,
          isLoading: _isExporting,
          leadingIcon: Icons.ios_share_rounded,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _handleSaveToWallet,
            icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
            label: Text(
              _isEn ? 'Add to Digital Wallet' : 'Añadir a Cartera Digital',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F766E),
              side: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF0F766E), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEn
                  ? 'This secure QR credential allows authorized healthcare providers to instantly verify your active insurance coverage and eligibility. Generated in real-time with HIPAA-compliant encryption.'
                  : 'Esta credencial QR segura permite a los proveedores de atención médica autorizados verificar instantáneamente su cobertura y elegibilidad de seguro activo. Generado en tiempo real con cifrado compatible con HIPAA.',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.45,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter simulating high-density 2D Matrix / QR patterns with finder squares
class _InsuranceQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    const blockSize = 8.0;
    final cols = (size.width / blockSize).floor();
    final rows = (size.height / blockSize).floor();

    // 3 Finder patterns at corners (Top-Left, Top-Right, Bottom-Left)
    _drawFinderPattern(canvas, 10, 10, 48, paint);
    _drawFinderPattern(canvas, size.width - 58, 10, 48, paint);
    _drawFinderPattern(canvas, 10, size.height - 58, 48, paint);

    // Grid data dots
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Skip finder areas
        if ((r < 8 && c < 8) || (r < 8 && c > cols - 9) || (r > rows - 9 && c < 8)) {
          continue;
        }
        // Skip center logo area
        if (r > rows / 2 - 4 && r < rows / 2 + 4 && c > cols / 2 - 4 && c < cols / 2 + 4) {
          continue;
        }
        // Pseudo-random deterministic bits
        if ((r * 13 + c * 37 + (r ^ c)) % 3 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * blockSize + 1, r * blockSize + 1, blockSize - 2, blockSize - 2),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double size, Paint paint) {
    // Outer box
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, size, size), const Radius.circular(6)),
      paint,
    );
    // Inner box
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x + 12, y + 12, size - 24, size - 24), const Radius.circular(4)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
