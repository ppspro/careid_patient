import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/family_models.dart';
import '../../data/repositories/family_repository.dart';
import 'family_members_screen.dart';
import 'health_card_screen.dart';
import 'medical_records_screen.dart';
import 'notification_center_screen.dart';
import 'patient_profile_screen.dart';
import 'pet_records_screen.dart';

/// CareID Patient App — Family Records Hub
/// Faithfully reproduces Figma Frame `20:30521` ("Care ID - Family Records", 390x1043)
/// Located on canvas "Careid patient app" (node 17-55).
class FamilyRecordsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final bool showBottomNav;
  final VoidCallback? onBackToHome;
  final String? patientInitials;

  const FamilyRecordsScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.showBottomNav = false,
    this.onBackToHome,
    this.patientInitials,
  });

  @override
  State<FamilyRecordsScreen> createState() => _FamilyRecordsScreenState();
}

class _FamilyRecordsScreenState extends State<FamilyRecordsScreen> {
  late final FamilyRepository _familyRepository;
  List<FamilyMemberDto> _familyMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _familyRepository = FamilyRepository(apiClient: widget.apiClient);
    _loadFamilyData();
  }

  bool get _isEn => widget.language == 'en';

  Future<void> _loadFamilyData() async {
    setState(() => _isLoading = true);
    final res = await _familyRepository.getMembers();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _familyMembers = res.dataOrNull ?? [];
    });
  }

  void _onOpenHealthCard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HealthCardScreen(
          apiClient: widget.apiClient,
          language: widget.language,
        ),
      ),
    );
  }

  void _onBottomNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    } else if (index == 1) {
      // Stay on records
    } else if (index == 2) {
      Navigator.of(context).pushNamed('/doctors');
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PatientProfileScreen(
            apiClient: widget.apiClient,
            language: widget.language,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header - Top AppBar (Figma 20:30635, 390x64)
            _buildTopAppBar(),

            // Main scrollable content
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF5B14B8),
                onRefresh: _loadFamilyData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2. Top Bar Complement / Status Strip (Figma 20:30523)
                      _buildStatusStrip(),

                      const SizedBox(height: 16),

                      if (_isLoading)
                        const LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B14B8)),
                        ),

                      const SizedBox(height: 8),

                      // 3. Card 1: My Health Records (Figma 20:30533)
                      _buildVaultCard(
                        title: _isEn ? 'My Health Records' : 'Mis Registros Médicos',
                        description: _isEn
                            ? 'Securely access and review synchronized medical, dental, and vision records for authorized Care ID account.'
                            : 'Accede y revisa de forma segura los registros sincronizados de medicina, dental y visión de tu cuenta Care ID.',
                        bgGradientColors: const [Colors.white, Color(0xFFF7FAFF)],
                        watermarkIcon: Icons.shield_outlined,
                        onContinue: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MedicalRecordsScreen(
                                apiClient: widget.apiClient,
                                language: widget.language,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // 4. Card 2: Family Health Records (Figma 20:30556)
                      _buildVaultCard(
                        title: _isEn ? 'Family Health Records' : 'Registros Familiares',
                        description: _isEn
                            ? 'Securely access and review synchronized medical, dental, and vision records for authorized family members and dependents under your Care ID account.'
                            : 'Revisa de forma segura los registros médicos, dentales y de visión sincronizados para los miembros autorizados de tu familia.',
                        bgGradientColors: const [Colors.white, Color(0xFFF7FAFF)],
                        watermarkIcon: Icons.people_outline_rounded,
                        badgeCount: _familyMembers.isNotEmpty ? _familyMembers.length : null,
                        onContinue: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => FamilyMembersScreen(
                                apiClient: widget.apiClient,
                                language: widget.language,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // 5. Card 3: Pet Records (Figma 20:30578)
                      _buildVaultCard(
                        title: _isEn ? 'Pet Records' : 'Registros de Mascotas',
                        description: _isEn
                            ? 'Securely access and review synchronized vaccination history, exam notes, and prescriptions for your pet.'
                            : 'Revisa de forma segura el historial de vacunación sincronizado, notas de exámenes y recetas de tu mascota.',
                        bgGradientColors: const [Colors.white, Color(0xFFF7FAFF)],
                        watermarkIcon: Icons.pets_outlined,
                        onContinue: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PetRecordsScreen(
                                apiClient: widget.apiClient,
                                language: widget.language,
                                patientInitials: widget.patientInitials,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 6. Bottom Navigation Bar (Figma 20:30604)
            if (widget.showBottomNav)
              CareIdBottomNavigationBar(
                currentIndex: 1, // Records tab active
                onTabSelected: _onBottomNavSelected,
                onCenterAction: _onOpenHealthCard,
                language: widget.language,
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION 1: Top App Bar (Figma 20:30635)
  // ===========================================================================
  Widget _buildTopAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE7ECF6), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF28006D)),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else if (widget.onBackToHome != null) {
                      widget.onBackToHome!();
                    }
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _isEn ? 'Record Details' : 'Detalles de Registros',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF28006D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CareIdLogo.emblem(height: 18),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF3F1D8B), width: 2),
                  color: const Color(0xFFE8DDFF),
                ),
                child: Center(
                  child: Text(
                    widget.patientInitials ?? 'JD',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3F1D8B),
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
  // SECTION 2: Top Status Strip (Figma 20:30523)
  // ===========================================================================
  Widget _buildStatusStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFFE7ECF6)),
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
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.folder_shared_rounded,
                  size: 18,
                  color: Color(0xFF5B14B8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isEn ? 'CARE ID VERIFIED DIRECTORY' : 'DIRECTORIO VERIFICADO CARE ID',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF494552),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationCenterScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5EEFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 16,
                      color: Color(0xFF28006D),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF56F5F8),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.security_rounded,
                    size: 16,
                    color: Color(0xFF004D52),
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
  // SECTION 3, 4, 5: Vault Card Component (Figma 20:30533, 20:30556, 20:30578)
  // ===========================================================================
  Widget _buildVaultCard({
    required String title,
    required String description,
    required List<Color> bgGradientColors,
    required IconData watermarkIcon,
    int? badgeCount,
    required VoidCallback onContinue,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECF6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1228006D),
            blurRadius: 24,
            offset: Offset(0, 10),
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
            // Subtle watermark icon at bottom right (Figma 20:30534, 20:30581)
            Positioned(
              right: -24,
              bottom: -24,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  watermarkIcon,
                  size: 160,
                  color: const Color(0xFF28006D),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags row: Family Vault Active + HIPAA Compliant
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF56F5F8).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 13,
                              color: Color(0xFF006E70),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _isEn ? 'Family Vault Active' : 'Bóveda Familiar Activa',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF006E70),
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
                            Icons.description_outlined,
                            size: 14,
                            color: Color(0xFF00696B),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _isEn ? 'HIPAA Compliant' : 'Cumple con HIPAA',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00696B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Title & Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                      ),
                      if (badgeCount != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8DDFF),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            '$badgeCount members',
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5B14B8),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF494552),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lower Actions Row: Change image (+) and Continue Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Change image button
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _isEn
                                          ? 'Vault image customization enabled.'
                                          : 'Personalización de imagen habilitada.',
                                    ),
                                    backgroundColor: const Color(0xFF5B14B8),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE7ECF6)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1228006D),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 20,
                                    color: Color(0xFF28006D),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _isEn ? 'Change image' : 'Cambiar imagen',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF596173),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Right: Continue CTA
                      PrimaryButton.gradient(
                        text: _isEn ? 'Continue' : 'Continuar',
                        width: 112,
                        height: 44,
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
