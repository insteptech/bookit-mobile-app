import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';

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
                padding: headerPadding ?? const EdgeInsets.fromLTRB(34, 40, 34, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBackButton) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: onBackPressed ?? () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 32),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          subtitle!,
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            
            // Body Section (Scrolls with content)
            SliverToBoxAdapter(
              child: Padding(
                padding: bodyPadding ?? const EdgeInsets.symmetric(horizontal: 34.0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
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
