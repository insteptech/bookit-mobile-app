import 'package:bookit_mobile_app/app/theme/app_typography.dart';
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

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14212529), // 8% opacity
            offset: Offset(0, 0),
            blurRadius: 1,
          ),
          BoxShadow(
            color: Color(0x10212529), // 6% opacity
            offset: Offset(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
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
      hintText: hintText,
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
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

class SearchableClientField extends StatelessWidget {
  final LayerLink layerLink;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool showSearchIcon;

  const SearchableClientField({
    super.key,
    required this.layerLink,
    required this.controller,
    required this.focusNode,
    this.hintText = "Search clients",
    this.showSearchIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: layerLink,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14212529), // 8% opacity
              offset: Offset(0, 0),
              blurRadius: 1,
            ),
            BoxShadow(
              color: Color(0x10212529), // 6% opacity
              offset: Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: _inputDecoration(theme),
          style: AppTypography.bodyMedium
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF6C757D),
        fontFamily: 'Campton',
      ),
      prefixIcon: showSearchIcon
          ? Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            )
          : null,
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
          color: Color(0xFF007BFF), // Changed to match InputField focus color
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