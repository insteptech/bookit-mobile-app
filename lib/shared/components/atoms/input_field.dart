import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final bool? isDisabled;
  final TextEditingController? controller;
  final String? initialValue;
  final void Function(String)? onChanged;
  final int? maxLines;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.hintText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.obscureText = false,
    this.isDisabled = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMultiline = maxLines != null && maxLines! > 1;

    return Container(
      height: isMultiline ? null : 44,
      decoration: BoxDecoration(
        color: isDisabled == true 
            ? theme.scaffoldBackgroundColor.withOpacity(0.6)
            : theme.scaffoldBackgroundColor,
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
              onChanged: isDisabled == true ? null : onChanged,
              enabled: isDisabled != true,
              readOnly: isDisabled == true,
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: _inputDecoration(theme),
            )
          : TextFormField(
              initialValue: initialValue,
              obscureText: obscureText,
              onChanged: isDisabled == true ? null : onChanged,
              enabled: isDisabled != true,
              readOnly: isDisabled == true,
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: _inputDecoration(theme),
            ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: isDisabled == true 
          ? theme.scaffoldBackgroundColor.withOpacity(0.6)
          : theme.scaffoldBackgroundColor,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isDisabled == true 
            ? const Color(0xFF6C757D).withOpacity(0.5)
            : const Color(0xFF6C757D),
        fontFamily: 'Campton',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDisabled == true 
              ? const Color(0xFFCED4DA).withOpacity(0.5)
              : const Color(0xFFCED4DA),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDisabled == true 
              ? theme.primaryColor.withOpacity(0.5)
              : AppColors.primary,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDisabled == true 
              ? const Color(0xFFCED4DA).withOpacity(0.5)
              : const Color(0xFFCED4DA),
          width: 1,
        ),
      ),
      disabledBorder: OutlineInputBorder(
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
          color: AppColors.primary, // Changed to match InputField focus color
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