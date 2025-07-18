import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookit_mobile_app/app/localization/language_provider.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';

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
        return IconButton(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                languageProvider.currentLocale.languageCode.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          onPressed: () => _showLanguageDialog(context),
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
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            context: context,
            locale: const Locale('ar', 'SA'),
            title: 'العربية',
            subtitle: 'Arabic',
            flag: '🇸🇦',
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
  }) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isSelected = languageProvider.currentLocale.languageCode == locale.languageCode;
        
        return InkWell(
          onTap: () async {
            await languageProvider.changeLanguage(locale);
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
            ),
            child: Row(
              children: [
                Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: languageProvider.isRTL 
                        ? CrossAxisAlignment.end 
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelector(showAsDialog: true),
    );
  }
}
