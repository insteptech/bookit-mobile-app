import 'dart:ui';

typedef LocaleChangeCallback = void Function(Locale locale);

class Application {
  static final Application _instance = Application._internal();

  factory Application() => _instance;

  Application._internal();

  final List<String> supportedLanguages = ["English", "Arabic",];
  final List<String> supportedLanguagesCodes = [ "en","ar",];

  Iterable<Locale> supportedLocales() =>
      supportedLanguagesCodes.map((code) => Locale(code));

  LocaleChangeCallback ?onLocaleChanged;
}

Application application = Application();

final List<String> languagesList = application.supportedLanguages;
final List<String> languageCodesList = application.supportedLanguagesCodes;

final Map<String, String> languagesMap = {
  languagesList[0]: languageCodesList[0],
  languagesList[1]: languageCodesList[1],
};
