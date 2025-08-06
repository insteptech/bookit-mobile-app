import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              AppBarTitle(title: title),
              const SizedBox(height: 64),
              Text(
                localizations.text("fogot_pass_title"),
                style: AppTypography.bodyLg,
              ),
              const SizedBox(height: 3),
              Expanded(child: child),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
