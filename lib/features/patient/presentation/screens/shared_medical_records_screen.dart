import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/family_models.dart';
import '../../data/repositories/family_repository.dart';

/// CareID Patient App — Shared Medical Records Screen
/// Faithfully reproduces Figma Frame `20:22594` ("Shared Medical Records", 390x1310)
/// Features 64px AppBar with CareIdLogo.horizontal(height: 18),
/// Family Member Switcher carousel, category search and filters,
/// and interactive clinical timeline entries for authorized dependent records.
class SharedMedicalRecordsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final FamilyRepository? repository;
  final String language;
  final List<FamilyMemberDto>? initialMembers;

  const SharedMedicalRecordsScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.language = 'en',
    this.initialMembers,
  });

  @override
  State<SharedMedicalRecordsScreen> createState() => _SharedMedicalRecordsScreenState();
}

class _SharedMedicalRecordsScreenState extends State<SharedMedicalRecordsScreen> {
  late final FamilyRepository _repository;
  List<FamilyMemberDto> _members = [];
  int _selectedMemberIndex = 0;
  String _selectedCategory = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FamilyRepository(apiClient: widget.apiClient);
    if (widget.initialMembers != null && widget.initialMembers!.isNotEmpty) {
      _members = List.from(widget.initialMembers!);
    } else {
      _loadMembers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isEn => widget.language == 'en';

  Future<void> _loadMembers() async {
    final res = await _repository.getMembers();
    if (!mounted) return;

    res.when(
      success: (list, _) {
        setState(() {
          _members = list;
        });
      },
      failure: (_, __, ___) {
        setState(() {
          _members = const [];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeMember = _members.isNotEmpty ? _members[_selectedMemberIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _isEn ? 'Shared Medical Records' : 'Registros Médicos Compartidos',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const CareIdLogo.onlyId(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // Section - Member Switcher (Figma 20:22642)
          Text(
            _isEn ? 'FAMILY MEMBERS' : 'MIEMBROS DE LA FAMILIA',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildMemberSwitcher(),
          const SizedBox(height: 20),

          // Section - Search & Filters (Figma 20:22664)
          _buildSearchAndFilters(),
          const SizedBox(height: 24),

          // Section - Medical History Timeline (Figma 20:22680)
          Text(
            activeMember != null
                ? (_isEn ? '${activeMember.name}\'s Timeline' : 'Historial de ${activeMember.name}')
                : (_isEn ? 'Clinical Timeline' : 'Historial Clínico'),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          _buildTimelineItem(
            title: _isEn ? 'Pediatric Wellness Checkup' : 'Revisión Pediátrica Preventiva',
            doctor: 'Dr. Sarah Jenkins • Pediatrics',
            date: '18 Oct 2026',
            category: 'PEDIATRICS',
            icon: Icons.child_care_rounded,
            iconColor: const Color(0xFF0F766E),
            bgColor: const Color(0xFFF0FDF4),
            status: _isEn ? 'DOCTOR SIGNED' : 'FIRMADO POR DOCTOR',
          ),
          _buildTimelineItem(
            title: _isEn ? 'Routine MMR Booster Vaccination' : 'Vacuna de Refuerzo Triple Vírica',
            doctor: 'Metro Children Clinic',
            date: '04 Sep 2026',
            category: 'IMMUNIZATION',
            icon: Icons.vaccines_outlined,
            iconColor: const Color(0xFF5B14B8),
            bgColor: const Color(0xFFEDE9FE),
            status: _isEn ? 'VERIFIED BATCH' : 'LOTE VERIFICADO',
          ),
          _buildTimelineItem(
            title: _isEn ? 'Pediatric Dental Cleaning' : 'Limpieza Dental Infantil',
            doctor: 'Dr. Marcus Vance • Pediatric Dentist',
            date: '15 Jul 2026',
            category: 'DENTAL',
            icon: Icons.cleaning_services_rounded,
            iconColor: const Color(0xFF0284C7),
            bgColor: const Color(0xFFE0F2FE),
            status: _isEn ? 'NO CAVITIES' : 'SIN CARIES',
          ),
        ],
      ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: 0,
        language: widget.language,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('/records');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/doctors');
          }
        },
      ),
    );
  }

  Widget _buildMemberSwitcher() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final mem = _members[index];
          final isSelected = _selectedMemberIndex == index;

          return InkWell(
            onTap: () => setState(() => _selectedMemberIndex = index),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 84,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5B14B8) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Color(0x265B14B8),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isSelected ? Colors.white : const Color(0xFFEDE9FE),
                    child: Text(
                      mem.name.isNotEmpty ? mem.name[0] : 'M',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFF5B14B8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mem.name.split(' ').first,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _isEn ? 'Search records, labs, doctors...' : 'Buscar registros, laboratorios...',
              hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('ALL', _isEn ? 'All' : 'Todos'),
              const SizedBox(width: 8),
              _buildFilterChip('LABS', _isEn ? 'Lab Results' : 'Laboratorios'),
              const SizedBox(width: 8),
              _buildFilterChip('PEDIATRICS', _isEn ? 'Pediatrics' : 'Pediatría'),
              const SizedBox(width: 8),
              _buildFilterChip('IMMUNIZATION', _isEn ? 'Vaccines' : 'Vacunas'),
              const SizedBox(width: 8),
              _buildFilterChip('DENTAL', _isEn ? 'Dental' : 'Dental'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedCategory == key;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String doctor,
    required String date,
    required String category,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F766E),
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isEn
                            ? 'Opening encrypted clinical document...'
                            : 'Abriendo documento clínico encriptado...',
                      ),
                      backgroundColor: const Color(0xFF0F172A),
                    ),
                  );
                },
                icon: const Icon(Icons.description_outlined, size: 14, color: Color(0xFF5B14B8)),
                label: Text(
                  _isEn ? 'View Record' : 'Ver Registro',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5B14B8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
