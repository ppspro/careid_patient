import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/careid_logo.dart';
import 'insurance_ocr_processing_screen.dart';

/// CareID Patient App — Insurance Card Camera Capture Screen
/// Faithfully reproduces Figma Frame `20:20258` ("Insurance Card - Camera Capture", 390x905)
/// Located on canvas "Careid patient app" (node 17:55).
class InsuranceCardCameraScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final bool openGalleryDirectly;

  const InsuranceCardCameraScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.openGalleryDirectly = false,
  });

  @override
  State<InsuranceCardCameraScreen> createState() => _InsuranceCardCameraScreenState();
}

class _InsuranceCardCameraScreenState extends State<InsuranceCardCameraScreen> {
  final _imagePicker = ImagePicker();
  bool _isFlashOn = false;
  String _selectedSide = 'FRONT'; // 'FRONT' or 'BACK'
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    if (widget.openGalleryDirectly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage(ImageSource.gallery);
      });
    }
  }

  bool get _isEn => widget.language == 'en';

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isCapturing = true);

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        final mimeType = pickedFile.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
        final dataUri = 'data:$mimeType;base64,$base64Image';

        _proceedToOcr(dataUri: dataUri, imageBytes: bytes);
      } else {
        setState(() => _isCapturing = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEn ? 'Could not access camera/gallery.' : 'No se pudo acceder a la cámara o galería.'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _proceedToOcr({required String dataUri, Uint8List? imageBytes}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => InsuranceOcrProcessingScreen(
          apiClient: widget.apiClient,
          language: widget.language,
          cardImageUrl: dataUri,
          cardImageBytes: imageBytes,
          cardSide: _selectedSide,
        ),
      ),
    );
  }

  void _simulateCaptureForTesting() {
    // Generates a mock lightweight data URI for test environments
    const mockUri = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD...';
    _proceedToOcr(dataUri: mockUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
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
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isEn ? 'Scan Card' : 'Escanear Tarjeta',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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
      body: Stack(
        children: [
          // 1. Live Camera Viewport Canvas
          Positioned.fill(
            child: Container(
              color: const Color(0xFF020617),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Side selector: Front / Back
                  _buildSideSelector(),
                  const Spacer(),
                  // Edge Detection Guide Cutout
                  _buildCardCutoutGuide(),
                  const SizedBox(height: 16),
                  // Floating Tip Text
                  _buildFloatingTip(),
                  const Spacer(),
                  // Bottom Controls Bar
                  _buildBottomControls(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          if (_isCapturing)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F766E)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSideSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSideOption('FRONT', _isEn ? 'Card Front' : 'Frente'),
          _buildSideOption('BACK', _isEn ? 'Card Back' : 'Dorso'),
        ],
      ),
    );
  }

  Widget _buildSideOption(String key, String label) {
    final isSelected = _selectedSide == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedSide = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildCardCutoutGuide() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 32.0).clamp(260.0, 328.0);
        final cardHeight = cardWidth * (215.0 / 340.0);
        return Center(
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0F766E).withValues(alpha: 0.6), width: 1.5),
            ),
            child: Stack(
          children: [
            // 4 Corner Brackets
            _buildCornerBracket(top: -2, left: -2, isTop: true, isLeft: true),
            _buildCornerBracket(top: -2, right: -2, isTop: true, isLeft: false),
            _buildCornerBracket(bottom: -2, left: -2, isTop: false, isLeft: true),
            _buildCornerBracket(bottom: -2, right: -2, isTop: false, isLeft: false),

            // Card watermark placeholder
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.credit_card_rounded,
                    size: 44,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedSide == 'FRONT' ? 'CARD FRONT' : 'CARD BACK',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildCornerBracket({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    const size = 26.0;
    const thickness = 3.5;
    const color = Color(0xFF0F766E);

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
            left: isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(16) : Radius.zero,
            topRight: isTop && !isLeft ? const Radius.circular(16) : Radius.zero,
            bottomLeft: !isTop && isLeft ? const Radius.circular(16) : Radius.zero,
            bottomRight: !isTop && !isLeft ? const Radius.circular(16) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingTip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF38BDF8)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _isEn ? 'Align card within the guide brackets' : 'Alinea la tarjeta dentro del marco',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flashlight Toggle
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isFlashOn ? const Color(0xFFFACC15) : Colors.white70,
              size: 26,
            ),
            onPressed: () {
              setState(() => _isFlashOn = !_isFlashOn);
            },
          ),

          // Primary Shutter Button (74x74)
          GestureDetector(
            onTap: () {
              // Real device camera capture
              _pickImage(ImageSource.camera);
            },
            onLongPress: () {
              // Fallback simulator trigger for automated tests
              _simulateCaptureForTesting();
            },
            child: Container(
              width: 74,
              height: 74,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0F766E), width: 3),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt_rounded, size: 30, color: Color(0xFF0F172A)),
                ),
              ),
            ),
          ),

          // Gallery Pick Button
          IconButton(
            icon: const Icon(Icons.photo_library_rounded, color: Colors.white70, size: 26),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

