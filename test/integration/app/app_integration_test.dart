import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'app_integration_test.dart' as app show main;
import 'setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupIntegrationTests();
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    app.main();
    
    await tester.pumpAndSettle();
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App respects system theme changes', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    
  });
}