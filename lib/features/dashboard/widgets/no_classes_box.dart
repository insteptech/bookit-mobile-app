import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoClassesBox extends StatelessWidget {
  final String? message;
  const NoClassesBox({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 160,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: AppColors.lightGrayBoxColor, 
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "You dont have any classes scheduled for $message. Click below to add class schedule.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),

          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: (){
            context.push("/add_class_schedule", extra: {'className': '', 'classId': ''});
          },
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Edit class schedule",
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        ),
        SizedBox(height: 10,)
      ],
    );
  }
}