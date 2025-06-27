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

  const RadioButton({
    super.key,
    required this.heading,
    this.description,
    required this.rememberMe,
    required this.onChanged,
    required this.bgColor,
    this.topRightLabel,
    this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool disabled = isDisabled ?? false;
    final bool hasDescription = description != null && description!.trim().isNotEmpty;
    final double verticalPadding = hasDescription ? 32 : 10;

    return Stack(
      children: [
        Container(
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
                child: Checkbox(
                  value: rememberMe,
                  shape: const CircleBorder(),
                  side: BorderSide(
                    color: rememberMe
                        ? theme.colorScheme.primary
                        : AppColors.socialIcon,
                    width: 2,
                  ),
                  onChanged: disabled ? null : (_) => onChanged(true),
                ),
              ),
              const SizedBox(width: 16),
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
        if (topRightLabel != null)
          Positioned(
            top: 5,
            right: 9,
            child: Text(
              topRightLabel!,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.scaffoldBackgroundColor,
              ),
            ),
          ),
      ],
    );
  }
}
