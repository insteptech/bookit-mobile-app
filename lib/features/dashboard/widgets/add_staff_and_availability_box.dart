import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddStaffAndAvailabilityBox extends StatelessWidget {
  final bool isClass;
  
  const AddStaffAndAvailabilityBox({
    super.key,
    this.isClass = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
  if (isClass) {
    context.push("/add_staff?isClass=true");
  } else {
    context.push("/add_staff?isClass=false");
  }
},

      child: Container(
        height: 160,
        color: AppColors.lightGrayBoxColor,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          AppTranslationsDelegate.of(context).text(
            isClass 
              ? "click_to_add_coaches_and_class_schedules"
              : "click_to_add_staff_and_their_availability"
          ),
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
