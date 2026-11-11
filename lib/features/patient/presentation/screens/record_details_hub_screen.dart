import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/primary_button.dart';


/// Page 24: Record Details (Family Records Hub)
/// Figma node: 20:30521 (Framed as "Care ID - Family Records", screen title "Record Details")
/// Canvas: Careid patient app (x: 11094, y: 0, width: 390, height: 862)
///
/// Serves as the primary records landing page when tapping "Records" in the bottom navigation.
/// Offers access to:
/// 1. My Health Records (navigates to HealthRecordsLandingPage)
/// 2. Family Health Records
/// 3. Pet Records
class RecordDetailsHubScreen extends StatefulWidget {
  const RecordDetailsHubScreen({super.key});

  @override
  State<RecordDetailsHubScreen> createState() => _RecordDetailsHubScreenState();
}

class _RecordDetailsHubScreenState extends State<RecordDetailsHubScreen> {
  void _navigateToMyHealthRecords() {
    Navigator.of(context).pushNamed('/health-records-landing');
  }

  void _showComingSoonSnackBar(String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title will be available in the upcoming release.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF28006D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 72, // Space for frosted Top App Bar
                bottom: 120,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card 1: My Health Records (Figma node 20:30533)
                  _buildRecordHubCard(
                    title: 'My Health Records',
                    description:
                        'Securely access and review synchronized medical, dental, and vision records for authorized Care ID account.',
                    bgImage: 'assets/images/family_records_my_health.png',
                    onContinue: _navigateToMyHealthRecords,
                  ),

                  const SizedBox(height: 16),

                  // Card 2: Family Health Records (Figma node 20:30556)
                  _buildRecordHubCard(
                    title: 'Family Health Records',
                    description:
                        'Securely access and review synchronized medical, dental, and vision records for authorized family members and dependents under your Care ID account.',
                    bgImage: 'assets/images/family_records_family.png',
                    onContinue: () {
                      Navigator.of(context).pushNamed('/family');
                    },
                  ),

                  const SizedBox(height: 16),

                  // Card 3: Pet Records (Figma node 20:30578)
                  _buildRecordHubCard(
                    title: 'Pet Records',
                    description:
                        'Securely access and review synchronized vaccination history, exam notes, and prescriptions for your pet.',
                    bgImage: 'assets/images/family_records_pets.png',
                    isPet: true,
                    onContinue: () => _showComingSoonSnackBar('Pet Records'),
                  ),
                ],
              ),
            ),
          ),

          // Fixed Frosted Top App Bar (Figma node 20:30635)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopAppBar(),
          ),
        ],
      ),

      // Docked unified Bottom Navigation Bar (Tab 1: Records active)
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: 1,
        onTabSelected: (idx) {
          if (idx == 0) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (idx == 1) {
            Navigator.of(context).pushReplacementNamed('/records');
          } else if (idx == 2) {
            Navigator.of(context).pushReplacementNamed('/doctors');
          } else if (idx == 3) {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        },
      ),
    );
  }

  /// Top App Bar (Figma node 20:30635)
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
                color: const Color(0xFFCBC4D4).withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Back button + Title
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      key: const Key('record_details_hub_back_button'),
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/qr_preview_back.svg',
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Record Details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF28006D),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/card_id_badge.png',
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right: Notification Bell + Profile Avatar
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF28006D)), onPressed: () => Navigator.of(context).pushNamed('/notification-center')),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF3F1D8B),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1428006D),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/patient_avatar.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hub Card (Figma nodes 20:30533, 20:30556, 20:30578)
  Widget _buildRecordHubCard({
    required String title,
    required String description,
    required String bgImage,
    required VoidCallback onContinue,
    bool isPet = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF7FAFF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE7ECF6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1228006D),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Exact Figma-aligned Background Graphics per Card
            if (title == 'My Health Records') ...[
              // Subtle Watermark Graphic at bottom right (Figma node 20:30534)
              Positioned(
                right: -33,
                bottom: -33,
                width: 144,
                height: 144,
                child: Opacity(
                  opacity: 0.12,
                  child: SvgPicture.asset(
                    'assets/icons/record_vault_shield.svg',
                    colorFilter: const ColorFilter.mode(Color(0xFF56F5F8), BlendMode.srcIn),
                  ),
                ),
              ),
              // Image 11 (Figma node 20:30536, left: -9, top: 13, size: 209)
              Positioned(
                left: -9,
                top: 13,
                width: 209,
                height: 209,
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    bgImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
              // Image 12 (Figma node 20:30537, left: 154, top: 11, size: 209)
              Positioned(
                left: 154,
                top: 11,
                width: 209,
                height: 209,
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    'assets/images/family_records_my_health_bg2.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
            ] else if (title == 'Family Health Records') ...[
              // Image 10 (Figma node 20:30557, left: 61, top: 15, size: 225)
              Positioned(
                left: 61,
                top: 15,
                width: 225,
                height: 225,
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    bgImage,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
              // Subtle Watermark Graphic at bottom right (Figma node 20:30558)
              Positioned(
                right: -33,
                bottom: -33,
                width: 144,
                height: 144,
                child: Opacity(
                  opacity: 0.12,
                  child: SvgPicture.asset(
                    'assets/icons/record_vault_shield.svg',
                    colorFilter: const ColorFilter.mode(Color(0xFF56F5F8), BlendMode.srcIn),
                  ),
                ),
              ),
            ] else if (isPet) ...[
              // Image 14 (Figma node 20:30579, left: -56, top: -1, width: 461, height: 263)
              Positioned(
                left: -56,
                top: -1,
                width: 461,
                height: 263,
                child: Opacity(
                  opacity: 0.35,
                  child: Image.asset(
                    bgImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
            ],

            // Card Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Family Vault Active & HIPAA Compliant
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF56F5F8).withValues(alpha: 0.40),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 13,
                              color: Color(0xFF006E70),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Family Vault Active',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF006E70),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: Color(0xFF00696B),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'HIPAA Compliant',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00696B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Title
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0B1C30),
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Description
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF494552),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Action Row: Change Image + Continue Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Change Image button
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Custom background image selector opening...',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFE7ECF6),
                                    width: 1,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1228006D),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 18,
                                    color: Color(0xFF28006D),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Change image',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF596173),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Continue CTA Button (Figma node 20:30552)
                      PrimaryButton.gradient(
                        key: Key('record_hub_continue_${title.toLowerCase().replaceAll(' ', '_')}'),
                        text: 'Continue',
                        width: 112,
                        height: 46,
                        onPressed: onContinue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

