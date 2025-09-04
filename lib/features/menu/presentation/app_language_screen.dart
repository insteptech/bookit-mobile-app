import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/localization/language_provider.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:bookit_mobile_app/shared/components/organisms/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppLanguageScreen extends StatefulWidget {
  const AppLanguageScreen({super.key});

  @override
  State<AppLanguageScreen> createState() => _AppLanguageScreenState();
}

class _AppLanguageScreenState extends State<AppLanguageScreen> {
  final List<Map<String, dynamic>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'العربية', 'code': 'ar'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final currentLanguageCode = languageProvider.currentLocale.languageCode;
        
        final theme = Theme.of(context);

        return MenuScreenScaffold(
          title: AppTranslationsDelegate.of(context).text("app_language"),
          subtitle: null,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslationsDelegate.of(context).text("choose_language"),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              DropDown(
                items: languages,
                hintText: languages.firstWhere(
                  (lang) => lang['code'] == currentLanguageCode,
                  orElse: () => {'name': AppTranslationsDelegate.of(context).text("select_language")},
                )['name'],
                onChanged: (selectedLanguage) async {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Language changed to ${selectedLanguage['name']}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                  final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
                  final locale = Locale(selectedLanguage['code'], selectedLanguage['code'] == 'ar' ? 'SA' : 'US');
                  await languageProvider.changeLanguage(locale);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}