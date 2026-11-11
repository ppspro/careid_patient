import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/primary_button.dart';


/// Page 25: Care ID - Health Records Landing (Refined)
/// Figma node: 20:25209
/// Canvas: Careid patient app (x: 11524, y: 0, width: 390, height: 862)
///
/// Features:
/// - Fixed Frosted Top App Bar ("Record Details" title, mini logo, avatar)
/// - Narrative header ("YOUR PROTECTED VITALITY", "My Health Records")
/// - Care ID Encrypted Vault Status Card (142 Total Records, 12m ago sync, Live pill)
/// - Search & Filter bar
/// - Category 01: Medical Records Card (navigates to MedicalRecordsPage)
/// - Category 02: Dental Records Card (navigates to DentalRecordsPage)
/// - Category 03: Vision Records Card (navigates to VisionRecordsPage)
/// - Prominent Gradient CTA: "+ Upload Record"
/// - Security & HIPAA compliance badge
/// - Persistent CareID Bottom Navigation Bar
class HealthRecordsLandingScreen extends StatefulWidget {
  const HealthRecordsLandingScreen({super.key});

  @override
  State<HealthRecordsLandingScreen> createState() => _HealthRecordsLandingScreenState();
}

class _HealthRecordsLandingScreenState extends State<HealthRecordsLandingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUploadRecordModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBC4D4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Upload Health Record',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF28006D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add clinical documents, lab reports, imaging scans, or prescriptions to your encrypted Care ID vault.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF494552),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildUploadOption(
                icon: Icons.camera_alt_rounded,
                title: 'Scan Document with Camera',
                subtitle: 'Auto-edge detection and OCR enhancement',
                onTap: () {
                  Navigator.of(modalContext).pop();
                  Navigator.of(context).pushNamed('/scan-reports');
                },
              ),
              const SizedBox(height: 12),
              _buildUploadOption(
                icon: Icons.file_upload_rounded,
                title: 'Upload PDF / Medical Image',
                subtitle: 'Supports PDF, DICOM, JPEG, PNG up to 50MB',
                onTap: () {
                  Navigator.of(modalContext).pop();
                  Navigator.of(context).pushNamed('/upload-medical-record');
                },
              ),
              const SizedBox(height: 12),
              _buildUploadOption(
                icon: Icons.cloud_sync_rounded,
                title: 'Sync from Hospital Portal',
                subtitle: 'Connect via SMART on FHIR',
                onTap: () {
                  Navigator.of(modalContext).pop();
                  _showMockUploadSuccess('FHIR portal sync initiated');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE7ECF6)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF28006D),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0B1C30),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF494552),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7A7583)),
          ],
        ),
      ),
    );
  }

  void _showMockUploadSuccess(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF006971),
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
                top: 72,
                bottom: 24,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header & Narrative (Figma node 20:25212)
                  _buildHeaderNarrative(),

                  const SizedBox(height: 20),

                  // Care ID Encrypted Vault Status Card (Figma node 20:25219)
                  _buildVaultStatusCard(),

                  const SizedBox(height: 20),

                  // Search & Filter Bar (Figma node 20:25244)
                  _buildSearchAndFilterBar(),

                  const SizedBox(height: 20),

                  // Record Categories: Primary Care ID Cards (Figma node 20:25254)
                  _buildCategoryCard(
                    categoryNum: 'CATEGORY 01',
                    categoryTitle: 'MEDICAL\nRECORDS',
                    recordCount: '86',
                    description:
                        'Physician consultations, lab reports, clinical notes, and prescriptions.',
                    colorTheme: const Color(0xFF28006D),
                    bgIconColor: const Color(0xFFE8DDFF),
                    icon: Icons.assignment_outlined,
                    onTap: () {
                      Navigator.of(context).pushNamed('/medical-records');
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildCategoryCard(
                    categoryNum: 'CATEGORY 02',
                    categoryTitle: 'DENTAL\nRECORDS',
                    recordCount: '24',
                    description:
                        'Panoramic X-rays, routine exams, cleanings, and dental treatments.',
                    colorTheme: const Color(0xFF00696B),
                    bgIconColor: const Color(0xFF5AF8FB),
                    icon: Icons.medical_services_outlined,
                    onTap: () {
                      Navigator.of(context).pushNamed('/dental-records');
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildCategoryCard(
                    categoryNum: 'CATEGORY 03',
                    categoryTitle: 'VISION\nRECORDS',
                    recordCount: '18',
                    description:
                        'Ophthalmology exams, retinal scans, refractive assessments, and optometry files.',
                    colorTheme: const Color(0xFF28006D),
                    bgIconColor: const Color(0xFFDCE9FF),
                    icon: Icons.remove_red_eye_outlined,
                    onTap: () {
                      Navigator.of(context).pushNamed('/vision-records');
                    },
                  ),

                  const SizedBox(height: 20),

                  PrimaryButton.gradient(
                    key: const Key('health_records_upload_button'),
                    label: 'Upload Record',
                    leadingIcon: Icons.add_rounded,
                    onPressed: _showUploadRecordModal,
                  ),

                  const SizedBox(height: 16),

                  // Security & HIPAA Badge (Figma node 20:25363)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        size: 13,
                        color: Color(0xFF494552),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '256-Bit Encrypted Healthcare Vault • HIPAA Compliant',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF494552),
                          letterSpacing: -0.25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Fixed Frosted Top App Bar (Figma node 20:25368)
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

  /// Top App Bar (Figma node 20:25368)
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
              Row(
                children: [
                  GestureDetector(
                    key: const Key('health_records_back_button'),
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/record-details-hub');
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
                  Text(
                    'Record Details',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF28006D),
                      letterSpacing: -0.2,
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

  /// Narrative Header (Figma node 20:25212)
  Widget _buildHeaderNarrative() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR PROTECTED VITALITY',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF00696B),
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'My Health Records',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF28006D),
            letterSpacing: -0.7,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Securely manage your medical, dental, and vision health records.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF494552),
            height: 1.45,
          ),
        ),
      ],
    );
  }

  /// Care ID Encrypted Vault Status Card (Figma node 20:25219)
  Widget _buildVaultStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient diffuse glow in top right corner
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5AF8FB).withValues(alpha: 0.35),
                    const Color(0xFF5AF8FB).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Shield Icon + Status Title + Live pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3F1D8B),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Care ID Encrypted Vault Status',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B1C30),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF56F5F8),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00696B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Live',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF006E70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Two Stats Cards: Total Records & Last Sync
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Records',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF494552),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '142',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF28006D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Sync',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF494552),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '12m ago',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00696B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Search & Filter Bar (Figma node 20:25244)
  Widget _buildSearchAndFilterBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF494552),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: const Color(0xFF0B1C30),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search all health records...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF494552),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.clear, size: 18, color: Color(0xFF7A7583)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Record filters: Showing all 3 categories',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE9FF),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.tune_rounded,
                color: Color(0xFF28006D),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Category Card (Figma nodes 20:25255, 20:25279, 20:25303)
  Widget _buildCategoryCard({
    required String categoryNum,
    required String categoryTitle,
    required String recordCount,
    required String description,
    required Color colorTheme,
    required Color bgIconColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE7ECF6),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Icon + Category number/title + Record count pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: bgIconColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(icon, color: colorTheme, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryNum,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.55,
                            color: colorTheme,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          categoryTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0B1C30),
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgIconColor,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Column(
                    children: [
                      Text(
                        recordCount,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorTheme,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Records',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colorTheme,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF494552),
                height: 1.45,
              ),
            ),

            const SizedBox(height: 12),

            // Footer: "Open Vault File" link + Arrow Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Open Vault File',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorTheme,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: colorTheme,
                    ),
                  ],
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF28006D),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

