import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuItem extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final VoidCallback? onTap;
  final bool hasArrow;

  const MenuItem({
    super.key,
    this.icon,
    this.iconAsset,
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
        margin: EdgeInsets.only(bottom: AppConstants.menuItemSpacing),
        child: Row(
          children: [
            if (iconAsset != null)
              SvgPicture.asset(
                iconAsset!,
                width: 24,
                height: 24,
                color: const Color(0xFF202733),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 24,
                color: const Color(0xFF202733),
              ),
            if (iconAsset != null || icon != null)
              SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(fontSize: 16, color: theme.colorScheme.onSurface),
              ),
            ),
            if (hasArrow)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: const Color(0xFF202733),
              ),
          ],
        ),
      ),
    );
  }
}
