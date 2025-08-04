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
    selected = widget.initialValue;
  }

  // Helper function to compare list contents
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(RadioButtonCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    bool optionsChanged = !_listsEqual(widget.options, oldWidget.options);
    
    // Always update selected value when initialValue prop changes
    if (widget.initialValue != oldWidget.initialValue) {
      selected = widget.initialValue;
    }
    
    // Reset selection if options change completely (different service selected)
    if (optionsChanged) {
      // If we have an initialValue, use it; otherwise clear selection
      if (widget.initialValue != null && widget.initialValue!.isNotEmpty && widget.options.contains(widget.initialValue)) {
        selected = widget.initialValue;
      } else {
        selected = null; // Clear selection when options change
      }
    }
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