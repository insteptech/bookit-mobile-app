import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/shared_pref_provider.dart';
import 'theme/theme_data.dart';
import 'router.dart';
import 'localization/app_translations_delegate.dart';
import '../core/providers/theme_provider.dart';

class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    final prefs = ref.watch(sharedPreferencesProvider);
    final language = prefs.getString('language');

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bookit',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: language != null ? Locale(language) : null,
      routerConfig: router,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppTranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (language != null) return Locale(language);
        for (final locale in supportedLocales) {
          if (locale.languageCode == deviceLocale?.languageCode) return locale;
        }
        return supportedLocales.first;
      },
    );
  }
}
