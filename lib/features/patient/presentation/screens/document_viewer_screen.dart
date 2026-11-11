import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/theme/app_colors.dart';

/// CareID Clinical Document & Report Viewer Screen
/// Faithfully reproduces Figma frame node 20:32097 / 20:32177 / 20:32816 ("Document Viewer", 390x936)
/// Located on canvas "Careid patient app" (node 17:55).
class DocumentViewerScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final String verifiedDate;
  final String doctorName;
  final String language;

  const DocumentViewerScreen({
    super.key,
    this.title = 'Dental X-Ray Report',
    this.fileName = 'X-Ray Report_042.pdf',
    this.verifiedDate = 'May 14, 2024',
    this.doctorName = 'Dr. Sarah Jenkins, MD',
    this.language = 'en',
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool get _isEn => widget.language == 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate viewer background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text.rich(
          TextSpan(
            text: '${widget.title}\n',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: widget.fileName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                  height: 1.2,
                ),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEn ? 'Preparing encrypted share link...' : 'Generando enlace cifrado...'),
                  backgroundColor: AppColors.purplePrimary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEn ? 'Document saved to local storage.' : 'Documento guardado localmente.'),
                  backgroundColor: AppColors.purplePrimary,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Security Protocol Verification Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF5EEAD4), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isEn
                          ? 'Verified by Care ID Security Protocol • ${widget.verifiedDate}'
                          : 'Verificado por Protocolo de Seguridad CareID • ${widget.verifiedDate}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5EEAD4), fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AES-256',
                      style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Interactive Document Viewport
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Report Document Header
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.health_and_safety_rounded, color: AppColors.purplePrimary, size: 28),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _isEn ? 'CAREID CLINICAL VAULT' : 'BÓVEDA CLÍNICA CAREID',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0, color: AppColors.purplePrimary),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'OFFICIAL RECORD',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Metadata Grid
                          Text(
                            widget.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_isEn ? "Physician" : "Médico"}: ${widget.doctorName} • ${_isEn ? "Date" : "Fecha"}: ${widget.verifiedDate}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),

                          const SizedBox(height: 20),

                          // Radiograph / High-Res Diagnostic Graphic Simulation
                          SizedBox(
                            height: 180,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            widget.title.toLowerCase().contains('dental')
                                                ? Icons.medical_information_rounded
                                                : (widget.title.toLowerCase().contains('vision')
                                                    ? Icons.remove_red_eye_rounded
                                                    : Icons.monitor_heart_rounded),
                                            size: 56,
                                            color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _isEn ? 'High-Resolution Diagnostic Render' : 'Visualización Diagnóstica en Alta Resolución',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'DICOM / PDF Composite • Standard Resolution 2048 x 1536',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'CareID Verifiable Seal ✓',
                                        style: TextStyle(color: Color(0xFF5EEAD4), fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Cryptographic Hash & Verification Stamp
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isEn ? 'IMMUTABLE RECORD HASH' : 'HASH DE REGISTRO',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                    ),
                                    const Text(
                                      'SHA-256: 8f4c2e...b971a0',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.qr_code_2_rounded, size: 36, color: AppColors.purplePrimary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Bottom Controls Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isEn ? 'Record shared securely with doctor.' : 'Registro compartido de forma segura.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _isEn ? 'Share with Doctor' : 'Enviar a Médico',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _isEn ? 'Download PDF' : 'Descargar PDF',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF export saved to downloads.'),
                            backgroundColor: Color(0xFF5B14B8),
                          ),
                        );
                      },
                      leadingIcon: Icons.file_download_outlined,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 48,
                    ),
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
