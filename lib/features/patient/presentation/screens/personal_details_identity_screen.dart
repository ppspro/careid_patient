import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/patient_profile_models.dart';
import '../../data/repositories/patient_repository.dart';

/// CareID Patient App — Personal Details & Identity Screen
/// Faithfully reproduces Figma Frame `20:24653` ("Personal Details & Identity", 390x1160)
/// Located on canvas "Careid patient app" (node 17:55).
class PersonalDetailsIdentityScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final String language;
  final PatientProfileDto? initialProfile;

  const PersonalDetailsIdentityScreen({
    super.key,
    this.apiClient,
    this.language = 'en',
    this.initialProfile,
  });

  @override
  State<PersonalDetailsIdentityScreen> createState() => _PersonalDetailsIdentityScreenState();
}

class _PersonalDetailsIdentityScreenState extends State<PersonalDetailsIdentityScreen> {
  late final PatientRepository _repository;
  late String _language;

  PatientProfileDto? _profile;
  bool _isLoading = true;
  bool _isSaving = false;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _dobController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  String _selectedGender = 'Female';
  String _selectedBloodGroup = 'O+';

  final List<String> _genderOptions = const ['Female', 'Male', 'Other', 'Prefer not to say'];
  final List<String> _bloodGroups = const ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _language = widget.language;
    _repository = PatientRepository(apiClient: widget.apiClient);

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dobController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();

    if (widget.initialProfile != null) {
      _applyProfile(widget.initialProfile!);
      _isLoading = false;
    } else {
      _fetchProfile();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool get _isEn => _language == 'en';

  void _applyProfile(PatientProfileDto profile) {
    _profile = profile;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _dobController.text = profile.dateOfBirth ?? '';
    _phoneController.text = profile.phone ?? '';
    _emailController.text = profile.email ?? '';
    _addressController.text = profile.address ?? '';

    if (profile.gender != null && _genderOptions.contains(profile.gender)) {
      _selectedGender = profile.gender!;
    }
    if (profile.bloodGroup != null && _bloodGroups.contains(profile.bloodGroup)) {
      _selectedBloodGroup = profile.bloodGroup!;
    }
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final res = await _repository.getPatientProfile();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      res.when(
        success: (data, _) => _applyProfile(data),
        failure: (msg, _, __) {
          // Display error state to user - no silent fake fallback
          _profile = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg.isNotEmpty ? msg : (_isEn ? 'Unable to load patient profile.' : 'No se pudo cargar el perfil.')),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    final basicResult = await _repository.updateBasicInfo(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
      gender: _selectedGender,
      bloodGroup: _selectedBloodGroup,
    );

    if (_addressController.text.trim().isNotEmpty) {
      await _repository.updateAddress(_addressController.text.trim());
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (basicResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_isEn ? 'Personal details updated successfully!' : '¡Detalles personales actualizados!'),
              ),
            ],
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(basicResult.messageOrNull ?? (_isEn ? 'Failed to update personal details.' : 'Error al actualizar detalles personales.')),
              ),
            ],
          ),
        ),
      );
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
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: _isEn ? 'Back' : 'Atrás',
                ),
                const CareIdLogo.horizontal(height: 20),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prominent Page Header Section (Figma 20:24653)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEn ? 'Personal Details' : 'Detalles Personales',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            height: 1.2,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isEn
                              ? 'Manage your legal identity, verified demographics & official contact'
                              : 'Administra tu identidad legal, datos demográficos y contacto oficial',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildFormSection(),
                  const SizedBox(height: 24),
                  _buildInformationCard(),
                  const SizedBox(height: 28),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    final initials = (_firstNameController.text.isNotEmpty ? _firstNameController.text[0] : 'J') +
        (_lastNameController.text.isNotEmpty ? _lastNameController.text[0] : 'D');

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B14B8), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B14B8).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (_profile?.photoUrl != null && _profile!.photoUrl!.isNotEmpty)
                      ? Image.network(
                          _profile!.photoUrl!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              initials.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initials.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.camera_alt_rounded, size: 16, color: Color(0xFF5B14B8)),
                  onPressed: _showPhotoActionSheet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_firstNameController.text} ${_lastNameController.text}'.trim(),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
                Text(
                  () {
                    final raw = _profile?.patientNumber?.trim() ?? '8829-X';
                    final tag = raw.startsWith('#') ? raw.substring(1) : raw;
                    return 'CareID: #$tag';
                  }(),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: _isEn ? 'First Name' : 'Nombre',
                  controller: _firstNameController,
                  icon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: _isEn ? 'Last Name' : 'Apellido',
                  controller: _lastNameController,
                  icon: Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: _isEn ? 'Date of Birth' : 'Fecha de Nacimiento',
                  controller: _dobController,
                  icon: Icons.calendar_today_outlined,
                  hint: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: _isEn ? 'Gender' : 'Género',
                  value: _selectedGender,
                  items: _genderOptions,
                  icon: Icons.wc_rounded,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGender = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDropdownField(
                  label: _isEn ? 'Blood Group' : 'Grupo',
                  value: _selectedBloodGroup,
                  items: _bloodGroups,
                  icon: Icons.water_drop_outlined,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedBloodGroup = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildInputField(
                  label: _isEn ? 'Phone Number' : 'Teléfono',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: _isEn ? 'Email Address' : 'Correo Electrónico',
            controller: _emailController,
            icon: Icons.mail_outline_rounded,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: _isEn ? 'Residential Address' : 'Dirección Residencial',
            controller: _addressController,
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: readOnly ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: readOnly ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5B14B8), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
              items: items.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: const Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          opt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEn ? 'Cryptographic Identity Integrity' : 'Integridad Criptográfica de Identidad',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEn
                      ? 'Changes to primary identity fields are signed and verified against your CareID biometric sovereign ledger.'
                      : 'Los cambios en tu identidad se firman y verifican con tu registro soberano biométrico CareID.',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: _isEn ? 'Save Changes' : 'Guardar Cambios',
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _saveChanges,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              _isEn ? 'Cancel' : 'Cancelar',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
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
                leading: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF5B14B8)),
                title: Text(_isEn ? 'Update / Upload Profile Photo' : 'Actualizar / Subir Foto de Perfil'),
                subtitle: Text(_isEn ? 'Enter photo URL or use verified avatar' : 'Ingresa URL o usa avatar verificado'),
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
                        content: Text(_isEn ? 'This will remove your current profile picture.' : 'Esto eliminará tu foto de perfil actual.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(_isEn ? 'Cancel' : 'Cancelar')),
                          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(_isEn ? 'Delete' : 'Eliminar', style: const TextStyle(color: Colors.red))),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final delRes = await _repository.deleteProfilePhoto();
                      if (mounted) {
                        if (delRes.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_isEn ? 'Profile photo deleted successfully.' : 'Foto eliminada con éxito.')),
                          );
                          unawaited(_fetchProfile());
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
            Text(_isEn ? 'Provide the secure photo URL for your CareID profile:' : 'Ingresa la URL de tu foto de perfil:'),
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
              final res = await _repository.updateProfilePhoto(photoUrl: url, photoKey: key);
              if (mounted) {
                if (res.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_isEn ? 'Profile photo updated successfully!' : '¡Foto de perfil actualizada con éxito!')),
                  );
                  unawaited(_fetchProfile());
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

}
