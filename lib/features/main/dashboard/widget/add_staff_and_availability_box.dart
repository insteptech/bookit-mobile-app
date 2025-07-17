import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddStaffAndAvailabilityBox extends StatelessWidget {
  const AddStaffAndAvailabilityBox({super.key});

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return GestureDetector(
    onTap: (){
      context.push("/add_staff");
    },
    child: Container(
    height: 160,
    color: AppColors.lightGrayBoxColor,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Text(
      "Click to add staff and their availability.",
      textAlign: TextAlign.center,
      style: AppTypography.bodyMedium.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.primary,
      ),
    ),
  )
  );
}

}
