import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class OnboardingChecklist extends StatelessWidget {

  final String heading;
  final String subHeading;
  final bool isCompleted;

  const OnboardingChecklist({super.key, required this.heading, required this.subHeading, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isCompleted? Icons.check_circle : Icons.reddit, 
          color: isCompleted? theme.colorScheme.primary: AppColors.socialIcon, size: 24,),
        SizedBox(width: 16,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(heading, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),),
            SizedBox(height: 4,),
            Text(subHeading, style: AppTypography.bodyMedium,)
          ],
        )
      ],
    );
  }
}