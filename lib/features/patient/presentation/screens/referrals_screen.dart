import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/referral_models.dart';
import '../../data/repositories/referral_repository.dart';

/// CareID Patient App — Clinical Referrals & Care Coordination Screen
/// Connects directly to Postman Folder `11. Referrals & Care Coordination` (`/api/v1/referrals`)
class ReferralsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;

  const ReferralsScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
  });

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  late final ReferralRepository _repository;
  List<ReferralDto> _referrals = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL'; // 'ALL', 'IN_PROGRESS', 'COMPLETED'
  int _navIndex = 2; // Doctor tab

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _repository = ReferralRepository(apiClient: widget.apiClient);
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    setState(() => _isLoading = true);
    final res = await _repository.getReferrals();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _referrals = res.dataOrNull ?? [];
    });
  }

  List<ReferralDto> get _filteredReferrals {
    if (_selectedFilter == 'ALL') return _referrals;
    if (_selectedFilter == 'IN_PROGRESS') {
      return _referrals.where((r) => r.status == ReferralStatus.inProgress || r.status == ReferralStatus.triaged).toList();
    }
    if (_selectedFilter == 'COMPLETED') {
      return _referrals.where((r) => r.status == ReferralStatus.completed).toList();
    }
    return _referrals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          height: 64,
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CareIdLogo.horizontal(height: 18),
                    Text(
                      _isEn ? 'Clinical Referrals & Coordination' : 'Referencias y Coordinación Clínica',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF64748B)),
                  onPressed: _loadReferrals,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B14B8)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B14B8), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B14B8).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.hub_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEn ? 'Active Care Referrals' : 'Referencias Activas',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isEn
                                  ? 'Authorized transfers, specialist consultations, and diagnostic reviews'
                                  : 'Transferencias autorizadas, consultas de especialistas y revisiones',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', _isEn ? 'All Referrals' : 'Todas'),
                      const SizedBox(width: 8),
                      _buildFilterChip('IN_PROGRESS', _isEn ? 'In Progress' : 'En Progreso'),
                      const SizedBox(width: 8),
                      _buildFilterChip('COMPLETED', _isEn ? 'Completed' : 'Completadas'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Referrals List
                if (_filteredReferrals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.assignment_turned_in_rounded, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          _isEn ? 'No care referrals found' : 'No se encontraron referencias',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._filteredReferrals.map((r) => _buildReferralCard(r)),
              ],
            ),
      bottomNavigationBar: CareIdBottomNavigationBar(
        currentIndex: _navIndex,
        doctorLabel: 'Doctor',
        onTabSelected: (int index) {
          setState(() => _navIndex = index);
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('/records');
          } else if (index == 3) {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        },
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B14B8) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B14B8) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralCard(ReferralDto referral) {
    final isUrgent = referral.priority == ReferralPriority.urgent || referral.priority == ReferralPriority.stat;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: isUrgent ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Doctor & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referral.receivingDoctorName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      referral.specialty,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5B14B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUrgent ? const Color(0xFFFCA5A5) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Text(
                  referral.status.name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Facility
          Row(
            children: [
              const Icon(Icons.apartment_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  referral.receivingFacilityName,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Reason & Clinical Summary
          Text(
            referral.reasonForReferral,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            referral.clinicalSummary,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text(
                    _isEn ? 'CareID Encrypted Referral' : 'Referencia Encriptada',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              Text(
                referral.createdAt != null
                    ? referral.createdAt!.split('T')[0]
                    : 'Recent',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
