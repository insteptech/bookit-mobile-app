import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bookit_mobile_app/app/app.dart';
import 'package:bookit_mobile_app/core/providers/shared_pref_provider.dart';
import 'package:bookit_mobile_app/core/providers/theme_provider.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late ProviderContainer container;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('themeModeProvider defaults to system', () {
    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  testWidgets('AppBootstrap uses correct locale when language is set', (tester) async {
    when(mockPrefs.getString('language')).thenReturn('ar');
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: const AppBootstrap(),
      ),
    );
    
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale?.languageCode, 'ar');
  });

  testWidgets('AppBootstrap uses device locale when language is not set', (tester) async {
    when(mockPrefs.getString('language')).thenReturn(null);
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: const AppBootstrap(),
      ),
    );
    
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale, isNull);
  });

  testWidgets('AppBootstrap has correct supported locales', (tester) async {
    when(mockPrefs.getString('language')).thenReturn(null);
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: const AppBootstrap(),
      ),
    );
    
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.supportedLocales, [const Locale('en'), const Locale('ar')]);
  });

  testWidgets('AppBootstrap uses correct theme mode', (tester) async {
    when(mockPrefs.getString('language')).thenReturn(null);
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          themeModeProvider.overrideWith((ref) => ThemeMode.dark),
        ],
        child: const AppBootstrap(),
      ),
    );
    
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });
}