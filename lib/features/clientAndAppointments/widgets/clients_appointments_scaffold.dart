import 'package:bookit_mobile_app/shared/components/organisms/sticky_header_scaffold.dart';
import 'package:flutter/material.dart';

class ClientsAppointmentsScaffold extends StatelessWidget {
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
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomSheet;
  final double? titleToContentSpacing;

  const ClientsAppointmentsScaffold({
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
    this.isButtonDisabled,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomSheet,
    this.titleToContentSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return StickyHeaderScaffold(
      title: title,
      subtitle: subtitle,
      content: content,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
      showBackButton: showBackButton,
      showTitle: showTitle,
      headerWidget: headerWidget,
      placeHeaderWidgetAfterSubtitle: placeHeaderWidgetAfterSubtitle,
      onBackPressed: onBackPressed,
      contentPadding: contentPadding,
      backgroundColor: backgroundColor,
      isButtonDisabled: isButtonDisabled,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomSheet: bottomSheet,
      titleToContentSpacing: titleToContentSpacing,
    );
  }
}