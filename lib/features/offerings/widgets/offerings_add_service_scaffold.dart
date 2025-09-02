import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/shared/components/organisms/sticky_header_scaffold.dart';

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
  final ScrollPhysics? physics;

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
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return StickyHeaderScaffold(
      title: title,
      subtitle: subtitle,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      backgroundColor: backgroundColor,
      contentPadding: bodyPadding,
      physics: physics,
      content: Column(
        children: [
          body,
          // Add bottom padding if there's a bottom button to prevent overlap
          if (bottomButton != null) const SizedBox(height: 80),
        ],
      ),
      bottomSheet: bottomButton != null
          ? SafeArea(
              child: Container(
                color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: bottomButton!,
              ),
            )
          : null,
    );
  }
}
