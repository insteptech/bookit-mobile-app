import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/service.dart';

void main() {
  group('Service Entity Tests', () {
    test('should create a Service with all fields', () {
      // Arrange
      final durations = [
        ServiceDuration(id: 'dur-1', durationMinutes: 30, price: 50.0),
        ServiceDuration(id: 'dur-2', durationMinutes: 60, price: 90.0),
      ];

      // Act
      final service = Service(
        id: 'svc-1',
        businessServiceId: 'biz-svc-1',
        name: 'Massage Therapy',
        description: 'Relaxing therapeutic massage',
        isClass: false,
        durations: durations,
      );

      // Assert
      expect(service.id, 'svc-1');
      expect(service.businessServiceId, 'biz-svc-1');
      expect(service.name, 'Massage Therapy');
      expect(service.description, 'Relaxing therapeutic massage');
      expect(service.isClass, false);
      expect(service.durations, durations);
      expect(service.durations.length, 2);
    });

    test('should create a Service for class type', () {
      // Arrange
      final durations = [
        ServiceDuration(id: 'dur-1', durationMinutes: 90, price: 25.0),
      ];

      // Act
      final service = Service(
        id: 'svc-2',
        businessServiceId: 'biz-svc-2',
        name: 'Yoga Class',
        description: 'Beginner friendly yoga session',
        isClass: true,
        durations: durations,
      );

      // Assert
      expect(service.id, 'svc-2');
      expect(service.businessServiceId, 'biz-svc-2');
      expect(service.name, 'Yoga Class');
      expect(service.description, 'Beginner friendly yoga session');
      expect(service.isClass, true);
      expect(service.durations.length, 1);
      expect(service.durations.first.durationMinutes, 90);
    });

    test('should create a Service with empty durations', () {
      // Act
      final service = Service(
        id: 'svc-3',
        businessServiceId: 'biz-svc-3',
        name: 'Consultation',
        description: 'Initial consultation',
        isClass: false,
        durations: [],
      );

      // Assert
      expect(service.durations, isEmpty);
    });

    test('should copy Service with new values', () {
      // Arrange
      final originalDurations = [
        ServiceDuration(id: 'dur-1', durationMinutes: 30, price: 50.0),
      ];
      final originalService = Service(
        id: 'svc-1',
        businessServiceId: 'biz-svc-1',
        name: 'Original Service',
        description: 'Original description',
        isClass: false,
        durations: originalDurations,
      );

      final newDurations = [
        ServiceDuration(id: 'dur-2', durationMinutes: 60, price: 80.0),
        ServiceDuration(id: 'dur-3', durationMinutes: 90, price: 110.0),
      ];

      // Act
      final updatedService = originalService.copyWith(
        name: 'Updated Service',
        description: 'Updated description',
        isClass: true,
        durations: newDurations,
      );

      // Assert
      expect(updatedService.id, 'svc-1'); // unchanged
      expect(updatedService.businessServiceId, 'biz-svc-1'); // unchanged
      expect(updatedService.name, 'Updated Service'); // changed
      expect(updatedService.description, 'Updated description'); // changed
      expect(updatedService.isClass, true); // changed
      expect(updatedService.durations, newDurations); // changed
      expect(updatedService.durations.length, 2);
    });

    test('should copy Service with all fields', () {
      // Arrange
      final originalService = Service(
        id: 'svc-1',
        businessServiceId: 'biz-svc-1',
        name: 'Original Service',
        description: 'Original description',
        isClass: false,
        durations: [],
      );

      final newDurations = [
        ServiceDuration(id: 'dur-1', durationMinutes: 45, price: 75.0),
      ];

      // Act
      final updatedService = originalService.copyWith(
        id: 'svc-2',
        businessServiceId: 'biz-svc-2',
        name: 'New Service',
        description: 'New description',
        isClass: true,
        durations: newDurations,
      );

      // Assert
      expect(updatedService.id, 'svc-2');
      expect(updatedService.businessServiceId, 'biz-svc-2');
      expect(updatedService.name, 'New Service');
      expect(updatedService.description, 'New description');
      expect(updatedService.isClass, true);
      expect(updatedService.durations, newDurations);
    });

    test('should maintain original values when copying with null', () {
      // Arrange
      final originalDurations = [
        ServiceDuration(id: 'dur-1', durationMinutes: 30, price: 50.0),
      ];
      final originalService = Service(
        id: 'svc-1',
        businessServiceId: 'biz-svc-1',
        name: 'Original Service',
        description: 'Original description',
        isClass: false,
        durations: originalDurations,
      );

      // Act
      final copiedService = originalService.copyWith();

      // Assert
      expect(copiedService.id, originalService.id);
      expect(copiedService.businessServiceId, originalService.businessServiceId);
      expect(copiedService.name, originalService.name);
      expect(copiedService.description, originalService.description);
      expect(copiedService.isClass, originalService.isClass);
      expect(copiedService.durations, originalService.durations);
    });
  });

  group('ServiceDuration Entity Tests', () {
    test('should create a ServiceDuration with all fields', () {
      // Act
      final duration = ServiceDuration(
        id: 'dur-1',
        durationMinutes: 60,
        price: 100.0,
      );

      // Assert
      expect(duration.id, 'dur-1');
      expect(duration.durationMinutes, 60);
      expect(duration.price, 100.0);
    });

    test('should create ServiceDuration with different durations and prices', () {
      // Test different common durations
      final testCases = [
        {'duration': 15, 'price': 25.0},
        {'duration': 30, 'price': 45.0},
        {'duration': 45, 'price': 65.0},
        {'duration': 60, 'price': 85.0},
        {'duration': 90, 'price': 120.0},
        {'duration': 120, 'price': 150.0},
      ];

      for (int i = 0; i < testCases.length; i++) {
        final testCase = testCases[i];
        final duration = ServiceDuration(
          id: 'dur-${i + 1}',
          durationMinutes: testCase['duration'] as int,
          price: testCase['price'] as double,
        );

        expect(duration.durationMinutes, testCase['duration']);
        expect(duration.price, testCase['price']);
      }
    });

    test('should handle zero and extreme values', () {
      // Test edge cases
      final extremeDuration = ServiceDuration(
        id: 'dur-extreme',
        durationMinutes: 0,
        price: 0.0,
      );

      expect(extremeDuration.durationMinutes, 0);
      expect(extremeDuration.price, 0.0);

      final maxDuration = ServiceDuration(
        id: 'dur-max',
        durationMinutes: 999,
        price: 9999.99,
      );

      expect(maxDuration.durationMinutes, 999);
      expect(maxDuration.price, 9999.99);
    });

    test('should copy ServiceDuration with new values', () {
      // Arrange
      final originalDuration = ServiceDuration(
        id: 'dur-1',
        durationMinutes: 30,
        price: 50.0,
      );

      // Act
      final updatedDuration = originalDuration.copyWith(
        durationMinutes: 60,
        price: 90.0,
      );

      // Assert
      expect(updatedDuration.id, 'dur-1'); // unchanged
      expect(updatedDuration.durationMinutes, 60); // changed
      expect(updatedDuration.price, 90.0); // changed
    });

    test('should copy ServiceDuration with all fields', () {
      // Arrange
      final originalDuration = ServiceDuration(
        id: 'dur-1',
        durationMinutes: 30,
        price: 50.0,
      );

      // Act
      final updatedDuration = originalDuration.copyWith(
        id: 'dur-2',
        durationMinutes: 90,
        price: 120.0,
      );

      // Assert
      expect(updatedDuration.id, 'dur-2');
      expect(updatedDuration.durationMinutes, 90);
      expect(updatedDuration.price, 120.0);
    });

    test('should maintain original values when copying ServiceDuration with null', () {
      // Arrange
      final originalDuration = ServiceDuration(
        id: 'dur-1',
        durationMinutes: 45,
        price: 75.0,
      );

      // Act
      final copiedDuration = originalDuration.copyWith();

      // Assert
      expect(copiedDuration.id, originalDuration.id);
      expect(copiedDuration.durationMinutes, originalDuration.durationMinutes);
      expect(copiedDuration.price, originalDuration.price);
    });
  });
}
