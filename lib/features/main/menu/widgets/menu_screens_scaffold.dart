import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
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

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: contentPadding ?? AppConstants.defaultScaffoldPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppConstants.scaffoldTopSpacing),
              
              // Back button
              if (showBackButton)
                GestureDetector(
                  onTap: onBackPressed ?? () => context.pop(),
                  child: Icon(Icons.arrow_back, size: AppConstants.backButtonIconSize),
                ),
              
              if (showBackButton) SizedBox(height: AppConstants.backButtonToTitleSpacing),
              
              // Title
              Text(
                title,
                style: AppTypography.headingLg,
              ),
              
              // Subtitle
              if (subtitle != null) ...[
                SizedBox(height: AppConstants.titleToSubtitleSpacing),
                Text(
                  subtitle!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
              
              SizedBox(height: AppConstants.headerToContentSpacing),
              
              // Main content
              Expanded(
                child: content,
              ),
              
              // Optional bottom button
              if (buttonText != null && onButtonPressed != null) ...[
                SizedBox(height: AppConstants.bottomButtonSpacing),
                PrimaryButton(onPressed: onButtonPressed, isDisabled: isButtonDisabled ?? false, text: buttonText!),
                SizedBox(height: AppConstants.bottomButtonMargin),
              ],
            ],
          ),
        ),
      ),
    );
  }
}