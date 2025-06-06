import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTranslations {
  final Locale locale;
  late Map<String, dynamic> _localizedValues;

  AppTranslations(this.locale);

  static AppTranslations? of(BuildContext context) {
    return Localizations.of<AppTranslations>(context, AppTranslations);
  }

  static Future<AppTranslations> load(Locale locale) async {
    final appTranslations = AppTranslations(locale);
    String jsonContent = await rootBundle.loadString(
      "assets/locale/localization_${locale.languageCode}.json",
    );
    appTranslations._localizedValues = json.decode(jsonContent);
    return appTranslations;
  }

  String get currentLanguage => locale.languageCode;

  String text(String key) {
    return _localizedValues[key] ?? "$key not found";
  }
}
