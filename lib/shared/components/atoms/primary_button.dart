import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {

  final VoidCallback? onPressed;
  final String text;
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.isDisabled,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isDisabled
              ? theme.colorScheme.primary.withOpacity(0.4)
              : theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ).copyWith(
          foregroundColor: MaterialStateProperty.all(
            theme.colorScheme.surface,
          ),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: Text(text),
      ),
    ); 
  }
}