import 'package:bookit_mobile_app/app/app.dart';
import 'package:bookit_mobile_app/core/providers/shared_pref_provider.dart';
import 'package:bookit_mobile_app/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: const AppBootstrap(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('AppBootstrap uses dark theme when themeMode is dark', (tester) async {
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
}