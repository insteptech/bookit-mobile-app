import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuScreenScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final bool? isButtonDisabled;

  const MenuScreenScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.buttonText,
    this.onButtonPressed,
    this.showBackButton = true,
    this.onBackPressed,
    this.contentPadding,
    this.backgroundColor,
    this.isButtonDisabled
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPadding = const EdgeInsets.symmetric(horizontal: 34, vertical: 24);

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: contentPadding ?? defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              
              // Back button
              if (showBackButton)
                GestureDetector(
                  onTap: onBackPressed ?? () => context.pop(),
                  child: const Icon(Icons.arrow_back, size: 32),
                ),
              
              if (showBackButton) const SizedBox(height: 9),
              
              // Title
              Text(
                title,
                style: AppTypography.headingLg,
              ),
              
              // Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
              
              // Main content
              Expanded(
                child: content,
              ),
              
              // Optional bottom button
              if (buttonText != null && onButtonPressed != null) ...[
                const SizedBox(height: 24),
                PrimaryButton(onPressed: onButtonPressed, isDisabled: isButtonDisabled ?? false, text: buttonText!),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}