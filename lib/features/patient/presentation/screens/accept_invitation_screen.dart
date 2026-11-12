import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/family_models.dart';
import '../../data/repositories/family_repository.dart';
import 'family_members_screen.dart';

/// CareID Patient App — Family Member Invitation Acceptance Screen
/// Handles deep links (e.g. careid://invite/:id or /invite/:id)
/// Directly integrates with POST /api/v1/family/invitations/:id/accept
class AcceptInvitationScreen extends StatefulWidget {
  final String invitationId;
  final ApiClient? apiClient;
  final FamilyRepository? repository;
  final TokenStorage? tokenStorage;

  const AcceptInvitationScreen({
    super.key,
    required this.invitationId,
    this.apiClient,
    this.repository,
    this.tokenStorage,
  });

  @override
  State<AcceptInvitationScreen> createState() => _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState extends State<AcceptInvitationScreen> {
  late final FamilyRepository _repository;
  late final TokenStorage _tokenStorage;

  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  bool _isAccepting = false;
  bool _isRejecting = false;
  bool _isAccepted = false;
  bool _isRejected = false;
  String? _errorMessage;
  int? _errorStatusCode;

  FamilyInvitationDto? _invitationDetails;

  @override
  void initState() {
    super.initState();
    _tokenStorage = widget.tokenStorage ?? widget.apiClient?.tokenStorage ?? AppTokenStorage();
    _repository = widget.repository ?? FamilyRepository(apiClient: widget.apiClient, tokenStorage: _tokenStorage);
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    final token = await _tokenStorage.getAccessToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      setState(() {
        _isCheckingAuth = false;
        _isAuthenticated = false;
      });
      return;
    }

    setState(() {
      _isCheckingAuth = false;
      _isAuthenticated = true;
    });

    // Try finding matching invitation details if available
    try {
      final res = await _repository.getInvitations();
      if (!mounted) return;
      res.when(
        success: (list, _) {
          final match = list.where((i) => i.id == widget.invitationId || i.invitationToken == widget.invitationId);
          if (match.isNotEmpty) {
            setState(() {
              _invitationDetails = match.first;
              if (_invitationDetails!.isAccepted) {
                _isAccepted = true;
              }
            });
          }
        },
        failure: (_, __, ___) {},
      );
    } catch (_) {}
  }

  Future<void> _handleAccept() async {
    if (_isAccepting || _isRejecting) return;

    setState(() {
      _isAccepting = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    final res = await _repository.acceptInvitation(widget.invitationId);
    if (!mounted) return;

    res.when(
      success: (data, _) {
        setState(() {
          _isAccepting = false;
          _isAccepted = true;
        });
        // Automatically refresh family data
        _repository.getMembers();
      },
      failure: (msg, code, _) {
        setState(() {
          _isAccepting = false;
          _errorStatusCode = code;
          _errorMessage = msg.isNotEmpty ? msg : 'Failed to accept invitation. Please try again.';
        });
      },
    );
  }

  Future<void> _handleReject() async {
    if (_isAccepting || _isRejecting) return;

    setState(() {
      _isRejecting = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    final res = await _repository.rejectInvitation(widget.invitationId);
    if (!mounted) return;

    res.when(
      success: (data, _) {
        setState(() {
          _isRejecting = false;
          _isRejected = true;
        });
      },
      failure: (msg, code, _) {
        // Fallback to cancel if reject endpoint is unavailable (e.g. 404)
        if (code == 404) {
          _repository.cancelInvitation(widget.invitationId).then((cancelRes) {
            if (!mounted) return;
            setState(() {
              _isRejecting = false;
              if (cancelRes.isSuccess) {
                _isRejected = true;
              } else {
                _errorMessage = 'Failed to reject invitation.';
              }
            });
          });
          return;
        }

        setState(() {
          _isRejecting = false;
          _errorStatusCode = code;
          _errorMessage = msg.isNotEmpty ? msg : 'Failed to reject invitation.';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const CareIdLogo.horizontal(height: 18),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: _isCheckingAuth
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF006971)))
            : !_isAuthenticated
                ? _buildUnauthenticatedView()
                : _isAccepted
                    ? _buildSuccessView()
                    : _isRejected
                        ? _buildRejectedView()
                        : _buildAcceptanceView(),
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, size: 36, color: Color(0xFF5B14B8)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In Required',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'To accept this family health linkage invitation, please sign in with your CareID verified account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Sign In to CareID',
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptanceView() {
    final inv = _invitationDetails;
    final name = inv?.inviteeName ?? 'Family Member';
    final relation = inv?.relationship ?? 'Care Linkage';
    final phone = inv?.inviteePhone ?? '';
    final idShort = widget.invitationId.length > 8 ? widget.invitationId.substring(0, 8) : widget.invitationId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF28006D), Color(0xFF4A148C), Color(0xFF5B14B8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.family_restroom, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'FAMILY INVITATION',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '#INV-$idShort',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'CareID Family Linkage',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'You have been invited to link with $name ($relation) in the CareID Health Vault ecosystem.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Error Banner if present
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _errorStatusCode == 400 && _errorMessage!.toLowerCase().contains('expired')
                              ? 'Invitation Expired'
                              : _errorStatusCode == 400 && _errorMessage!.toLowerCase().contains('already')
                                  ? 'Already Accepted'
                                  : 'Invitation Error',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Details Bento
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invitation Summary',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Invited Member', name),
                const Divider(height: 18),
                _buildInfoRow('Relationship', relation),
                if (phone.isNotEmpty) ...[
                  const Divider(height: 18),
                  _buildInfoRow('Mobile Number', phone),
                ],
                const Divider(height: 18),
                _buildInfoRow('Status', inv?.status ?? 'PENDING'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Security & Vault Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: Color(0xFF16A34A), size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Accepting this invitation auto-creates your linked family profile and establishes authorized clinical record sharing.',
                    style: TextStyle(color: Color(0xFF166534), fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Actions
          PrimaryButton.gradient(
            label: _isAccepting ? 'Accepting Invitation...' : 'Accept Invitation & Connect',
            onPressed: _isAccepting || _isRejecting ? null : _handleAccept,
            isLoading: _isAccepting,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isAccepting || _isRejecting ? null : _handleReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              ),
              child: _isRejecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)),
                    )
                  : const Text('Decline Invitation', style: TextStyle(fontWeight: FontWeight.bold)),
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
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 13)),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF15803D)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Invitation Accepted!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Family linkage successfully established. The family member has been added to your CareID Ecosystem.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'View Family Dashboard',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const FamilyMembersScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_outlined, size: 40, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Invitation Declined',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have declined this family linkage invitation. No shared records or permissions were granted.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Return to Home',
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

