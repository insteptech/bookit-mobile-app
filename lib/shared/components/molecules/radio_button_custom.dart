import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class RadioButtonCustom extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const RadioButtonCustom({
    super.key,
    required this.options,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<RadioButtonCustom> createState() => _RadioButtonCustomState();
}

class _RadioButtonCustomState extends State<RadioButtonCustom> {
  late String? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue ?? (widget.options.isNotEmpty ? widget.options[0] : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 80,
      runSpacing: 8,
      children: widget.options.map((option) {
        final isSelected = selected == option;
        return GestureDetector(
          onTap: () {
            setState(() => selected = option);
            if (widget.onChanged != null) widget.onChanged!(option);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                "$option min",
                style: AppTypography.bodyMedium
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}