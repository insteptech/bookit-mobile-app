import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final String? initialValue;
  final void Function(String)? onChanged;

  const InputField({
    super.key,
    required this.hintText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: controller != null
          ? TextField(
              controller: controller,
              obscureText: obscureText,
              onChanged: onChanged,
              decoration: _inputDecoration(theme),
            )
          : TextFormField(
              initialValue: initialValue,
              obscureText: obscureText,
              onChanged: onChanged,
              decoration: _inputDecoration(theme),
            ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme) {
    return InputDecoration(
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF6C757D),
        fontFamily: 'Campton',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFCED4DA),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF007BFF),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFCED4DA),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
    );
  }
}
