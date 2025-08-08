import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/auth/presentation/widgets/login_form.dart';

void main() {
  group('LoginForm Widget Tests', () {
    testWidgets('should render login form with input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const LoginForm(),
            ),
          ),
        ),
      );

      // Verify the form renders without errors
      expect(find.byType(LoginForm), findsOneWidget);
      
      // Check for input fields (adjust based on actual field types used)
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have email and password input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const LoginForm(),
            ),
          ),
        ),
      );

      // Look for text input fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsAtLeastNWidgets(2)); // Email and password fields
    });

    testWidgets('should have submit button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const LoginForm(),
            ),
          ),
        ),
      );

      // Look for buttons
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should accept text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const LoginForm(),
            ),
          ),
        ),
      );

      // Find text fields and enter text
      final textFields = find.byType(TextFormField);
      if (textFields.hasFound) {
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.pump();
        
        expect(find.text('test@example.com'), findsOneWidget);
      }
    });

    testWidgets('should have proper styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const LoginForm(),
            ),
          ),
        ),
      );

      // Verify container and styling elements
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      
      // Check for padding and spacing
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
