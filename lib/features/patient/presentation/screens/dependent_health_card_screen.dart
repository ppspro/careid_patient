import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../data/models/family_models.dart';

/// CareID Patient App — Shared Health Card (Dependent View) Screen
/// Faithfully reproduces Figma Frame `20:22459` ("Shared Health Card - Dependent View", 390x1062.5)
/// Features Apple Wallet inspired physical health card preview for dependent,
/// high-contrast Emergency QR credential, blood group, DOB, known allergies,
/// insurance provider bar, and quick stats bento.
class DependentHealthCardScreen extends StatelessWidget {
  final ApiClient? apiClient;
  final String language;
  final FamilyMemberDto? member;

  const DependentHealthCardScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.member,
  });

  bool get _isEn => language == 'en';

  String get _name => member?.name ?? 'Benjamin Harrison';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation Bar
            _buildTopHeader(context),

            // 2. Main Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Physical Pass Card (Apple Wallet Style)
                  _buildWalletCard(),
                  const SizedBox(height: 16),

                  // Insurance Provider Card
                  _buildInsuranceProviderCard(),
                  const SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 20),

                  // Bento Quick Stats (Immunizations & Prescriptions)
                  _buildBentoStats(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: 1, // Records tab active with cyan capsule
        language: language,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/doctors');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/profile');
          }
        },
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF2E006A)),
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Family Member',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E006A),
                fontFamily: 'Plus Jakarta Sans',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Notification Bell with red badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF2E006A)),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // User Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/sarah_jenkins_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const CircleAvatar(
                  backgroundColor: Color(0xFF5B14B8),
                  child: Text('SJ', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E006A), // Deep Purple
            Color(0xFF1E0A4E), // Mid Dark Purple
            Color(0xFF042F2E), // Deep Cyan / Teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332E006A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Emblem + Premium Care, Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/careid_only_id.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.fingerprint_rounded, color: Color(0xFF2E006A), size: 24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Premium Care',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 11, color: Colors.white),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'VERIFIED DEPENDENT',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Middle Section: Child Photo + Name & Demographics
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 90,
                  height: 90,
                  color: const Color(0xFF1E293B),
                  child: Image.asset(
                    'assets/images/benjamin_harrison_avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/family_oliver.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFA5B4FC),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Blood Group',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFA5B4FC),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                member?.bloodGroup ?? 'O- Positive (O+)',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DOB',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFA5B4FC),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '12 May 2018',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 14),

          // Bottom Section: Severe Allergies + QR Code
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Severe Allergies',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC4B5FD),
                      ),
                    ),
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _AllergyCapsule(label: 'PENICILLIN'),
                        _AllergyCapsule(label: 'PEANUTS'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: QrImageView(
                  data: member?.id.isNotEmpty == true ? 'HC-${member!.id}' : 'HC-DEP-2026-0001',
                  version: QrVersions.auto,
                  size: 54,
                  padding: EdgeInsets.zero,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF2E006A),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF2E006A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceProviderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Teal vertical accent line on left
              Container(
                width: 4,
                color: const Color(0xFF00796B),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F7FA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: Color(0xFF00796B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Insurance Provider',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'BlueCross Platinum Plus',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00796B),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Exp: 12/2025',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Button: Share with Provider
        PrimaryButton(
          label: _isEn ? 'Share with Provider' : 'Compartir con Proveedor',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing pass with healthcare provider...')),
            );
          },
          leadingIcon: Icons.share_outlined,
        ),
        const SizedBox(height: 12),

        // Teal Outlined Button: Download Health PDF
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading encrypted health summary PDF...')),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: Text(
              _isEn ? 'Download Health PDF' : 'Descargar PDF de Salud',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00796B),
              side: const BorderSide(color: Color(0xFF00796B), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoStats() {
    return const Row(
      children: [
        Expanded(
          child: _BentoStatCard(
            icon: Icons.vaccines_rounded,
            title: 'Immunizations',
            subtitle: '12 Up-to-date',
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _BentoStatCard(
            icon: Icons.medication_rounded,
            title: 'Prescriptions',
            subtitle: '2 Active Refills',
          ),
        ),
      ],
    );
  }
}

class _AllergyCapsule extends StatelessWidget {
  final String label;

  const _AllergyCapsule({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4C1D95).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _BentoStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BentoStatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF5B14B8)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
