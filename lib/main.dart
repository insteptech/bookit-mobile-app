import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/localization/language_provider.dart';
import 'core/providers/shared_pref_provider.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(statusBarColor: const Color(0xff280073)),
  );

  final prefs = await SharedPreferences.getInstance();

  String ACCESS_TOKEN = "pk.eyJ1IjoiYm9va2l0YXBwIiwiYSI6ImNtY2l4MG9tbDBtYmYycXBkcThydjF2NWQifQ.mDqPDO6pyA6JzDXEh3hOsg".toString();
  MapboxOptions.setAccessToken(ACCESS_TOKEN);


  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(
          create: (context) => LanguageProvider()..initializeLanguage(),
        ),
      ],
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const AppBootstrap(),
      ),
    ),
  );
}

void main() {
  bootstrap();
}
