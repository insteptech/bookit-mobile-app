import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const CustomSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 39,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value 
              ? (activeColor ?? theme.primaryColor)
              : (inactiveColor ?? Colors.grey[300]),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: thumbColor ?? Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
