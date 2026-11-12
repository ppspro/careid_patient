import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/family_models.dart';
import '../../data/repositories/family_repository.dart';
import 'invitation_sent_screen.dart';

/// CareID Patient App — Add Family Member Multi-step Screen
/// Aligned strictly with Figma Frames:
/// - 20:22023 (Add Family Member - Form)
/// - 20:19424 (Add Family Member — Access)
/// - 20:19238 (Add Family Member — Review)
class AddFamilyMemberScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final FamilyRepository? repository;

  const AddFamilyMemberScreen({
    super.key,
    this.apiClient,
    this.repository,
  });

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  late final FamilyRepository _repository;
  int _currentStep = 0; // 0: Form, 1: Access Permissions, 2: Review

  // Form Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(text: '05/12/1988');
  final TextEditingController _ssnController = TextEditingController(text: '4821');
  final TextEditingController _notesController = TextEditingController();

  String _selectedRelationship = 'Spouse';
  final List<String> _relationshipOptions = const [
    'Spouse',
    'Child',
    'Parent',
    'Sibling',
    'Other Dependent',
  ];

  // Access Permissions
  bool _grantMedicalRecords = true;
  bool _grantInsuranceSharing = true;
  bool _grantEmergencyIce = true;
  bool _grantAppointmentBooking = false;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FamilyRepository(apiClient: widget.apiClient);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _ssnController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _normalizePhone(String raw) {
    String cleaned = raw.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    if (!cleaned.startsWith('+')) {
      if (cleaned.length == 10) {
        cleaned = '+1$cleaned';
      } else {
        cleaned = '+$cleaned';
      }
    }
    return cleaned;
  }

  Future<void> _handleSendInvitation() async {
    if (_isSubmitting) return;

    final name = _nameController.text.trim();
    final rawPhone = _phoneController.text.trim();

    if (name.isEmpty || rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and mobile number')),
      );
      return;
    }

    final normalizedPhone = _normalizePhone(rawPhone);
    if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(normalizedPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number in E.164 format (e.g. +16505550001)'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final relationshipType = _selectedRelationship.toUpperCase().replaceAll(' ', '_');

    final invitation = FamilyInvitationDto(
      id: '',
      inviteeName: name,
      inviteePhone: normalizedPhone,
      relationship: _selectedRelationship,
      relationshipType: relationshipType,
      status: 'PENDING',
    );

    final result = await _repository.sendInvitation(invitation);

    if (!mounted) return;

    result.when(
      success: (createdInvite, _) {
        setState(() => _isSubmitting = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => InvitationSentScreen(
              memberName: name,
              relationship: _selectedRelationship,
              emailOrPhone: normalizedPhone,
            ),
          ),
        );
      },
      failure: (message, statusCode, _) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Add Family Member'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildProgressTracker(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _buildStepContent(),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildProgressTracker() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStepNode(0, 'Details'),
              _buildStepDivider(0),
              _buildStepNode(1, 'Access'),
              _buildStepDivider(1),
              _buildStepNode(2, 'Review'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStepDescription(),
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone || isActive ? AppColors.tealPrimary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int afterStep) {
    final isDone = _currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: isDone ? AppColors.tealPrimary : Colors.grey.shade300,
      ),
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Step 1 of 3: Enter family member demographic details';
      case 1:
        return 'Step 2 of 3: Configure Care ID record sharing permissions';
      case 2:
        return 'Step 3 of 3: Review and send cryptographic invitation';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Form();
      case 1:
        return _buildStep2Access();
      case 2:
        return _buildStep3Review();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Form() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Member Information',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Legal Name *',
              hintText: 'e.g. Jane Doe',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Mobile Phone Number *',
              hintText: '+1 (650) 555-0007',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth (MM/DD/YYYY)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _ssnController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'SSN (Last 4)',
                    hintText: '••••',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _selectedRelationship,
            decoration: InputDecoration(
              labelText: 'Relationship to Primary Patient',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _relationshipOptions.map((rel) {
              return DropdownMenuItem(value: rel, child: Text(rel));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedRelationship = val);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Medical Notes / Known Allergies',
              hintText: 'Known allergies, chronic conditions, emergency instructions...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Access() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Healthcare Data Sharing Permissions',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Define which Care ID health assets this family member can access.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              value: _grantMedicalRecords,
              activeThumbColor: AppColors.tealPrimary,
              contentPadding: EdgeInsets.zero,
              title: const Text('Medical Records Access', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Allow viewing clinical consultations, notes & lab reports', style: AppTypography.bodySmall),
              onChanged: (val) => setState(() => _grantMedicalRecords = val),
            ),
          ),
          const Divider(),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              value: _grantInsuranceSharing,
              activeThumbColor: AppColors.tealPrimary,
              contentPadding: EdgeInsets.zero,
              title: const Text('Shared Insurance Coverage', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Link under primary policy and view coverage benefits', style: AppTypography.bodySmall),
              onChanged: (val) => setState(() => _grantInsuranceSharing = val),
            ),
          ),
          const Divider(),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              value: _grantEmergencyIce,
              activeThumbColor: AppColors.tealPrimary,
              contentPadding: EdgeInsets.zero,
              title: const Text('Emergency ICE Guardian', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Authorized to receive emergency alerts and triage notifications', style: AppTypography.bodySmall),
              onChanged: (val) => setState(() => _grantEmergencyIce = val),
            ),
          ),
          const Divider(),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              value: _grantAppointmentBooking,
              activeThumbColor: AppColors.tealPrimary,
              contentPadding: EdgeInsets.zero,
              title: const Text('Appointment Scheduling Proxy', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Allow booking clinical consultations on patient behalf', style: AppTypography.bodySmall),
              onChanged: (val) => setState(() => _grantAppointmentBooking = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Review() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Text(
            'Review Linkage Invitation',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildReviewItem('Full Legal Name', _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Jane Doe'),
          const Divider(height: 16),
          _buildReviewItem('Mobile Number', _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : '+1 (650) 555-0007'),
          const Divider(height: 16),
          _buildReviewItem('Relationship', _selectedRelationship),
          const Divider(height: 16),
          _buildReviewItem('Date of Birth', _dobController.text.trim()),
          const Divider(height: 16),
          _buildReviewItem(
            'Permissions Granted',
            [
              if (_grantMedicalRecords) 'Records',
              if (_grantInsuranceSharing) 'Insurance',
              if (_grantEmergencyIce) 'Emergency ICE',
              if (_grantAppointmentBooking) 'Scheduling',
            ].join(', '),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.mark_email_read_outlined, color: AppColors.tealPrimary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'A secure cryptographic family linkage invitation will be created. The recipient can accept via the link or deep-link notification.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.tealPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
          child: PrimaryButton(
            label: _currentStep == 0
                ? 'Continue to Permissions'
                : _currentStep == 1
                    ? 'Review Invitation'
                    : 'Send Linkage Invitation',
            onPressed: _isSubmitting
                ? null
                : () {
                    if (_currentStep < 2) {
                      if (_currentStep == 0) {
                        if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter name and mobile number')),
                          );
                          return;
                        }
                      }
                      setState(() => _currentStep++);
                    } else {
                      _handleSendInvitation();
                    }
                  },
            isLoading: _isSubmitting,
            backgroundColor: AppColors.tealPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
  }
}
