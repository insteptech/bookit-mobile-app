import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {

  final VoidCallback? onPressed;
  final String text;
  final bool isDisabled;
  final bool? isHollow;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.isDisabled,
    required this.text,
    this.isHollow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isHollow == true
              ? theme.scaffoldBackgroundColor
              : isDisabled
                  ? theme.colorScheme.primary.withOpacity(0.4)
                  : theme.colorScheme.primary,
          foregroundColor: isHollow == true
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          textStyle: AppTypography.button,
          padding: EdgeInsets.symmetric(vertical: AppConstants.buttonVerticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: isHollow == true
                ? BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
        ).copyWith(
          foregroundColor: MaterialStateProperty.all(
            isHollow == true
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
          ),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: Text(text),
      ),
    ); 
  }
}