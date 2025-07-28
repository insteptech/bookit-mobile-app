import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class MultiSelectItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final ValueChanged<bool> onChanged;
  final bool? isDisabled;

  const MultiSelectItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onChanged,
    this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool disabled = isDisabled ?? false;
    final bool hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return GestureDetector(
      onTap: disabled ? null : () => onChanged(!isSelected),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Opacity(
              opacity: disabled ? 0.8 : 1.0,
              child: Transform.translate(
                offset: const Offset(-4, 0),
                child: Checkbox(
                  value: isSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: disabled
                        ? Colors.black
                        : (isSelected
                            ? theme.colorScheme.primary
                            : AppColors.socialIcon),
                    width: 2,
                  ),
                  checkColor: Colors.white,
                  activeColor: theme.colorScheme.primary,
                  onChanged: disabled ? null : (value) => onChanged(value ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: disabled 
                          ? Colors.grey 
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: disabled 
                            ? Colors.grey 
                            : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
