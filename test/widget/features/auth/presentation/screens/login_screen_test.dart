import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should render login screen with all components', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );

      // Verify the screen renders without errors
      expect(find.byType(LoginScreen), findsOneWidget);
      
      // Verify the main scaffold is present
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Verify there's a scrollable content area
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display app logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );

      // Look for logo or brand elements (adjust based on actual implementation)
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );

      // Verify the main container structure
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );

      // Verify scrollability
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);
      
      // Test scroll functionality
      await tester.drag(scrollView, const Offset(0, -100));
      await tester.pump();
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Test with smaller screen
      tester.binding.window.physicalSizeTestValue = const Size(400, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      
      // Reset window size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
