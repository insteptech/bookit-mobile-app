import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final VoidCallback? onTap;
  final bool hasArrow;

  const MenuItem({
    super.key,
    this.icon,
    required this.title,
    this.onTap,
    this.hasArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            if (icon != null)
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            if (icon != null) 
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (hasArrow)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }
}
