import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookit_mobile_app/app/localization/language_provider.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsDialog;
  
  const LanguageSelector({
    Key? key,
    this.showAsDialog = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showAsDialog) {
      return _buildLanguageDialog(context);
    } else {
      return _buildLanguageButton(context);
    }
  }

  Widget _buildLanguageButton(context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLanguageOption(
              context: context,
              locale: const Locale('en', 'US'),
              title: 'English',
              subtitle: 'English',
              flag: '🇺🇸',
              isDialog: false,
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context: context,
              locale: const Locale('ar', 'SA'),
              title: 'العربية',
              subtitle: 'Arabic',
              flag: '🇸🇦',
              isDialog: false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return AlertDialog(
      title: Text(
        AppTranslationsDelegate.of(context).text("choose_language"),
        textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            context: context,
            locale: const Locale('en', 'US'),
            title: 'English',
            subtitle: 'English',
            flag: '🇺🇸',
            isDialog: true,
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            context: context,
            locale: const Locale('ar', 'SA'),
            title: 'العربية',
            subtitle: 'Arabic',
            flag: '🇸🇦',
            isDialog: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppTranslationsDelegate.of(context).text("cancel"),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required Locale locale,
    required String title,
    required String subtitle,
    required String flag,
    required bool isDialog,
  }) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isSelected = languageProvider.currentLocale.languageCode == locale.languageCode;
        final theme = Theme.of(context);
        
        return GestureDetector(
          onTap: () async {
            await languageProvider.changeLanguage(locale);
            if (isDialog) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  flag,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
