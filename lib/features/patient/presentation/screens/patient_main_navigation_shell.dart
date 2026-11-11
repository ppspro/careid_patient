import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../auth/data/models/registration_context.dart';
import 'doctors_directory_screen.dart';
import 'family_records_screen.dart';
import 'health_card_screen.dart';
import 'home_screen.dart';
import 'patient_profile_screen.dart';
import 'scan_health_card_qr_screen.dart';
import 'scan_medical_document_ocr_screen.dart';

/// CareID Patient Main Navigation Shell
/// Coordinates the primary navigation modules of the approved Patient App,
/// standardized with the Figma `Bottom Nav Bar (Mobile)` (`20:19764`):
/// 0: Home (Dashboard - Figma 20:19552 "Home - Option 6")
/// 1: Medical Records (Figma 20:20000 / 20:30521)
/// 2: Doctor Directory / Consultations (Figma 20:28020)
/// 3: Profile (Demographics, Security, Settings - Figma 20:23000)
/// Central Floating QR Action Menu:
/// - Action 1: Scan Health Card (Figma 20:19873 / 20:22771)
/// - Action 2: Scan Medical Document (OCR) (Figma 20:32268 / 20:32321)
class PatientMainNavigationShell extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final int initialIndex;
  final RegistrationContext? registrationContext;
  final bool initialExpandQrMenu;

  const PatientMainNavigationShell({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.initialIndex = 0,
    this.registrationContext,
    this.initialExpandQrMenu = false,
  });

  @override
  State<PatientMainNavigationShell> createState() =>
      _PatientMainNavigationShellState();
}

class _PatientMainNavigationShellState extends State<PatientMainNavigationShell>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late String _currentLanguage;

  bool _isMenuExpanded = false;
  late final AnimationController _menuAnimController;
  late final Animation<double> _menuAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentLanguage = widget.language;
    _isMenuExpanded = widget.initialExpandQrMenu;

    _menuAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
      value: widget.initialExpandQrMenu ? 1.0 : 0.0,
    );

    _menuAnimation = CurvedAnimation(
      parent: _menuAnimController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInQuad,
    );
  }

  @override
  void dispose() {
    _menuAnimController.dispose();
    super.dispose();
  }

  bool get _isEn => _currentLanguage == 'en';

  void _onTabSelected(int index) {
    _collapseMenu();
    setState(() {
      _currentIndex = index;
    });
  }

  void _onLanguageChanged(String lang) {
    setState(() {
      _currentLanguage = lang;
    });
  }

  void _toggleQrMenu() {
    setState(() {
      _isMenuExpanded = !_isMenuExpanded;
      if (_isMenuExpanded) {
        _menuAnimController.forward();
      } else {
        _menuAnimController.reverse();
      }
    });
  }

  void _collapseMenu() {
    if (_isMenuExpanded) {
      setState(() {
        _isMenuExpanded = false;
        _menuAnimController.reverse();
      });
    }
  }

  void _openScanHealthCard() {
    _collapseMenu();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScanHealthCardQrScreen(
          apiClient: widget.apiClient,
          language: _currentLanguage,
        ),
      ),
    );
  }

  void _openScanMedicalDocument() {
    _collapseMenu();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScanMedicalDocumentOcrScreen(
          apiClient: widget.apiClient,
          language: _currentLanguage,
        ),
      ),
    );
  }

  void _openHealthCard() {
    _collapseMenu();
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

  @override
  Widget build(BuildContext context) {
    final nameParts =
        widget.registrationContext?.fullName.trim().split(RegExp(r'\s+')) ?? [];
    final patientInitials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (nameParts.isNotEmpty && nameParts[0].isNotEmpty
            ? nameParts[0]
                .substring(0, nameParts[0].length >= 2 ? 2 : 1)
                .toUpperCase()
            : 'JD');

    final screens = [
      // 0: Home (Option 6 - Figma 20:19552)
      HomeScreen(
        apiClient: widget.apiClient,
        language: _currentLanguage,
        registrationContext: widget.registrationContext,
        onNavigateToTab: _onTabSelected,
        onLanguageChanged: _onLanguageChanged,
      ),
      // 1: Records Hub (Care ID - Family Records - Figma 20:30521)
      FamilyRecordsScreen(
        apiClient: widget.apiClient,
        language: _currentLanguage,
        showBottomNav: false,
        onBackToHome: () => _onTabSelected(0),
        patientInitials: patientInitials,
      ),
      // 2: Doctor (Directory - Figma 20:28020)
      const DoctorsDirectoryScreen(
        repository: null,
      ),
      // 3: Profile (Figma 20:24204)
      PatientProfileScreen(
        apiClient: widget.apiClient,
        language: _currentLanguage,
        registrationContext: widget.registrationContext,
        onLanguageChanged: _onLanguageChanged,
        onBack: () => _onTabSelected(0),
      ),
    ];

    return PopScope(
      canPop: !_isMenuExpanded,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isMenuExpanded) {
          _collapseMenu();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Current Destination Tab Screen
            IndexedStack(
              index: _currentIndex.clamp(0, screens.length - 1),
              children: screens,
            ),

            // Semi-transparent Scrim Backdrop
            if (_isMenuExpanded)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _collapseMenu,
                  child: AnimatedBuilder(
                    animation: _menuAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _menuAnimation.value.clamp(0.0, 1.0) * 0.45,
                        child: Container(color: const Color(0xFF0F172A)),
                      );
                    },
                  ),
                ),
              ),

            // Floating Action Bubbles Container
            if (_isMenuExpanded)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: AnimatedBuilder(
                    animation: _menuAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _menuAnimation.value.clamp(0.0, 1.0),
                        alignment: Alignment.bottomCenter,
                        child: Opacity(
                          opacity: _menuAnimation.value.clamp(0.0, 1.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Bubble 2: Scan Medical Document (OCR)
                              _buildActionBubble(
                                label: _isEn
                                    ? 'Scan Medical Document (OCR)'
                                    : 'Escanear Documento Médico (OCR)',
                                subtitle: _isEn
                                    ? 'Prescriptions, Lab Slips, X-Rays'
                                    : 'Recetas, Informes, Rayos X',
                                icon: Icons.document_scanner_rounded,
                                iconColor: const Color(0xFF0284C7),
                                badgeBgColor: const Color(0xFFE0F2FE),
                                onTap: _openScanMedicalDocument,
                              ),
                              const SizedBox(height: 12),

                              // Bubble 1: Scan Health Card
                              _buildActionBubble(
                                label: _isEn
                                    ? 'Scan Health Card'
                                    : 'Escanear Tarjeta de Salud',
                                subtitle: _isEn
                                    ? 'Verify Patient CareID Credentials'
                                    : 'Verificar Credencial CareID',
                                icon: Icons.qr_code_scanner_rounded,
                                iconColor: const Color(0xFF5B14B8),
                                badgeBgColor: const Color(0xFFEDE9FE),
                                onTap: _openScanHealthCard,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: CareIdBottomNavigationBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
          onCenterAction: _toggleQrMenu,
          onCenterLongPress: _openHealthCard,
          isMenuExpanded: _isMenuExpanded,
          showCenterButton: true,
          language: _currentLanguage,
        ),
      ),
    );
  }

  Widget _buildActionBubble({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color badgeBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x0C3F1D8B),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
