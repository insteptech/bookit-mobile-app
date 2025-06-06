import 'package:bookit_mobile_app/app/theme/theme_data.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const InputField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 324, 
      height: 44, 
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: lightTheme.scaffoldBackgroundColor,
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
        ),
      ),
    );
  }
}
