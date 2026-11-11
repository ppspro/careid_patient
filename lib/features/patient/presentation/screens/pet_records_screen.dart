import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/pet_models.dart';
import '../../data/repositories/pet_repository.dart';
import 'add_health_record_screen.dart';
import 'pet_record_detail_screen.dart';

/// CareID Patient App — Pet Care Records Screen
/// Faithfully reproduces Figma Frame `20:26073` & `20:30578` ("Pet Care Records", 390x1400)
class PetRecordsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final PetRepository? repository;
  final String language;
  final String? patientInitials;

  const PetRecordsScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.language = 'en',
    this.patientInitials,
  });

  @override
  State<PetRecordsScreen> createState() => _PetRecordsScreenState();
}

class _PetRecordsScreenState extends State<PetRecordsScreen> {
  late final PetRepository _repository;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<PetModel> _pets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PetRepository(apiClient: widget.apiClient);
    _loadPets();
  }

  Future<void> _loadPets() async {
    if (widget.apiClient == null && widget.repository == null) return;
    setState(() => _isLoading = true);
    try {
      final res = await _repository.getPets().timeout(const Duration(seconds: 4));
      if (mounted && res.isSuccess && res.dataOrNull != null) {
        setState(() {
          _pets = res.dataOrNull!;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  final List<String> _categories = [
    'All Records',
    'Vaccines',
    'Vet Visits',
    'Medications',
    'Lab Tests',
  ];

  final List<Map<String, dynamic>> _allPetRecords = [
    {
      'id': 'PET-REC-01',
      'title': 'Rabies Core Annual Booster',
      'category': 'Vaccines',
      'date': 'Sep 14, 2023',
      'nextDue': 'Sep 14, 2024',
      'vetName': 'Dr. Amanda Bell, DVM',
      'clinic': 'Metropolitan Veterinary Hospital',
      'batch': 'DEF-2023-RAB-9912',
      'status': 'Compliant',
      'statusColor': const Color(0xFF10B981),
      'icon': Icons.vaccines_rounded,
    },
    {
      'id': 'PET-REC-02',
      'title': 'DHPP 4-in-1 Comprehensive Vaccine',
      'category': 'Vaccines',
      'date': 'Sep 14, 2023',
      'nextDue': 'Sep 14, 2024',
      'vetName': 'Dr. Amanda Bell, DVM',
      'clinic': 'Metropolitan Veterinary Hospital',
      'batch': 'ZOE-2023-DHPP-441',
      'status': 'Compliant',
      'statusColor': const Color(0xFF10B981),
      'icon': Icons.shield_rounded,
    },
    {
      'id': 'PET-REC-03',
      'title': 'Dental Scaling & Oral Health Exam',
      'category': 'Vet Visits',
      'date': 'Jun 20, 2023',
      'nextDue': 'Jun 2024',
      'vetName': 'Dr. Kevin Miller, DVM',
      'clinic': 'All Pets Animal Wellness',
      'batch': 'EXAM-6610-DENT',
      'status': 'Completed',
      'statusColor': const Color(0xFF0284C7),
      'icon': Icons.medical_services_rounded,
    },
    {
      'id': 'PET-REC-04',
      'title': 'Bordetella Bronchiseptica Oral',
      'category': 'Vaccines',
      'date': 'Jan 10, 2023',
      'nextDue': 'Jan 2024',
      'vetName': 'Dr. Amanda Bell, DVM',
      'clinic': 'Metropolitan Veterinary Hospital',
      'batch': 'BOR-2023-ORAL',
      'status': 'Renew Soon',
      'statusColor': const Color(0xFFF59E0B),
      'icon': Icons.vaccines_rounded,
    },
    {
      'id': 'PET-REC-05',
      'title': 'Heartworm & Flea/Tick Prevention',
      'category': 'Medications',
      'date': 'Oct 01, 2023',
      'nextDue': 'Nov 01, 2023',
      'vetName': 'Dr. Amanda Bell, DVM',
      'clinic': 'Metropolitan Veterinary Hospital',
      'batch': 'RX-HEARTGARD-PLUS',
      'status': 'Active Rx',
      'statusColor': const Color(0xFF7C3AED),
      'icon': Icons.medication_liquid_rounded,
    },
  ];

  bool get _isEn => widget.language == 'en';

  List<Map<String, dynamic>> get _filteredRecords {
    final query = _searchController.text.toLowerCase().trim();
    return _allPetRecords.where((r) {
      final matchesCategory = _selectedCategoryIndex == 0 ||
          r['category'] == _categories[_selectedCategoryIndex];
      final matchesQuery = query.isEmpty ||
          r['title'].toString().toLowerCase().contains(query) ||
          r['vetName'].toString().toLowerCase().contains(query) ||
          r['clinic'].toString().toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context),
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B14B8)),
                minHeight: 2,
              ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPetProfileCard(),
                    const SizedBox(height: 14),
                    _buildSecuritySyncStrip(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _buildCategoryPills(),
                    const SizedBox(height: 16),
                    _buildTimelineHeader(),
                    const SizedBox(height: 12),
                    _buildTimelineList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  // 1. Top App Bar
  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7ECF6), width: 1)),
        boxShadow: [
          BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF28006D)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 4),
              Text(
                _isEn ? 'Pet Care Records' : 'Registros de Mascotas',
                style: const TextStyle(
                  fontSize: 19,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF28006D),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CareIdLogo.horizontal(height: 18),
              const SizedBox(width: 10),
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

  // 2. Pet Health Passport Profile Banner Card
  Widget _buildPetProfileCard() {
    final pet = _pets.isNotEmpty ? _pets.first : null;
    final petName = pet?.name ?? 'Max';
    final petSpecies = pet != null ? '${pet.species} • ${pet.gender ?? "Male"}' : 'Canine • Male';
    final petBreed = pet?.breed != null ? '${pet!.breed} • ${pet.age != null ? "${pet.age!.toInt()} Years Old" : "3 Years Old"}' : 'Golden Retriever • 3 Years Old';
    final chipNumber = pet?.microchipId != null ? 'Microchip #${pet!.microchipId}' : 'Microchip #985141002345678';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E1065), Color(0xFF4C1D95), Color(0xFF6B21A8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x182E1065), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Subtle Paw Watermark
          const Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.pets_rounded, size: 160, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Pet Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(color: const Color(0xFF56F5F8), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.pets_rounded, size: 32, color: Color(0xFF56F5F8)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                petName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF56F5F8).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF56F5F8)),
                                ),
                                child: Text(
                                  petSpecies,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF56F5F8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            petBreed,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Plus Jakarta Sans',
                              color: Color(0xFFE9D5FF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chipNumber,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _PetStatItem(title: 'WEIGHT', value: '68 lbs'),
                      _PetStatDivider(),
                      _PetStatItem(title: 'RABIES EXP', value: 'Sep 2024'),
                      _PetStatDivider(),
                      _PetStatItem(title: 'CARE ID', value: 'PET-9942'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Security & Sync Strip
  Widget _buildSecuritySyncStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.sync_rounded, size: 18, color: Color(0xFF15803D)),
              SizedBox(width: 8),
              Text(
                'Synced with VCA Animal Hospital',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF15803D),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Up to Date',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
        decoration: InputDecoration(
          hintText: _isEn ? 'Search vaccines, clinics, tests...' : 'Buscar vacunas, clínicas...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF5B14B8), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  // 5. Category Pills
  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedCategoryIndex = index);
              },
              selectedColor: const Color(0xFF5B14B8),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 6. Timeline Header
  Widget _buildTimelineHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Health History & Immunizations',
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            color: Color(0xFF28006D),
          ),
        ),
        Text(
          '${_filteredRecords.length} records',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  // 7. Timeline List
  Widget _buildTimelineList() {
    if (_filteredRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.pets_outlined, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            Text(
              _isEn ? 'No pet records found' : 'No se encontraron registros',
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _filteredRecords.map((r) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7ECF6)),
            boxShadow: const [
              BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PetRecordDetailScreen(
                      recordData: r,
                      patientInitials: widget.patientInitials,
                      language: widget.language,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(r['icon'] as IconData, color: const Color(0xFF7C3AED), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['title'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${r['clinic']} • ${r['vetName']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (r['statusColor'] as Color).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            r['status'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              color: r['statusColor'] as Color,
                            ),
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
                        Row(
                          children: [
                            const Icon(Icons.event_available_rounded, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(
                              'Administered: ${r['date']}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Next Due: ',
                              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                            Text(
                              r['nextDue'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF5B14B8)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 8. Bottom Action Bar
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7ECF6))),
      ),
      child: SafeArea(
        child: PrimaryButton(
          label: _isEn ? 'Add Pet Health Record' : 'Agregar Registro de Mascota',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AddHealthRecordScreen(
                  initialCategory: 'PETS',
                ),
              ),
            );
          },
          leadingIcon: Icons.add_rounded,
        ),
      ),
    );
  }
}

class _PetStatItem extends StatelessWidget {
  final String title;
  final String value;

  const _PetStatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            color: Color(0xFFCBD5E1),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _PetStatDivider extends StatelessWidget {
  const _PetStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
