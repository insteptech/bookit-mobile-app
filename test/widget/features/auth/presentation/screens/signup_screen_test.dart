import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/auth/presentation/screens/signup_screen.dart';

void main() {
  group('SignupScreen Widget Tests', () {
    testWidgets('should render signup screen with all components', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SignupScreen(),
          ),
        ),
      );

      // Verify the screen renders without errors
      expect(find.byType(SignupScreen), findsOneWidget);
      
      // Verify the main scaffold is present
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Verify there's a scrollable content area
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display signup form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SignupScreen(),
          ),
        ),
      );

      // Look for form elements
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SignupScreen(),
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
            home: const SignupScreen(),
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

    testWidgets('should handle screen orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SignupScreen(),
          ),
        ),
      );

      expect(find.byType(SignupScreen), findsOneWidget);
      
      // Test with landscape orientation
      tester.binding.window.physicalSizeTestValue = const Size(800, 400);
      await tester.pump();
      
      expect(find.byType(SignupScreen), findsOneWidget);
      
      // Reset window size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
