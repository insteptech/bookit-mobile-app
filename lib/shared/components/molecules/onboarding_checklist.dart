import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class OnboardingChecklist extends StatelessWidget {
  final String heading;
  final String subHeading;
  final bool isCompleted;

  const OnboardingChecklist({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: isCompleted ? theme.colorScheme.primary : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check,
              color: isCompleted ? theme.scaffoldBackgroundColor : Colors.black87, 
              size: 22, 
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(subHeading, style: AppTypography.bodyMedium),
          ],
        ),
      ],
    );
  }
}
