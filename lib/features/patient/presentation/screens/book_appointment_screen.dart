import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/careid_logo.dart';
import '../../data/models/appointment_models.dart';
import '../../data/models/doctor_models.dart';
import '../../data/repositories/doctor_repository.dart';
import 'appointment_confirmation_screen.dart';

/// CareID Patient App — Book Appointment Multi-step Screen
/// Aligned strictly with Figma Frames:
/// - 20:28764 (Type Selection)
/// - 20:28312 (Date & Time)
/// - 20:28595 (Review Appointment)
/// - 20:29208 (Confirmation & Digital Pass)
class BookAppointmentScreen extends StatefulWidget {
  final DoctorModel doctor;
  final DoctorRepository? repository;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
    this.repository,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  late final DoctorRepository _repository;
  int _currentStep = 0; // 0: Type, 1: Date & Time, 2: Review, 3: Confirmed

  String _selectedType = 'In-Person Consultation';
  final TextEditingController _reasonController = TextEditingController(
    text: 'Follow-up consultation after lipid panel test and routine checkup.',
  );

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  String _selectedTimeSlot = '09:45 AM';

  bool _isBooking = false;
  AppointmentModel? _bookedAppointment;

  final List<Map<String, String>> _consultationTypes = const [
    {
      'title': 'In-Person Consultation',
      'desc': 'Comprehensive physical examination at clinic facility',
      'icon': 'local_hospital',
    },
    {
      'title': 'Lab & Medication Review',
      'desc': 'Review lab results, medication response, and vitals check',
      'icon': 'biotech',
    },
    {
      'title': 'Specialized Evaluation',
      'desc': 'Specialized diagnostic assessment and treatment baseline',
      'icon': 'medical_services',
    },
  ];

  final List<String> _timeSlots = const [
    '09:00 AM',
    '09:45 AM',
    '10:30 AM',
    '11:15 AM',
    '02:00 PM',
    '02:45 PM',
    '03:30 PM',
    '04:15 PM',
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DoctorRepository();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmBooking() async {
    setState(() => _isBooking = true);

    final appointment = AppointmentModel(
      id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
      doctorId: widget.doctor.id,
      doctorName: widget.doctor.fullName,
      specialization: widget.doctor.primarySpecialization,
      facility: widget.doctor.facilityName,
      dateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(_selectedTimeSlot.split(':')[0]) + (_selectedTimeSlot.contains('PM') && !_selectedTimeSlot.startsWith('12') ? 12 : 0),
        int.parse(_selectedTimeSlot.split(':')[1].split(' ')[0]),
      ),
      consultationType: _selectedType,
      status: AppointmentStatus.upcoming,
      reasonForVisit: _reasonController.text.trim().isNotEmpty
          ? _reasonController.text.trim()
          : 'Consultation & clinical review',
      preparationNote: 'Arrive 10 mins prior for contactless Care ID check-in.',
      qrPassCode: 'CAREID-PASS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      suiteRoom: '4th Floor, Suite 400 • Check-in Kiosk 2',
      durationMinutes: 45,
    );

    final result = await _repository.bookAppointment(appointment);

    if (mounted) {
      setState(() {
        _isBooking = false;
        _bookedAppointment = result.dataOrNull ?? appointment;
        _currentStep = 3; // Jump to Confirmation View
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 3 && _bookedAppointment != null) {
      return _buildConfirmationView(_bookedAppointment!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(child: CareIdLogo.horizontal(height: 18)),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
                      onPressed: () {
                        if (_currentStep > 0) {
                          setState(() => _currentStep--);
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _buildCurrentStepContent(),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStepIndicator(0, 'Type'),
              _buildStepDivider(0),
              _buildStepIndicator(1, 'Date & Time'),
              _buildStepDivider(1),
              _buildStepIndicator(2, 'Review'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStepSubtitle(),
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone || isActive ? AppColors.primary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
        color: isDone ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Configure consultation context and visit scope';
      case 1:
        return 'Select an available appointment date and arrival slot';
      case 2:
        return 'Verify doctor details and confirm clinical booking';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1TypeSelection();
      case 1:
        return _buildStep2DateTime();
      case 2:
        return _buildStep3Review();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1TypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDoctorContextBanner(),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Select Consultation Type',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose how you would like to consult with ${widget.doctor.fullName}',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._consultationTypes.map((type) {
          final isSelected = _selectedType == type['title'];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : Colors.white,
            child: ListTile(
              onTap: () => setState(() => _selectedType = type['title']!),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: Icon(
                _getIconData(type['icon']!),
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              title: Text(
                type['title']!,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                type['desc']!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              trailing: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Reason for Visit',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g. Follow-up after blood test, routine checkup, heart palpitation review...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'biotech':
        return Icons.biotech_outlined;
      case 'medical_services':
        return Icons.medical_services_outlined;
      default:
        return Icons.local_hospital_outlined;
    }
  }

  Widget _buildStep2DateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDoctorContextBanner(),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Select Appointment Date',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index + 1));
              final isSelected = date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;

              final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final dayName = weekDays[date.weekday - 1];

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 64,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Select Time Slot',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                ),
              ),
              onSelected: (selected) {
                if (selected) setState(() => _selectedTimeSlot = slot);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'All times are in Eastern Standard Time (EST). Please arrive 10 minutes prior for seamless digital Care ID contactless check-in.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Review() {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${_selectedDate.day} ${monthNames[_selectedDate.month - 1]} ${_selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDoctorContextBanner(),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Appointment Summary',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildReviewRow(Icons.medical_services_outlined, 'Consultation Type', _selectedType),
              const Divider(height: 16),
              _buildReviewRow(Icons.calendar_today_outlined, 'Date & Time', '$dateStr at $_selectedTimeSlot (EST)'),
              const Divider(height: 16),
              _buildReviewRow(Icons.location_on_outlined, 'Facility & Location', widget.doctor.facilityName),
              const Divider(height: 16),
              _buildReviewRow(Icons.notes_outlined, 'Reason for Visit', _reasonController.text.trim()),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.green, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Your appointment QR pass will be issued immediately upon confirmation for instant clinic tap-and-scan arrival.',
                  style: AppTypography.bodySmall.copyWith(color: Colors.green.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorContextBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              widget.doctor.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.fullName,
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.doctor.primarySpecialization,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
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
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
          child: PrimaryButton.gradient(
            label: _currentStep == 0
                ? 'Continue to Date & Time'
                : _currentStep == 1
                    ? 'Review Appointment Details'
                    : 'Confirm & Book Appointment',
            onPressed: _isBooking
                ? null
                : () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      _handleConfirmBooking();
                    }
                  },
            isLoading: _isBooking,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
  }

  Widget _buildConfirmationView(AppointmentModel appointment) {
    return AppointmentConfirmationScreen(appointment: appointment);
  }
}
