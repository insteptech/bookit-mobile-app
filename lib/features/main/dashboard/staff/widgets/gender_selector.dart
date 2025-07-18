import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  final VoidCallback? onSelectionChanged;

  const GenderSelector({super.key, this.onSelectionChanged});

  @override
  State<GenderSelector> createState() => GenderSelectorState();
}

class GenderSelectorState extends State<GenderSelector> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildOption("female"),
        const SizedBox(width: 16),
        _buildOption("male"),
      ],
    );
  }

  Widget _buildOption(String value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: selectedGender,
            activeColor: theme.colorScheme.primary,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (val) {
              setState(() => selectedGender = val);
              widget.onSelectionChanged?.call();
            },
          ),
          const SizedBox(width: 8),
          Text(AppTranslationsDelegate.of(context).text(value), style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
