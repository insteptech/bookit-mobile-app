import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PasswordInputField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;

  const PasswordInputField({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 44, 
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          hintText: widget.hintText,
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
              color: AppColors.primary,
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
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: _toggleVisibility,
          ),
        ),
      ),
    );
  }
}
