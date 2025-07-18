import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/localization/language_service.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = LanguageService.defaultLocale;
  
  Locale get currentLocale => _currentLocale;
  
  bool get isRTL => LanguageService.isRTL(_currentLocale);
  
  // Initialize language from saved preferences
  Future<void> initializeLanguage() async {
    _currentLocale = await LanguageService.getCurrentLanguage();
    notifyListeners();
  }
  
  // Change language
  Future<void> changeLanguage(Locale locale) async {
    if (LanguageService.isSupported(locale) && _currentLocale != locale) {
      _currentLocale = locale;
      await LanguageService.saveLanguage(locale);
      notifyListeners();
    }
  }
  
  // Toggle between English and Arabic
  Future<void> toggleLanguage() async {
    if (_currentLocale.languageCode == 'en') {
      await changeLanguage(const Locale('ar', 'SA'));
    } else {
      await changeLanguage(const Locale('en', 'US'));
    }
  }
}
