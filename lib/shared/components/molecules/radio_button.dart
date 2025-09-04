import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class RadioButton extends StatelessWidget {
  final String heading;
  final String? description;
  final bool rememberMe;
  final Color bgColor;
  final ValueChanged<bool> onChanged;
  final String? topRightLabel;
  final bool? isDisabled;
  final VoidCallback? onTileTap; // Optional: separate tile tap handler (e.g., expand/collapse)

  const RadioButton({
    super.key,
    required this.heading,
    this.description,
    required this.rememberMe,
    required this.onChanged,
    required this.bgColor,
    this.topRightLabel,
    this.isDisabled,
    this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool disabled = isDisabled ?? false;
    final bool hasDescription = description != null && description!.trim().isNotEmpty;
    final double verticalPadding = hasDescription ? 32 : 10;

    // Track tap position to differentiate checkbox vs tile area when needed
    Offset? lastTapDownPosition;

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: disabled
              ? null
              : (details) {
                  lastTapDownPosition = details.localPosition;
                },
          onTap: disabled
              ? null
              : () {
                  // Heuristic: taps near the left within checkbox area toggle selection
                  const double horizontalPadding = 32;
                  const double checkboxTouchWidth = 40; // generous tap target
                  final bool tappedCheckboxArea = lastTapDownPosition != null &&
                      lastTapDownPosition!.dx <=
                          (horizontalPadding + checkboxTouchWidth);

                  if (tappedCheckboxArea) {
                    onChanged(!rememberMe);
                  } else if (onTileTap != null) {
                    onTileTap!();
                  } else {
                    onChanged(!rememberMe);
                  }
                },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: verticalPadding),
            decoration: BoxDecoration(
              border: Border.all(
                color: rememberMe
                    ? theme.colorScheme.primary
                    : const Color(0xFF6C757D),
              ),
              borderRadius: BorderRadius.circular(20),
              color: bgColor,
            ),
            child: Row(
              crossAxisAlignment: hasDescription
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: hasDescription ? const Offset(0, -12) : Offset.zero,
                  child: Opacity(
                    opacity: disabled ? 0.8 : 1.0, // Only fades the radio icon
                    child: Checkbox(
                      value: rememberMe,
                      shape: const CircleBorder(),
                      side: BorderSide(
                        color: disabled
                            ? Colors.black
                            : (rememberMe
                                ? theme.colorScheme.primary
                                : AppColors.socialIcon),
                        width: 2,
                      ),
                      checkColor: Colors.white,
                      onChanged: disabled ? null : (_) => onChanged(!rememberMe),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hasDescription) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (topRightLabel != null)
          Positioned(
            top: 5,
            right: 9,
            child: Opacity(
              opacity: 0.8,
              child: Text(
                topRightLabel!,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.scaffoldBackgroundColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
