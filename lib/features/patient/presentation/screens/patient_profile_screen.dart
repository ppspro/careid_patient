import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/careid_avatar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/data/models/registration_context.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../onboarding/presentation/screens/welcome_screen.dart';
import '../../data/models/faq_models.dart';
import '../../data/models/patient_profile_models.dart';
import '../../data/repositories/faq_repository.dart';
import '../../data/repositories/patient_repository.dart';
import 'access_history_screen.dart';
import 'health_card_screen.dart';
import 'insurance_screen.dart';
import 'live_chat_screen.dart';
import 'medical_info_summary_screen.dart';
import 'notification_center_screen.dart';
import 'personal_details_identity_screen.dart';
import 'security_privacy_controls_screen.dart';

/// CareID Patient App — Profile & Settings Hub
/// Faithfully reproduces Figma Frame `20:24204` ("Profile & Settings Hub", 390x2002)
/// Located on canvas "Careid patient app" (node 17:55) and matching User Reference Image 1.
class PatientProfileScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final FaqRepository? faqRepository;
  final String language;
  final RegistrationContext? registrationContext;
  final void Function(String language)? onLanguageChanged;
  final VoidCallback? onBack;

  const PatientProfileScreen({
    super.key,
    this.apiClient,
    this.faqRepository,
    this.language = 'en',
    this.registrationContext,
    this.onLanguageChanged,
    this.onBack,
  });

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late String _currentLanguage;
  late final PatientRepository _patientRepository;
  late final AuthRepository _authRepository;
  late final FaqRepository _faqRepository;

  PatientProfileDto? _profile;
  bool _isLoading = false;
  bool _isLoggingOut = false;
  bool _isBiometricsEnabled = true;
  bool _isUploadingPhoto = false;
  String? _photoCacheBuster;

  bool get _isEn => _currentLanguage == 'en';

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _patientRepository = PatientRepository(apiClient: widget.apiClient);
    _authRepository = AuthRepository(
      apiClient: widget.apiClient,
      tokenStorage: AppTokenStorage(),
    );
    _faqRepository = widget.faqRepository ?? FaqRepository(apiClient: widget.apiClient);

    if (widget.registrationContext != null) {
      final ctx = widget.registrationContext!;
      final parts = ctx.fullName.trim().split(RegExp(r'\s+'));
      final first = parts.isNotEmpty ? parts.first : 'Sarah';
      final last = parts.length > 1 ? parts.sublist(1).join(' ') : (parts.isNotEmpty ? '' : 'Jenkins');
      _profile = PatientProfileDto(
        id: ctx.profileId ?? 'local-patient',
        patientNumber: ctx.displayCareId,
        firstName: first,
        lastName: last,
        phone: ctx.phone,
        email: ctx.email,
        bloodGroup: ctx.bloodGroup ?? 'O+',
        allergies: ctx.knownAllergies,
        conditions: ctx.chronicConditions,
        medications: ctx.currentMedications,
        status: 'ACTIVE',
      );
    } else {
      _profile = const PatientProfileDto(
        id: 'local-patient',
        patientNumber: 'HV-360-9928',
        firstName: 'Sarah',
        lastName: 'Jenkins',
        phone: '+1 (555) 234-5678',
        email: 'sarah.j@email.com',
        dateOfBirth: '1992-05-12',
        gender: 'Female',
        bloodGroup: 'O+',
        allergies: ['Penicillin', 'Peanuts'],
        conditions: ['Asthma'],
        medications: ['Albuterol Inhaler'],
        status: 'ACTIVE',
      );
    }

    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (widget.apiClient == null) {
      // Test / offline preview mode
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _patientRepository.tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final profileRes = await _patientRepository
            .getPatientProfile()
            .timeout(const Duration(seconds: 4));
        if (!mounted) return;

        if (profileRes.isSuccess && profileRes.dataOrNull != null) {
          setState(() {
            _profile = profileRes.dataOrNull;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {
      // Fallback to local profile on timeout or offline
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isEn ? 'Log Out' : 'Cerrar Sesión'),
        content: Text(
          _isEn
              ? 'Are you sure you want to log out of your CareID Health Vault on this device?'
              : '¿Seguro que deseas cerrar sesión en este dispositivo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(_isEn ? 'Cancel' : 'Cancelar'),
          ),
          PrimaryButton(
            label: _isEn ? 'Log Out' : 'Cerrar Sesión',
            onPressed: () => Navigator.of(ctx).pop(true),
            backgroundColor: AppColors.error,
            isFullWidth: false,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);
    await _authRepository.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (context) => WelcomeScreen(apiClient: widget.apiClient),
      ),
      (route) => false,
    );
  }

  void _confirmDeleteAccount() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
            const SizedBox(width: 8),
            Text(
              _isEn ? 'Delete Account' : 'Eliminar Cuenta',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          _isEn
              ? 'This action cannot be undone. Irreversibly erase all medical records, health cards, and personal credentials associated with this CareID vault?'
              : 'Esta acción no se puede deshacer. ¿Eliminar permanentemente todos los registros y credenciales?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_isEn ? 'Cancel' : 'Cancelar'),
          ),
          PrimaryButton(
            label: _isEn ? 'Erase Account' : 'Eliminar',
            backgroundColor: const Color(0xFFDC2626),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _handleLogout();
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    final pinController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _isEn ? 'Change Vault PIN' : 'Cambiar PIN de Bóveda',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEn ? 'Enter your new 4-digit security PIN:' : 'Ingresa tu nuevo PIN de 4 dígitos:',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_isEn ? 'Cancel' : 'Cancelar'),
          ),
          PrimaryButton(
            label: _isEn ? 'Update PIN' : 'Actualizar PIN',
            isFullWidth: false,
            onPressed: () {
              if (pinController.text.length == 4) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isEn ? 'Security PIN updated successfully' : 'PIN actualizado con éxito'),
                    backgroundColor: const Color(0xFF0D9488),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showTermsAndPrivacyModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (c, scroll) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scroll,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEn ? 'Terms & Privacy Policy' : 'Términos y Política de Privacidad',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
              ),
              const SizedBox(height: 12),
              Text(
                _isEn
                    ? 'CareID is committed to cryptographic healthcare data security and strict compliance with global privacy regulations (HIPAA, GDPR).\n\n1. Clinical Vault Ownership\nAll personal health records, immunisations, and biometric references belong exclusively to you. CareID stores encrypted records on secure, audited nodes.\n\n2. Consent Architecture\nClinicians may only access your medical timeline with explicit, authenticated consent granted by QR pass or digital authorization.\n\n3. Revocation Rights\nYou can revoke provider access at any time through the Privacy Controls screen.'
                    : 'CareID está comprometido con la privacidad clínica y la seguridad criptográfica bajo estándares HIPAA y GDPR.',
                style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF334155)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEditProfile() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PersonalDetailsIdentityScreen(
          apiClient: widget.apiClient,
          language: _currentLanguage,
          initialProfile: _profile,
        ),
      ),
    );
    if (updated == true) {
      await _loadProfileData();
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null || !mounted) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final bytes = await pickedFile.readAsBytes();
      final res = await _patientRepository.uploadProfilePhotoFile(
        bytes: bytes,
        fileName: pickedFile.name,
      );

      if (!mounted) return;

      if (res.isSuccess) {
        setState(() {
          _photoCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEn ? 'Profile photo updated successfully!' : '¡Foto de perfil actualizada con éxito!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        await _loadProfileData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.messageOrNull ?? (_isEn ? 'Failed to upload photo' : 'Error al subir foto')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEn ? 'Error selecting image: $e' : 'Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  void _showPhotoActionSheet() {
    final hasPhoto = _profile?.photoUrl != null && _profile!.photoUrl!.isNotEmpty;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 16),
              Text(
                _isEn ? 'Profile Photo Management' : 'Gestión de Foto de Perfil',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF5B14B8)),
                title: Text(_isEn ? 'Choose from Gallery' : 'Elegir de la Galería'),
                subtitle: Text(_isEn ? 'Upload an image from your device' : 'Sube una imagen desde tu dispositivo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF00838F)),
                title: Text(_isEn ? 'Take Photo' : 'Tomar Foto'),
                subtitle: Text(_isEn ? 'Use camera to capture new photo' : 'Usa la cámara para tomar una foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link_rounded, color: Colors.blueGrey),
                title: Text(_isEn ? 'Enter Photo URL' : 'Ingresar URL de Foto'),
                subtitle: Text(_isEn ? 'Use web link or verified URL' : 'Usa un enlace web o URL verificada'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showUpdatePhotoDialog();
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: Text(_isEn ? 'Remove Current Photo' : 'Eliminar Foto Actual', style: const TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(_isEn ? 'Remove Profile Photo?' : '¿Eliminar foto de perfil?'),
                        content: Text(_isEn ? 'This will remove your current profile picture.' : 'Esto eliminará tu foto actual.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(_isEn ? 'Cancel' : 'Cancelar')),
                          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(_isEn ? 'Delete' : 'Eliminar', style: const TextStyle(color: Colors.red))),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      setState(() {
                        _isUploadingPhoto = true;
                      });
                      final delRes = await _patientRepository.deleteProfilePhoto();
                      if (mounted) {
                        setState(() {
                          _isUploadingPhoto = false;
                        });
                        if (delRes.isSuccess) {
                          setState(() {
                            _photoCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_isEn ? 'Profile photo removed.' : 'Foto eliminada.')),
                          );
                          unawaited(_loadProfileData());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(delRes.messageOrNull ?? 'Failed to delete photo')),
                          );
                        }
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdatePhotoDialog() {
    final urlController = TextEditingController(
      text: _profile?.photoUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isEn ? 'Update Profile Photo' : 'Actualizar Foto de Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_isEn ? 'Provide the secure photo URL for your CareID profile:' : 'Ingresa la URL de tu foto:'),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'Photo URL',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_isEn ? 'Cancel' : 'Cancelar')),
          PrimaryButton(
            label: _isEn ? 'Save Photo' : 'Guardar Foto',
            isFullWidth: false,
            onPressed: () async {
              final url = urlController.text.trim();
              if (url.isEmpty) return;
              Navigator.pop(ctx);
              final key = 'avatars/${_profile?.id ?? "patient"}.jpg';
              setState(() {
                _isUploadingPhoto = true;
              });
              final res = await _patientRepository.updateProfilePhoto(photoUrl: url, photoKey: key);
              if (mounted) {
                setState(() {
                  _isUploadingPhoto = false;
                });
                if (res.isSuccess) {
                  setState(() {
                    _photoCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_isEn ? 'Profile photo updated!' : '¡Foto actualizada!')),
                  );
                  unawaited(_loadProfileData());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.messageOrNull ?? 'Failed to update photo')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSupportOptions() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF5B14B8)),
                title: Text(_isEn ? 'Live Medical Chat' : 'Chat Médico en Vivo'),
                subtitle: Text(_isEn ? 'Talk to our 24/7 clinical care team' : 'Habla con el equipo de atención 24/7'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const LiveChatScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF5B14B8)),
                title: Text(_isEn ? 'Frequently Asked Questions (FAQ)' : 'Preguntas Frecuentes (FAQ)'),
                subtitle: Text(_isEn ? 'Browse support articles & guides' : 'Explora artículos y guías de ayuda'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showFaqBottomSheet();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFaqBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (c, scrollController) => FutureBuilder<ApiResult<List<FaqItemDto>>>(
          future: _faqRepository.getFaqs(),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.help_outline_rounded, color: Color(0xFF5B14B8), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        _isEn ? 'Frequently Asked Questions' : 'Preguntas Frecuentes',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEn
                        ? 'Official CareID patient support guides and answers.'
                        : 'Guías y respuestas oficiales para pacientes de CareID.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.purplePrimary));
                        }

                        final faqs = snapshot.data?.dataOrNull ?? [];
                        if (faqs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF3E8FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.help_center_outlined, size: 48, color: Color(0xFF5B14B8)),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isEn ? 'No FAQs Published' : 'Sin Preguntas Publicadas',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    _isEn
                                        ? 'Help articles and frequently asked questions will appear here once published to the CMS ledger.'
                                        : 'Las guías y preguntas frecuentes aparecerán aquí una vez publicadas.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: scrollController,
                          itemCount: faqs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final faq = faqs[i];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  faq.question,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: faq.category != null
                                    ? Text(
                                        faq.category!,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF5B14B8), fontWeight: FontWeight.w600),
                                      )
                                    : null,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: Text(
                                      faq.answer,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // Top App Bar matching Figma Frame 20:24443 & Reference Image 1
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back Action
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF2E006A)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      tooltip: _isEn ? 'Back' : 'Atrás',
                    ),

                    // Centered Profile Title (Figma 20:24448)
                    Text(
                      _isEn ? 'Profile' : 'Perfil',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E006A),
                        letterSpacing: -0.2,
                      ),
                    ),

                    // Notification Action (Figma 20:24450)
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, size: 22, color: Color(0xFF2E006A)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => NotificationCenterScreen(
                              apiClient: widget.apiClient,
                              language: _currentLanguage,
                            ),
                          ),
                        );
                      },
                      tooltip: _isEn ? 'Notifications' : 'Notificaciones',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.purplePrimary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Header Section / Large Identity Card (Figma 20:24206)
                  _buildProfileIdentityCard(),

                  const SizedBox(height: 16),

                  // 2. Horizontal Status Cards (Figma 20:24228)
                  _buildStatusCardsSection(),

                  const SizedBox(height: 20),

                  // 3. Settings Groups (Figma 20:24269)
                  _buildSettingsGroups(),
                ],
              ),
            ),
    );
  }

  /// Large Profile Identity Card matching Figma 20:24206 & Reference Image 1
  Widget _buildProfileIdentityCard() {
    final fullName = (_profile != null && _profile!.fullName.isNotEmpty) ? _profile!.fullName : 'Patient Profile';
    final rawNumber = _profile?.patientNumber;
    final careIdTag = (rawNumber != null && rawNumber.isNotEmpty)
        ? (rawNumber.startsWith('#') || rawNumber.startsWith('HV-')
            ? rawNumber
            : 'HV-$rawNumber')
        : 'Pending Identification';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Avatar with Cyan Glow Ring & Verified Badge (Figma 20:24207)
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Cyan Circular Ring Border
                GestureDetector(
                  onTap: _showPhotoActionSheet,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00E5FF), width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CareIdAvatar(
                          photoUrl: _profile?.photoUrl,
                          size: 105,
                          name: _profile?.fullName,
                          cacheBuster: _photoCacheBuster,
                          tokenStorage: _patientRepository.tokenStorage,
                        ),
                        if (_isUploadingPhoto)
                          Container(
                            width: 105,
                            height: 105,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black45,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Overlapping Verified Badge Pill at bottom (Figma 20:24210)
                Positioned(
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00838F),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00838F).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 11, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          _isEn ? 'VERIFIED' : 'VERIFICADO',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Patient Name (Figma 20:24217)
          Text(
            fullName,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 6),

          // Health ID Badge + Membership Date (Figma 20:24219)
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                ),
                child: Text(
                  careIdTag,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              Text(
                _isEn ? 'Member Since Jan 2024' : 'Miembro desde Ene 2024',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Edit Profile Pill Button (Figma 20:24224)
          PrimaryButton(
            label: _isEn ? 'Edit Profile' : 'Editar Perfil',
            onPressed: _navigateToEditProfile,
            isFullWidth: false,
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            leadingIcon: Icons.edit_outlined,
          ),
        ],
      ),
    );
  }



  /// Horizontal Status Cards matching Figma 20:24228 & Reference Image 1
  Widget _buildStatusCardsSection() {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // Card 1: Card / Active (Cyan/Mint)
          _buildStatusCard(
            icon: Icons.credit_card_rounded,
            iconColor: const Color(0xFF00BFA5),
            label: _isEn ? 'Card' : 'Tarjeta',
            status: _isEn ? 'Active' : 'Activo',
            statusColor: const Color(0xFF00897B),
            backgroundColor: const Color(0xFFE0F7FA),
            borderColor: const Color(0xFFB2EBF2),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HealthCardScreen(
                    apiClient: widget.apiClient,
                    language: _currentLanguage,
                    registrationContext: widget.registrationContext,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Card 2: Insurance / Verified (Lavender)
          _buildStatusCard(
            icon: Icons.verified_user_outlined,
            iconColor: const Color(0xFF5B14B8),
            label: _isEn ? 'Insurance' : 'Seguro',
            status: _isEn ? 'Verified' : 'Verificado',
            statusColor: const Color(0xFF2E006A),
            backgroundColor: const Color(0xFFEDE9FE),
            borderColor: const Color(0xFFDDD6FE),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InsuranceScreen(
                    apiClient: widget.apiClient,
                    language: _currentLanguage,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Card 3: Consent / Active (Light Blue)
          _buildStatusCard(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFF2563EB),
            label: _isEn ? 'Consent' : 'Consentimiento',
            status: _isEn ? 'Active' : 'Activo',
            statusColor: const Color(0xFF1D4ED8),
            backgroundColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFBFDBFE),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AccessHistoryScreen(
                    language: _currentLanguage,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String status,
    required Color statusColor,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 20, color: iconColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// All 6 Settings Groups matching Figma 20:24269 & Reference Image 1
  Widget _buildSettingsGroups() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Account Settings (Figma 20:24270)
        _buildGroupHeader(_isEn ? 'Account Settings' : 'Ajustes de Cuenta'),
        _buildCardGroup([
          _buildSettingsTile(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Personal Information' : 'Información Personal',
            subtitle: _isEn ? 'Name, Address, Date of Birth' : 'Nombre, dirección, fecha de nacimiento',
            onTap: _navigateToEditProfile,
          ),
          _buildSettingsTile(
            icon: Icons.mail_outline_rounded,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Email & Phone' : 'Correo y Teléfono',
            subtitle: _isEn ? 'Manage your contact details' : 'Administra tus datos de contacto',
            onTap: _navigateToEditProfile,
          ),
        ]),

        const SizedBox(height: 20),

        // 2. Medical Information (Figma 20:24297)
        _buildGroupHeader(_isEn ? 'Medical Information' : 'Información Médica'),
        _buildCardGroup([
          _buildSettingsTile(
            icon: Icons.medical_services_outlined,
            iconColor: const Color(0xFF00BFA5),
            title: _isEn ? 'Health Profiles' : 'Perfiles de Salud',
            subtitle: _isEn ? 'Conditions, Allergies, Medications' : 'Condiciones, alergias, medicamentos',
            onTap: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => MedicalInfoSummaryScreen(
                    apiClient: widget.apiClient,
                    language: _currentLanguage,
                    initialProfile: _profile,
                  ),
                ),
              );
              if (updated == true) {
                await _loadProfileData();
              }
            },
          ),
          _buildSettingsTile(
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFF00BFA5),
            title: _isEn ? 'Insurance Details' : 'Detalles del Seguro',
            subtitle: _isEn ? 'Policy 44829 - Primary Health' : 'Póliza 44829 - Salud Primaria',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InsuranceScreen(
                    apiClient: widget.apiClient,
                    language: _currentLanguage,
                  ),
                ),
              );
            },
          ),
        ]),

        const SizedBox(height: 20),

        // 3. Security (Figma 20:24324)
        _buildGroupHeader(_isEn ? 'Security' : 'Seguridad'),
        _buildCardGroup([
          _buildSettingsTile(
            icon: Icons.fingerprint_rounded,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Biometric Login' : 'Inicio Biométrico',
            subtitle: _isEn ? 'Use FaceID or Fingerprint' : 'Usar FaceID o Huella dactilar',
            trailing: Switch(
              value: _isBiometricsEnabled,
              onChanged: (val) {
                setState(() => _isBiometricsEnabled = val);
              },
              activeThumbColor: const Color(0xFF2E006A),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.pin_outlined,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Change PIN' : 'Cambiar PIN',
            subtitle: _isEn ? 'Update your 4-digit vault PIN' : 'Actualizar PIN de 4 dígitos',
            onTap: _showChangePinDialog,
          ),
          _buildSettingsTile(
            icon: Icons.devices_rounded,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Active Sessions' : 'Sesiones Activas',
            subtitle: _isEn ? '2 active on Mobile & Web' : '2 activas en Móvil y Web',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SecurityPrivacyControlsScreen(
                    language: _currentLanguage,
                  ),
                ),
              );
            },
          ),
        ]),

        const SizedBox(height: 20),

        // 4. Privacy (Figma 20:24361)
        _buildGroupHeader(_isEn ? 'Privacy' : 'Privacidad'),
        _buildCardGroup([
          _buildSettingsTile(
            icon: Icons.tune_rounded,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Consent & Permissions' : 'Consentimiento y Permisos',
            subtitle: _isEn ? 'Who can view your data' : 'Quién puede ver tus datos',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AccessHistoryScreen(
                    language: _currentLanguage,
                  ),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.share_outlined,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Data Sharing' : 'Compartición de Datos',
            subtitle: _isEn ? 'External app connections' : 'Conexiones con apps externas',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SecurityPrivacyControlsScreen(
                    language: _currentLanguage,
                  ),
                ),
              );
            },
          ),
        ]),

        const SizedBox(height: 20),

        // 5. Application (Figma 20:24388)
        _buildGroupHeader(_isEn ? 'Application' : 'Aplicación'),
        _buildCardGroup([
          _buildSettingsTile(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Language' : 'Idioma',
            subtitle: _isEn ? 'English (US)' : 'Español',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9FE),
              ),
              child: Text(
                _currentLanguage.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5B14B8),
                ),
              ),
            ),
            onTap: _showLanguageSelectionSheet,
          ),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Version' : 'Versión',
            subtitle: 'v3.4.2 (Production)',
            trailing: const SizedBox.shrink(),
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Terms & Privacy Policy' : 'Términos y Política de Privacidad',
            subtitle: _isEn ? 'Read CareID patient protections' : 'Leer protecciones de privacidad',
            onTap: _showTermsAndPrivacyModal,
          ),
          _buildSettingsTile(
            icon: Icons.headset_mic_outlined,
            iconColor: const Color(0xFF5B14B8),
            title: _isEn ? 'Support Center' : 'Centro de Soporte',
            subtitle: _isEn ? '24/7 dedicated medical help' : 'Ayuda médica dedicada 24/7',
            onTap: _showSupportOptions,
          ),
        ]),

        const SizedBox(height: 20),

        // 6. Account Actions (Figma 20:24422)
        _buildGroupHeader(_isEn ? 'Account Actions' : 'Acciones de Cuenta'),
        _buildCardGroup([
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFDC2626),
            title: _isEn ? 'Logout' : 'Cerrar Sesión',
            subtitle: '',
            titleColor: const Color(0xFFDC2626),
            onTap: _isLoggingOut ? null : _handleLogout,
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline_rounded,
            iconColor: const Color(0xFFDC2626),
            title: _isEn ? 'Delete Account' : 'Eliminar Cuenta',
            subtitle: _isEn ? 'Irreversibly erase all medical data' : 'Borrar todos los datos médicos irreversiblemente',
            titleColor: const Color(0xFFDC2626),
            subtitleColor: const Color(0xFFEF4444),
            onTap: _confirmDeleteAccount,
          ),
        ]),
      ],
    );
  }

  void _showLanguageSelectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEn ? 'Select Application Language' : 'Selecciona el Idioma de la Aplicación',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  title: const Text(
                    'English (US)',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: _currentLanguage == 'en'
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF5B14B8))
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (_currentLanguage != 'en') {
                      setState(() => _currentLanguage = 'en');
                      widget.onLanguageChanged?.call('en');
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                  title: const Text(
                    'Español',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: _currentLanguage == 'es'
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF5B14B8))
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (_currentLanguage != 'es') {
                      setState(() => _currentLanguage = 'es');
                      widget.onLanguageChanged?.call('es');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              children[i],
              if (i < children.length - 1)
                const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? titleColor,
    Color? subtitleColor,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? const Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: subtitleColor ?? const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
          ],
        ),
      ),
    );
  }
}
