import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/practitioner.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/service.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/get_practitioners.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/get_services.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/book_appointment.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/application/controllers/appointment_controller.dart';

class MockGetPractitioners extends Mock implements GetPractitioners {}
class MockGetServices extends Mock implements GetServices {}
class MockBookAppointment extends Mock implements BookAppointment {}

void main() {
  group('AppointmentController Tests', () {
    late AppointmentController controller;
    late MockGetPractitioners mockGetPractitioners;
    late MockGetServices mockGetServices;
    late MockBookAppointment mockBookAppointment;
    late ProviderContainer container;

    setUp(() {
      mockGetPractitioners = MockGetPractitioners();
      mockGetServices = MockGetServices();
      mockBookAppointment = MockBookAppointment();
      controller = AppointmentController(
        mockGetPractitioners,
        mockGetServices,
        mockBookAppointment,
      );
      container = ProviderContainer();
    });

    tearDown(() {
      controller.dispose();
      container.dispose();
    });

    test('should have initial state', () {
      // Assert
      expect(controller.state.practitioners, isEmpty);
      expect(controller.state.serviceList, isEmpty);
      expect(controller.state.selectedPractitioner, '');
      expect(controller.state.selectedService, '');
      expect(controller.state.selectedDuration, '');
      expect(controller.state.isLoading, false);
      expect(controller.state.error, isNull);
      expect(controller.state.partialPayload, isNull);
      expect(controller.state.canProceed, false);
    });

    group('updateSelectedPractitioner', () {
      test('should update selected practitioner', () {
        // Arrange
        const practitionerId = 'prac-1';

        // Act
        controller.updateSelectedPractitioner(practitionerId);

        // Assert
        expect(controller.state.selectedPractitioner, practitionerId);
      });

      test('should update to empty practitioner', () {
        // Arrange
        controller.updateSelectedPractitioner('prac-1');

        // Act
        controller.updateSelectedPractitioner('');

        // Assert
        expect(controller.state.selectedPractitioner, '');
      });
    });

    group('updateSelectedService', () {
      test('should update selected service and reset duration', () {
        // Arrange
        const serviceId = 'svc-1';
        controller.updateSelectedDuration('dur-1'); // Set initial duration

        // Act
        controller.updateSelectedService(serviceId);

        // Assert
        expect(controller.state.selectedService, serviceId);
        expect(controller.state.selectedDuration, ''); // Should be reset
      });

      test('should update to empty service', () {
        // Arrange
        controller.updateSelectedService('svc-1');
        controller.updateSelectedDuration('dur-1');

        // Act
        controller.updateSelectedService('');

        // Assert
        expect(controller.state.selectedService, '');
        expect(controller.state.selectedDuration, ''); // Should be reset
      });
    });

    group('updateSelectedDuration', () {
      test('should update selected duration', () {
        // Arrange
        const durationId = 'dur-1';

        // Act
        controller.updateSelectedDuration(durationId);

        // Assert
        expect(controller.state.selectedDuration, durationId);
      });

      test('should update to empty duration', () {
        // Arrange
        controller.updateSelectedDuration('dur-1');

        // Act
        controller.updateSelectedDuration('');

        // Assert
        expect(controller.state.selectedDuration, '');
      });
    });

    group('clearSelections', () {
      test('should clear all selections', () {
        // Arrange
        controller.updateSelectedPractitioner('prac-1');
        controller.updateSelectedService('svc-1');
        controller.updateSelectedDuration('dur-1');

        // Act
        controller.clearSelections();

        // Assert
        expect(controller.state.selectedPractitioner, '');
        expect(controller.state.selectedService, '');
        expect(controller.state.selectedDuration, '');
        expect(controller.state.canProceed, false);
      });
    });

    group('updatePartialPayload', () {
      test('should update partial payload', () {
        // Arrange
        final payload = {
          'business_id': 'biz-1',
          'location_id': 'loc-1',
          'date': '2024-01-15',
        };

        // Act
        controller.updatePartialPayload(payload);

        // Assert
        expect(controller.state.partialPayload, payload);
      });

      test('should update with complex payload', () {
        // Arrange
        final complexPayload = {
          'appointment': {
            'business_id': 'biz-1',
            'location_id': 'loc-1',
            'client': {
              'id': 'client-1',
              'preferences': ['morning', 'quiet'],
            },
          },
          'metadata': {
            'source': 'mobile_app',
            'version': '1.0.0',
          },
        };

        // Act
        controller.updatePartialPayload(complexPayload);

        // Assert
        expect(controller.state.partialPayload, complexPayload);
        expect(controller.state.partialPayload!['appointment']['business_id'], 'biz-1');
        expect(controller.state.partialPayload!['metadata']['source'], 'mobile_app');
      });
    });

    group('fetchPractitioners', () {
      test('should fetch practitioners successfully', () async {
        // Arrange
        const locationId = 'loc-1';
        final practitioners = [
          Practitioner(
            id: 'prac-1',
            name: 'Dr. Smith',
            email: 'dr.smith@example.com',
            locationSchedules: [
              {
                'location_id': locationId,
                'schedule': [
                  {'day': 'monday', 'start': '09:00', 'end': '17:00'},
                ]
              }
            ],
            serviceIds: ['service-1', 'service-2'],
          ),
          Practitioner(
            id: 'prac-2',
            name: 'Dr. Johnson',
            email: 'dr.johnson@example.com',
            locationSchedules: [
              {
                'location_id': locationId,
                'schedule': [
                  {'day': 'tuesday', 'start': '08:00', 'end': '16:00'},
                ]
              }
            ],
            serviceIds: ['service-2', 'service-3'],
          ),
        ];

        when(mockGetPractitioners(locationId))
            .thenAnswer((_) async => practitioners);

        // Act
        await controller.fetchPractitioners(locationId);

        // Assert
        expect(controller.state.isLoading, false);
        expect(controller.state.error, isNull);
        expect(controller.state.practitioners.length, 2);
        
        final firstPractitioner = controller.state.practitioners[0];
        expect(firstPractitioner['id'], 'prac-1');
        expect(firstPractitioner['name'], 'Dr. Smith');
        expect(firstPractitioner['email'], 'dr.smith@example.com');
        expect(firstPractitioner['location_schedules'], practitioners[0].locationSchedules);
        expect(firstPractitioner['service_ids'], ['service-1', 'service-2']);

        verify(mockGetPractitioners(locationId)).called(1);
      });

      test('should handle fetch practitioners error', () async {
        // Arrange
        const locationId = 'loc-error';
        final exception = Exception('Failed to fetch practitioners');

        when(mockGetPractitioners(locationId))
            .thenThrow(exception);

        // Act
        await controller.fetchPractitioners(locationId);

        // Assert
        expect(controller.state.isLoading, false);
        expect(controller.state.error, exception.toString());
        expect(controller.state.practitioners, isEmpty);

        verify(mockGetPractitioners(locationId)).called(1);
      });

      test('should handle empty practitioners list', () async {
        // Arrange
        const locationId = 'loc-empty';
        final emptyPractitioners = <Practitioner>[];

        when(mockGetPractitioners(locationId))
            .thenAnswer((_) async => emptyPractitioners);

        // Act
        await controller.fetchPractitioners(locationId);

        // Assert
        expect(controller.state.isLoading, false);
        expect(controller.state.error, isNull);
        expect(controller.state.practitioners, isEmpty);

        verify(mockGetPractitioners(locationId)).called(1);
      });
    });

    group('fetchServices', () {
      test('should fetch services successfully', () async {
        // Arrange
        final services = [
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

        when(mockGetServices())
            .thenAnswer((_) async => services);

        // Act
        await controller.fetchServices();

        // Assert
        expect(controller.state.isLoading, false);
        expect(controller.state.error, isNull);
        expect(controller.state.serviceList.length, 2);
        
        final firstService = controller.state.serviceList[0];
        expect(firstService['id'], 'svc-1');
        expect(firstService['business_service_id'], 'biz-svc-1');
        expect(firstService['name'], 'Massage Therapy');
        expect(firstService['description'], 'Relaxing therapeutic massage');
        expect(firstService['is_class'], false);
        expect(firstService['durations'].length, 2);
        
        final firstDuration = firstService['durations'][0];
        expect(firstDuration['id'], 'dur-1');
        expect(firstDuration['duration_minutes'], 30);
        expect(firstDuration['price'], 50.0);

        verify(mockGetServices()).called(1);
      });

      test('should handle fetch services error', () async {
        // Arrange
        final exception = Exception('Failed to fetch services');

        when(mockGetServices())
            .thenThrow(exception);

        // Act
        await controller.fetchServices();

        // Assert
        expect(controller.state.isLoading, false);
        expect(controller.state.error, exception.toString());
        expect(controller.state.serviceList, isEmpty);

        verify(mockGetServices()).called(1);
      });

      test('should handle empty services list', () async {
        // Arrange
        final emptyServices = <Service>[];

        when(mockGetServices())
            .thenAnswer((_) async => emptyServices);

        // Act
        await controller.fetchServices();

        // Assert
        expect(controller.state.isLoading, false);
        expect(controller.state.error, isNull);
        expect(controller.state.serviceList, isEmpty);

        verify(mockGetServices()).called(1);
      });
    });

    group('bookAppointment', () {
      test('should book appointment successfully', () async {
        // Arrange
        const businessId = 'biz-1';
        const locationId = 'loc-1';
        const businessServiceId = 'biz-svc-1';
        const practitionerId = 'prac-1';
        final date = DateTime(2024, 1, 15);
        const startTime = '14:00';
        const endTime = '15:00';
        const userId = 'user-1';
        const durationMinutes = 60;
        const serviceName = 'Consultation';
        const practitionerName = 'Dr. Smith';

        when(mockBookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: serviceName,
          practitionerName: practitionerName,
        )).thenAnswer((_) async => {});

        // Act
        await controller.bookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: serviceName,
          practitionerName: practitionerName,
        );

        // Assert
        verify(mockBookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: serviceName,
          practitionerName: practitionerName,
        )).called(1);
      });

      test('should book appointment with client ID', () async {
        // Arrange
        const businessId = 'biz-1';
        const locationId = 'loc-1';
        const businessServiceId = 'biz-svc-1';
        const practitionerId = 'prac-1';
        final date = DateTime(2024, 1, 15);
        const startTime = '14:00';
        const endTime = '15:00';
        const userId = 'user-1';
        const durationMinutes = 60;
        const serviceName = 'Consultation';
        const practitionerName = 'Dr. Smith';
        const clientId = 'client-1';

        when(mockBookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: serviceName,
          practitionerName: practitionerName,
          clientId: clientId,
        )).thenAnswer((_) async => {});

        // Act
        await controller.bookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: serviceName,
          practitionerName: practitionerName,
          clientId: clientId,
        );

        // Assert
        verify(mockBookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: serviceName,
          practitionerName: practitionerName,
          clientId: clientId,
        )).called(1);
      });

      test('should handle book appointment error', () async {
        // Arrange
        const businessId = 'biz-1';
        const locationId = 'loc-1';
        const businessServiceId = 'biz-svc-1';
        const practitionerId = 'prac-1';
        final date = DateTime(2024, 1, 15);
        const startTime = '14:00';
        const endTime = '15:00';
        const userId = 'user-1';
        const durationMinutes = 60;
        const serviceName = 'Consultation';
        const practitionerName = 'Dr. Smith';
        final exception = Exception('Failed to book appointment');

        when(mockBookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: serviceName,
          practitionerName: practitionerName,
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () async => await controller.bookAppointment(
            businessId: businessId,
            locationId: locationId,
            businessServiceId: businessServiceId,
            practitionerId: practitionerId,
            date: date,
            startTime: startTime,
            endTime: endTime,
            userId: userId,
            durationMinutes: durationMinutes,
            serviceName: serviceName,
            practitionerName: practitionerName,
          ),
          throwsA(exception),
        );

        verify(mockBookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: serviceName,
          practitionerName: practitionerName,
        )).called(1);
      });
    });

    test('should handle state transitions correctly during fetch operations', () async {
      // Test loading states during fetchPractitioners
      const locationId = 'loc-1';
      final practitioners = <Practitioner>[];

      when(mockGetPractitioners(locationId))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 10));
            return practitioners;
          });

      // Act
      final fetchFuture = controller.fetchPractitioners(locationId);
      
      // Check intermediate state
      expect(controller.state.isLoading, true);
      expect(controller.state.error, isNull);

      await fetchFuture;

      // Check final state
      expect(controller.state.isLoading, false);
    });

    test('should maintain canProceed state correctly', () {
      // Initially should be false
      expect(controller.state.canProceed, false);

      // After selecting practitioner only
      controller.updateSelectedPractitioner('prac-1');
      expect(controller.state.canProceed, false);

      // After selecting practitioner and service
      controller.updateSelectedService('svc-1');
      expect(controller.state.canProceed, false);

      // After selecting all required fields
      controller.updateSelectedDuration('dur-1');
      expect(controller.state.canProceed, true);

      // After clearing one field
      controller.updateSelectedService('svc-2'); // This resets duration
      expect(controller.state.canProceed, false);
    });
  });
}
