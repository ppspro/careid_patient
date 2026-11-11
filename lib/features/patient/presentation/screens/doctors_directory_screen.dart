import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_dental_logo.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/doctor_models.dart';
import '../../data/repositories/doctor_repository.dart';
import 'book_appointment_screen.dart';
import 'doctor_profile_screen.dart';
import 'my_appointments_screen.dart';
import 'notification_center_screen.dart';

/// CareID Patient App — Doctors & Providers Directory Screen
/// Aligned strictly with Figma Frame `20:28020` ("Doctors", 390x1810)
/// Grounded in OpenAPI 3.0.0 `/api/v1/doctors` specifications
class DoctorsDirectoryScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final DoctorRepository? repository;
  final String language;
  final bool showBottomNav;

  const DoctorsDirectoryScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.language = 'en',
    this.showBottomNav = false,
  });

  @override
  State<DoctorsDirectoryScreen> createState() => _DoctorsDirectoryScreenState();
}

class _DoctorsDirectoryScreenState extends State<DoctorsDirectoryScreen> {
  late final DoctorRepository _repository;
  final TextEditingController _searchController = TextEditingController();

  List<DoctorModel> _doctors = [];
  bool _isLoading = true;
  String _selectedSpecialty = 'All';

  final List<String> _specialtyTabs = const [
    'All Clinicians',
    'Medical (MD)',
    'Dental (DDS)',
    'Vision (OD)',
    'My Appointments',
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DoctorRepository(apiClient: widget.apiClient);
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isEn => widget.language == 'en';

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);

    String? specialtyParam;
    if (_selectedSpecialty == 'Medical (MD)') specialtyParam = 'Medical';
    if (_selectedSpecialty == 'Dental (DDS)') specialtyParam = 'Dental';
    if (_selectedSpecialty == 'Vision (OD)') specialtyParam = 'Vision';

    final result = await _repository.getDoctors(
      query: _searchController.text.trim(),
      specialty: specialtyParam,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _doctors = result.dataOrNull ?? [];
      });
    }
  }

  void _onBottomNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/records');
    } else if (index == 2) {
      // Current tab
    } else if (index == 3) {
      Navigator.of(context).pushNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar with CareID Logo (Figma 20:28277, 390x64)
            _buildTopAppBar(),

            // 2. Greeting, Search & Filter Chips (Figma 20:28023, 390x265)
            _buildSearchAndFilters(),

            // 3. Clinicians Directory List (Figma 20:28057)
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF5B14B8)),
                    )
                  : _doctors.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: const Color(0xFF5B14B8),
                          onRefresh: _loadDoctors,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                            itemCount: _doctors.length,
                            itemBuilder: (context, index) {
                              return _buildDoctorCard(_doctors[index]);
                            },
                          ),
                        ),
            ),

            // 4. Bottom Navigation Bar (if enabled)
            if (widget.showBottomNav)
              CareIdBottomNavigationBar(
                currentIndex: 2, // Doctors tab
                onTabSelected: _onBottomNavSelected,
                language: widget.language,
              ),
          ],
        ),
      ),
    );
  }

  // 1. Top Bar (Figma Node 20:28277, 390x64)
  Widget _buildTopAppBar() {
    return Container(
      height: 64,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.event_note_rounded, size: 22, color: Color(0xFF5B14B8)),
                  tooltip: _isEn ? 'My Appointments' : 'Mis Citas',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyAppointmentsScreen(),
                      ),
                    ).then((_) => _loadDoctors());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, size: 22, color: Color(0xFF0F172A)),
                  tooltip: _isEn ? 'Notifications' : 'Notificaciones',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationCenterScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Greeting & Search Area (Figma 20:28023)
  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEn ? 'Doctors/ Providers' : 'Médicos y Proveedores',
                      style: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEn
                          ? 'Find and manage doctors connected to your Care ID vault'
                          : 'Encuentra y gestiona médicos conectados a tu bóveda Care ID',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Bar (Figma Node 20:28036, 358x56)
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _loadDoctors(),
              style: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64748B)),
                        onPressed: () {
                          _searchController.clear();
                          _loadDoctors();
                        },
                      )
                    : null,
                hintText: _isEn ? 'Search by name, clinic, or specialty...' : 'Buscar por nombre o especialidad...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontFamily: 'Plus Jakarta Sans'),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Category Filter Chips (Figma Node 20:28046)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _specialtyTabs.map((tab) {
                final isSelected = _selectedSpecialty == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      if (tab == 'My Appointments') {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MyAppointmentsScreen(),
                          ),
                        ).then((_) => _loadDoctors());
                        return;
                      }
                      setState(() => _selectedSpecialty = tab);
                      _loadDoctors();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF5B14B8) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tab.contains('Dental')) ...[
                            CareIdDentalLogo(
                              size: 14,
                              color: isSelected ? Colors.white : const Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            tab,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Doctor Card (Figma Node 20:28064, 358x244)
  Widget _buildDoctorCard(DoctorModel doctor) {
    final initials = doctor.fullName.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();

    // Discipline accent colors
    Color accentColor = const Color(0xFF5B14B8);
    Color lightBg = const Color(0xFFEDE9FE);
    final spec = doctor.primarySpecialization.toLowerCase();
    if (spec.contains('dental') || spec.contains('dds') || spec.contains('orthodontics')) {
      accentColor = const Color(0xFF0284C7);
      lightBg = const Color(0xFFE0F2FE);
    } else if (spec.contains('vision') || spec.contains('optometry') || spec.contains('ophthalmology')) {
      accentColor = const Color(0xFF6366F1);
      lightBg = const Color(0xFFEEF2FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info Row: Avatar + Name + Specialization + Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: lightBg,
                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            doctor.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (doctor.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFECFDF5),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, size: 12, color: Color(0xFF10B981)),
                                SizedBox(width: 3),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.primarySpecialization,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '(${doctor.reviewCount} reviews) • ${doctor.yearsOfExperience} yrs exp',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Facility & Next Slot Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    doctor.facilityName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'Next: Tomorrow',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Button Row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DoctorProfileScreen(doctor: doctor),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isEn ? 'View Profile' : 'Ver Perfil',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton.gradient(
                  label: _isEn ? 'Book Slot' : 'Reservar Cita',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BookAppointmentScreen(doctor: doctor),
                      ),
                    );
                  },
                  trailingIcon: Icons.arrow_forward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_search_outlined, size: 36, color: Color(0xFF5B14B8)),
            ),
            const SizedBox(height: 16),
            Text(
              _isEn ? 'No clinicians found' : 'Sin proveedores encontrados',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isEn
                  ? 'Try adjusting your search criteria or specialty filters.'
                  : 'Intenta ajustar tus criterios de búsqueda o filtros.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Plus Jakarta Sans'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
