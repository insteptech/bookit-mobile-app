import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bookit_mobile_app/features/main/offerings/presentation/offerings_screen.dart';
import 'package:bookit_mobile_app/features/main/offerings/controllers/offerings_controller.dart';

void main() {
  group('OfferingsScreen Tests', () {
    testWidgets('should display offerings screen with loading state', (WidgetTester tester) async {
      final controller = OfferingsController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: controller,
            child: const OfferingsScreen(),
          ),
        ),
      );

      // Verify the screen renders
      expect(find.text('Offerings'), findsOneWidget);
      expect(find.text('Add service'), findsOneWidget);
    });

    testWidgets('should display expand/collapse button when services exist', (WidgetTester tester) async {
      final controller = OfferingsController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: controller,
            child: const OfferingsScreen(),
          ),
        ),
      );

      await tester.pump();

      // Initially no expand/collapse button since no services loaded
      expect(find.text('Expand'), findsNothing);
      expect(find.text('Collapse'), findsNothing);
    });
  });

  group('OfferingsController Tests', () {
    test('should initialize with correct default values', () {
      final controller = OfferingsController();

      expect(controller.isLoading, false);
      expect(controller.error, null);
      expect(controller.isOfferingsLoading, false);
      expect(controller.offeringsError, null);
      expect(controller.allExpanded, false);
      expect(controller.availableCategories, isEmpty);
    });

    test('should handle category expansion correctly', () {
      final controller = OfferingsController();
      const categoryId = 'test-category-id';

      expect(controller.isCategoryExpanded(categoryId), false);

      controller.toggleCategoryExpansion(categoryId);
      expect(controller.isCategoryExpanded(categoryId), true);

      controller.toggleCategoryExpansion(categoryId);
      expect(controller.isCategoryExpanded(categoryId), false);
    });

    test('should handle service expansion correctly', () {
      final controller = OfferingsController();
      const serviceId = 'test-service-id';

      expect(controller.isServiceExpanded(serviceId), false);

      controller.toggleServiceExpansion(serviceId);
      expect(controller.isServiceExpanded(serviceId), true);

      controller.toggleServiceExpansion(serviceId);
      expect(controller.isServiceExpanded(serviceId), false);
    });

    test('should handle expand/collapse all correctly', () {
      final controller = OfferingsController();

      expect(controller.allExpanded, false);

      controller.expandAll();
      expect(controller.allExpanded, true);

      controller.collapseAll();
      expect(controller.allExpanded, false);
    });
  });
}
