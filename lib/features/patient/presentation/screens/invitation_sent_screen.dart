import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

import '../../../../shared/widgets/careid_bottom_navigation_bar.dart';
import '../../../../shared/widgets/careid_logo.dart';
import 'family_members_screen.dart';

/// CareID Patient App — Family Linkage Invitation Sent Confirmation Screen
/// Faithfully reproduces Figma Frame `20:19138` ("Invitation Sent", 390x1143)
/// Located on canvas "Careid patient app" (node 17-55).
class InvitationSentScreen extends StatelessWidget {
  final String memberName;
  final String relationship;
  final String emailOrPhone;
  final String language;

  const InvitationSentScreen({
    super.key,
    required this.memberName,
    required this.relationship,
    required this.emailOrPhone,
    this.language = 'en',
  });

  bool get _isEn => language == 'en';

  @override
  Widget build(BuildContext context) {
    final initials = memberName.trim().isNotEmpty
        ? memberName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'FM';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE7ECF6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF28006D)),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => FamilyMembersScreen(language: language),
                        ),
                        (route) => route.isFirst,
                      );
                    },
                  ),
                  const CareIdLogo.onlyId(height: 18),
                  const SizedBox(width: 48), // spacer
                ],
              ),
            ),

            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Column(
                  children: [
                    // 1. Success Hero (Figma 20:19140)
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 56,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      _isEn ? 'Invitation sent' : 'Invitación enviada',
                      style: const TextStyle(
                        fontSize: 28,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B1C30),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      _isEn
                          ? 'We sent $memberName a secure invitation to join your family health network.'
                          : 'Enviamos a $memberName una invitación segura para unirse a tu red de salud familiar.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF494552),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pending acceptance badge (Figma 20:19149)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EEFF),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xFF28006D),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isEn ? 'Pending acceptance' : 'Pendiente de aceptación',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF28006D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 2. Pending member summary card (Figma 20:19153)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE7ECF6)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1028006D),
                            blurRadius: 15,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF75F2FE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF006971),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memberName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0B1C30),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$relationship • $emailOrPhone',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF494552),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5EEFF),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  _isEn ? 'Pending' : 'Pendiente',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF28006D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: Color(0xFFE7ECF6)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  _isEn ? 'Sent today' : 'Enviado hoy',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Color(0xFF7A7583),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _isEn ? 'Expires in 7 days' : 'Vence en 7 días',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF006971),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 3. Next Steps (Figma 20:19165)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _isEn ? 'WHAT HAPPENS NEXT' : 'QUÉ SUCEDE DESPUÉS',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7A7583),
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildStepRow(
                      icon: Icons.mark_email_read_outlined,
                      title: _isEn
                          ? 'Member receives secure notification'
                          : 'El familiar recibe notificación segura',
                      description: _isEn
                          ? 'They will receive an invitation link via SMS and email.'
                          : 'Recibirán un enlace de invitación por SMS y correo.',
                    ),
                    const SizedBox(height: 12),
                    _buildStepRow(
                      icon: Icons.verified_user_outlined,
                      title: _isEn
                          ? 'Identity verification'
                          : 'Verificación de identidad',
                      description: _isEn
                          ? 'They confirm consent and link their verifiable Care ID pass.'
                          : 'Confirman su consentimiento y vinculan su pase Care ID.',
                    ),
                    const SizedBox(height: 12),
                    _buildStepRow(
                      icon: Icons.sync_rounded,
                      title: _isEn
                          ? 'Automatic vault synchronization'
                          : 'Sincronización automática de bóveda',
                      description: _isEn
                          ? 'Authorized medical records and alerts appear in your family dashboard.'
                          : 'Los registros autorizados y alertas aparecerán en tu panel.',
                    ),
                    const SizedBox(height: 36),

                    // 4. Primary & Secondary CTA Buttons
                    PrimaryButton(
                      label: _isEn ? 'Back to Family Dashboard' : 'Volver al Panel Familiar',
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => FamilyMembersScreen(language: language),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            CareIdBottomNavigationBar(
              currentIndex: 0,
              onTabSelected: (idx) {
                Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
              },
              language: language,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECF6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFE8FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF5B14B8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF494552),
                    height: 1.35,
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

