import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';

class OfferingsAddServiceScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? bottomButton;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final EdgeInsets? headerPadding;
  final EdgeInsets? bodyPadding;
  final Color? backgroundColor;

  const OfferingsAddServiceScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.bottomButton,
    this.onBackPressed,
    this.showBackButton = true,
    this.headerPadding,
    this.bodyPadding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section (Scrolls with content)
            SliverToBoxAdapter(
              child: Padding(
                padding: headerPadding ?? EdgeInsets.fromLTRB(AppConstants.defaultHorizontalPadding, AppConstants.scaffoldTopSpacingAlt, AppConstants.defaultHorizontalPadding, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBackButton) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: onBackPressed ?? () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back, size: AppConstants.backButtonIconSize),
                        ),
                      ),
                      SizedBox(height: AppConstants.backButtonToTitleSpacingAlt),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        title,
                        style: AppTypography.headingLg,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: AppConstants.titleToSubtitleSpacing),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          subtitle!,
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                    SizedBox(height: AppConstants.headerToContentSpacing),
                  ],
                ),
              ),
            ),
            
            // Body Section (Scrolls with content)
            SliverToBoxAdapter(
              child: Padding(
                padding: bodyPadding ?? EdgeInsets.symmetric(horizontal: AppConstants.defaultHorizontalPadding),
                child: body,
              ),
            ),
            
            // Spacer to push bottom button to end if needed
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const Spacer(),
                  // Bottom Button Section (Scrolls with content but stays at bottom)
                  if (bottomButton != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultHorizontalPadding, vertical: AppConstants.sectionSpacing),
                      child: bottomButton!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
