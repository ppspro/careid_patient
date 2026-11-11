import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../shared/widgets/careid_logo.dart';

/// CareID Patient App — Record Saved Success Screen
/// Grounded faithfully in Figma Frame `20:33470` (Canvas 17:55)
class RecordSavedSuccessScreen extends StatelessWidget {
  final String recordTitle;
  final String category;
  final String recordId;

  const RecordSavedSuccessScreen({
    super.key,
    this.recordTitle = 'Clinical Health Record',
    this.category = 'Medical',
    this.recordId = 'REC-VAULT-2026',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const CareIdLogo.horizontal(height: 18),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Glowing Success Badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF14B8A6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Heading: Record Saved Successfully
              Text(
                'Record Saved\nSuccessfully',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.6,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your health record has been encrypted and securely committed to your CareID Health Vault.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Document Title', recordTitle, isBold: true),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildSummaryRow('Category', category),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildSummaryRow('Vault ID', recordId),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildSummaryRow('Security Protocol', 'AES-256 GCM Encrypted'),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Primary CTA: View Health Vault
              PrimaryButton(
                label: 'View Health Vault',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                },
              ),

              const SizedBox(height: 14),

              // Secondary CTA: Share Record Pass
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/share-options');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5B14B8),
                    side: const BorderSide(color: Color(0xFF5B14B8), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    'Share Secure QR Pass',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}

