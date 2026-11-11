import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../data/repositories/financing_repository.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/insurance_assets.dart';

/// Screen 72: Financing Option Details (Figma Node 20:26692)
class FinancingOptionDetailsScreen extends StatefulWidget {
  final String? offerId;
  const FinancingOptionDetailsScreen({super.key, this.offerId});

  @override
  State<FinancingOptionDetailsScreen> createState() => _FinancingOptionDetailsScreenState();
}

class _FinancingOptionDetailsScreenState extends State<FinancingOptionDetailsScreen> {
  final FinancingRepository _financingRepository = FinancingRepository();
  bool _isProcessing = false;

  String? _resolveOfferId() {
    if (widget.offerId != null && widget.offerId!.isNotEmpty) {
      return widget.offerId;
    }
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      return args;
    }
    if (args is Map<String, dynamic> && args['offerId'] != null) {
      return args['offerId'].toString();
    }
    return null;
  }

  Future<void> _handleAccept() async {
    final offerId = _resolveOfferId();
    if (offerId == null || offerId.isEmpty) {
      Navigator.pushNamed(context, '/insurance-offer-accepted');
      return;
    }

    setState(() => _isProcessing = true);
    final res = await _financingRepository.acceptFinancingOffer(
      offerId,
      signatureConsent: true,
      notes: 'Financing option accepted via patient app',
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (res.isSuccess) {
      Navigator.pushNamed(context, '/insurance-offer-accepted');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.messageOrNull ?? 'Failed to accept financing option'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _handleReject() async {
    final offerId = _resolveOfferId();
    if (offerId == null || offerId.isEmpty) {
      Navigator.pushNamed(context, '/insurance-offer-rejected');
      return;
    }

    setState(() => _isProcessing = true);
    final res = await _financingRepository.rejectFinancingOffer(
      offerId,
      reason: 'Patient opted out of this financing structure',
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (res.isSuccess) {
      Navigator.pushNamed(context, '/insurance-offer-rejected');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.messageOrNull ?? 'Failed to decline financing option'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubHeaderBar(context),
                    const SizedBox(height: 16),
                    _buildHeroSummaryCard(context),
                    const SizedBox(height: 16),
                    _buildAssociatedTreatmentTile(context),
                    const SizedBox(height: 16),
                    _buildRepaymentScheduleCard(context),
                    const SizedBox(height: 16),
                    _buildKeyTermsCard(context),
                    const SizedBox(height: 16),
                    _buildTrustSealMicroCopy(context),
                    const SizedBox(height: 20),
                    _buildActionsArea(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(currentIndex: 1, onTabSelected: (int idx) { if (idx == 0) Navigator.of(context).pushReplacementNamed('/home'); }),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF).withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF28006D).withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back Nav Button + Title + Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacementNamed('/insurance-treatment-offers');
                  }
                },
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF28006D)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Financing Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF28006D),
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/card_id_badge.png',
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ],
          ),

          // Right: Profile Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF3F1D8B), width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            InsuranceAssets.avatarUserHub,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Color(0xFF3F1D8B),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSubHeaderBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financing Details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0B1C30),
              ),
            ),
            Text(
              'Verified Care ID Plan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF00696B),
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF4FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              InsuranceAssets.infoCircle,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Color(0xFF28006D),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF28006D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28006D).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3F1D8B).withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Opacity(
              opacity: 0.15,
              child: SvgPicture.asset(
                InsuranceAssets.shieldWatermarkLarge,
                width: 90,
                height: 120,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00696B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'PRE-APPROVED OFFER',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF006E70),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$200.00 ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '/ month',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFFCFBDFF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F1D8B),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          InsuranceAssets.creditCard,
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F1D8B).withOpacity(0.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Plan Type',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFCFBDFF),
                            ),
                          ),
                          Text(
                            'CareCredit 0% APR (12 Mo)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Financed',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFCFBDFF),
                            ),
                          ),
                          Text(
                            '\$2,400.00',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF56F5F8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'First Payment Due',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFCFBDFF),
                            ),
                          ),
                          Text(
                            'Nov 15, 2023',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SvgPicture.asset(
                      InsuranceAssets.checkSuccess,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF56F5F8),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Instant direct settlement with clinic via Care ID',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFFE8DDFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssociatedTreatmentTile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                InsuranceAssets.toothClinical,
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF28006D),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CLINICAL CARE ITEM',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00696B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Verified',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF494552),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Dental Implant & Crown',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SvgPicture.asset(
                      InsuranceAssets.calendarContext,
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF494552),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'City Dental Care • Dr. A. Morgan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF494552),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentScheduleCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    InsuranceAssets.clockContext,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF28006D),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Repayment Schedule',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B1C30),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '12 Months Term',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00696B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Installments Planned',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B1C30),
                      ),
                    ),
                    Text(
                      '12 × \$200.00',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF28006D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 12-segment progress bar with gradient opacities
                Row(
                  children: List.generate(12, (index) {
                    final opacities = [
                      1.0, 0.85, 0.75, 0.65, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2
                    ];
                    return Expanded(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.only(right: index == 11 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF28006D).withOpacity(opacities[index]),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Starts Nov 15, 2023',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF494552),
                      ),
                    ),
                    Text(
                      'Concludes Oct 15, 2024',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF494552),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE9FF).withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      InsuranceAssets.bankTransfer,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF28006D),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinical Auto-Debit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B1C30),
                        ),
                      ),
                      Text(
                        'Linked Chase Checking (•••• 4092)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF494552),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF00696B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00696B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTermsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: Color(0xFF28006D),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Terms & Transparency',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B1C30),
                    ),
                  ),
                ],
              ),
              Text(
                'NO HIDDEN FEES',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF494552),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTermRow(
            icon: Icons.percent_rounded,
            title: '0% Promotional APR',
            description:
                'No interest charged provided the full \$2,400.00 principal balance is paid within 12 months.',
          ),
          const SizedBox(height: 14),
          _buildTermRow(
            icon: Icons.verified_user_outlined,
            title: 'No Prepayment Penalties',
            description:
                'Pay ahead or close the remaining balance anytime without service charges or pre-closure fees.',
          ),
          const SizedBox(height: 14),
          _buildTermRow(
            icon: Icons.local_hospital_outlined,
            title: 'Direct Provider Settlement',
            description:
                'Funds are remitted directly to City Dental Care to cover your treatment without reimbursement paperwork.',
          ),
          const SizedBox(height: 14),
          _buildTermRow(
            icon: Icons.lock_outline_rounded,
            title: 'Care ID Instant Verification',
            description:
                'Protected cryptographic signature seamlessly verifies your identity and accepts clinical terms.',
          ),
        ],
      ),
    );
  }

  Widget _buildTermRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFFE5EEFF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 14,
              color: const Color(0xFF28006D),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.4,
                  color: const Color(0xFF494552),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustSealMicroCopy(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            InsuranceAssets.lockKeyhole,
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              Color(0xFF494552),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'By continuing, you authorize Care ID to configure the installment agreement under federal disclosure guidelines.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.4,
                color: const Color(0xFF494552),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsArea(BuildContext context) {
    return Column(
      children: [
        PrimaryButton.gradient(
          label: 'Accept Financing Plan',
          leadingIcon: Icons.check_rounded,
          isLoading: _isProcessing,
          onPressed: _handleAccept,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isProcessing ? null : _handleReject,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF00696B),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Decline Option',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00696B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

