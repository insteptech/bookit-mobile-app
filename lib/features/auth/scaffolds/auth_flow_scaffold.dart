import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/shared/components/atoms/app_bar_title.dart';

class AuthFlowScaffold extends StatelessWidget {
  final Widget child;
  final String title;

  const AuthFlowScaffold({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppTranslationsDelegate.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: AppConstants.authScaffoldPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppConstants.scaffoldTopSpacingWithBackButton),
              AppBarTitle(title: title),
              SizedBox(height: AppConstants.largeContentSpacing + AppConstants.sectionSpacing),
              Text(
                localizations.text("fogot_pass_title"),
                style: AppTypography.bodyLg,
              ),
              SizedBox(height: AppConstants.tinySpacing),
              Expanded(child: child),
              SizedBox(height: AppConstants.headerToContentSpacingMedium),
            ],
          ),
        ),
      ),
    );
  }
}
