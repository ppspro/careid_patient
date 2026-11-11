import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_logo.dart';
import 'insurance_card_camera_screen.dart';

/// CareID Patient App — Add Insurance - Select Method Screen
/// Faithfully reproduces Figma Frame `20:20311` ("Add Insurance - Select Method", 390x1539)
/// Located on canvas "Careid patient app" (node 17:55).
class AddInsuranceSelectMethodScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;

  const AddInsuranceSelectMethodScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
  });

  @override
  State<AddInsuranceSelectMethodScreen> createState() => _AddInsuranceSelectMethodScreenState();
}

class _AddInsuranceSelectMethodScreenState extends State<AddInsuranceSelectMethodScreen> {
  late String _language;

  @override
  void initState() {
    super.initState();
    _language = widget.language;
  }

  bool get _isEn => _language == 'en';

  void _navigateToCameraCapture({bool openGalleryDirectly = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InsuranceCardCameraScreen(
          apiClient: widget.apiClient,
          language: _language,
          openGalleryDirectly: openGalleryDirectly,
        ),
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEn ? 'Add Insurance' : 'Agregar Seguro',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const CareIdLogo.horizontal(height: 18),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionalHeader(),
            const SizedBox(height: 28),
            _buildSelectionCardsBento(),
            const SizedBox(height: 28),
            _buildOcrFeaturesSection(),
            const SizedBox(height: 24),
            _buildSecurityFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionalHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.health_and_safety_rounded, size: 34, color: Color(0xFF0F766E)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isEn ? 'Add Insurance Card' : 'Agregar Tarjeta de Seguro',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _isEn
                  ? 'Choose how you would like to digitize and verify your health coverage into your CareID vault.'
                  : 'Elige cómo deseas digitalizar y verificar tu póliza médica en tu bóveda segura CareID.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCardsBento() {
    return Column(
      children: [
        // Option 1: Live Camera Scan
        _buildMethodCard(
          icon: Icons.camera_alt_rounded,
          iconBg: const Color(0xFF5B14B8).withValues(alpha: 0.1),
          iconColor: const Color(0xFF5B14B8),
          title: _isEn ? 'Live Camera Scan' : 'Escanear con Cámara',
          description: _isEn
              ? 'Point camera at your physical card for automatic edge detection & AI OCR reading.'
              : 'Apunta la cámara a tu tarjeta física para detección de bordes y lectura OCR inteligente.',
          actionLabel: _isEn ? 'Take Photo' : 'Tomar Foto',
          isRecommended: true,
          onTap: () => _navigateToCameraCapture(openGalleryDirectly: false),
        ),
        const SizedBox(height: 16),
        // Option 2: Gallery Upload
        _buildMethodCard(
          icon: Icons.photo_library_rounded,
          iconBg: const Color(0xFF0F766E).withValues(alpha: 0.1),
          iconColor: const Color(0xFF0F766E),
          title: _isEn ? 'Upload from Gallery' : 'Subir desde Galería',
          description: _isEn
              ? 'Select an existing photo or scan of your insurance card from your phone files.'
              : 'Selecciona una foto o imagen existente de tu tarjeta desde la galería de tu teléfono.',
          actionLabel: _isEn ? 'Choose Image' : 'Elegir Imagen',
          isRecommended: false,
          onTap: () => _navigateToCameraCapture(openGalleryDirectly: true),
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required String actionLabel,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRecommended ? const Color(0xFF5B14B8).withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
            width: isRecommended ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isRecommended
                  ? const Color(0xFF5B14B8).withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: iconColor),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B14B8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isEn ? 'RECOMMENDED' : 'RECOMENDADO',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  actionLabel,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16, color: iconColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOcrFeaturesSection() {
    final features = [
      {'title': 'Carrier & Payer ID', 'icon': Icons.business_rounded},
      {'title': 'Policy & Member ID', 'icon': Icons.badge_outlined},
      {'title': 'RxBIN, RxPCN, RxGroup', 'icon': Icons.medication_outlined},
      {'title': 'Copays & Deductible', 'icon': Icons.attach_money_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF0F766E), size: 20),
              const SizedBox(width: 8),
              Text(
                _isEn ? 'Automated OCR Extraction' : 'Extracción OCR Inteligente',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _isEn
                ? 'CareID reads structured card metadata with high precision:'
                : 'CareID extrae metadatos estructurados con alta precisión:',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features.map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(f['icon'] as IconData, size: 14, color: const Color(0xFF0F766E)),
                    const SizedBox(width: 6),
                    Text(
                      f['title'] as String,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF64748B)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            _isEn
                ? 'HIPAA Compliant • 256-bit Encrypted Ledger'
                : 'Cumplimiento HIPAA • Cifrado de 256 bits',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

