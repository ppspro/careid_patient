import '../../data/repositories/insurance_repository.dart';
import '../../data/repositories/mock_insurance_repository.dart';
import '../../data/models/insurance_policy_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/insurance_assets.dart';

/// Screen 6: Manual Review & Edit (`20:20723`)
class InsuranceManualReviewScreen extends StatefulWidget {
  const InsuranceManualReviewScreen({super.key});

  @override
  State<InsuranceManualReviewScreen> createState() => _InsuranceManualReviewScreenState();
}

class _InsuranceManualReviewScreenState extends State<InsuranceManualReviewScreen> {
  late TextEditingController _providerCtrl;
  late TextEditingController _memberIdCtrl;
  late TextEditingController _groupNumberCtrl;
  late TextEditingController _effectiveDateCtrl;
  late TextEditingController _expiryDateCtrl;
  late TextEditingController _planTypeCtrl;
  
  @override
  void initState() {
    super.initState();
    final policy = MockInsuranceRepository.instance.primaryPolicy;
    _providerCtrl = TextEditingController(text: 'Aura Health Global');
    _memberIdCtrl = TextEditingController(text: '882-991-0045');
    _groupNumberCtrl = TextEditingController(text: 'TX-90210-V');
    _effectiveDateCtrl = TextEditingController(text: '01 / 01 / 2023');
    _expiryDateCtrl = TextEditingController(text: '12 / 31 / 2025');
    _planTypeCtrl = TextEditingController(text: policy.planType);
  }

  @override
  void dispose() {
    _providerCtrl.dispose();
    _memberIdCtrl.dispose();
    _groupNumberCtrl.dispose();
    _effectiveDateCtrl.dispose();
    _expiryDateCtrl.dispose();
    _planTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSaveChanges() async {
    final provider = _providerCtrl.text.trim();
    final policyNum = _memberIdCtrl.text.trim();
    final groupNum = _groupNumberCtrl.text.trim();
    final plan = _planTypeCtrl.text.trim().isNotEmpty
        ? _planTypeCtrl.text.trim()
        : 'Individual PPO Premium';

    try {
      await InsuranceRepository().createPolicy(
        InsurancePolicyDto(
          id: '',
          providerName: provider,
          policyNumber: policyNum,
          groupNumber: groupNum,
          planName: plan,
          status: 'ACTIVE',
        ),
      );
    } catch (_) {}

    final repo = MockInsuranceRepository.instance;
    repo.updatePrimaryPolicy(
      repo.primaryPolicy.copyWith(
        providerName: provider,
        policyNumber: policyNum,
        groupNumber: groupNum,
        effectiveDate: _effectiveDateCtrl.text.trim(),
        expiryDate: _expiryDateCtrl.text.trim(),
        planType: plan,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Policy Details Updated Successfully!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF006D76),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOcrStatusBanner(),
                    const SizedBox(height: 20),
                    _buildCardPreview(),
                    const SizedBox(height: 24),
                    _buildPrimaryInfoSection(),
                    const SizedBox(height: 20),
                    _buildCoverageDatesSection(),
                    const SizedBox(height: 20),
                    _buildPlanTypeErrorShowcase(),
                    const SizedBox(height: 20),
                    _buildAdditionalDetailsSection(),
                    const SizedBox(height: 28),
                    _buildSaveButton(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFF8F9FF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      InsuranceAssets.backArrow,
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Edit Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
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
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.more_vert,
              color: Color(0xFF494552),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOcrStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF75F2FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            InsuranceAssets.ocrBannerIcon,
            width: 22,
            height: 22,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.auto_awesome,
              color: Color(0xFF006D76),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data extracted via Scan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF006D76),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "We've highlighted fields detected by our AI. Please verify for accuracy.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF006D76).withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBC4D4).withOpacity(0.5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    InsuranceAssets.cardBackground,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF28006D),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.local_hospital,
                            color: Color(0xFF28006D),
                            size: 28,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Provider',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF28006D).withOpacity(0.6),
                                ),
                              ),
                              Text(
                                'Aura Health Global',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF28006D),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Member ID',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF28006D).withOpacity(0.6),
                                ),
                              ),
                              Text(
                                '882-991-0045',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: const Color(0xFF28006D),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: -16,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/insuranceCameraCapture');
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF28006D),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3328006D),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Information',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF28006D),
          ),
        ),
        const SizedBox(height: 14),

        // Provider Name (OCR Highlighted in Teal)
        _buildInputField(
          controller: _providerCtrl,
          label: 'Provider Name',
          isHighlighted: true,
          suffixIcon: SvgPicture.asset(
            InsuranceAssets.sparkIcon,
            width: 14,
            height: 14,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.auto_awesome,
              color: Color(0xFF006971),
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Member ID / Policy Number
        _buildInputField(
          controller: _memberIdCtrl,
          label: 'Member ID / Policy Number',
          isHighlighted: false,
          suffixIcon: const Icon(Icons.edit, color: Color(0xFF7A7583), size: 16),
        ),
        const SizedBox(height: 16),

        // Group Number (OCR Highlighted in Teal)
        _buildInputField(
          controller: _groupNumberCtrl,
          label: 'Group Number',
          isHighlighted: true,
          suffixIcon: const Icon(Icons.verified, color: Color(0xFF006971), size: 16),
        ),
      ],
    );
  }

  Widget _buildCoverageDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coverage Dates',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF28006D),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _effectiveDateCtrl,
                label: 'Effective Date',
                isHighlighted: false,
                suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF7A7583), size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildInputField(
                controller: _expiryDateCtrl,
                label: 'Expiry Date',
                isHighlighted: false,
                suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF7A7583), size: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanTypeErrorShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFBA1A1A),
                  width: 2,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _planTypeCtrl,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'e.g. PPO, HMO',
                        hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B1C30),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    InsuranceAssets.errorExclamation,
                    width: 18,
                    height: 18,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.error_outline,
                      color: Color(0xFFBA1A1A),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              top: -9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: const Color(0xFFF8F9FF),
                child: Text(
                  'Plan Type',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFBA1A1A),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Please specify your plan type.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFBA1A1A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required bool isHighlighted,
    required Widget suffixIcon,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted ? const Color(0xFF006971) : const Color(0xFFCBC4D4),
              width: 2,
            ),
            boxShadow: isHighlighted
                ? const [
                    BoxShadow(
                      color: Color(0x33006971),
                      blurRadius: 4,
                      offset: Offset(0, 0),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
              ),
              suffixIcon,
            ],
          ),
        ),
        Positioned(
          left: 12,
          top: -9,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: const Color(0xFFF8F9FF),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isHighlighted ? const Color(0xFF006971) : const Color(0xFF7A7583),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBC4D4).withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Emergency Phone',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF494552),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '+ Add',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF28006D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBC4D4).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 18, color: Color(0xFF28006D)),
                    const SizedBox(width: 10),
                    Text(
                      '1-800-HEALTH-360',
                      style: GoogleFonts.robotoMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B1C30),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF494552)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return PrimaryButton(
      label: 'Save Changes',
      leadingIcon: Icons.save_outlined,
      onPressed: _onSaveChanges,
    );
  }
}

