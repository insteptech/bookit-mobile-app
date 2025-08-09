import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/onboarding/domain/entities/onboarding_request.dart';
import 'package:bookit_mobile_app/features/onboarding/domain/entities/onboarding_step.dart';

void main() {
  group('OnboardingRequest', () {
    test('should create instance with step and data', () {
      final data = BusinessInfoStepData(
        name: 'Test Business',
        email: 'test@example.com',
        phone: '+1234567890',
      );

      final request = OnboardingRequest(
        step: OnboardingStep.aboutYou,
        data: data,
      );

      expect(request.step, OnboardingStep.aboutYou);
      expect(request.data, data);
    });

    test('should convert to JSON correctly', () {
      final data = BusinessInfoStepData(
        businessId: 'biz123',
        name: 'Test Business',
        email: 'test@example.com',
        phone: '+1234567890',
        website: 'https://example.com',
        activeStep: 'locations',
      );

      final request = OnboardingRequest(
        step: OnboardingStep.aboutYou,
        data: data,
      );

      final json = request.toJson();

      expect(json['step'], 'about_you');
      expect(json['data'], isA<Map<String, dynamic>>());
      expect(json['data']['business_id'], 'biz123');
      expect(json['data']['name'], 'Test Business');
      expect(json['data']['email'], 'test@example.com');
      expect(json['data']['phone'], '+1234567890');
      expect(json['data']['website'], 'https://example.com');
      expect(json['data']['active_step'], 'locations');
    });
  });

  group('OnboardingRequestFactory', () {
    group('createBusinessInfoRequest', () {
      test('should create business info request with required fields', () {
        final request = OnboardingRequestFactory.createBusinessInfoRequest(
          name: 'Test Business',
          email: 'test@example.com',
          phone: '+1234567890',
        );

        expect(request.step, OnboardingStep.aboutYou);
        expect(request.data, isA<BusinessInfoStepData>());

        final data = request.data as BusinessInfoStepData;
        expect(data.name, 'Test Business');
        expect(data.email, 'test@example.com');
        expect(data.phone, '+1234567890');
        expect(data.businessId, isNull);
        expect(data.website, isNull);
        expect(data.activeStep, 'locations');
      });

      test('should create business info request with all fields', () {
        final request = OnboardingRequestFactory.createBusinessInfoRequest(
          name: 'Test Business',
          email: 'test@example.com',
          phone: '+1234567890',
          website: 'https://example.com',
          businessId: 'biz123',
        );

        final data = request.data as BusinessInfoStepData;
        expect(data.businessId, 'biz123');
        expect(data.website, 'https://example.com');
        expect(data.activeStep, 'locations');
      });
    });

    group('createLocationRequest', () {
      test('should create location request correctly', () {
        final locations = [
          {'address': '123 Main St', 'city': 'Anytown'},
          {'address': '456 Oak Ave', 'city': 'Other City'},
        ];

        final request = OnboardingRequestFactory.createLocationRequest(
          businessId: 'biz123',
          locations: locations,
        );

        expect(request.step, OnboardingStep.locations);
        expect(request.data, isA<LocationStepData>());

        final data = request.data as LocationStepData;
        expect(data.businessId, 'biz123');
        expect(data.locations, locations);
      });

      test('should handle empty locations list', () {
        final request = OnboardingRequestFactory.createLocationRequest(
          businessId: 'biz123',
          locations: [],
        );

        final data = request.data as LocationStepData;
        expect(data.locations, isEmpty);
      });
    });

    group('createCategoryRequest', () {
      test('should create category request with required fields', () {
        final request = OnboardingRequestFactory.createCategoryRequest(
          businessId: 'biz123',
          categoryId: 'cat456',
        );

        expect(request.step, OnboardingStep.categories);
        expect(request.data, isA<CategoryStepData>());

        final data = request.data as CategoryStepData;
        expect(data.businessId, 'biz123');
        expect(data.categoryId, 'cat456');
        expect(data.id, isNull);
      });

      test('should create category request with all fields', () {
        final request = OnboardingRequestFactory.createCategoryRequest(
          id: 'step123',
          businessId: 'biz123',
          categoryId: 'cat456',
        );

        final data = request.data as CategoryStepData;
        expect(data.id, 'step123');
        expect(data.businessId, 'biz123');
        expect(data.categoryId, 'cat456');
      });
    });

    group('createServicesRequest', () {
      test('should create services request correctly', () {
        final services = [
          {'name': 'Service 1', 'price': 100},
          {'name': 'Service 2', 'price': 200},
        ];

        final request = OnboardingRequestFactory.createServicesRequest(
          services: services,
        );

        expect(request.step, OnboardingStep.services);
        expect(request.data, isA<ServicesStepData>());

        final data = request.data as ServicesStepData;
        expect(data.services, services);
      });

      test('should handle empty services list', () {
        final request = OnboardingRequestFactory.createServicesRequest(
          services: [],
        );

        final data = request.data as ServicesStepData;
        expect(data.services, isEmpty);
      });
    });

    group('createServiceDetailsRequest', () {
      test('should create service details request correctly', () {
        final details = [
          {'detail': 'Duration: 60 min'},
          {'detail': 'Includes materials'},
        ];

        final request = OnboardingRequestFactory.createServiceDetailsRequest(
          details: details,
        );

        expect(request.step, OnboardingStep.serviceDetails);
        expect(request.data, isA<ServiceDetailsStepData>());

        final data = request.data as ServiceDetailsStepData;
        expect(data.details, details);
      });

      test('should handle empty details list', () {
        final request = OnboardingRequestFactory.createServiceDetailsRequest(
          details: [],
        );

        final data = request.data as ServiceDetailsStepData;
        expect(data.details, isEmpty);
      });
    });
  });
}
