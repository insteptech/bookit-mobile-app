import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/shared/components/atoms/nav_icon.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';

class BookitBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BookitBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final double bottomInset = mediaQuery.padding.bottom;
    final double bottomPadding = bottomInset > 12 ? bottomInset : 12;
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = math.max(16, math.min(24, screenWidth * 0.04));

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, bottomPadding),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D212529), // rgba(33,37,41,0.05)
            offset: Offset(0, -4),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _BottomNavItem(
              height: 56,
              asset: 'assets/icons/nav/dashboard.svg',
              label: AppTranslationsDelegate.of(context).text('dashboard'),
              isSelected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              height: 56,
              asset: 'assets/icons/nav/calendar.svg',
              label: AppTranslationsDelegate.of(context).text('calendar'),
              isSelected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              height: 56,
              asset: 'assets/icons/nav/offerings.svg',
              label: AppTranslationsDelegate.of(context).text('offerings'),
              isSelected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              height: 56,
              asset: 'assets/icons/nav/menu.svg',
              label: AppTranslationsDelegate.of(context).text('menu'),
              isSelected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final double height;
  final String asset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.height,
    required this.asset,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = AppColors.accentPrimary;
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final TextStyle labelStyle = AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: isSelected ? selectedColor : theme.colorScheme.onSurface,
            );

            final textPainter = TextPainter(
              text: TextSpan(text: label, style: labelStyle),
              textDirection: TextDirection.ltr,
              maxLines: 1,
              ellipsis: '…',
              textScaler: MediaQuery.of(context).textScaler,
            )..layout(minWidth: 0, maxWidth: constraints.maxWidth);

            final double underlineWidth = textPainter.size.width;

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                NavIcon(
                  asset: asset,
                  color: isSelected ? selectedColor : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Opacity(
                  opacity: isSelected ? 1 : 0,
                  child: Container(
                    width: underlineWidth,
                    height: 1,
                    color: selectedColor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

