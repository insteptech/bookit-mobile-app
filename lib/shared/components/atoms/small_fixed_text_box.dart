import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class SmallFixedTextBox extends StatelessWidget {
  final String text;
  const SmallFixedTextBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.socialIcon),
        borderRadius: BorderRadius.circular(7),
      ),
      child: SizedBox(
        height: 44,
        width: 88,
        child: Center(
          child: Text(
            "minutes", 
            style: AppTypography.bodyMedium
          )
        ),
      ),
    );
  }
}
