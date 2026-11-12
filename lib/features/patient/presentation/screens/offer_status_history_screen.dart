import '../../data/repositories/financing_repository.dart';
import '../../data/repositories/treatment_offer_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';

import '../../data/models/insurance_domain_models.dart';
import '../widgets/insurance_assets.dart';

/// Screen 77: Care ID - Offer Status & History (`20:27768`)
class OfferStatusHistoryScreen extends StatefulWidget {
  const OfferStatusHistoryScreen({super.key});

  @override
  State<OfferStatusHistoryScreen> createState() => _OfferStatusHistoryScreenState();
}

class _OfferStatusHistoryScreenState extends State<OfferStatusHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All Statuses';
  String _searchQuery = '';
  bool _isDemoMode = false;
  List<HistoricalOfferItem> _liveOffers = [];
  bool _isLoading = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLiveHistory();
  }

  Future<void> _loadLiveHistory() async {
    setState(() => _isLoading = true);
    final liveItems = <HistoricalOfferItem>[];
    try {
      final treatmentRes = await TreatmentOfferRepository().getTreatmentOffers();
      if (treatmentRes.isSuccess && treatmentRes.dataOrNull != null) {
        for (final offer in treatmentRes.dataOrNull!) {
          liveItems.add(
            HistoricalOfferItem(
              id: offer.id,
              title: offer.clinicalIndication.isNotEmpty ? offer.clinicalIndication : 'Treatment Plan (${offer.offerNumber})',
              clinic: offer.facilityName ?? 'CareID Network Facility',
              category: offer.procedures.isNotEmpty ? offer.procedures.first.category.toLowerCase() : 'medical',
              status: offer.status.toLowerCase() == 'accepted' ? 'Accepted' : (offer.status.toLowerCase() == 'rejected' ? 'Declined' : 'Pending'),
              date: offer.validUntil.isNotEmpty ? offer.validUntil.split('T')[0] : 'Active',
              referenceCode: offer.offerNumber,
              amount: offer.netPayableCost > 0 ? offer.netPayableCost : offer.totalProceduresCost,
              savedAmount: offer.discountAmount,
              amountLabel: 'Net Payable',
            ),
          );
        }
      }
    } catch (_) {}

    try {
      final finRes = await FinancingRepository().getFinancingApplications();
      if (finRes.isSuccess && finRes.dataOrNull != null) {
        for (final app in finRes.dataOrNull!) {
          final statusStr = app['status']?.toString() ?? 'SUBMITTED';
          liveItems.add(
            HistoricalOfferItem(
              id: app['id']?.toString() ?? '',
              title: 'Healthcare Financing (${app['applicationNumber'] ?? 'APP'})',
              clinic: 'CareFinance Partner',
              category: 'financing',
              status: (statusStr == 'APPROVED' || statusStr == 'ACCEPTED') ? 'Accepted' : (statusStr == 'REJECTED' ? 'Declined' : 'In Review'),
              date: (app['createdAt']?.toString().split('T')[0]) ?? 'Recent',
              referenceCode: app['applicationNumber']?.toString() ?? '#FIN-APP',
              amount: (app['requestedAmount'] is num) ? (app['requestedAmount'] as num).toDouble() : 0.0,
              savedAmount: 0.0,
              amountLabel: 'Requested Amount',
            ),
          );
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _liveOffers = liveItems;
        _isLoading = false;
        _hasLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOffers = _liveOffers;

    final filteredOffers = allOffers.where((offer) {
      // Filter chip matching
      if (_selectedFilter != 'All Statuses') {
        if (_selectedFilter.toLowerCase() == 'completed') {
          if (offer.status.toLowerCase() != 'completed') return false;
        } else if (offer.status.toLowerCase() != _selectedFilter.toLowerCase()) {
          return false;
        }
      }

      // Search query matching
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = offer.title.toLowerCase().contains(query);
        final matchClinic = offer.clinic.toLowerCase().contains(query);
        final matchRef = offer.referenceCode.toLowerCase().contains(query);
        if (!matchTitle && !matchClinic && !matchRef) {
          return false;
        }
      }

      return true;
    }).toList();

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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: LinearProgressIndicator(minHeight: 2, color: Color(0xFF6B46C1)),
                      ),
                    _buildTopActionRow(context),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildSummaryStatsRow(allOffers),
                    const SizedBox(height: 16),
                    _buildFilterChipsRow(),
                    const SizedBox(height: 16),
                    _buildOffersList(filteredOffers),
                    const SizedBox(height: 16),
                    _buildSecurityNotice(),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF).withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF28006D).withOpacity(0.06),
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
                    Navigator.of(context).pushReplacementNamed('/insurance-financing-hub');
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
                'Offer History',
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

          // Right: Notification Bell + Profile Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF28006D)), onPressed: () => Navigator.of(context).pushNamed('/notification-center')),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(2),
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
                              color: Color(0xFF28006D),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
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

  Widget _buildTopActionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offer History',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.6,
                color: const Color(0xFF28006D),
              ),
            ),
            Text(
              'Care ID Estimates &\nPlans',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.25,
                color: const Color(0xFF494552),
              ),
            ),
          ],
        ),

        // Quick Demo Interactive Toggle
        GestureDetector(
          onTap: () {
            setState(() {
              _isDemoMode = !_isDemoMode;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isDemoMode
                      ? 'Demo mode enabled: showing all audit records'
                      : 'Demo mode disabled: standard timeline view',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                backgroundColor: const Color(0xFF006E70),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _isDemoMode ? const Color(0xFF28006D) : const Color(0xFF56F5F8),
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: _isDemoMode ? Colors.white : const Color(0xFF006E70),
                ),
                const SizedBox(width: 6),
                Text(
                  'Demo\nToggle',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    color: _isDemoMode ? Colors.white : const Color(0xFF006E70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0B1C30),
        ),
        decoration: InputDecoration(
          hintText: 'Search treatment, clinic, or reference...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF7A7583),
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: Color(0xFF7A7583),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF7A7583)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSummaryStatsRow(List<HistoricalOfferItem> allOffers) {
    final total = allOffers.length;
    final accepted = allOffers.where((o) => o.status.toLowerCase() == 'accepted').length;
    final declined = allOffers.where((o) => o.status.toLowerCase() == 'declined').length;
    final expired = allOffers.where((o) => o.status.toLowerCase() == 'expired').length;

    return Row(
      children: [
        _buildStatCard(
          title: 'Total',
          count: total.toString(),
          color: const Color(0xFF28006D),
          onTap: () {
            setState(() {
              _selectedFilter = 'All Statuses';
            });
          },
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          title: 'Accepted',
          count: accepted.toString(),
          color: const Color(0xFF00696B),
          onTap: () {
            setState(() {
              _selectedFilter = 'Accepted';
            });
          },
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          title: 'Declined',
          count: declined.toString(),
          color: const Color(0xFF7A7583),
          onTap: () {
            setState(() {
              _selectedFilter = 'Declined';
            });
          },
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          title: 'Expired',
          count: expired.toString(),
          color: const Color(0xFFBA1A1A),
          onTap: () {
            setState(() {
              _selectedFilter = 'Expired';
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isCurrent = (_selectedFilter == title) ||
        (title == 'Total' && _selectedFilter == 'All Statuses');

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE5EEFF),
            borderRadius: BorderRadius.circular(12),
            border: isCurrent
                ? Border.all(color: const Color(0xFF28006D), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                count,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF494552),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    final chips = ['All Statuses', 'Accepted', 'Declined', 'Completed', 'Expired'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: chips.map((chip) {
          final isSelected = _selectedFilter.toLowerCase() == chip.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = chip;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF28006D) : Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  chip,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF494552),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOffersList(List<HistoricalOfferItem> offers) {
    if (!_hasLoaded && _isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: CircularProgressIndicator(color: Color(0xFF6B46C1)),
        ),
      );
    }
    if (offers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5EEFF)),
        ),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 40, color: Color(0xFF7A7583)),
            const SizedBox(height: 12),
            Text(
              'No Offer History Found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No offers matched your filter criteria or search query.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF494552),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: offers.map((offer) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildHistoricalOfferCard(offer),
        );
      }).toList(),
    );
  }

  Widget _buildHistoricalOfferCard(HistoricalOfferItem offer) {
    final isExpired = offer.status.toLowerCase() == 'expired';

    IconData getCategoryIcon(String cat) {
      switch (cat.toLowerCase()) {
        case 'vision':
          return Icons.remove_red_eye_outlined;
        case 'therapy':
          return Icons.accessibility_new_rounded;
        case 'dental':
        default:
          return Icons.medical_services_outlined;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/insurance-offer-details');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpired ? Colors.white.withOpacity(0.92) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon + Title/Clinic + Optional Expired pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      getCategoryIcon(offer.category),
                      color: const Color(0xFF28006D),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0B1C30),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        offer.clinic,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF494552),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE9FF),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 12, color: Color(0xFF7A7583)),
                        const SizedBox(width: 4),
                        Text(
                          'Expired',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7A7583),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Middle Box (Amount / Benefit / Status / Discount)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Amount Label + Value
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.amountLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF494552),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${offer.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isExpired
                              ? const Color(0xFF7A7583)
                              : (offer.status.toLowerCase() == 'declined'
                                  ? const Color(0xFF0B1C30)
                                  : const Color(0xFF28006D)),
                          decoration: isExpired ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),

                  // Right: Dynamic detail or status pill
                  if (offer.savedAmount != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Insurance Benefit',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00696B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Saved \$${offer.savedAmount!.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00696B),
                          ),
                        ),
                      ],
                    )
                  else if (offer.badgeText == 'Cash Discount')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF56F5F8).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Cash Discount',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF006E70),
                        ),
                      ),
                    )
                  else if (offer.badgeText != null)
                    Text(
                      offer.badgeText!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7A7583),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Footer Row: Date + Reference Code
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF494552),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      offer.date,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF494552),
                      ),
                    ),
                  ],
                ),
                Text(
                  offer.referenceCode.startsWith('Ref:')
                      ? offer.referenceCode
                      : 'Ref: ${offer.referenceCode}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7A7583),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.security_rounded,
                size: 16,
                color: Color(0xFF00696B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Healthcare ID Guarantee',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All past financial estimates comply with patient billing transparency standards.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    color: const Color(0xFF494552),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

