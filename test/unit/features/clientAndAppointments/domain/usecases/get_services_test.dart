import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/service.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/repositories/appointment_repository.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/get_services.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  group('GetServices UseCase Tests', () {
    late GetServices useCase;
    late MockAppointmentRepository mockRepository;

    setUp(() {
      mockRepository = MockAppointmentRepository();
      useCase = GetServices(mockRepository);
    });

    test('should get services from repository', () async {
      // Arrange
      final testServices = [
        Service(
          id: 'svc-1',
          businessServiceId: 'biz-svc-1',
          name: 'Massage Therapy',
          description: 'Relaxing therapeutic massage',
          isClass: false,
          durations: [
            ServiceDuration(id: 'dur-1', durationMinutes: 30, price: 50.0),
            ServiceDuration(id: 'dur-2', durationMinutes: 60, price: 90.0),
          ],
        ),
        Service(
          id: 'svc-2',
          businessServiceId: 'biz-svc-2',
          name: 'Yoga Class',
          description: 'Beginner friendly yoga session',
          isClass: true,
          durations: [
            ServiceDuration(id: 'dur-3', durationMinutes: 90, price: 25.0),
          ],
        ),
      ];

      when(mockRepository.getServices())
          .thenAnswer((_) async => testServices);

      // Act
      final result = await useCase();

      // Assert
      expect(result, testServices);
      expect(result.length, 2);
      expect(result.first.name, 'Massage Therapy');
      expect(result.first.isClass, false);
      expect(result.last.name, 'Yoga Class');
      expect(result.last.isClass, true);
      verify(mockRepository.getServices()).called(1);
    });

    test('should return empty list when no services available', () async {
      // Arrange
      final emptyServices = <Service>[];

      when(mockRepository.getServices())
          .thenAnswer((_) async => emptyServices);

      // Act
      final result = await useCase();

      // Assert
      expect(result, emptyServices);
      expect(result.isEmpty, true);
      verify(mockRepository.getServices()).called(1);
    });

    test('should handle repository exception', () async {
      // Arrange
      final exception = Exception('Failed to fetch services');

      when(mockRepository.getServices())
          .thenThrow(exception);

      // Act & Assert
      expect(
        () async => await useCase(),
        throwsA(exception),
      );
      verify(mockRepository.getServices()).called(1);
    });

    test('should get services with different duration options', () async {
      // Arrange
      final testServices = [
        Service(
          id: 'svc-multi-duration',
          businessServiceId: 'biz-svc-multi',
          name: 'Consultation',
          description: 'Medical consultation with flexible duration',
          isClass: false,
          durations: [
            ServiceDuration(id: 'dur-1', durationMinutes: 15, price: 25.0),
            ServiceDuration(id: 'dur-2', durationMinutes: 30, price: 45.0),
            ServiceDuration(id: 'dur-3', durationMinutes: 45, price: 65.0),
            ServiceDuration(id: 'dur-4', durationMinutes: 60, price: 80.0),
            ServiceDuration(id: 'dur-5', durationMinutes: 90, price: 110.0),
          ],
        ),
      ];

      when(mockRepository.getServices())
          .thenAnswer((_) async => testServices);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, 1);
      expect(result.first.durations.length, 5);
      expect(result.first.durations.first.durationMinutes, 15);
      expect(result.first.durations.last.durationMinutes, 90);
      verify(mockRepository.getServices()).called(1);
    });

    test('should get services with no duration options', () async {
      // Arrange
      final testServices = [
        Service(
          id: 'svc-no-duration',
          businessServiceId: 'biz-svc-no-duration',
          name: 'Custom Service',
          description: 'Service with custom duration',
          isClass: false,
          durations: [],
        ),
      ];

      when(mockRepository.getServices())
          .thenAnswer((_) async => testServices);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, 1);
      expect(result.first.durations, isEmpty);
      verify(mockRepository.getServices()).called(1);
    });

    test('should get mix of individual services and classes', () async {
      // Arrange
      final testServices = [
        Service(
          id: 'svc-individual-1',
          businessServiceId: 'biz-svc-ind-1',
          name: 'Personal Training',
          description: 'One-on-one fitness training',
          isClass: false,
          durations: [
            ServiceDuration(id: 'dur-1', durationMinutes: 60, price: 80.0),
          ],
        ),
        Service(
          id: 'svc-class-1',
          businessServiceId: 'biz-svc-cls-1',
          name: 'Group Fitness',
          description: 'High-energy group workout',
          isClass: true,
          durations: [
            ServiceDuration(id: 'dur-2', durationMinutes: 45, price: 20.0),
          ],
        ),
        Service(
          id: 'svc-individual-2',
          businessServiceId: 'biz-svc-ind-2',
          name: 'Nutrition Consultation',
          description: 'Personalized nutrition advice',
          isClass: false,
          durations: [
            ServiceDuration(id: 'dur-3', durationMinutes: 30, price: 50.0),
            ServiceDuration(id: 'dur-4', durationMinutes: 60, price: 90.0),
          ],
        ),
        Service(
          id: 'svc-class-2',
          businessServiceId: 'biz-svc-cls-2',
          name: 'Meditation Workshop',
          description: 'Guided meditation session',
          isClass: true,
          durations: [
            ServiceDuration(id: 'dur-5', durationMinutes: 120, price: 35.0),
          ],
        ),
      ];

      when(mockRepository.getServices())
          .thenAnswer((_) async => testServices);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, 4);
      
      final individualServices = result.where((s) => !s.isClass).toList();
      final classServices = result.where((s) => s.isClass).toList();
      
      expect(individualServices.length, 2);
      expect(classServices.length, 2);
      
      expect(individualServices.first.name, 'Personal Training');
      expect(classServices.first.name, 'Group Fitness');
      
      verify(mockRepository.getServices()).called(1);
    });

    test('should get services with varied pricing', () async {
      // Arrange
      final testServices = [
        Service(
          id: 'svc-low-cost',
          businessServiceId: 'biz-svc-low',
          name: 'Basic Consultation',
          description: 'Affordable basic service',
          isClass: false,
          durations: [
            ServiceDuration(id: 'dur-1', durationMinutes: 15, price: 15.0),
            ServiceDuration(id: 'dur-2', durationMinutes: 30, price: 25.0),
          ],
        ),
        Service(
          id: 'svc-premium',
          businessServiceId: 'biz-svc-premium',
          name: 'Premium Treatment',
          description: 'High-end luxury service',
          isClass: false,
          durations: [
            ServiceDuration(id: 'dur-3', durationMinutes: 90, price: 200.0),
            ServiceDuration(id: 'dur-4', durationMinutes: 120, price: 350.0),
          ],
        ),
        Service(
          id: 'svc-free',
          businessServiceId: 'biz-svc-free',
          name: 'Community Workshop',
          description: 'Free community service',
          isClass: true,
          durations: [
            ServiceDuration(id: 'dur-5', durationMinutes: 60, price: 0.0),
          ],
        ),
      ];

      when(mockRepository.getServices())
          .thenAnswer((_) async => testServices);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, 3);
      
      final lowCostService = result.firstWhere((s) => s.id == 'svc-low-cost');
      final premiumService = result.firstWhere((s) => s.id == 'svc-premium');
      final freeService = result.firstWhere((s) => s.id == 'svc-free');
      
      expect(lowCostService.durations.first.price, 15.0);
      expect(premiumService.durations.last.price, 350.0);
      expect(freeService.durations.first.price, 0.0);
      
      verify(mockRepository.getServices()).called(1);
    });

    test('should get large list of services', () async {
      // Arrange
      final largeServiceList = List.generate(25, (index) => Service(
        id: 'svc-$index',
        businessServiceId: 'biz-svc-$index',
        name: 'Service $index',
        description: 'Description for service $index',
        isClass: index % 3 == 0, // Every third service is a class
        durations: [
          ServiceDuration(
            id: 'dur-$index',
            durationMinutes: 30 + (index * 15),
            price: 25.0 + (index * 5),
          ),
        ],
      ));

      when(mockRepository.getServices())
          .thenAnswer((_) async => largeServiceList);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, 25);
      expect(result.first.name, 'Service 0');
      expect(result.last.name, 'Service 24');
      
      final classServices = result.where((s) => s.isClass).toList();
      expect(classServices.length, 9); // Every third service (0, 3, 6, 9, 12, 15, 18, 21, 24)
      
      verify(mockRepository.getServices()).called(1);
    });

    test('should get services with complex descriptions and names', () async {
      // Arrange
      final testServices = [
        Service(
          id: 'svc-complex',
          businessServiceId: 'biz-svc-complex',
          name: 'Advanced Therapeutic Massage with Aromatherapy & Hot Stones',
          description: 'A comprehensive therapeutic massage experience that combines traditional massage techniques with the healing properties of essential oils and the therapeutic benefits of heated volcanic stones. This service is designed to provide deep relaxation, muscle tension relief, and stress reduction through a multi-modal approach.',
          isClass: false,
          durations: [
            ServiceDuration(id: 'dur-1', durationMinutes: 75, price: 120.0),
            ServiceDuration(id: 'dur-2', durationMinutes: 90, price: 140.0),
            ServiceDuration(id: 'dur-3', durationMinutes: 120, price: 180.0),
          ],
        ),
      ];

      when(mockRepository.getServices())
          .thenAnswer((_) async => testServices);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, 1);
      expect(result.first.name.contains('Advanced Therapeutic Massage'), true);
      expect(result.first.description.length, greaterThan(200));
      expect(result.first.durations.length, 3);
      verify(mockRepository.getServices()).called(1);
    });
  });
}
