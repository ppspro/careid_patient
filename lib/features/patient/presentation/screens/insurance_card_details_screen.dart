import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/insurance_policy_models.dart';
import '../../data/repositories/insurance_repository.dart';
import 'insurance_qr_screen.dart';

/// CareID Patient App — Insurance Card Details Screen
/// Faithfully reproduces Figma Frame `20:20890` ("Insurance Card Details", 390x1384.75)
/// Located on canvas "Careid patient app" (node 17:55).
class InsuranceCardDetailsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final InsurancePolicyDto policy;
  final Uint8List? cardImageBytes;

  const InsuranceCardDetailsScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    required this.policy,
    this.cardImageBytes,
  });

  @override
  State<InsuranceCardDetailsScreen> createState() => _InsuranceCardDetailsScreenState();
}

class _InsuranceCardDetailsScreenState extends State<InsuranceCardDetailsScreen> {
  late final InsuranceRepository _repository;
  late InsurancePolicyDto _currentPolicy;
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _showMaskedId = true;

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _repository = InsuranceRepository(apiClient: widget.apiClient);
    _currentPolicy = widget.policy;
    _isVerified = _currentPolicy.status.toUpperCase() == 'ACTIVE' ||
        _currentPolicy.status.toUpperCase() == 'VERIFIED';
  }

  Future<void> _verifyCoverage() async {
    setState(() => _isVerifying = true);
    try {
      await _repository.verifyPolicy(_currentPolicy.id);
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
        _isVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEn
                      ? 'Policy coverage verified successfully with payer network.'
                      : 'Cobertura de póliza verificada con éxito con la red pagadora.',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEn ? 'Unable to verify coverage currently' : 'No se pudo verificar la cobertura'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _sharePass() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InsuranceQrScreen(
          policy: _currentPolicy,
          language: widget.language,
          apiClient: widget.apiClient,
        ),
      ),
    );
  }

  void _downloadPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEn ? 'Downloading policy verification document (PDF)...' : 'Descargando documento de póliza (PDF)...'),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isEn ? 'Insurance Card Details' : 'Detalles de Tarjeta',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const CareIdLogo.onlyId(height: 18),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        children: [
          _buildDigitalCardPreview(),
          const SizedBox(height: 20),
          _buildQuickActionsRow(),
          const SizedBox(height: 24),
          _buildPolicySummarySection(),
          const SizedBox(height: 20),
          _buildFinancialsSection(),
          const SizedBox(height: 20),
          _buildPrescriptionSection(),
          const SizedBox(height: 20),
          _buildContactSupportBanner(),
          const SizedBox(height: 28),
          _buildSecondaryActions(),
        ],
      ),
    );
  }

  Widget _buildDigitalCardPreview() {
    final policyNum = _currentPolicy.policyNumber.isNotEmpty
        ? _currentPolicy.policyNumber
        : 'BCBS-88421903';
    final maskedNum = policyNum.length > 4
        ? '•••• •••• •••• ${policyNum.substring(policyNum.length - 4)}'
        : policyNum;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Dark slate
            Color(0xFF1E293B),
            Color(0xFF0F766E), // Deep teal
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x250F766E),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient shapes
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2DD4BF).withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Carrier & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentPolicy.providerName.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentPolicy.planName ?? 'Comprehensive Health Plan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isVerified
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isVerified ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isVerified ? Icons.check_circle_rounded : Icons.pending_rounded,
                            size: 13,
                            color: _isVerified ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isVerified ? 'ACTIVE' : 'PENDING',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _isVerified ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Card Chip & Holographic Shield
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFD97706), width: 0.8),
                      ),
                      child: const Center(
                        child: Icon(Icons.nfc_rounded, size: 18, color: Color(0xFF92400E)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.health_and_safety_outlined, size: 28, color: Color(0xFF2DD4BF)),
                  ],
                ),
                const SizedBox(height: 20),

                // Policy Number & Toggle Mask
                Text(
                  _isEn ? 'MEMBER / POLICY NUMBER' : 'NÚMERO DE MIEMBRO',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showMaskedId ? maskedNum : policyNum,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showMaskedId ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _showMaskedId = !_showMaskedId),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom row: Group Number & Expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEn ? 'GROUP ID' : 'GRUPO',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentPolicy.groupNumber ?? 'GRP-772109',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _isEn ? 'VALID THRU' : 'VENCE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentPolicy.validThru ?? '12/2026',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.verified_user_outlined,
            label: _isEn ? 'Verify' : 'Verificar',
            color: const Color(0xFF0F766E),
            isLoading: _isVerifying,
            onTap: _verifyCoverage,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.ios_share_rounded,
            label: _isEn ? 'Share Pass' : 'Compartir',
            color: const Color(0xFF6366F1),
            onTap: _sharePass,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.picture_as_pdf_outlined,
            label: _isEn ? 'Download PDF' : 'Bajar PDF',
            color: const Color(0xFF0284C7),
            onTap: _downloadPdf,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.post_add_rounded,
            label: _isEn ? 'New Claim' : 'Reclamo',
            color: const Color(0xFF0F172A),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEn ? 'Opening Claim Submission form...' : 'Abriendo formulario de reclamos...'),
                  backgroundColor: const Color(0xFF0F172A),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: color),
                      )
                    : Icon(icon, color: color, size: 18),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySummarySection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 20, color: Color(0xFF0F766E)),
              const SizedBox(width: 8),
              Text(
                _isEn ? 'Coverage & Plan Summary' : 'Resumen de Plan y Cobertura',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(_isEn ? 'Insurance Network' : 'Red de Seguro', _currentPolicy.providerName),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(_isEn ? 'Plan Type' : 'Tipo de Plan', _currentPolicy.planName ?? 'PPO Comprehensive'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(_isEn ? 'Policy Number' : 'Número de Póliza', _currentPolicy.policyNumber),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(_isEn ? 'Group Number' : 'Número de Grupo', _currentPolicy.groupNumber ?? 'GRP-772109'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(_isEn ? 'Coverage Status' : 'Estado de Cobertura', _isVerified ? 'Active & Eligible' : 'Verification Needed'),
        ],
      ),
    );
  }

  Widget _buildFinancialsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 20, color: Color(0xFF0F766E)),
              const SizedBox(width: 8),
              Text(
                _isEn ? 'Copays & Deductibles' : 'Copagos y Deducibles',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFinancialBadge(
                  title: _isEn ? 'Primary Care' : 'Atención Primaria',
                  amount: '\$25',
                  subtitle: _isEn ? 'Per in-network visit' : 'Por visita en red',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFinancialBadge(
                  title: _isEn ? 'Specialist' : 'Especialista',
                  amount: '\$50',
                  subtitle: _isEn ? 'Per consultation' : 'Por consulta',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFinancialBadge(
                  title: _isEn ? 'Emergency Room' : 'Emergencias',
                  amount: '\$250',
                  subtitle: _isEn ? 'Waived if admitted' : 'Exonerado si ingresa',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFinancialBadge(
                  title: _isEn ? 'Annual Deductible' : 'Deducible Anual',
                  amount: '\$1,500',
                  subtitle: _isEn ? '\$3,000 Family max' : '\$3,000 Familiar',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialBadge({
    required String title,
    required String amount,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_outlined, size: 20, color: Color(0xFF0F766E)),
              const SizedBox(width: 8),
              Text(
                _isEn ? 'Prescription (Rx) Routing' : 'Enrutamiento de Farmacia (Rx)',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('RxBIN', '004336'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('RxPCN', 'ADV'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('RxGroup', 'RX9921'),
        ],
      ),
    );
  }

  Widget _buildContactSupportBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEn ? 'Need help with benefits or pre-auth?' : '¿Necesita ayuda con beneficios?',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEn ? 'Member Services: 1-800-555-0199' : 'Atención al Cliente: 1-800-555-0199',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF0F766E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F766E),
              side: const BorderSide(color: Color(0xFF0F766E)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              _isEn ? 'Done / Back to Policies' : 'Listo / Volver a Pólizas',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(_isEn ? 'Archive Policy' : 'Archivar Póliza'),
                content: Text(
                  _isEn
                      ? 'Are you sure you want to archive this insurance policy from your wallet?'
                      : '¿Está seguro de que desea archivar esta póliza de seguro?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(_isEn ? 'Cancel' : 'Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).maybePop();
                    },
                    child: Text(
                      _isEn ? 'Archive' : 'Archivar',
                      style: const TextStyle(color: Color(0xFFDC2626)),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Text(
            _isEn ? 'Archive or Remove Policy' : 'Archivar o Eliminar Póliza',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
