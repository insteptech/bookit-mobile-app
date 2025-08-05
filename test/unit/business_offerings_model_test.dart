import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/main/offerings/models/business_offerings_model.dart';

void main() {
  group('BusinessOfferingsModel Tests', () {
    test('should parse API response correctly for nested categories', () {
      final jsonResponse = {
        "success": true,
        "data": {
          "offerings": [
            {
              "id": "71939c02-6bed-4cdc-a51c-fe750aef27d0",
              "business_id": "fbf4e222-7e62-42a4-a3a2-faaf16950040",
              "category_id": "be622a68-ea9f-4553-b117-0f4e9d719f5e",
              "is_class": false,
              "is_active": true,
              "createdAt": "2025-08-05T04:49:17.603Z",
              "updatedAt": "2025-08-05T04:49:17.603Z",
              "category": {
                "id": "be622a68-ea9f-4553-b117-0f4e9d719f5e",
                "name": "Osteopath",
                "level": 1,
                "parent": {
                  "id": "7cb0fbb6-69d6-49c1-86b4-a524f2b6573c",
                  "name": "Health & Wellness",
                  "level": 0,
                  "is_class": false
                },
                "root_parent": {
                  "id": "7cb0fbb6-69d6-49c1-86b4-a524f2b6573c",
                  "name": "Health & Wellness",
                  "is_class": false
                }
              },
              "service_details": [
                {
                  "id": "9c597eea-d73b-4546-8105-4aa9148c11ec",
                  "name": "Osteopath",
                  "description": "fjdsfjdslkf ds4",
                  "created_at": "2025-08-05T04:49:17.603Z",
                  "updated_at": "2025-08-05T04:49:17.603Z",
                  "durations": [
                    {
                      "id": "66fc727c-c6a9-4a28-b1a3-220cf5494213",
                      "duration_minutes": 54,
                      "price": "444.00",
                      "package_amount": null,
                      "package_person": null
                    }
                  ]
                }
              ]
            }
          ]
        }
      };

      final response = BusinessOfferingsResponse.fromJson(jsonResponse);

      expect(response.success, true);
      expect(response.data.offerings.length, 1);
      
      final offering = response.data.offerings.first;
      expect(offering.id, "71939c02-6bed-4cdc-a51c-fe750aef27d0");
      expect(offering.isClass, false);
      expect(offering.isActive, true);
      
      expect(offering.category.name, "Osteopath");
      expect(offering.category.level, 1);
      expect(offering.category.parent!.name, "Health & Wellness");
      expect(offering.category.rootParent!.name, "Health & Wellness");
      
      expect(offering.serviceDetails.length, 1);
      final service = offering.serviceDetails.first;
      expect(service.name, "Osteopath");
      expect(service.description, "fjdsfjdslkf ds4");
      expect(service.durations.length, 1);
      
      final duration = service.durations.first;
      expect(duration.durationMinutes, 54);
      expect(duration.price, "444.00");
    });

    test('should parse API response correctly for deeper nested categories', () {
      final jsonResponse = {
        "success": true,
        "data": {
          "offerings": [
            {
              "id": "3ccd360f-552e-4685-995e-dacbed9122d2",
              "business_id": "7d135ccf-61c1-4583-a8ad-9c5f70bfee15",
              "category_id": "35f0c893-18ff-4489-ad76-3055e523e438",
              "is_class": false,
              "is_active": true,
              "createdAt": "2025-08-04T12:28:34.642Z",
              "updatedAt": "2025-08-04T12:28:34.642Z",
              "category": {
                "id": "35f0c893-18ff-4489-ad76-3055e523e438",
                "name": "Body Treatments Subcategory 2",
                "level": 2,
                "parent": {
                  "id": "d758eb48-8c5f-4f5c-a438-31e843a1401d",
                  "name": "Body Treatments",
                  "level": 1,
                  "parent": {
                    "id": "d06d4da7-dcda-4128-846f-3d9cd5cabe01",
                    "name": "Beauty",
                    "level": 0
                  }
                },
                "root_parent": {
                  "id": "d06d4da7-dcda-4128-846f-3d9cd5cabe01",
                  "name": "Beauty",
                  "is_class": false
                }
              },
              "service_details": [
                {
                  "id": "9e9d7289-44e8-486b-a922-188ee68184ed",
                  "name": "beauty 1",
                  "description": "short description of beuty",
                  "created_at": "2025-08-04T12:29:18.996Z",
                  "updated_at": "2025-08-04T12:29:18.996Z",
                  "durations": [
                    {
                      "id": "e27e2d42-fde8-47db-8982-12ca7b523419",
                      "duration_minutes": 45,
                      "price": "100.00",
                      "package_amount": null,
                      "package_person": null
                    }
                  ]
                }
              ]
            }
          ]
        }
      };

      final response = BusinessOfferingsResponse.fromJson(jsonResponse);

      expect(response.success, true);
      expect(response.data.offerings.length, 1);
      
      final offering = response.data.offerings.first;
      expect(offering.category.name, "Body Treatments Subcategory 2");
      expect(offering.category.level, 2);
      expect(offering.category.parent!.name, "Body Treatments");
      expect(offering.category.parent!.level, 1);
      expect(offering.category.parent!.parent!.name, "Beauty");
      expect(offering.category.parent!.parent!.level, 0);
      expect(offering.category.rootParent!.name, "Beauty");
    });

    test('should handle classes correctly', () {
      final jsonResponse = {
        "success": true,
        "data": {
          "offerings": [
            {
              "id": "0fc4deea-365e-4f09-a5d4-0e8359aac5e0",
              "business_id": "fbf4e222-7e62-42a4-a3a2-faaf16950040",
              "category_id": "605e4f3d-e7f6-49ee-8aa9-9e5e7bfcac5c",
              "is_class": true,
              "is_active": true,
              "createdAt": "2025-07-31T11:39:04.958Z",
              "updatedAt": "2025-07-31T11:39:04.958Z",
              "category": {
                "id": "605e4f3d-e7f6-49ee-8aa9-9e5e7bfcac5c",
                "name": "Barre",
                "level": 1,
                "parent": {
                  "id": "e55a7926-103b-496f-a11f-4eb5a09a37a3",
                  "name": "Fitness Classes",
                  "level": 0,
                  "is_class": true
                },
                "root_parent": {
                  "id": "e55a7926-103b-496f-a11f-4eb5a09a37a3",
                  "name": "Fitness Classes",
                  "is_class": true
                }
              },
              "service_details": [
                {
                  "id": "f89c49da-3074-4578-a15e-57bfa1e60d6c",
                  "name": "ma barre class",
                  "description": "its description of barre",
                  "created_at": "2025-07-31T11:39:40.901Z",
                  "updated_at": "2025-07-31T11:39:40.901Z",
                  "durations": [
                    {
                      "id": "290edc03-1405-4ff7-8d4c-d3817414f754",
                      "duration_minutes": 50,
                      "price": "100.00",
                      "package_amount": null,
                      "package_person": null
                    }
                  ]
                }
              ]
            }
          ]
        }
      };

      final response = BusinessOfferingsResponse.fromJson(jsonResponse);

      expect(response.success, true);
      final offering = response.data.offerings.first;
      expect(offering.isClass, true);
      expect(offering.category.name, "Barre");
      expect(offering.category.rootParent!.name, "Fitness Classes");
      expect(offering.category.rootParent!.isClass, true);
    });

    test('should handle duration formatting correctly', () {
      final duration1 = ServiceDuration(
        id: "1",
        durationMinutes: 30,
        price: "100.00",
      );
      
      final duration2 = ServiceDuration(
        id: "2",
        durationMinutes: 60,
        price: "150.00",
      );
      
      final duration3 = ServiceDuration(
        id: "3",
        durationMinutes: 90,
        price: "200.00",
      );

      expect(duration1.formattedDuration, "30 min");
      expect(duration2.formattedDuration, "1 hr");
      expect(duration3.formattedDuration, "1 hr 30 min");
    });
  });
}
