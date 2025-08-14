import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/back_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuScreenScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool showBackButton;
  final bool showTitle;
  final Widget? headerWidget;
  final bool placeHeaderWidgetAfterSubtitle;
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
    this.showTitle = true,
    this.headerWidget,
    this.placeHeaderWidgetAfterSubtitle = true,
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
                BackIcon(
                  size: AppConstants.backButtonIconSize,
                  onPressed: onBackPressed ?? () => context.pop(),
                ),
              
              if (showBackButton)
                SizedBox(
                  height: showTitle
                      ? AppConstants.backButtonToTitleSpacing
                      : 10,
                ),
              
              // Title
              if (showTitle)
                Text(
                  title,
                  style: AppTypography.headingLg,
                ),
              
              // Subtitle
              if (showTitle && subtitle != null) ...[
                SizedBox(height: AppConstants.titleToSubtitleSpacing),
                Text(
                  subtitle!,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],

              // Optional header widget placement
              if (headerWidget != null) ...[
                SizedBox(
                  height: (showTitle && subtitle != null && placeHeaderWidgetAfterSubtitle)
                      ? AppConstants.contentSpacing
                      : (showTitle && (subtitle == null || !placeHeaderWidgetAfterSubtitle))
                          ? AppConstants.contentSpacing
                          : 0,
                ),
                headerWidget!,
              ],
              
              SizedBox(
                height: showTitle
                    ? AppConstants.headerToContentSpacing
                    : 0,
              ),
              
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