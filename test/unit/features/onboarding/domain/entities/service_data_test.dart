import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/onboarding/domain/entities/service_data.dart';

void main() {
  group('ServiceDuration', () {
    test('should create instance with required fields', () {
      final duration = ServiceDuration(
        durationMinutes: 60,
        price: 100,
      );

      expect(duration.durationMinutes, 60);
      expect(duration.price, 100);
      expect(duration.packageAmount, isNull);
      expect(duration.packagePerson, isNull);
    });

    test('should create instance with all fields', () {
      final duration = ServiceDuration(
        durationMinutes: 90,
        price: 150,
        packageAmount: 5,
        packagePerson: 10,
      );

      expect(duration.durationMinutes, 90);
      expect(duration.price, 150);
      expect(duration.packageAmount, 5);
      expect(duration.packagePerson, 10);
    });

    test('should convert to JSON with required fields only', () {
      final duration = ServiceDuration(
        durationMinutes: 60,
        price: 100,
      );

      final json = duration.toJson();

      expect(json['duration_minutes'], 60);
      expect(json['price'], 100);
      expect(json.containsKey('package_amount'), false);
      expect(json.containsKey('package_person'), false);
    });

    test('should convert to JSON with all fields', () {
      final duration = ServiceDuration(
        durationMinutes: 90,
        price: 150,
        packageAmount: 5,
        packagePerson: 10,
      );

      final json = duration.toJson();

      expect(json['duration_minutes'], 90);
      expect(json['price'], 150);
      expect(json['package_amount'], 5);
      expect(json['package_person'], 10);
    });

    test('should include null package fields when provided', () {
      final duration = ServiceDuration(
        durationMinutes: 60,
        price: 100,
        packageAmount: null,
        packagePerson: 5,
      );

      final json = duration.toJson();

      expect(json['duration_minutes'], 60);
      expect(json['price'], 100);
      expect(json.containsKey('package_amount'), false);
      expect(json['package_person'], 5);
    });
  });

  group('ServiceData', () {
    test('should create instance with required fields', () {
      final durations = [
        ServiceDuration(durationMinutes: 60, price: 100),
      ];

      final serviceData = ServiceData(
        serviceId: 'srv123',
        name: 'Test Service',
        description: 'Test Description',
        durations: durations,
      );

      expect(serviceData.serviceId, 'srv123');
      expect(serviceData.name, 'Test Service');
      expect(serviceData.description, 'Test Description');
      expect(serviceData.durations, durations);
      expect(serviceData.spotsAvailable, isNull);
    });

    test('should create instance with all fields', () {
      final durations = [
        ServiceDuration(durationMinutes: 60, price: 100),
        ServiceDuration(durationMinutes: 90, price: 150),
      ];

      final serviceData = ServiceData(
        serviceId: 'srv123',
        name: 'Test Service',
        description: 'Test Description',
        durations: durations,
        spotsAvailable: 5,
      );

      expect(serviceData.spotsAvailable, 5);
    });

    test('should convert to JSON correctly', () {
      final durations = [
        ServiceDuration(durationMinutes: 60, price: 100),
        ServiceDuration(durationMinutes: 90, price: 150, packageAmount: 3),
      ];

      final serviceData = ServiceData(
        serviceId: 'srv123',
        name: 'Test Service',
        description: 'Test Description',
        durations: durations,
        spotsAvailable: 5,
      );

      final json = serviceData.toJson('biz123');

      expect(json['business_id'], 'biz123');
      expect(json['service_id'], 'srv123');
      expect(json['name'], 'Test Service');
      expect(json['description'], 'Test Description');
      expect(json['spots_available'], 5);
      expect(json['durations'], isA<List>());
      expect(json['durations'].length, 2);

      final firstDuration = json['durations'][0];
      expect(firstDuration['duration_minutes'], 60);
      expect(firstDuration['price'], 100);

      final secondDuration = json['durations'][1];
      expect(secondDuration['duration_minutes'], 90);
      expect(secondDuration['price'], 150);
      expect(secondDuration['package_amount'], 3);
    });
  });

  group('ServiceDataFactory', () {
    group('fromFormData', () {
      test('should create service data from valid form data', () {
        final durationAndCosts = [
          {'duration': '60', 'cost': '100'},
          {'duration': '90', 'cost': '150', 'packageAmount': '5'},
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: 'Test Service',
          description: 'Test Description',
          durationAndCosts: durationAndCosts,
        );

        expect(result, isNotNull);
        expect(result!.serviceId, 'srv123');
        expect(result.name, 'Test Service');
        expect(result.description, 'Test Description');
        expect(result.durations.length, 2);
        expect(result.spotsAvailable, isNull);

        final firstDuration = result.durations[0];
        expect(firstDuration.durationMinutes, 60);
        expect(firstDuration.price, 100);
        expect(firstDuration.packageAmount, isNull);

        final secondDuration = result.durations[1];
        expect(secondDuration.durationMinutes, 90);
        expect(secondDuration.price, 150);
        expect(secondDuration.packageAmount, 5);
      });

      test('should handle spots available', () {
        final durationAndCosts = [
          {'duration': '60', 'cost': '100'},
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: 'Test Service',
          description: 'Test Description',
          durationAndCosts: durationAndCosts,
          spotsAvailable: true,
          spotsText: '10',
        );

        expect(result!.spotsAvailable, 10);
      });

      test('should trim name and description', () {
        final durationAndCosts = [
          {'duration': '60', 'cost': '100'},
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: '  Test Service  ',
          description: '  Test Description  ',
          durationAndCosts: durationAndCosts,
        );

        expect(result!.name, 'Test Service');
        expect(result.description, 'Test Description');
      });

      test('should return null for empty name', () {
        final durationAndCosts = [
          {'duration': '60', 'cost': '100'},
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: '',
          description: 'Test Description',
          durationAndCosts: durationAndCosts,
        );

        expect(result, isNull);
      });

      test('should return null for whitespace-only name', () {
        final durationAndCosts = [
          {'duration': '60', 'cost': '100'},
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: '   ',
          description: 'Test Description',
          durationAndCosts: durationAndCosts,
        );

        expect(result, isNull);
      });

      test('should return null for empty durations', () {
        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: 'Test Service',
          description: 'Test Description',
          durationAndCosts: [],
        );

        expect(result, isNull);
      });

      test('should filter out invalid duration entries', () {
        final durationAndCosts = [
          {'duration': '60', 'cost': '100'},
          {'duration': '', 'cost': '150'},  // Invalid - empty duration
          {'duration': '90', 'cost': ''},   // Invalid - empty cost
          {'duration': '120', 'cost': '200'},
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: 'Test Service',
          description: 'Test Description',
          durationAndCosts: durationAndCosts,
        );

        expect(result!.durations.length, 2);
        expect(result.durations[0].durationMinutes, 60);
        expect(result.durations[0].price, 100);
        expect(result.durations[1].durationMinutes, 120);
        expect(result.durations[1].price, 200);
      });

      test('should return null when all durations are filtered out', () {
        final durationAndCosts = [
          {'duration': '', 'cost': '100'},
          {'duration': '60', 'cost': ''},
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: 'Test Service',
          description: 'Test Description',
          durationAndCosts: durationAndCosts,
        );

        expect(result, isNull);
      });

      test('should handle package fields correctly', () {
        final durationAndCosts = [
          {
            'duration': '60',
            'cost': '100',
            'packageAmount': '5',
            'packagePerson': '2',
          },
          {
            'duration': '90',
            'cost': '150',
            'packageAmount': '',  // Empty string should be treated as null
            'packagePerson': '3',
          },
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: 'Test Service',
          description: 'Test Description',
          durationAndCosts: durationAndCosts,
        );

        expect(result!.durations.length, 2);

        final firstDuration = result.durations[0];
        expect(firstDuration.packageAmount, 5);
        expect(firstDuration.packagePerson, 2);

        final secondDuration = result.durations[1];
        expect(secondDuration.packageAmount, isNull);
        expect(secondDuration.packagePerson, 3);
      });

      test('should handle invalid number parsing gracefully', () {
        final durationAndCosts = [
          {'duration': 'invalid', 'cost': '100'},
          {'duration': '60', 'cost': 'invalid'},
          {'duration': '90', 'cost': '150'},
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: 'Test Service',
          description: 'Test Description',
          durationAndCosts: durationAndCosts,
        );

        expect(result!.durations.length, 1);
        expect(result.durations[0].durationMinutes, 90);
        expect(result.durations[0].price, 150);
      });

      test('should handle spots available with invalid number', () {
        final durationAndCosts = [
          {'duration': '60', 'cost': '100'},
        ];

        final result = ServiceDataFactory.fromFormData(
          serviceId: 'srv123',
          name: 'Test Service',
          description: 'Test Description',
          durationAndCosts: durationAndCosts,
          spotsAvailable: true,
          spotsText: 'invalid',
        );

        expect(result!.spotsAvailable, isNull);
      });
    });
  });
}
