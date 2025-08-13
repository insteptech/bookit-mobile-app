import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';

class DropDown extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String hintText;
  final Function(Map<String, dynamic>)? onChanged;
  final Map<String, dynamic>? initialSelectedItem;

  const DropDown({
    super.key,
    required this.items,
    this.hintText = "Select service",
    this.onChanged,
    this.initialSelectedItem,
  });

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  Map<String, dynamic>? selectedItem;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initialSelectedItem;
  }

  @override
  void didUpdateWidget(DropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selectedItem if initialSelectedItem changes
    if (widget.initialSelectedItem != oldWidget.initialSelectedItem) {
      selectedItem = widget.initialSelectedItem;
    }
  }

  void _selectItem(Map<String, dynamic> item) {
    setState(() {
      selectedItem = item;
      isOpen = false;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.12)
        : const Color(0xFFCED4DA);
    final boxColor = theme.scaffoldBackgroundColor;
    // final shadowColor = isDark
    //     ? Colors.black.withOpacity(0.2)
    //     : Colors.black.withOpacity(0.04);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => isOpen = !isOpen),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 1, offset: const Offset(0, 0)),
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 2, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedItem?['name'] ?? widget.hintText,
                  style: selectedItem == null
                      ? AppTypography.bodyMedium.copyWith(
                          color: theme.hintColor,
                        )
                      : AppTypography.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 1, offset: const Offset(0, 0)),
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 2, offset: const Offset(0, 2)),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.items.length,
              separatorBuilder: (_, __) => Divider(
                color: borderColor,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return ListTile(
                  title: Text(
                    item['name'],
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  onTap: () => _selectItem(item),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }
}