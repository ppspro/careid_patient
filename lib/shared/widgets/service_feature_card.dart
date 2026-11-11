import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'careid_dental_logo.dart';

enum ServiceType { medical, dental, vision, pets }

/// Service Feature Card
/// Renders an individual service record category matching Figma cards
/// (nodes 20:19812, 20:19823, 20:19834, 20:19853).
class ServiceFeatureCard extends StatelessWidget {
  final ServiceType type;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const ServiceFeatureCard({
    super.key,
    required this.type,
    required this.title,
    required this.description,
    this.onTap,
  });

  Color get _iconBgColor => switch (type) {
    ServiceType.medical => AppColors.medicalBg,
    ServiceType.dental => AppColors.dentalBg,
    ServiceType.vision => AppColors.visionBg,
    ServiceType.pets => AppColors.petsBg,
  };

  Color get _iconColor => switch (type) {
    ServiceType.medical => AppColors.medicalIcon,
    ServiceType.dental => AppColors.dentalIcon,
    ServiceType.vision => AppColors.visionIcon,
    ServiceType.pets => AppColors.petsIcon,
  };

  IconData get _iconData => switch (type) {
    ServiceType.medical => Icons.medical_services_rounded,
    ServiceType.dental => Icons.health_and_safety_rounded,
    ServiceType.vision => Icons.visibility_rounded,
    ServiceType.pets => Icons.pets_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Squircle Icon Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: type == ServiceType.dental
                        ? CareIdDentalLogo(size: 26, color: _iconColor)
                        : Icon(_iconData, color: _iconColor, size: 26),
                  ),
                ),
                const SizedBox(width: 16),
                // Title and Subtitle Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: AppTypography.heading3),
                      const SizedBox(height: 4),
                      Text(description, style: AppTypography.body),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
