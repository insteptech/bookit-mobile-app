import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/offerings/controllers/offerings_controller.dart';

void main() {
  group('OfferingsController Tests', () {
    late OfferingsController controller;

    setUp(() {
      controller = OfferingsController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('should process single category correctly', () {
      // Test data matching the API response format from the user
      final testData = [
        {
          "id": "95ab4f57-4e8d-42e2-8ff7-5072d25aab6a",
          "business_id": "some-business-id",
          "category": {
            "id": "7cb0fbb6-69d6-49c1-86b4-a524f2b6573c",
            "is_class": false,
            "name": "Health & Wellness",
            "description": "Massage therapist, chiropractor, acupuncture, dietitian, physiotherapy...",
            "related": []
          }
        }
      ];

      // Simulate processing this data
      final categoryData = testData.map((item) => CategoryData.fromJson(item)).toList();
      
      expect(categoryData.length, 1);
      expect(categoryData.first.category.name, "Health & Wellness");
      expect(categoryData.first.category.isClass, false);
    });

    test('should process multiple categories with relations correctly', () {
      // Test data with related categories
      final testData = [
        {
          "id": "95ab4f57-4e8d-42e2-8ff7-5072d25aab6a",
          "business_id": "some-business-id",
          "category": {
            "id": "7cb0fbb6-69d6-49c1-86b4-a524f2b6573c",
            "is_class": false,
            "name": "Health & Wellness",
            "description": "Massage therapist, chiropractor, acupuncture, dietitian, physiotherapy...",
            "related": [
              {
                "id": "044e9a93-3693-4205-a98b-6c371232dd86",
                "related_category": {
                  "id": "e55a7926-103b-496f-a11f-4eb5a09a37a3",
                  "name": "Fitness Classes",
                  "slug": "fitness",
                  "description": "Group training, fitness classes, personal training..."
                }
              }
            ]
          }
        },
        {
          "id": "e55a7926-103b-496f-a11f-4eb5a09a37a3",
          "business_id": "some-business-id",
          "category": {
            "id": "e55a7926-103b-496f-a11f-4eb5a09a37a3",
            "is_class": true,
            "name": "Fitness Classes",
            "description": "Group training, fitness classes, personal training...",
            "related": [
              {
                "id": "83f64238-29d9-47e4-85fd-4488985a9ff7",
                "related_category": {
                  "id": "7cb0fbb6-69d6-49c1-86b4-a524f2b6573c",
                  "name": "Health & Wellness",
                  "slug": "health",
                  "description": "Massage therapist, chiropractor, acupuncture, dietitian, physiotherapy..."
                }
              }
            ]
          }
        }
      ];

      final categoryData = testData.map((item) => CategoryData.fromJson(item)).toList();
      
      expect(categoryData.length, 2);
      expect(categoryData.first.category.related.length, 1);
      expect(categoryData.last.category.related.length, 1);
    });
  });
}
