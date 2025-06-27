import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class NumericInputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const NumericInputBox({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = '00',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 88,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 4,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.socialIcon),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.socialIcon),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.socialIcon, width: 1.2),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}