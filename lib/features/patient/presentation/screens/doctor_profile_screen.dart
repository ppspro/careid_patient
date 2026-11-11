import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/careid_dental_logo.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/doctor_models.dart';
import 'book_appointment_screen.dart';
import 'live_chat_screen.dart';
import '../../../../shared/widgets/primary_button.dart';

/// CareID Patient App — Doctor Profile Screen
/// Faithfully reproduces Figma Frame `20:28961` ("Doctor Profile") on Canvas 17:55
/// Implements full clinical overview, patient connection context, facility showcase,
/// focus tag cloud, rating submission, and non-clipping persistent bottom actions.
class DoctorProfileScreen extends StatefulWidget {
  final DoctorModel doctor;
  final double initialScrollOffset;

  const DoctorProfileScreen({
    super.key,
    required this.doctor,
    this.initialScrollOffset = 0.0,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _userRating = 5;
  bool _ratingSubmitted = false;
  bool _isBookmarked = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching Figma 20:28995
            _buildTopAppBar(),

            // Scrollable Content with 140dp bottom padding for floating bottom panel
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb Sub-bar (Figma 20:29016)
                    _buildBreadcrumbSubBar(),
                    const SizedBox(height: 12),

                    // Doctor Header Card with Care ID Watermark Glass Frame (Figma 20:29025)
                    _buildHeroCard(doctor),
                    const SizedBox(height: 16),

                    // Associated Patient Connection Context (Figma 20:29068)
                    _buildConnectionContext(doctor),
                    const SizedBox(height: 16),

                    // Clinical Overview & Practice Highlights (Figma 20:29094)
                    _buildClinicalOverview(doctor),
                    const SizedBox(height: 16),

                    // Practice Facility Gallery Showcase (Figma 20:29154)
                    _buildFacilityGallery(),
                    const SizedBox(height: 16),

                    // Verified Care ID Security Assurance Note (Figma 20:29169)
                    _buildSecurityAssuranceNote(),
                    const SizedBox(height: 16),

                    // Rate this Doctor Section (Figma 20:29174)
                    _buildRatingSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Persistent Bottom Action Floating Panel matching Figma 20:29192
      bottomNavigationBar: _buildPersistentBottomActionPanel(doctor),
    );
  }

  /// Top App Bar (Figma 20:28995)
  Widget _buildTopAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(child: CareIdLogo.horizontal(height: 18)),
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF0F172A)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Doctor profile link copied to clipboard.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Breadcrumb Sub-bar (Figma 20:29016)
  Widget _buildBreadcrumbSubBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_rounded, size: 14, color: Color(0xFF5B14B8)),
              SizedBox(width: 4),
              Text(
                'Doctors Directory',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF5B14B8),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() => _isBookmarked = !_isBookmarked);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isBookmarked ? 'Doctor saved to bookmarks.' : 'Doctor removed from bookmarks.'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 16,
              color: _isBookmarked ? const Color(0xFF5B14B8) : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  /// Doctor Header Card with Care ID Watermark Glass Frame (Figma 20:29025)
  Widget _buildHeroCard(DoctorModel doctor) {
    final bool isDental = doctor.primarySpecialization.toLowerCase().contains('dent') ||
        doctor.fullName.contains('DDS') ||
        doctor.primarySpecialization.toLowerCase().contains('oral');

    final String secondaryText = doctor.secondarySpecializations.isNotEmpty
        ? doctor.secondarySpecializations.join(' • ')
        : 'Comprehensive Health & Assessment';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x083F1D8B),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar + Verified + Online status
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: const Color(0xFF5B14B8).withValues(alpha: 0.15), width: 2.5),
                ),
                child: ClipOval(
                  child: doctor.photoAsset != null
                      ? Image.asset(
                          doctor.photoAsset!,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarInitials(doctor),
                        )
                      : _buildAvatarInitials(doctor),
                ),
              ),
              if (doctor.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      size: 20,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Specialty Pill Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDental ? const Color(0xFFFEF3C7) : const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDental) ...[
                  const CareIdDentalLogo(size: 13, color: AppColors.dentalIcon),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    doctor.primarySpecialization,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Plus Jakarta Sans',
                      color: isDental ? AppColors.dentalIcon : const Color(0xFF5B14B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Full Name
          Text(
            doctor.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Secondary qualifications & specializations
          Text(
            secondaryText,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),

          // Practice Location & Rating Band (Figma 20:29050)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_hospital_outlined, size: 15, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  doctor.facilityName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 12, color: const Color(0xFFCBD5E1)),
              const SizedBox(width: 10),
              const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
              const SizedBox(width: 3),
              Text(
                doctor.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 3),
              Text(
                '(${doctor.reviewCount})',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Vault Connected Status Pill (Figma 20:29061)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 14, color: Color(0xFF16A34A)),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Care ID Vault Connected • End-to-End Encrypted Access',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF166534),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitials(DoctorModel doctor) {
    return Center(
      child: Text(
        doctor.fullName
            .replaceFirst('Dr. ', '')
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((e) => e[0])
            .join(),
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF5B14B8),
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  /// Associated Patient Connection Context (Figma 20:29068)
  Widget _buildConnectionContext(DoctorModel doctor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_edu_rounded, size: 18, color: Color(0xFF5B14B8)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Your Care Connection',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync_rounded, size: 12, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'Sync Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Card 1: Last Consultation
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Completed',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Plus Jakarta Sans',
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Last Consultation',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Aug 15, 2023',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Annual Assessment',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Card 2: Synced Vault Records
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.folder_shared_rounded, size: 14, color: Color(0xFF5B14B8)),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Encrypted',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Plus Jakarta Sans',
                                color: Color(0xFF5B14B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Synced Records',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '5 Care Documents',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '3 Notes • 2 Lab Reports',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF94A3B8),
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
    );
  }

  /// Clinical Overview & Practice Highlights (Figma 20:29094)
  Widget _buildClinicalOverview(DoctorModel doctor) {
    final List<String> focusTags = [
      'Preventive Medicine',
      'Cardiovascular Screening',
      'Hypertension Management',
      'Comprehensive Wellness',
      'Lipid Disorders',
      'Digital Record Sync',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinical Specializations & Practice',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Tag Cloud (Figma 20:29097)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: focusTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF334155),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Hospital Affiliation Bento Row (Figma 20:29113)
          _buildDetailRow(
            icon: Icons.business_rounded,
            title: 'Hospital Affiliation & Department',
            subtitle: '${doctor.facilityName} • Internal Medicine & Cardiovascular Unit',
            extraInfo: 'Attending Physician • ${doctor.yearsOfExperience} Years Active Clinical Practice',
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Licensure & Medical Board
          _buildDetailRow(
            icon: Icons.verified_user_outlined,
            title: 'Licensure & Credentials',
            subtitle: 'License #${doctor.licenseNumber ?? "NY-55193"} • Active Full License',
            extraInfo: doctor.medicalCouncil ?? 'State Board of Medical Examiners',
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Languages Supported Bento Row (Figma 20:29126)
          _buildDetailRow(
            icon: Icons.translate_rounded,
            title: 'Languages Supported',
            subtitle: '${doctor.languages.join(", ")} (Bilingual Consultations Supported)',
            extraInfo: 'Medical translation and interpretation services available on request',
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Coverage & Care ID Compatibility (Figma 20:29139)
          _buildDetailRow(
            icon: Icons.health_and_safety_outlined,
            title: 'Coverage & Care ID Compatibility',
            subtitle: 'Care ID Tier-1 Verified Partner • In-Network with Major Insurers',
            extraInfo: 'Direct Vault Record Exchange Active • Zero-Knowledge HIPAA Consent',
          ),

          if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),
            const Text(
              'About Clinician',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Plus Jakarta Sans',
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor.bio!,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                fontFamily: 'Plus Jakarta Sans',
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String extraInfo,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF5B14B8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                extraInfo,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Practice Facility Gallery Showcase (Figma 20:29154)
  Widget _buildFacilityGallery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, size: 18, color: Color(0xFF5B14B8)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Practice & Facility Showcase',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Text(
                '2 Suites',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Facility Card 1
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEDE9FE), Color(0xFFE0E7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.monitor_heart_rounded, size: 24, color: Color(0xFF5B14B8)),
                      SizedBox(height: 16),
                      Text(
                        'Diagnostic Wing',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ECG & Ultrasound',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF4338CA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Facility Card 2
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF7DD3FC)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.meeting_room_rounded, size: 24, color: Color(0xFF0369A1)),
                      SizedBox(height: 16),
                      Text(
                        'Consultation Suite 4B',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF082F49),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Private Assessment',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF0284C7),
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
    );
  }

  /// Verified Care ID Security Assurance Note (Figma 20:29169)
  Widget _buildSecurityAssuranceNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_rounded, color: Color(0xFF5B14B8), size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strong → Care ID Trust Standard',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF5B14B8),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Meets Care ID Trust Standards with sovereign 256-bit encrypted medical record access. Only you can authorize record sharing.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.45,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF4C1D95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Rate this Doctor Section (Figma 20:29174)
  Widget _buildRatingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this doctor',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'How was your visit? Choose a rating to share your experience with other patients.',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          if (_ratingSubmitted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Thank you! Your verified feedback has been recorded into the Care ID Trust network.',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final starNum = index + 1;
                    return InkWell(
                      onTap: () {
                        setState(() => _userRating = starNum);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                        child: Icon(
                          starNum <= _userRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 26,
                        ),
                      ),
                    );
                  }),
                ),
                PrimaryButton(
                  label: 'Submit',
                  onPressed: () {
                    setState(() => _ratingSubmitted = true);
                  },
                  isFullWidth: false,
                  width: 90,
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '1 = Poor · 5 = Excellent',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Plus Jakarta Sans',
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Persistent Bottom Action Floating Panel (Figma 20:29192)
  Widget _buildPersistentBottomActionPanel(DoctorModel doctor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary Pill Action: Book Consultation
            PrimaryButton(
              label: 'Book Consultation',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BookAppointmentScreen(doctor: doctor),
                  ),
                );
              },
              leadingIcon: Icons.calendar_month_rounded,
            ),
            const SizedBox(height: 8),

            // Secondary Actions Row: Live Chat & Call Facility
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LiveChatScreen(
                              conversationTitle: doctor.fullName,
                              participantSubtitle: '${doctor.primarySpecialization} • ${doctor.facilityName}',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Color(0xFF5B14B8)),
                      label: const Text(
                        'Message Team',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF5B14B8),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDDD6FE)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Direct dial line: ${doctor.facilityName} (212) 555-0199'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone_outlined, size: 15, color: Color(0xFF475569)),
                      label: const Text(
                        'Call Practice',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF475569),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
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
