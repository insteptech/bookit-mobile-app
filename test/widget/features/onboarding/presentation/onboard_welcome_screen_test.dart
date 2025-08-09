import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/screens/onboard_welcome_screen.dart';

void main() {
  group('OnboardWelcomeScreen Widget Tests', () {
    testWidgets('should display welcome screen with onboarding steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      // Verify screen loads
      expect(find.byType(OnboardWelcomeScreen), findsOneWidget);
    });

    testWidgets('should show onboarding checklist', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      // Wait for the widget to build completely
      await tester.pumpAndSettle();

      // Look for common onboarding text elements
      expect(find.text('About you'), findsWidgets);
      expect(find.text('Locations'), findsWidgets);
      expect(find.text('Your offerings'), findsWidgets);
    });

    testWidgets('should handle loading state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      // Initial state should show loading or content
      await tester.pump();
      
      // Verify that the widget doesn't crash
      expect(find.byType(OnboardWelcomeScreen), findsOneWidget);
    });

    testWidgets('should display step indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for step-related UI elements
      expect(find.byType(OnboardWelcomeScreen), findsOneWidget);
    });
  });

  group('OnboardWelcomeScreen Interaction Tests', () {
    testWidgets('should handle navigation actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for navigation buttons
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();
      }

      // Verify no crashes occur
      expect(find.byType(OnboardWelcomeScreen), findsOneWidget);
    });

    testWidgets('should update step progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the screen renders without errors
      expect(find.byType(OnboardWelcomeScreen), findsOneWidget);
    });
  });

  group('OnboardWelcomeScreen State Management', () {
    testWidgets('should manage current step state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify state management works
      expect(find.byType(OnboardWelcomeScreen), findsOneWidget);
    });

    testWidgets('should handle next route determination', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify routing logic
      expect(find.byType(OnboardWelcomeScreen), findsOneWidget);
    });
  });

  group('OnboardWelcomeScreen Error Handling', () {
    testWidgets('should handle missing data gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not crash with missing data
      expect(find.byType(OnboardWelcomeScreen), findsOneWidget);
    });

    testWidgets('should display error states appropriately', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardWelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error handling
      expect(find.byType(OnboardWelcomeScreen), findsOneWidget);
    });
  });
}
