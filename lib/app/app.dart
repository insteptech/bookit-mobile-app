import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'theme/theme_data.dart';
import 'router.dart';
import 'localization/app_translations_delegate.dart';
import 'localization/language_provider.dart';
import '../core/services/navigation_service.dart';

class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize navigation service with router
    NavigationService.initialize(router);

    return provider.Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Bookit',
          theme: lightTheme,
          themeMode: ThemeMode.light, // Force light mode only
          locale: languageProvider.currentLocale,
          routerConfig: router,
          // Set the navigator key for global navigation access
          // Note: This is commented out because MaterialApp.router manages its own navigator
          // navigatorKey: NavigationService.navigatorKey,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'SA'),
          ],
          localizationsDelegates: const [
            AppTranslationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            // Use the current language from provider
            final currentLocale = languageProvider.currentLocale;
            
            // Check if current locale is supported
            for (final locale in supportedLocales) {
              if (locale.languageCode == currentLocale.languageCode) {
                return currentLocale;
              }
            }
            
            // Fallback to device locale if supported
            if (deviceLocale != null) {
              for (final locale in supportedLocales) {
                if (locale.languageCode == deviceLocale.languageCode) {
                  return locale;
                }
              }
            }
            
            // Default to English
            return const Locale('en', 'US');
          },
          // Add RTL support
          builder: (context, widget) {
            return Directionality(
              textDirection: languageProvider.isRTL 
                  ? TextDirection.rtl 
                  : TextDirection.ltr,
              child: widget!,
            );
          },
        );
      },
    );
  }
}
