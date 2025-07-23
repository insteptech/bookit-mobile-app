import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/shared/components/molecules/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppLanguageScreen extends StatefulWidget {
  const AppLanguageScreen({super.key});

  @override
  State<AppLanguageScreen> createState() => _AppLanguageScreenState();
}

class _AppLanguageScreenState extends State<AppLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back, size: 32),
              ),
              const SizedBox(height: 9),
              Text(
                AppTranslationsDelegate.of(context).text("app_language"),
                style: AppTypography.headingLg,
              ),
              const SizedBox(height: 16),
              Text(
                AppTranslationsDelegate.of(context).text("choose_language"),
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 24),
              const Expanded(
                child: LanguageSelector(showAsDialog: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
