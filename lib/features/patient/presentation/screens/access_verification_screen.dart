import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';

/// CareID Patient App — Access Verification Screen
/// Grounded faithfully in Figma Frame `20:23745` (Canvas 17:55)
class AccessVerificationScreen extends StatefulWidget {
  final String doctorName;
  final String sessionId;

  const AccessVerificationScreen({
    super.key,
    this.doctorName = 'Dr. Marcus Thorne',
    this.sessionId = 'HV-90210-X',
  });

  @override
  State<AccessVerificationScreen> createState() => _AccessVerificationScreenState();
}

class _AccessVerificationScreenState extends State<AccessVerificationScreen> {
  void _handleCopySessionId() {
    Clipboard.setData(ClipboardData(text: widget.sessionId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Session ID copied: ${widget.sessionId}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF28006D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDone() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          // Lower glowing accent
          Positioned(
            right: 20,
            bottom: 120,
            child: IgnorePointer(
              child: Container(
                width: (MediaQuery.sizeOf(context).width * 0.75).clamp(200.0, 280.0),
                height: (MediaQuery.sizeOf(context).width * 0.75).clamp(200.0, 280.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8DDFF).withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8DDFF).withValues(alpha: 0.20),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 72, bottom: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        _buildHeroIllustration(),
                        const SizedBox(height: 24),
                        _buildVerificationTextHierarchy(),
                        const SizedBox(height: 32),
                        _buildVerificationBadges(),
                        const SizedBox(height: 32),
                        _buildPrimaryCtaButton(),
                        const SizedBox(height: 24),
                        _buildFooterSecurityNote(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopAppBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 64 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FF).withValues(alpha: 0.90),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Color(0xFF28006D),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Access Verification',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF28006D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const CareIdLogo.horizontal(height: 18),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCE9FF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, size: 20, color: Color(0xFF0F766E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroIllustration() {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF006971),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF75F2FE).withValues(alpha: 0.5),
              blurRadius: 36,
              spreadRadius: 10,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.verified_user_rounded,
            size: 72,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationTextHierarchy() {
    return Column(
      children: [
        Text(
          'Verified',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B1C30),
            letterSpacing: -0.96,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text.rich(
            TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF494552),
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Your health records have been\nsecurely shared with '),
                TextSpan(
                  text: widget.doctorName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF28006D),
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: _handleCopySessionId,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFCBC4D4).withValues(alpha: 0.50),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF006971)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Encrypted Session ID: ${widget.sessionId}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF494552),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF494552)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationBadges() {
    return Column(
      children: [
        _buildBadgeCard(icon: Icons.badge_outlined, title: 'Identity Verified'),
        const SizedBox(height: 12),
        _buildBadgeCard(icon: Icons.medical_services_outlined, title: 'Doctor Verified'),
        const SizedBox(height: 12),
        _buildBadgeCard(icon: Icons.shield_outlined, title: 'Secure Encryption'),
      ],
    );
  }

  Widget _buildBadgeCard({required IconData icon, required String title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF75F2FE).withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 22, color: const Color(0xFF006971)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0B1C30),
              ),
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Color(0xFF00838F), size: 20),
        ],
      ),
    );
  }

  Widget _buildPrimaryCtaButton() {
    return PrimaryButton(
      text: 'Done',
      trailingIcon: Icons.arrow_forward_rounded,
      onPressed: _handleDone,
    );
  }

  Widget _buildFooterSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF64748B)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Protected by end-to-end medical grade encryption.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}
