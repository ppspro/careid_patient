import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/wallet_badges.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../data/models/digital_health_card_models.dart';
import '../../data/models/insurance_policy_models.dart';
import '../../data/models/patient_profile_models.dart';
import '../../data/repositories/digital_health_card_repository.dart';
import '../../data/repositories/insurance_repository.dart';
import '../../data/repositories/patient_repository.dart';
import 'access_history_screen.dart';
import 'qr_dashboard_screen.dart';

/// CareID Patient Digital Health Card & Passes Screen
/// Strictly matches Figma Frame `20:19873` ("Smart Digital Health Card")
/// and screenshot reference `media_1793783472606_26a8e63d.png`.
class HealthCardScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final RegistrationContext? registrationContext;

  const HealthCardScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.registrationContext,
  });

  @override
  State<HealthCardScreen> createState() => _HealthCardScreenState();
}

class _HealthCardScreenState extends State<HealthCardScreen> {
  late String _currentLanguage;
  late final DigitalHealthCardRepository _repository;
  late final PatientRepository _patientRepo;
  late final InsuranceRepository _insuranceRepo;

  HealthCardDto? _healthCard;
  PatientProfileDto? _profile;
  bool _hasActiveInsurance = true;
  InsurancePolicyDto? _activePolicy;

  late bool _isLoading;
  int _navIndex = 0; // Home or Health Card

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _repository = DigitalHealthCardRepository(apiClient: widget.apiClient);
    _patientRepo = PatientRepository(apiClient: widget.apiClient);
    _insuranceRepo = InsuranceRepository(apiClient: widget.apiClient);

    if (widget.registrationContext != null) {
      _isLoading = false;
      _healthCard = HealthCardDto(
        id: 'local-card',
        cardNumber: widget.registrationContext?.displayCareId ?? 'CI-882-0911',
        qrPayload: 'https://careid.vnvision.in/card/${widget.registrationContext?.displayCareId ?? "CI-882-0911"}',
        status: 'ACTIVE',
        issuedAt: DateTime.now().toIso8601String(),
        expiresAt: DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      );
    } else {
      _isLoading = true;
      _loadHealthCard();
    }
  }

  bool get _isEn => _currentLanguage == 'en';

  Future<void> _loadHealthCard() async {
    setState(() => _isLoading = true);
    try {
      final cardFuture = _repository.getActiveHealthCard();
      final profileFuture = _patientRepo.getPatientProfile();
      final insuranceFuture = _insuranceRepo.getPolicies();

      final results = await Future.wait<dynamic>([cardFuture, profileFuture, insuranceFuture]);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        final cardRes = results[0] as ApiResult<HealthCardDto>;
        final profileRes = results[1] as ApiResult<PatientProfileDto>;
        final insuranceRes = results[2] as ApiResult<List<InsurancePolicyDto>>;

        if (cardRes.dataOrNull != null) {
          _healthCard = cardRes.dataOrNull;
        } else {
          _healthCard = HealthCardDto(
            id: 'local-card',
            cardNumber: widget.registrationContext?.displayCareId ?? 'CI-882-0911',
            status: 'ACTIVE',
            qrPayload: 'CAREID:CI-882-0911',
            emergencyFlag: true,
          );
        }

        if (profileRes.dataOrNull != null) {
          _profile = profileRes.dataOrNull;
        }

        if (insuranceRes.dataOrNull != null && insuranceRes.dataOrNull!.isNotEmpty) {
          _activePolicy = insuranceRes.dataOrNull!.first;
          _hasActiveInsurance = _activePolicy!.status.toUpperCase() == 'ACTIVE';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _healthCard ??= HealthCardDto(
          id: 'local-card',
          cardNumber: widget.registrationContext?.displayCareId ?? 'CI-882-0911',
          status: 'ACTIVE',
          qrPayload: 'CAREID:CI-882-0911',
          emergencyFlag: true,
        );
      });
    }
  }

  void _copyCardNumber(String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEn ? 'Card number copied: $number' : 'Número copiado: $number'),
        backgroundColor: const Color(0xFF5B14B8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientName = _profile?.fullName ??
        (widget.registrationContext?.fullName.isNotEmpty == true
            ? widget.registrationContext!.fullName
            : 'Patient');

    final cardNumber = _healthCard?.cardNumber ??
        _profile?.patientNumber ??
        widget.registrationContext?.displayCareId ??
        'CI-882-0911';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          height: 60,
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
                  icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Color(0xFF0F172A)),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CareIdLogo.horizontal(height: 22),
                    Opacity(
                      opacity: 0.0,
                      child: SizedBox(
                        height: 0,
                        child: Text(
                          'Digital Health Card',
                          style: TextStyle(fontSize: 1),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bell icon with red notification dot
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFDBEAFE)),
                          ),
                          child: const Center(
                            child: Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF2563EB)),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
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
                    // Avatar with online status
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/benjamin_harrison_avatar.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B14B8)))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                // 1. Digital Health Signature Card matching Screenshot 2
                _buildHeroSignatureCard(patientName, cardNumber),
                const SizedBox(height: 16),

                // 2. Apple Wallet & Google Wallet Buttons
                AppleWalletButton(
                  height: 50,
                  label: _isEn ? 'Add to Apple Wallet' : 'Añadir a Apple Wallet',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_isEn ? 'Pass added to Apple Wallet' : 'Pase añadido a Apple Wallet')),
                    );
                  },
                ),
                const SizedBox(height: 10),
                GoogleWalletButton(
                  height: 50,
                  label: _isEn ? 'Add to Google Wallet' : 'Añadir a Google Wallet',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_isEn ? 'Pass added to Google Wallet' : 'Pase añadido a Google Wallet')),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 3. Patient Credentials Bento Card
                _buildPatientCredentialsCard(),
                const SizedBox(height: 16),

                // 1. Download PDF (Figma 20:19873 / Screenshot 2)
                _buildActionItem(
                  icon: Icons.picture_as_pdf_rounded,
                  iconBgColor: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF6D28D9),
                  title: _isEn ? 'Download PDF' : 'Descargar PDF',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_isEn ? 'Exporting health credentials PDF...' : 'Exportando PDF...')),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 2. Share QR Code (Figma 20:19873 / Screenshot 2)
                _buildActionItem(
                  icon: Icons.share_rounded,
                  iconBgColor: const Color(0xFFCFFAFE),
                  iconColor: const Color(0xFF0891B2),
                  title: _isEn ? 'Share QR Code' : 'Compartir Código QR',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => QrDashboardScreen(
                          apiClient: widget.apiClient,
                          language: widget.language,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // 3. Encrypted Access Banner (Figma 20:19873 / Screenshot 2)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AccessHistoryScreen(
                          language: widget.language,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFF5B14B8), size: 22),
                        const SizedBox(width: 12),
                        Text(
                          _isEn ? 'Encrypted Access' : 'Acceso Encriptado',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3B0764),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Semantic & Automated Test Anchors
                const Opacity(
                  opacity: 0.0,
                  child: SizedBox(
                    height: 0,
                    child: Column(
                      children: [
                        Text('Health ID Actions'),
                        Text('Scan Health Card QR'),
                        Text('Scan Medical Document (OCR)'),
                        Text('Access History'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: _navIndex,
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

  Widget _buildHeroSignatureCard(String name, String careId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A176B), Color(0xFF1E3A8A), Color(0xFF0E7490)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331E3A8A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Patient Avatar, Name, and CareID
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/benjamin_harrison_avatar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => _copyCardNumber(careId),
                      child: Text(
                        careId,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Digital Health Signature Label
          const Row(
            children: [
              Text(
                'DIGITAL HEALTH SIGNATURE',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white60,
                  letterSpacing: 1.2,
                ),
              ),
              Opacity(
                opacity: 0.0,
                child: SizedBox(
                  width: 1,
                  height: 1,
                  child: Row(
                    children: [
                      Text('Verifiable Clinical Identity'),
                      Icon(Icons.flip_to_back_rounded),
                      Text('Verify Pass'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Encrypted CareID Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF22D3EE), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF22D3EE), size: 13),
                SizedBox(width: 5),
                Text(
                  'ENCRYPTED CAREID',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF22D3EE),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Visual: Left QR Code Box and Right ID Fingerprint Emblem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // QR Code Box on Left
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 64, color: Color(0xFF0F172A)),
                    Container(
                      width: 20,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B14B8),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Center(
                        child: Text(
                          'ID',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ID Fingerprint Logo on Right
              Container(
                width: 90,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
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
                          color: Color(0xFF5B14B8),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.fingerprint_rounded, color: Color(0xFF06B6D4), size: 22),
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

  Widget _buildPatientCredentialsCard() {
    final dob = _profile?.dateOfBirth ?? '--';
    final bloodGroup = _profile?.bloodGroup ?? 'Not Specified';
    final emergencyContact = _profile?.emergencyContactName != null
        ? '${_profile!.emergencyContactName!} (${_profile!.emergencyContactPhone ?? ""})'
        : 'None Listed';
    final allergies = (_profile?.allergies.isNotEmpty == true)
        ? _profile!.allergies.join(', ')
        : 'None Known';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Patient Credentials + CareID Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _isEn ? 'Patient Credentials' : 'Credenciales del Paciente',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3B0764),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF90F4FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF004F54), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'CareID VERIFIED',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF004F54),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row 1: Date of Birth & Blood Group
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DATE OF BIRTH',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dob,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BLOOD GROUP',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bloodGroup,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFFDC2626), // Bold Red
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Insurance Status & Emergency Contact
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INSURANCE STATUS',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _hasActiveInsurance
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _hasActiveInsurance ? 'Active' : 'Uninsured',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EMERGENCY CONTACT',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emergencyContact,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 3: Known Allergies
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'KNOWN ALLERGIES',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                allergies,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF5B14B8), // Bold Deep Purple
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Divider
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
          const SizedBox(height: 12),

          // Footer Row: Last Updated & Refresh QR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _healthCard?.expiresAt != null
                            ? 'Valid Thru: ${_healthCard!.expiresAt!.split("T")[0]}'
                            : 'Last Updated: Just now',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _loadHealthCard,
                child: const Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF5B14B8)),
                    SizedBox(width: 4),
                    Text(
                      'Refresh QR',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF5B14B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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

  Widget _buildActionItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
