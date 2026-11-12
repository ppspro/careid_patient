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
  final List<DoctorScheduleSlotModel>? initialSlots;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
    this.repository,
    this.initialSlots,
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

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DoctorScheduleSlotModel? _selectedSlot;

  List<DoctorScheduleSlotModel> _doctorSlots = [];
  bool _isLoadingSlots = false;
  String? _slotsErrorMessage;

  bool _isBooking = false;
  String? _bookingErrorMessage;
  int? _conflictStatusCode;
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

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DoctorRepository();
    if (widget.initialSlots != null) {
      _doctorSlots = List.from(widget.initialSlots!);
      _selectDefaultSlotForDate();
    } else {
      _loadDoctorScheduleSlots();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorScheduleSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _slotsErrorMessage = null;
    });

    try {
      final res = await _repository.getDoctorSlots(widget.doctor.id);
      if (!mounted) return;

      if (res.isSuccess && res.dataOrNull != null) {
        setState(() {
          _doctorSlots = res.dataOrNull!;
          _isLoadingSlots = false;
          _selectDefaultSlotForDate();
        });
      } else {
        setState(() {
          _doctorSlots = [];
          _isLoadingSlots = false;
          _slotsErrorMessage = 'No available schedule slots from provider.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _doctorSlots = [];
        _isLoadingSlots = false;
        _slotsErrorMessage = 'Failed to load schedule: $e';
      });
    }
  }

  String _getDayName(DateTime date) {
    const weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekDays[date.weekday - 1];
  }

  bool _isSlotInPast(DoctorScheduleSlotModel slot) {
    final now = DateTime.now();
    if (_selectedDate.year < now.year ||
        (_selectedDate.year == now.year && _selectedDate.month < now.month) ||
        (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day < now.day)) {
      return true;
    }
    if (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day) {
      final parts = slot.startTime.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = parts.length > 1 ? (int.tryParse(parts[1].split(' ')[0]) ?? 0) : 0;
      if (h < now.hour || (h == now.hour && m <= now.minute)) {
        return true;
      }
    }
    return false;
  }

  List<DoctorScheduleSlotModel> _getSlotsForSelectedDate() {
    final dayName = _getDayName(_selectedDate).toLowerCase();
    return _doctorSlots.where((slot) {
      if (slot.slotDate != null) {
        return slot.slotDate!.year == _selectedDate.year &&
            slot.slotDate!.month == _selectedDate.month &&
            slot.slotDate!.day == _selectedDate.day;
      }
      return slot.dayOfWeek.toLowerCase() == dayName;
    }).toList();
  }

  void _selectDefaultSlotForDate() {
    final availableSlots = _getSlotsForSelectedDate().where((s) => s.isAvailable && !_isSlotInPast(s)).toList();
    if (availableSlots.isNotEmpty) {
      _selectedSlot = availableSlots.first;
    } else {
      _selectedSlot = null;
    }
  }

  Future<void> _handleConfirmBooking() async {
    if (_isBooking) return; // Prevent duplicate submissions

    if (_selectedSlot == null) {
      setState(() {
        _currentStep = 1;
        _bookingErrorMessage = 'Please select an available appointment time slot to proceed.';
      });
      return;
    }

    setState(() {
      _isBooking = true;
      _bookingErrorMessage = null;
      _conflictStatusCode = null;
    });

    final slotTime = _selectedSlot!.startTime;
    final parts = slotTime.split(':');
    final h = int.tryParse(parts[0]) ?? 9;
    final m = parts.length > 1 ? (int.tryParse(parts[1].split(' ')[0]) ?? 0) : 0;

    final appointment = AppointmentModel(
      id: '',
      doctorId: widget.doctor.id,
      doctorName: widget.doctor.fullName,
      specialization: widget.doctor.primarySpecialization,
      facility: widget.doctor.facilityName,
      dateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        h,
        m,
      ),
      consultationType: _selectedType,
      status: AppointmentStatus.upcoming,
      reasonForVisit: _reasonController.text.trim().isNotEmpty
          ? _reasonController.text.trim()
          : 'Consultation & clinical review',
      preparationNote: 'Arrive 10 mins prior for contactless Care ID check-in.',
      qrPassCode: 'CAREID-PASS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      suiteRoom: '4th Floor, Suite 400 • Check-in Kiosk 2',
      durationMinutes: 15,
    );

    final result = await _repository.bookAppointment(appointment, slotId: _selectedSlot?.id);

    if (!mounted) return;

    result.when(
      success: (apt, _) {
        _repository.getMyAppointments();

        setState(() {
          _isBooking = false;
          _bookedAppointment = apt;
          _currentStep = 3; // Jump to Confirmation View
        });
      },
      failure: (msg, code, _) {
        setState(() {
          _isBooking = false;
          _conflictStatusCode = code;
          _bookingErrorMessage = code == 409
              ? 'The selected slot ($slotTime) is no longer available. Please select another slot.'
              : (msg.isNotEmpty ? msg : 'Failed to book appointment. Please try again.');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_bookingErrorMessage!),
            backgroundColor: code == 409 ? const Color(0xFFDC2626) : const Color(0xFF006D76),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );
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
        return 'Step 1 of 3: Choose consultation format & reason';
      case 1:
        return 'Step 2 of 3: Select date and available schedule slot';
      case 2:
        return 'Step 3 of 3: Review booking & clinic preparation';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Type();
      case 1:
        return _buildStep2DateTime();
      case 2:
        return _buildStep3Review();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Type() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDoctorContextBanner(),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Select Consultation Type',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._consultationTypes.map((type) {
          final isSelected = _selectedType == type['title'];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            elevation: isSelected ? 1 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
    final slotsForDate = _getSlotsForSelectedDate();

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
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectDefaultSlotForDate();
                  });
                },
                child: Container(
                  width: 64,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Time Slot',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_isLoadingSlots)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_isLoadingSlots)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: AppColors.primary),
          )
        else if (slotsForDate.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy_outlined, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text(
                  'No Available Slots',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _slotsErrorMessage ??
                      'No schedule slots are published for ${widget.doctor.fullName} on this date. Please select another date.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slotsForDate.map((slot) {
              final isPast = _isSlotInPast(slot);
              final isBooked = !slot.isAvailable && !isPast;
              final isAvailable = slot.isAvailable && !isPast;
              final isSelected = _selectedSlot?.id == slot.id ||
                  (_selectedSlot?.startTime == slot.startTime && _selectedSlot?.endTime == slot.endTime);

              Color bgColor;
              Color borderColor;
              Color textColor;
              String? statusBadge;

              if (isSelected) {
                bgColor = AppColors.primary;
                borderColor = AppColors.primary;
                textColor = Colors.white;
              } else if (isAvailable) {
                bgColor = Colors.white;
                borderColor = AppColors.primary.withValues(alpha: 0.4);
                textColor = AppColors.textPrimary;
              } else if (isBooked) {
                bgColor = Colors.grey.shade100;
                borderColor = Colors.grey.shade300;
                textColor = Colors.grey.shade500;
                statusBadge = 'Booked';
              } else {
                bgColor = Colors.grey.shade100;
                borderColor = Colors.grey.shade200;
                textColor = Colors.grey.shade400;
                statusBadge = 'Past';
              }

              return InkWell(
                onTap: isAvailable
                    ? () {
                        setState(() {
                          _selectedSlot = slot;
                          _bookingErrorMessage = null;
                        });
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slot.displayLabel,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                          decoration: isBooked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (statusBadge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusBadge,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'All appointments are verified in real time. Please arrive 10 minutes prior for contactless Care ID check-in.',
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
    final slotLabel = _selectedSlot != null ? _selectedSlot!.displayLabel : 'No slot selected';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_bookingErrorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _conflictStatusCode == 409 ? 'Slot Unavailable (Conflict)' : 'Booking Error',
                        style: AppTypography.titleSmall.copyWith(
                          color: const Color(0xFF991B1B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _bookingErrorMessage!,
                        style: AppTypography.bodySmall.copyWith(color: const Color(0xFFB91C1C)),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _currentStep = 1;
                    _bookingErrorMessage = null;
                    _conflictStatusCode = null;
                    _selectedSlot = null;
                  }),
                  child: const Text('Change Slot', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                ),
              ],
            ),
          ),
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildReviewRow(Icons.medical_services_outlined, 'Consultation Type', _selectedType),
              const Divider(height: 16),
              _buildReviewRow(Icons.calendar_today_outlined, 'Date & Time', '$dateStr at $slotLabel'),
              const Divider(height: 16),
              _buildReviewRow(Icons.location_on_outlined, 'Facility & Location', widget.doctor.facilityName),
              const Divider(height: 16),
              _buildReviewRow(Icons.notes_outlined, 'Reason for Visit', _reasonController.text.trim().isNotEmpty ? _reasonController.text.trim() : 'Routine clinical consultation'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
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
        borderRadius: BorderRadius.circular(10),
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
    final canContinueStep1 = _currentStep != 1 || _selectedSlot != null;

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
                  ? (_selectedSlot != null ? 'Review Appointment Details' : 'Select a Slot to Continue')
                  : (_isBooking ? 'Confirming Booking...' : 'Confirm & Book Appointment'),
          onPressed: _isBooking || !canContinueStep1
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
