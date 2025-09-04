import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Widget? prefix;
  final bool isDisabled;
  final Widget? suffix;
  final FontWeight? textWeight;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.prefix,
    this.isDisabled = false,
    this.suffix,
    this.textWeight
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = isDisabled 
      ? theme.colorScheme.primary.withValues(alpha: 0.4)
      : theme.colorScheme.primary;
    
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (prefix != null) ...[
            IconTheme(
              data: IconThemeData(color: primaryColor, size: 22, weight: 9),
              child: prefix!,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: textWeight ?? FontWeight.w500,
              color: primaryColor,
            ),
          ),
           if (suffix != null) ...[
            const SizedBox(width: 5),
            IconTheme(
              data: IconThemeData(color: primaryColor, size: 22),
              child: suffix!,
            ),
          ],
        ],
      ),
    );
  }
}
