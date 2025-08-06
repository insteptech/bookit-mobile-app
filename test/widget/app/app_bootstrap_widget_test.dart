import 'package:bookit_mobile_app/app/app.dart';
import 'package:bookit_mobile_app/app/localization/language_provider.dart';
import 'package:bookit_mobile_app/core/providers/shared_pref_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';


class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
  });

  testWidgets('AppBootstrap renders MaterialApp with router', (tester) async {
    when(mockPrefs.getString('language')).thenReturn(null);

    await tester.pumpWidget(
      provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (context) => LanguageProvider(),
          ),
        ],
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: const AppBootstrap(),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('AppBootstrap uses light theme only', (tester) async {
    when(mockPrefs.getString('language')).thenReturn(null);

    await tester.pumpWidget(
      provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (context) => LanguageProvider(),
          ),
        ],
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: const AppBootstrap(),
        ),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);
  });

  testWidgets('AppBootstrap uses correct locale when language is set', (tester) async {
    when(mockPrefs.getString('language')).thenReturn('ar');

    await tester.pumpWidget(
      provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (context) => LanguageProvider(),
          ),
        ],
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: const AppBootstrap(),
        ),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale?.languageCode, 'ar');
  });
}