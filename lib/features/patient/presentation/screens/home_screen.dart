import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../data/models/appointment_models.dart';
import '../../data/models/digital_health_card_models.dart';
import '../../data/models/medical_record_models.dart';
import '../../data/models/patient_profile_models.dart';
import '../../data/repositories/digital_health_card_repository.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../data/repositories/medical_records_repository.dart';
import '../../data/repositories/patient_repository.dart';
import 'doctors_directory_screen.dart';
import 'emergency_center_screen.dart';
import 'family_members_screen.dart';
import 'full_kiosk_pass_screen.dart';
import 'health_card_screen.dart';
import 'insurance_screen.dart';
import 'medical_records_screen.dart';
import 'my_appointments_screen.dart';
import 'notification_center_screen.dart';
import 'patient_profile_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/careid_dental_logo.dart';
import 'dental_records_screen.dart';
import 'pet_records_screen.dart';
import 'vision_records_screen.dart';

/// CareID Patient Home / Dashboard Screen
/// Faithfully reproduces Figma Frame `20:19552` ("Home - Option 6")
/// Canvas: "Careid patient app" (node 17-55)
/// Height: 1846px, Width: 390px
class HomeScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final RegistrationContext? registrationContext;
  final void Function(int tabIndex)? onNavigateToTab;
  final void Function(String language)? onLanguageChanged;

  const HomeScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.registrationContext,
    this.onNavigateToTab,
    this.onLanguageChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _currentLanguage;
  late final PatientRepository _patientRepository;
  late final DigitalHealthCardRepository _healthCardRepository;
  late final MedicalRecordsRepository _recordsRepository;
  late final DoctorRepository _doctorRepository;

  PatientProfileDto? _profile;
  HealthCardDto? _healthCard;
  List<MedicalRecordDto> _recentRecords = [];
  List<AppointmentModel> _upcomingAppointments = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _patientRepository = PatientRepository(apiClient: widget.apiClient);
    _healthCardRepository = DigitalHealthCardRepository(apiClient: widget.apiClient);
    _recordsRepository = MedicalRecordsRepository(apiClient: widget.apiClient);
    _doctorRepository = DoctorRepository(apiClient: widget.apiClient);

    _loadDashboardData();
  }

  bool get _isEn => _currentLanguage == 'en';

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final profileRes = await _patientRepository.getPatientProfile();
    final cardRes = await _healthCardRepository.getActiveHealthCard();
    final recordsRes = await _recordsRepository.getMedicalRecords();
    final aptRes = await _doctorRepository.getMyAppointments();

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      profileRes.when(
        success: (data, msg) => _profile = data,
        failure: (msg, code, err) {
          if (widget.registrationContext != null) {
            final ctx = widget.registrationContext!;
            final rawBg = ctx.bloodGroup;
            _profile = PatientProfileDto(
              id: ctx.profileId ?? 'demo-patient',
              firstName: ctx.fullName.isNotEmpty ? ctx.fullName.split(' ').first : 'Patient',
              lastName: ctx.fullName.isNotEmpty && ctx.fullName.contains(' ')
                  ? ctx.fullName.split(' ').sublist(1).join(' ')
                  : '',
              phone: ctx.phone,
              email: ctx.email,
              bloodGroup: rawBg != null && rawBg.isNotEmpty ? rawBg : 'Not Specified',
              allergies: ctx.knownAllergies,
              conditions: ctx.chronicConditions,
              status: 'ACTIVE',
            );
          }
        },
      );

      cardRes.when(
        success: (data, msg) => _healthCard = data,
        failure: (msg, code, err) {
          if (widget.registrationContext != null) {
            _healthCard = HealthCardDto(
              cardNumber: widget.registrationContext!.displayCareId,
              status: 'ACTIVE',
              qrPayload: 'CAREID:${widget.registrationContext!.displayCareId}',
            );
          }
        },
      );

      recordsRes.when(
        success: (data, msg) => _recentRecords = data,
        failure: (msg, code, err) {
          _recentRecords = [];
        },
      );

      _upcomingAppointments = aptRes.dataOrNull ?? [];
    });
  }

  void _onOpenHealthCard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HealthCardScreen(
          apiClient: widget.apiClient,
          language: _currentLanguage,
          registrationContext: widget.registrationContext,
        ),
      ),
    );
  }

  void _onOpenKioskPass() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullKioskPassScreen(
          language: _currentLanguage,
        ),
      ),
    );
  }

  void _onAddToWallet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEn
              ? 'CareID Digital Health Pass saved to mobile wallet.'
              : 'Pase Digital CareID guardado en la billetera móvil.',
        ),
        backgroundColor: const Color(0xFF3F1D8B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic values with Figma Option 6 defaults
    final firstName = _profile?.firstName.isNotEmpty == true
        ? _profile!.firstName
        : (widget.registrationContext?.fullName.isNotEmpty == true
            ? widget.registrationContext!.fullName.split(' ').first
            : 'Patient');

    final lastName = _profile?.lastName.isNotEmpty == true
        ? _profile!.lastName
        : (widget.registrationContext?.fullName.isNotEmpty == true &&
                widget.registrationContext!.fullName.contains(' ')
            ? widget.registrationContext!.fullName.split(' ').sublist(1).join(' ')
            : '');

    final fullName = '$firstName $lastName'.trim();

    final profileBg = _profile?.bloodGroup;
    final contextBg = widget.registrationContext?.bloodGroup;
    final bloodGroup = (profileBg != null && profileBg.isNotEmpty)
        ? profileBg
        : ((contextBg != null && contextBg.isNotEmpty)
            ? contextBg
            : 'Not Specified');

    final profileDob = _profile?.dateOfBirth;
    final dob = (profileDob != null && profileDob.isNotEmpty)
        ? profileDob
        : '--';

    final cardNumber = _healthCard?.cardNumber ??
        widget.registrationContext?.displayCareId ??
        'PT-CAREID-2026-0004';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF3F1D8B),
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header - Top App Bar (Figma 20:19753)
                _buildTopAppBar(fullName),

                if (_isLoading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F1D8B)),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // 2. Hero Health Card (Figma 20:19554)
                      _buildHeroHealthCard(
                        firstName: firstName,
                        lastName: lastName,
                        dob: dob,
                        bloodGroup: bloodGroup,
                        cardNumber: cardNumber,
                      ),

                      const SizedBox(height: 32),

                      // 3. Health Records - Bento Grid (Figma 20:19631)
                      _buildHealthRecordsSection(),

                      const SizedBox(height: 32),

                      // 4. Quick Actions (Figma 20:19687)
                      _buildQuickActionsSection(),

                      const SizedBox(height: 32),

                      // 5. Upcoming Appointments (Figma 20:19598)
                      _buildUpcomingAppointmentsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION 1: Header - Top App Bar (Figma 20:19753, 390x64)
  // ===========================================================================
  Widget _buildTopAppBar(String patientName) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE7EAF5), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A3F1D8B),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Complete CareID Logo: Brand Emblem + Wordmark (Figma Node 20:19759, 79x18)
          const CareIdLogo.horizontal(height: 18),

          // Right Controls: Notifications, Profile Avatar & Language
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Bell (Figma 20:19760, 40x40 circle, #E5EEFF)
              Semantics(
                button: true,
                label: _isEn ? 'Notifications' : 'Notificaciones',
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationCenterScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5EEFF),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                          color: Color(0xFF28006D),
                        ),
                        // Unread notification red dot (Figma 20:19763)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFBA1A1A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Profile Avatar with Status Badge (Figma 20:19754)
              Semantics(
                button: true,
                label: _isEn ? 'Patient Profile' : 'Perfil del Paciente',
                child: GestureDetector(
                  onTap: () {
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(3);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PatientProfileScreen(
                            apiClient: widget.apiClient,
                            language: _currentLanguage,
                            registrationContext: widget.registrationContext,
                          ),
                        ),
                      );
                    }
                  },
                  child: SizedBox(
                    width: 40,
                    height: 44,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF3F1D8B), width: 2),
                            color: const Color(0xFFE8DDFF),
                          ),
                          child: Center(
                            child: Text(
                              patientName.isNotEmpty
                                  ? patientName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                                  : 'RM',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3F1D8B),
                              ),
                            ),
                          ),
                        ),
                        // Online indicator dot (Figma 20:19758, 12x12 green #22C55E with 2px white border)
                        Positioned(
                          right: 0,
                          bottom: 2,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 2: Hero Health Card (Figma 20:19554, 342x434.25)
  // ===========================================================================
  Widget _buildHeroHealthCard({
    required String firstName,
    required String lastName,
    required String dob,
    required String bloodGroup,
    required String cardNumber,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F1D8B), Color(0xFF006971)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x663F1D8B),
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Top-right radial blur sphere (Figma 20:19555, 256x256, rgba(117,242,254,0.2))
            Positioned(
              top: -64,
              right: -64,
              child: Container(
                width: 256,
                height: 256,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x3375F2FE),
                ),
              ),
            ),
            // Bottom-left radial blur sphere (Figma 20:19556, 256x256, rgba(63,29,139,0.3))
            Positioned(
              bottom: -64,
              left: -64,
              child: Container(
                width: 256,
                height: 256,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x4D3F1D8B),
                ),
              ),
            ),

            // Card Inner Content (Padded 28px per Figma)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upper Row: Title, Name, Member Since & Actions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Patient Demographics Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEn ? 'DIGITAL HEALTH ID' : 'ID DE SALUD DIGITAL',
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFCFBDFF),
                                letterSpacing: 0.7,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$firstName\n$lastName',
                              style: const TextStyle(
                                fontSize: 36,
                                height: 1.15,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isEn ? 'Member since 2021' : 'Miembro desde 2021',
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFE8DDFF),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Upper Right Action Icon & ICE Pill
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Glass Shield / Pass Button (Figma 20:19566, 48x48)
                          GestureDetector(
                            onTap: _onOpenKioskPass,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0D000000),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ICE Active Badge (Figma 20:19570, pill #BA1A1A, 101.33x28.5)
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const EmergencyCenterScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xE6BA1A1A),
                                borderRadius: BorderRadius.circular(9999),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emergency_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isEn ? 'ICE Active' : 'ICE Activo',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
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

                  const SizedBox(height: 28),

                  // Lower Glass Shelf (Figma 20:19576, rounded 24, p:21)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: DOB & Blood Group
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // DOB
                              Text(
                                _isEn ? 'DOB' : 'FECHA NAC.',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFCFBDFF),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dob,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // BLOOD GROUP
                              Text(
                                _isEn ? 'BLOOD GROUP' : 'GRUPO SANGUÍNEO',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFCFBDFF),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                bloodGroup,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF83F3FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Right: QR Code & Add to Wallet Button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // QR Box (Figma 20:19589, 68x68)
                            GestureDetector(
                              onTap: _onOpenHealthCard,
                              child: Tooltip(
                                message: cardNumber,
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1F000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 54,
                                      color: Color(0xFF0B1C30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Add to Wallet Button (Figma 20:19591)
                            GestureDetector(
                              onTap: _onAddToWallet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isEn ? 'Add to Wallet' : 'Añadir a Wallet',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION 3: Health Records Bento Grid (Figma 20:19631, 342x326)
  // ===========================================================================
  Widget _buildHealthRecordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: Health Records (Figma 20:19634)
        Text(
          _isEn ? 'Health Records' : 'Registros Médicos',
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B1C30),
          ),
        ),
        const SizedBox(height: 16),

        // 2x2 Bento Grid
        Row(
          children: [
            // Card 1: Medical (Figma 20:19638)
            Expanded(
              child: _buildBentoCard(
                title: _isEn ? 'Medical' : 'Médico',
                subtitle: _isEn ? 'Lab result & scans' : 'Análisis y escaneos',
                icon: Icons.biotech_outlined,
                iconBg: const Color(0xFFE8F8FA),
                iconColor: const Color(0xFF006971),
                recordsCount: _recentRecords.isNotEmpty ? _recentRecords.length : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MedicalRecordsScreen(
                        apiClient: widget.apiClient,
                        language: _currentLanguage,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            // Card 2: Dental (Figma 20:19647 - Approved Molar Tooth Vector #0284C7 on #E0F2FE)
            Expanded(
              child: _buildBentoCard(
                title: _isEn ? 'Dental' : 'Dental',
                subtitle: _isEn ? 'Checkup & X-rays' : 'Revisión y rayos X',
                customIcon: const CareIdDentalLogo(size: 24, color: AppColors.dentalIcon),
                iconBg: AppColors.dentalBg,
                iconColor: AppColors.dentalIcon,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DentalRecordsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            // Card 3: Vision (Figma 20:19657)
            Expanded(
              child: _buildBentoCard(
                title: _isEn ? 'Vision' : 'Visión',
                subtitle: _isEn ? 'Eye Checkups' : 'Examen de la vista',
                icon: Icons.visibility_outlined,
                iconBg: AppColors.visionBg,
                iconColor: AppColors.visionIcon,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VisionRecordsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            // Card 4: Pets (Figma 20:19668)
            Expanded(
              child: _buildBentoCard(
                title: _isEn ? 'Pets' : 'Mascotas',
                subtitle: _isEn ? 'Pet Checkups' : 'Consultas veterinarias',
                icon: Icons.pets_outlined,
                iconBg: AppColors.petsBg,
                iconColor: AppColors.petsIcon,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PetRecordsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String subtitle,
    IconData icon = Icons.circle,
    Widget? customIcon,
    required Color iconBg,
    required Color iconColor,
    int? recordsCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 156,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE7EAF5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A3F1D8B),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon Container (48x48, rounded 16)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: customIcon ?? Icon(
                      icon,
                      size: 24,
                      color: iconColor,
                    ),
                  ),
                ),
                if (recordsCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8FA),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '$recordsCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006971),
                      ),
                    ),
                  ),
              ],
            ),

            // Text Labels
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF494552),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION 4: Quick Actions 2x2 Grid (Figma 20:19687, 342x234)
  // ===========================================================================
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: Quick Actions (Figma 20:19686)
        Text(
          _isEn ? 'Quick Actions' : 'Acciones Rápidas',
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B1C30),
          ),
        ),
        const SizedBox(height: 16),

        // Row 1
        Row(
          children: [
            // Action 1: Insurance Card (Figma 20:19688)
            Expanded(
              child: _buildQuickActionCard(
                title: _isEn ? 'Insurance Card' : 'Tarjeta de Seguro',
                subtitle: _isEn ? 'Secure vault upload' : 'Subida a bóveda segura',
                icon: Icons.shield_outlined,
                iconCircleBg: const Color(0xFFD3E4FE),
                iconColor: const Color(0xFF00696B),
                dotColor: const Color(0xFF00696B),
                cardBg: Colors.white,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => InsuranceScreen(
                        apiClient: widget.apiClient,
                        language: _currentLanguage,
                        registrationContext: widget.registrationContext,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Action 2: Add Family Member (Figma 20:19700)
            Expanded(
              child: _buildQuickActionCard(
                title: _isEn ? 'Add Family Member' : 'Añadir Familiar',
                subtitle: _isEn ? 'Secure health profile' : 'Perfil médico seguro',
                icon: Icons.people_outline_rounded,
                iconCircleBg: const Color(0xFFD3E4FE),
                iconColor: const Color(0xFF00696B),
                dotColor: const Color(0xFF00696B),
                cardBg: Colors.white,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => FamilyMembersScreen(
                        apiClient: widget.apiClient,
                        language: _currentLanguage,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2
        Row(
          children: [
            // Action 3: Book Appointment (Figma 20:19713)
            Expanded(
              child: _buildQuickActionCard(
                title: _isEn ? 'Book Appointment' : 'Reservar Cita',
                subtitle: _isEn ? 'Clinics & Specialists' : 'Clínicas y especialistas',
                icon: Icons.calendar_month_outlined,
                iconCircleBg: const Color(0xFFE8DDFF),
                iconColor: const Color(0xFF3F1D8B),
                badgeText: _isEn ? 'PRIMARY' : 'PRINCIPAL',
                badgeBg: const Color(0xFF00696B),
                cardBg: Colors.white,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DoctorsDirectoryScreen(
                        repository: _doctorRepository,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Action 4: Emergency SOS (Figma 20:19726)
            Expanded(
              child: _buildQuickActionCard(
                title: _isEn ? 'Emergency' : 'Emergencia',
                subtitle: _isEn ? 'Critical medical data' : 'Datos médicos críticos',
                icon: Icons.emergency_share_outlined,
                iconCircleBg: const Color(0xFFBA1A1A),
                iconColor: Colors.white,
                badgeText: 'SOS',
                badgeBg: const Color(0xFF93000A),
                cardBg: const Color(0x66FFDAD6),
                titleColor: const Color(0xFF93000A),
                subtitleColor: const Color(0xCC93000A),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EmergencyCenterScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconCircleBg,
    required Color iconColor,
    Color? dotColor,
    String? badgeText,
    Color? badgeBg,
    Color cardBg = Colors.white,
    Color titleColor = const Color(0xFF0B1C30),
    Color subtitleColor = const Color(0xFF494552),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: titleColor == const Color(0xFF93000A)
                ? const Color(0xFFFFDAD6)
                : const Color(0xFFE7EAF5),
          ),
          boxShadow: [
            BoxShadow(
              color: titleColor == const Color(0xFF93000A)
                  ? const Color(0x1ABA1A1A)
                  : const Color(0x0A3F1D8B),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon circle + Badge / Dot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconCircleBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ),
                if (badgeText != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg ?? const Color(0xFF00696B),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        badgeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                else if (dotColor != null)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),

            // Titles
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION 5: Upcoming Appointments (Figma 20:19598, 343x356)
  // ===========================================================================
  Widget _buildUpcomingAppointmentsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE7EAF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A3F1D8B),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Upcoming & View All (Figma 20:19600)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _isEn ? 'Upcoming' : 'Próximas Citas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1C30),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MyAppointmentsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FF),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: const Color(0xFFE7EAF5)),
                  ),
                  child: Text(
                    _isEn ? 'View All' : 'Ver Todas',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF28006D),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE7EAF5), height: 1),
          const SizedBox(height: 16),

          // Appointment Cards: Live list or approved Figma mock cards
          if (_upcomingAppointments.isNotEmpty) ...[
            ..._upcomingAppointments.take(2).map((apt) {
              final month = _formatMonth(apt.dateTime);
              final day = apt.dateTime.day.toString().padLeft(2, '0');
              final time = '${apt.dateTime.hour}:${apt.dateTime.minute.toString().padLeft(2, '0')}';
              final isDental = apt.specialization.toLowerCase().contains('dent') ||
                  apt.reasonForVisit.toLowerCase().contains('dent');

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAppointmentItem(
                  month: month,
                  day: day,
                  badgeBg: isDental ? const Color(0xFFEFE8FA) : const Color(0xFFD9F4F5),
                  monthColor: isDental ? const Color(0xFF8B30E6) : const Color(0xFF006971),
                  dayColor: isDental ? const Color(0xFF28006D) : const Color(0xFF004D52),
                  cardBg: isDental ? const Color(0xFFF8F6FF) : const Color(0xFFF0FAFA),
                  status: apt.status == AppointmentStatus.upcoming ? 'Confirmed' : 'Pending',
                  statusBg: apt.status == AppointmentStatus.upcoming
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF9C3),
                  statusColor: apt.status == AppointmentStatus.upcoming
                      ? const Color(0xFF15803D)
                      : const Color(0xFF854D0E),
                  title: apt.reasonForVisit.isNotEmpty ? apt.reasonForVisit : apt.specialization,
                  subtitle: '${apt.facility} · $time',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyAppointmentsScreen(),
                      ),
                    );
                  },
                ),
              );
            }),
          ] else ...[
            // Figma Card 1: Dental Radiograph (Figma 20:19607)
            _buildAppointmentItem(
              month: 'JUN',
              day: '12',
              badgeBg: const Color(0xFFEFE8FA),
              monthColor: const Color(0xFF8B30E6),
              dayColor: const Color(0xFF28006D),
              cardBg: const Color(0xFFF8F6FF),
              status: _isEn ? 'Confirmed' : 'Confirmada',
              statusBg: const Color(0xFFDCFCE7),
              statusColor: const Color(0xFF15803D),
              title: _isEn ? 'Dental Appointment' : 'Cita Odontológica',
              subtitle: _isEn ? 'City Hospital · 9:00 AM' : 'Hospital Central · 9:00 AM',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MyAppointmentsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Figma Card 2: Prescription Collection (Figma 20:19619)
            _buildAppointmentItem(
              month: 'JUN',
              day: '18',
              badgeBg: const Color(0xFFD9F4F5),
              monthColor: const Color(0xFF006971),
              dayColor: const Color(0xFF004D52),
              cardBg: const Color(0xFFF0FAFA),
              status: _isEn ? 'Pending' : 'Pendiente',
              statusBg: const Color(0xFFFEF9C3),
              statusColor: const Color(0xFF854D0E),
              title: _isEn ? 'Prescription Collection' : 'Entrega de Receta',
              subtitle: _isEn ? 'Dr. Smith · 11:30 AM' : 'Dr. Smith · 11:30 AM',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MyAppointmentsScreen(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentItem({
    required String month,
    required String day,
    required Color badgeBg,
    required Color monthColor,
    required Color dayColor,
    required Color cardBg,
    required String status,
    required Color statusBg,
    required Color statusColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7EAF5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A3F1D8B),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date Badge (52x60, rounded 14, Figma 20:19608)
            Container(
              width: 52,
              height: 60,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    month,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: monthColor,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      color: dayColor,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B1C30),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF494552),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF757575),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMonth(DateTime dt) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[dt.month - 1];
  }
}
