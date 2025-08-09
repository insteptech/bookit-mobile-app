import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/onboarding/domain/entities/onboarding_step.dart';

void main() {
  group('OnboardingStep', () {
    test('should have correct string values', () {
      expect(OnboardingStep.aboutYou.value, 'about_you');
      expect(OnboardingStep.locations.value, 'locations');
      expect(OnboardingStep.categories.value, 'categories');
      expect(OnboardingStep.services.value, 'services');
      expect(OnboardingStep.serviceDetails.value, 'service_details');
    });

    test('should contain all expected steps', () {
      final allSteps = OnboardingStep.values;
      expect(allSteps.length, 5);
      expect(allSteps, contains(OnboardingStep.aboutYou));
      expect(allSteps, contains(OnboardingStep.locations));
      expect(allSteps, contains(OnboardingStep.categories));
      expect(allSteps, contains(OnboardingStep.services));
      expect(allSteps, contains(OnboardingStep.serviceDetails));
    });
  });

  group('BusinessInfoStepData', () {
    test('should create instance with required fields', () {
      final stepData = BusinessInfoStepData(
        name: 'Test Business',
        email: 'test@example.com',
        phone: '+1234567890',
      );

      expect(stepData.name, 'Test Business');
      expect(stepData.email, 'test@example.com');
      expect(stepData.phone, '+1234567890');
      expect(stepData.businessId, isNull);
      expect(stepData.website, isNull);
      expect(stepData.activeStep, isNull);
    });

    test('should create instance with all fields', () {
      final stepData = BusinessInfoStepData(
        businessId: 'biz123',
        name: 'Test Business',
        email: 'test@example.com',
        phone: '+1234567890',
        website: 'https://example.com',
        activeStep: 'locations',
      );

      expect(stepData.businessId, 'biz123');
      expect(stepData.name, 'Test Business');
      expect(stepData.email, 'test@example.com');
      expect(stepData.phone, '+1234567890');
      expect(stepData.website, 'https://example.com');
      expect(stepData.activeStep, 'locations');
    });

    test('should convert to JSON correctly', () {
      final stepData = BusinessInfoStepData(
        businessId: 'biz123',
        name: 'Test Business',
        email: 'test@example.com',
        phone: '+1234567890',
        website: 'https://example.com',
        activeStep: 'locations',
      );

      final json = stepData.toJson();

      expect(json['business_id'], 'biz123');
      expect(json['name'], 'Test Business');
      expect(json['email'], 'test@example.com');
      expect(json['phone'], '+1234567890');
      expect(json['website'], 'https://example.com');
      expect(json['active_step'], 'locations');
    });

    test('should handle null values in JSON conversion', () {
      final stepData = BusinessInfoStepData(
        name: 'Test Business',
        email: 'test@example.com',
        phone: '+1234567890',
      );

      final json = stepData.toJson();

      expect(json['business_id'], isNull);
      expect(json['website'], isNull);
      expect(json['active_step'], isNull);
      expect(json['name'], 'Test Business');
      expect(json['email'], 'test@example.com');
      expect(json['phone'], '+1234567890');
    });
  });

  group('LocationStepData', () {
    test('should create instance and convert to JSON', () {
      final locations = [
        {'address': '123 Main St', 'city': 'Anytown'},
        {'address': '456 Oak Ave', 'city': 'Other City'},
      ];

      final stepData = LocationStepData(
        businessId: 'biz123',
        locations: locations,
      );

      expect(stepData.businessId, 'biz123');
      expect(stepData.locations, locations);

      final json = stepData.toJson();
      expect(json['business_id'], 'biz123');
      expect(json['locations'], locations);
    });

    test('should handle empty locations list', () {
      final stepData = LocationStepData(
        businessId: 'biz123',
        locations: [],
      );

      final json = stepData.toJson();
      expect(json['business_id'], 'biz123');
      expect(json['locations'], isEmpty);
    });
  });

  group('CategoryStepData', () {
    test('should create instance with required fields', () {
      final stepData = CategoryStepData(
        businessId: 'biz123',
        categoryId: 'cat456',
      );

      expect(stepData.businessId, 'biz123');
      expect(stepData.categoryId, 'cat456');
      expect(stepData.id, isNull);
    });

    test('should create instance with all fields', () {
      final stepData = CategoryStepData(
        id: 'step123',
        businessId: 'biz123',
        categoryId: 'cat456',
      );

      expect(stepData.id, 'step123');
      expect(stepData.businessId, 'biz123');
      expect(stepData.categoryId, 'cat456');
    });

    test('should convert to JSON correctly', () {
      final stepData = CategoryStepData(
        id: 'step123',
        businessId: 'biz123',
        categoryId: 'cat456',
      );

      final json = stepData.toJson();
      expect(json['id'], 'step123');
      expect(json['business_id'], 'biz123');
      expect(json['category_id'], 'cat456');
    });
  });

  group('ServicesStepData', () {
    test('should create instance and convert to JSON', () {
      final services = [
        {'name': 'Service 1', 'price': 100},
        {'name': 'Service 2', 'price': 200},
      ];

      final stepData = ServicesStepData(services: services);

      expect(stepData.services, services);

      final json = stepData.toJson();
      expect(json['services'], services);
    });

    test('should handle empty services list', () {
      final stepData = ServicesStepData(services: []);

      final json = stepData.toJson();
      expect(json['services'], isEmpty);
    });
  });

  group('ServiceDetailsStepData', () {
    test('should create instance and convert to JSON', () {
      final details = [
        {'detail': 'Duration: 60 min'},
        {'detail': 'Includes materials'},
      ];

      final stepData = ServiceDetailsStepData(details: details);

      expect(stepData.details, details);

      final json = stepData.toJson();
      expect(json['details'], details);
    });

    test('should handle empty details list', () {
      final stepData = ServiceDetailsStepData(details: []);

      final json = stepData.toJson();
      expect(json['details'], isEmpty);
    });
  });
}
