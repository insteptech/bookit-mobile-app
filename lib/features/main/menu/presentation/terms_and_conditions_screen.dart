import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/localization/language_provider.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/main/menu/widgets/menu_screens_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';

// Custom config classes to remove dividers
class CustomH1Config extends H1Config {
  @override
  HeadingDivider? get divider => null;
  
  @override
  TextStyle get style => AppTypography.headingMd;
}

class CustomH2Config extends H2Config {
  @override
  HeadingDivider? get divider => null;
  
  @override
  TextStyle get style => AppTypography.headingSm;
}

class CustomH3Config extends H3Config {
  @override
  HeadingDivider? get divider => null;
  
  @override
  TextStyle get style => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    height: 1.4,
  );
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  String _getTermsFilePath(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'assets/bookitTermsOfServices/bookit_terms_of_services_ar.md';
      case 'en':
      default:
        return 'assets/bookitTermsOfServices/bookit_terms_of_services_en.md';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final currentLanguageCode = languageProvider.currentLocale.languageCode;
        final termsFilePath = _getTermsFilePath(currentLanguageCode);
        
        return MenuScreenScaffold(
          title: AppTranslationsDelegate.of(context).text("terms_of_services"),
          content: FutureBuilder<String>(
            future: rootBundle.loadString(termsFilePath),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MarkdownWidget(
                    data: snapshot.data!,
                    shrinkWrap: true,
                    config: MarkdownConfig(
                      configs: [
                        PConfig(
                          textStyle: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        CustomH1Config(),
                        CustomH2Config(),
                        CustomH3Config(),
                        LinkConfig(
                          style: AppTypography.bodyMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading terms: ${snapshot.error}',
                    style: AppTypography.bodyMedium,
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        );
      },
    );
  }
}