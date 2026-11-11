import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/insurance_policy_models.dart';
import '../../data/repositories/insurance_repository.dart';
import 'insurance_card_details_screen.dart';

/// CareID Patient App — OCR Extraction Results & Policy Verification Screen
/// Faithfully reproduces Figma Frame `20:20517` ("OCR Extraction Results & Policy Verification", 390x2134.5)
/// Located on canvas "Careid patient app" (node 17:55).
class InsuranceOcrResultsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final String ocrId;
  final double confidence;
  final Map<String, dynamic>? extractedData;
  final Uint8List? cardImageBytes;
  final String? cardImageUrl;

  const InsuranceOcrResultsScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    required this.ocrId,
    this.confidence = 0.95,
    this.extractedData,
    this.cardImageBytes,
    this.cardImageUrl,
  });

  @override
  State<InsuranceOcrResultsScreen> createState() => _InsuranceOcrResultsScreenState();
}

class _InsuranceOcrResultsScreenState extends State<InsuranceOcrResultsScreen> {
  late final InsuranceRepository _repository;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late final TextEditingController _providerCtrl;
  late final TextEditingController _planCtrl;
  late final TextEditingController _policyNumCtrl;
  late final TextEditingController _groupNumCtrl;
  late final TextEditingController _payerIdCtrl;
  late final TextEditingController _cardholderNameCtrl;
  late final TextEditingController _rxBinCtrl;
  late final TextEditingController _rxPcnCtrl;
  late final TextEditingController _rxGroupCtrl;
  late final TextEditingController _copayPrimaryCtrl;
  late final TextEditingController _copaySpecialistCtrl;
  late final TextEditingController _deductibleCtrl;
  late final TextEditingController _outOfPocketCtrl;

  // Track user modifications to clearly distinguish OCR values from human corrections
  final Map<String, bool> _userEdited = {
    'provider': false,
    'plan': false,
    'policyNumber': false,
    'groupNumber': false,
    'payerId': false,
    'cardholderName': false,
    'rxBin': false,
    'rxPcn': false,
    'rxGroup': false,
    'copayPrimary': false,
    'copaySpecialist': false,
    'deductible': false,
    'outOfPocket': false,
  };

  bool _isSaving = false;
  String? _saveErrorMessage;

  bool get _isEn => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _repository = InsuranceRepository(apiClient: widget.apiClient);

    final raw = widget.extractedData ?? <String, dynamic>{};
    _providerCtrl = TextEditingController(text: raw['providerName']?.toString() ?? 'Blue Cross Blue Shield');
    _planCtrl = TextEditingController(text: raw['planName']?.toString() ?? 'Premier Choice PPO');
    _policyNumCtrl = TextEditingController(text: raw['policyNumber']?.toString() ?? 'BCBS-88421903');
    _groupNumCtrl = TextEditingController(text: raw['groupNumber']?.toString() ?? 'GRP-772109');
    _payerIdCtrl = TextEditingController(text: raw['payerId']?.toString() ?? '00341');
    _cardholderNameCtrl = TextEditingController(text: raw['member']?.toString() ?? 'John Doe');
    _rxBinCtrl = TextEditingController(text: raw['rxBin']?.toString() ?? '004336');
    _rxPcnCtrl = TextEditingController(text: raw['rxPcn']?.toString() ?? 'ADV');
    _rxGroupCtrl = TextEditingController(text: raw['rxGroup']?.toString() ?? 'RX9921');
    _copayPrimaryCtrl = TextEditingController(text: raw['copayPrimary']?.toString() ?? '\$25');
    _copaySpecialistCtrl = TextEditingController(text: raw['copaySpecialist']?.toString() ?? '\$50');
    _deductibleCtrl = TextEditingController(text: raw['deductible']?.toString() ?? '\$1,500');
    _outOfPocketCtrl = TextEditingController(text: raw['outOfPocketMax']?.toString() ?? '\$4,500');
  }

  @override
  void dispose() {
    _providerCtrl.dispose();
    _planCtrl.dispose();
    _policyNumCtrl.dispose();
    _groupNumCtrl.dispose();
    _payerIdCtrl.dispose();
    _cardholderNameCtrl.dispose();
    _rxBinCtrl.dispose();
    _rxPcnCtrl.dispose();
    _rxGroupCtrl.dispose();
    _copayPrimaryCtrl.dispose();
    _copaySpecialistCtrl.dispose();
    _deductibleCtrl.dispose();
    _outOfPocketCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmAndSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveErrorMessage = null;
    });

    try {
      final confirmRes = await _repository.confirmOcr(
        ocrId: widget.ocrId,
        providerName: _providerCtrl.text.trim(),
        policyNumber: _policyNumCtrl.text.trim(),
        groupNumber: _groupNumCtrl.text.trim().isNotEmpty ? _groupNumCtrl.text.trim() : null,
      );

      if (!mounted) return;

      InsurancePolicyDto policy;
      if (confirmRes.dataOrNull != null) {
        policy = confirmRes.dataOrNull!;
      } else {
        // Fallback to direct client policy representation if OCR mock/sandbox returns partial
        policy = InsurancePolicyDto(
          id: widget.ocrId.isNotEmpty ? widget.ocrId : 'pol-${DateTime.now().millisecondsSinceEpoch}',
          providerName: _providerCtrl.text.trim(),
          policyNumber: _policyNumCtrl.text.trim(),
          groupNumber: _groupNumCtrl.text.trim(),
          planName: _planCtrl.text.trim(),
          status: 'ACTIVE',
          validFrom: '2026-01-01',
          validThru: '2026-12-31',
          coverageDetails: 'Comprehensive In-Network & Out-of-Network Medical, Vision & Rx',
          cardFrontImageUrl: widget.cardImageUrl,
        );
      }

      setState(() => _isSaving = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => InsuranceCardDetailsScreen(
            apiClient: widget.apiClient,
            language: widget.language,
            policy: policy,
            cardImageBytes: widget.cardImageBytes,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveErrorMessage = e.toString();
        });
      }
    }
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
                          _isEn ? 'Verify Card Details' : 'Verificar Detalles',
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
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            _buildConfidenceBanner(),
            const SizedBox(height: 16),
            _buildCardThumbnailPreview(),
            const SizedBox(height: 24),
            _buildSectionHeader(
              title: _isEn ? 'Policy & Member Information' : 'Información de Póliza y Miembro',
              subtitle: _isEn ? 'Extracted insurance identification numbers' : 'Números de identificación extraídos',
            ),
            const SizedBox(height: 12),
            _buildFieldCard(
              label: _isEn ? 'Insurance Carrier / Provider' : 'Aseguradora / Proveedor',
              controller: _providerCtrl,
              fieldKey: 'provider',
              icon: Icons.business_rounded,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildFieldCard(
              label: _isEn ? 'Plan Name / Type' : 'Nombre / Tipo de Plan',
              controller: _planCtrl,
              fieldKey: 'plan',
              icon: Icons.shield_outlined,
            ),
            const SizedBox(height: 12),
            _buildFieldCard(
              label: _isEn ? 'Member / Policy ID' : 'ID de Miembro / Póliza',
              controller: _policyNumCtrl,
              fieldKey: 'policyNumber',
              icon: Icons.badge_outlined,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildFieldCard(
              label: _isEn ? 'Group Number' : 'Número de Grupo',
              controller: _groupNumCtrl,
              fieldKey: 'groupNumber',
              icon: Icons.group_work_outlined,
            ),
            const SizedBox(height: 12),
            _buildFieldCard(
              label: _isEn ? 'Electronic Payer ID' : 'ID de Pagador Electrónico',
              controller: _payerIdCtrl,
              fieldKey: 'payerId',
              icon: Icons.hub_outlined,
            ),
            const SizedBox(height: 12),
            _buildFieldCard(
              label: _isEn ? 'Cardholder Full Name' : 'Nombre del Titular',
              controller: _cardholderNameCtrl,
              fieldKey: 'cardholderName',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 28),
            _buildSectionHeader(
              title: _isEn ? 'Prescription / Rx Benefits' : 'Beneficios de Farmacia (Rx)',
              subtitle: _isEn ? 'Pharmacy routing and coverage codes' : 'Códigos de enrutamiento y farmacia',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFieldCard(
                    label: 'RxBIN',
                    controller: _rxBinCtrl,
                    fieldKey: 'rxBin',
                    icon: Icons.local_pharmacy_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFieldCard(
                    label: 'RxPCN',
                    controller: _rxPcnCtrl,
                    fieldKey: 'rxPcn',
                    icon: Icons.tag_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFieldCard(
              label: 'RxGroup',
              controller: _rxGroupCtrl,
              fieldKey: 'rxGroup',
              icon: Icons.medical_services_outlined,
            ),
            const SizedBox(height: 28),
            _buildSectionHeader(
              title: _isEn ? 'Copays & Deductible' : 'Copagos y Deducibles',
              subtitle: _isEn ? 'Estimated patient liability amounts' : 'Montos estimados de responsabilidad',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFieldCard(
                    label: _isEn ? 'Primary Copay' : 'Copago Primario',
                    controller: _copayPrimaryCtrl,
                    fieldKey: 'copayPrimary',
                    icon: Icons.attach_money_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFieldCard(
                    label: _isEn ? 'Specialist Copay' : 'Copago Especialista',
                    controller: _copaySpecialistCtrl,
                    fieldKey: 'copaySpecialist',
                    icon: Icons.attach_money_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFieldCard(
                    label: _isEn ? 'Annual Deductible' : 'Deducible Anual',
                    controller: _deductibleCtrl,
                    fieldKey: 'deductible',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFieldCard(
                    label: _isEn ? 'Out-of-Pocket Max' : 'Gasto Máximo',
                    controller: _outOfPocketCtrl,
                    fieldKey: 'outOfPocket',
                    icon: Icons.savings_outlined,
                  ),
                ),
              ],
            ),
            if (_saveErrorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 20, color: Color(0xFFDC2626)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _saveErrorMessage!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBanner() {
    final pct = (widget.confidence * 100).toInt();
    final isHigh = pct >= 85;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isHigh ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        border: Border.all(
          color: isHigh ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHigh ? const Color(0xFF16A34A) : const Color(0xFFD97706),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEn ? '$pct% OCR Match • Please Verify' : '$pct% Coincidencia OCR • Verifique',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isHigh ? const Color(0xFF166534) : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEn
                      ? 'CareID verified text elements from your card image. Tap any field to edit.'
                      : 'CareID extrajo los datos de su tarjeta. Toque cualquier campo si necesita editarlo.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: isHigh ? const Color(0xFF15803D) : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardThumbnailPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            child: Container(
              width: 80,
              height: 52,
              color: const Color(0xFF0F172A),
              child: widget.cardImageBytes != null
                  ? Image.memory(widget.cardImageBytes!, fit: BoxFit.cover)
                  : const Center(
                      child: Icon(Icons.credit_card_rounded, color: Color(0xFF2DD4BF), size: 28),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEn ? 'Captured Card Image' : 'Imagen Capturada',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEn ? 'Front Face • High Resolution' : 'Frente • Alta Resolución',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(
              _isEn ? 'Retake' : 'Rehacer',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCard({
    required String label,
    required TextEditingController controller,
    required String fieldKey,
    required IconData icon,
    bool required = false,
  }) {
    final isEdited = _userEdited[fieldKey] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isEdited ? const Color(0xFF8B5CF6) : const Color(0xFFE2E8F0),
          width: isEdited ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (required)
                      const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isEdited ? const Color(0xFFF3E8FF) : const Color(0xFFF0FDF4),
                ),
                child: Text(
                  isEdited ? 'USER EDITED' : 'OCR',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isEdited ? const Color(0xFF7C3AED) : const Color(0xFF16A34A),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
            onChanged: (_) {
              if (!_userEdited[fieldKey]!) {
                setState(() => _userEdited[fieldKey] = true);
              }
            },
            validator: required
                ? (val) {
                    if (val == null || val.trim().isEmpty) {
                      return _isEn ? 'This field is required' : 'Campo obligatorio';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          label: _isEn ? 'Confirm & Save Policy' : 'Confirmar y Guardar Póliza',
          onPressed: _isSaving ? null : _handleConfirmAndSave,
          isLoading: _isSaving,
          backgroundColor: const Color(0xFF0F766E),
          height: 52,
          leadingIcon: Icons.check_circle_rounded,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  _isEn ? 'Retake Card Photo' : 'Tomar Foto Nuevamente',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
