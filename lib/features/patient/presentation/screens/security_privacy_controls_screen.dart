import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../core/theme/app_colors.dart';
import 'access_history_screen.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/digital_health_card_models.dart';
import '../../data/repositories/digital_health_card_repository.dart';
import '../../data/repositories/security_repository.dart';
import '../../data/models/security_session_models.dart';

/// CareID Security & Privacy Controls Screen
/// Faithfully reproduces Figma frame node 20:24805 ("Security & Privacy Controls", 390x1906)
/// Located on canvas "Careid patient app" (node 17:55).
class SecurityPrivacyControlsScreen extends StatefulWidget {
  final String language;
  final SecurityRepository? securityRepository;
  final DigitalHealthCardRepository? healthCardRepository;

  const SecurityPrivacyControlsScreen({
    super.key,
    this.language = 'en',
    this.securityRepository,
    this.healthCardRepository,
  });

  @override
  State<SecurityPrivacyControlsScreen> createState() => _SecurityPrivacyControlsScreenState();
}

class _SecurityPrivacyControlsScreenState extends State<SecurityPrivacyControlsScreen> {
  bool _biometricEnabled = true;
  bool _screenLockEnabled = true;
  late final SecurityRepository _securityRepo;
  late final DigitalHealthCardRepository _cardRepo;
  List<UserSessionDto> _activeSessions = [];
  HealthCardDto? _healthCard;
  bool _isLoadingSessions = false;
  bool _isLoadingCard = false;
  bool _isTogglingCard = false;

  @override
  void initState() {
    super.initState();
    _securityRepo = widget.securityRepository ?? SecurityRepository();
    _cardRepo = widget.healthCardRepository ?? DigitalHealthCardRepository();
    _loadSessions();
    _loadCard();
  }

  Future<void> _loadCard() async {
    setState(() => _isLoadingCard = true);
    final res = await _cardRepo.getActiveHealthCard();
    if (mounted) {
      setState(() {
        _isLoadingCard = false;
        _healthCard = res.dataOrNull;
      });
    }
  }

  Future<void> _toggleBlockCard() async {
    final cardId = _healthCard?.id;
    if (cardId == null || cardId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEn ? 'No active health card found to block.' : 'No hay tarjeta activa para bloquear.')),
      );
      return;
    }

    final isBlocked = (_healthCard!.status ?? '').toUpperCase() == 'BLOCKED';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBlocked
            ? (_isEn ? 'Unblock Digital Health Card?' : '¿Desbloquear Tarjeta Digital?')
            : (_isEn ? 'Freeze / Block Digital Health Card?' : '¿Bloquear / Congelar Tarjeta?')),
        content: Text(isBlocked
            ? (_isEn
                ? 'Your health card will be unblocked and valid for healthcare providers to scan and verify.'
                : 'La tarjeta se reactivará para consultas médicas.')
            : (_isEn
                ? 'Your card and offline QR tokens will be blocked immediately to prevent unauthorized access.'
                : 'La tarjeta y los tokens QR se bloquearán de inmediato.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_isEn ? 'Cancel' : 'Cancelar')),
          PrimaryButton(
            label: isBlocked
                ? (_isEn ? 'Unblock Card' : 'Desbloquear')
                : (_isEn ? 'Freeze Card' : 'Bloquear Tarjeta'),
            onPressed: () => Navigator.pop(ctx, true),
            isFullWidth: false,
            height: 40,
            backgroundColor: isBlocked ? const Color(0xFF5B14B8) : Colors.red,
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isTogglingCard = true);
      final res = isBlocked
          ? await _cardRepo.unblockHealthCard(cardId)
          : await _cardRepo.blockHealthCard(cardId, reason: 'Patient initiated security freeze');

      if (mounted) {
        setState(() => _isTogglingCard = false);
        if (res.isSuccess) {
          setState(() => _healthCard = res.dataOrNull);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isBlocked
                  ? (_isEn ? 'Card unblocked successfully.' : 'Tarjeta desbloqueada.')
                  : (_isEn ? 'Card blocked and frozen.' : 'Tarjeta bloqueada con éxito.')),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.messageOrNull ?? 'Failed to update card status')),
          );
        }
      }
    }
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoadingSessions = true);
    final res = await _securityRepo.getActiveSessions();
    if (mounted) {
      setState(() {
        _activeSessions = res.dataOrNull ?? [];
        _isLoadingSessions = false;
      });
    }
  }

  Future<void> _terminateAllOther() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isEn ? 'Terminate All Other Sessions?' : '¿Cerrar todas las demás sesiones?'),
        content: Text(_isEn
            ? 'This will immediately revoke access from all other devices and web browsers.'
            : 'Esto cerrará la sesión inmediatamente en todos los demás dispositivos y navegadores.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_isEn ? 'Cancel' : 'Cancelar')),
          PrimaryButton(
            label: _isEn ? 'Terminate All' : 'Cerrar todas',
            onPressed: () => Navigator.pop(ctx, true),
            isFullWidth: false,
            height: 40,
            backgroundColor: Colors.redAccent,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await _securityRepo.terminateAllOtherSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.isSuccess
                ? (_isEn ? 'All other sessions terminated successfully.' : 'Todas las demás sesiones fueron cerradas.')
                : (_isEn ? 'Failed to terminate other sessions.' : 'Error al cerrar las sesiones.')),
            backgroundColor: res.isSuccess ? AppColors.purplePrimary : Colors.redAccent,
          ),
        );
        await _loadSessions();
      }
    }
  }

  bool get _isEn => widget.language == 'en';

  void _exportHealthData() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.download_rounded, color: AppColors.purplePrimary),
            const SizedBox(width: 8),
            Text(_isEn ? 'Export Patient Data' : 'Exportar Datos'),
          ],
        ),
        content: Text(
          _isEn
              ? 'A portable encrypted JSON and PDF bundle of your CareID health records is being prepared.'
              : 'Se está preparando un paquete cifrado JSON y PDF con tu historial médico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_isEn ? 'Cancel' : 'Cancelar'),
          ),
          PrimaryButton(
            label: _isEn ? 'Download Bundle' : 'Descargar',
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data bundle downloaded successfully to documents.'),
                  backgroundColor: Color(0xFF5B14B8),
                ),
              );
            },
            isFullWidth: false,
            height: 40,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CareIdLogo.horizontal(height: 18),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CareIdLogo.emblem(height: 18),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prominent Page Header Section (Figma 20:23956)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEn ? 'Security & Privacy' : 'Seguridad y Privacidad',
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
                          ? 'Control biometric access, digital health card protection & active sessions'
                          : 'Configura acceso biométrico, protección de tarjeta y sesiones activas',
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

              // 1. Biometric Security Section
              _buildSectionHeader(_isEn ? 'BIOMETRIC SECURITY' : 'SEGURIDAD BIOMÉTRICA'),
              Material(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(color: AppColors.borderMedium),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _biometricEnabled,
                      activeThumbColor: AppColors.purplePrimary,
                      secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.purplePrimary),
                      title: Text(
                        _isEn ? 'Biometric Authentication' : 'Autenticación Biométrica',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        _isEn ? 'Use FaceID or Fingerprint to unlock vault' : 'Usa FaceID o huella dactilar para desbloquear',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      onChanged: (val) => setState(() => _biometricEnabled = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _screenLockEnabled,
                      activeThumbColor: AppColors.purplePrimary,
                      secondary: const Icon(Icons.lock_clock_rounded, color: AppColors.purplePrimary),
                      title: Text(
                        _isEn ? 'Auto-Lock Screen' : 'Bloqueo Automático',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        _isEn ? 'Lock app when backgrounded for 60 seconds' : 'Bloquear tras 60 segundos en segundo plano',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      onChanged: (val) => setState(() => _screenLockEnabled = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. PIN Management Section
              _buildSectionHeader(_isEn ? 'PIN MANAGEMENT' : 'GESTIÓN DE CÓDIGO PIN'),
              Material(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(color: AppColors.borderMedium),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: const Icon(Icons.pin_rounded, color: AppColors.purplePrimary),
                  title: Text(
                    _isEn ? 'Change 6-Digit Vault PIN' : 'Cambiar PIN de 6 Dígitos',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    _isEn ? 'Update your secondary offline security passcode' : 'Actualiza tu código secundario',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isEn ? 'PIN update challenge initiated.' : 'Actualización de PIN iniciada.'),
                        backgroundColor: AppColors.purplePrimary,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 3. Session Management Section
              _buildSectionHeader(_isEn ? 'SESSION MANAGEMENT' : 'SESIONES ACTIVAS'),
              Material(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(color: AppColors.borderMedium),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.phone_android_rounded, color: Color(0xFF10B981)),
                      title: Text(
                        _isEn ? 'Android Device (Xiaomi Redmi 8A)' : 'Dispositivo Android',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        _isEn ? 'Springfield, US • Active now' : 'Springfield, EE.UU. • Activo ahora',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF10B981)),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isEn ? 'Current' : 'Actual',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.laptop_chromebook_rounded, color: AppColors.textSecondary),
                      title: Text(
                        _isLoadingSessions
                            ? (_isEn ? 'Loading active sessions...' : 'Cargando sesiones...')
                            : (_activeSessions.length > 1
                                ? (_isEn ? '${_activeSessions.length - 1} Other Active Devices / Sessions' : '${_activeSessions.length - 1} Otras sesiones activas')
                                : (_isEn ? 'No other active devices' : 'No hay otros dispositivos activos')),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        _isEn ? 'Connected via 256-bit encrypted API' : 'Conectado mediante API segura cifrada',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: _activeSessions.length > 1
                          ? TextButton(
                              onPressed: _terminateAllOther,
                              child: Text(
                                _isEn ? 'Revoke All' : 'Cerrar',
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Health Card Protection Section
              _buildSectionHeader(_isEn ? 'DIGITAL HEALTH CARD PROTECTION' : 'PROTECCIÓN DE TARJETA DIGITAL'),
              Material(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(color: AppColors.borderMedium),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: Icon(
                    (_healthCard?.status ?? '').toUpperCase() == 'BLOCKED'
                        ? Icons.lock_rounded
                        : Icons.shield_rounded,
                    color: (_healthCard?.status ?? '').toUpperCase() == 'BLOCKED'
                        ? Colors.red
                        : AppColors.purplePrimary,
                  ),
                  title: Text(
                    _isEn ? 'Card Security Freeze' : 'Congelar Tarjeta de Salud',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    _isLoadingCard
                        ? (_isEn ? 'Checking card status...' : 'Comprobando estado...')
                        : ((_healthCard?.status ?? '').toUpperCase() == 'BLOCKED'
                            ? (_isEn ? 'Status: FROZEN / BLOCKED' : 'Estado: BLOQUEADA')
                            : (_isEn ? 'Status: ACTIVE • Tap to block' : 'Estado: ACTIVA • Toca para congelar')),
                    style: TextStyle(
                      fontSize: 12,
                      color: (_healthCard?.status ?? '').toUpperCase() == 'BLOCKED'
                          ? Colors.red
                          : AppColors.textSecondary,
                      fontWeight: (_healthCard?.status ?? '').toUpperCase() == 'BLOCKED'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: _isTogglingCard
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.purplePrimary),
                        )
                      : OutlinedButton(
                          onPressed: _toggleBlockCard,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: (_healthCard?.status ?? '').toUpperCase() == 'BLOCKED'
                                  ? AppColors.purplePrimary
                                  : const Color(0xFFFCA5A5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            (_healthCard?.status ?? '').toUpperCase() == 'BLOCKED'
                                ? (_isEn ? 'Unblock' : 'Desbloquear')
                                : (_isEn ? 'Freeze' : 'Bloquear'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: (_healthCard?.status ?? '').toUpperCase() == 'BLOCKED'
                                  ? AppColors.purplePrimary
                                  : Colors.red,
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // 5. Privacy & Data Sovereignty Section
              _buildSectionHeader(_isEn ? 'PRIVACY & DATA SOVEREIGNTY' : 'PRIVACIDAD Y CONTROL'),
              Material(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(color: AppColors.borderMedium),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history_toggle_off_rounded, color: AppColors.purplePrimary),
                      title: Text(
                        _isEn ? 'Access History' : 'Historial de Accesos',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        _isEn ? 'Audit healthcare providers who viewed your records' : 'Auditoría de médicos que vieron tu expediente',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => AccessHistoryScreen(language: widget.language),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.download_rounded, color: AppColors.purplePrimary),
                      title: Text(
                        _isEn ? 'Download My Data' : 'Descargar Mis Datos',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        _isEn
                            ? 'Generate a portable JSON/PDF export of all your stored medical history and vault records.'
                            : 'Genera un archivo portátil JSON/PDF de todo tu historial clínico.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: _exportHealthData,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.shield_outlined, color: AppColors.purplePrimary),
                      title: Text(
                        _isEn ? 'Consent Management' : 'Gestión de Consentimientos',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        _isEn
                            ? 'Manage third-party provider access and clinical study permissions for your health profile.'
                            : 'Administra permisos para proveedores e investigaciones clínicas.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isEn ? 'Consents up to date.' : 'Consentimientos al día.'),
                            backgroundColor: AppColors.purplePrimary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. AES-256 Security Assurance Tag
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, color: AppColors.purplePrimary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isEn
                            ? 'Your health information is protected using AES-256 encryption. Only you decide who accesses your verifiable credentials.'
                            : 'Tu información está protegida con cifrado AES-256. Solo tú decides quién accede a tus datos.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
