import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/application/state/appointment_state.dart';

void main() {
  group('AppointmentState Tests', () {
    test('should create AppointmentState with default values', () {
      // Act
      const state = AppointmentState();

      // Assert
      expect(state.practitioners, isEmpty);
      expect(state.serviceList, isEmpty);
      expect(state.selectedPractitioner, '');
      expect(state.selectedService, '');
      expect(state.selectedDuration, '');
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.partialPayload, isNull);
      expect(state.canProceed, false);
    });

    test('should create AppointmentState with custom values', () {
      // Arrange
      final practitioners = [
        {
          'id': 'prac-1',
          'name': 'Dr. Smith',
          'email': 'dr.smith@example.com',
          'location_schedules': [],
          'service_ids': ['service-1', 'service-2'],
        },
        {
          'id': 'prac-2',
          'name': 'Dr. Johnson',
          'email': 'dr.johnson@example.com',
          'location_schedules': [],
          'service_ids': ['service-2', 'service-3'],
        },
      ];

      final serviceList = [
        {
          'id': 'svc-1',
          'business_service_id': 'biz-svc-1',
          'name': 'Massage Therapy',
          'description': 'Relaxing massage',
          'is_class': false,
          'durations': [
            {'id': 'dur-1', 'duration_minutes': 30, 'price': 50.0},
            {'id': 'dur-2', 'duration_minutes': 60, 'price': 90.0},
          ],
        },
      ];

      final partialPayload = {'key': 'value', 'nested': {'data': 'test'}};

      // Act
      final state = AppointmentState(
        practitioners: practitioners,
        serviceList: serviceList,
        selectedPractitioner: 'prac-1',
        selectedService: 'svc-1',
        selectedDuration: 'dur-1',
        isLoading: true,
        error: 'Test error',
        partialPayload: partialPayload,
      );

      // Assert
      expect(state.practitioners, practitioners);
      expect(state.serviceList, serviceList);
      expect(state.selectedPractitioner, 'prac-1');
      expect(state.selectedService, 'svc-1');
      expect(state.selectedDuration, 'dur-1');
      expect(state.isLoading, true);
      expect(state.error, 'Test error');
      expect(state.partialPayload, partialPayload);
      expect(state.canProceed, true);
    });

    test('should copy with new values', () {
      // Arrange
      const originalState = AppointmentState();
      final newPractitioners = [
        {
          'id': 'prac-3',
          'name': 'Dr. Wilson',
          'email': 'dr.wilson@example.com',
        },
      ];
      final newServiceList = [
        {
          'id': 'svc-2',
          'name': 'Acupuncture',
          'durations': [],
        },
      ];

      // Act
      final newState = originalState.copyWith(
        practitioners: newPractitioners,
        serviceList: newServiceList,
        selectedPractitioner: 'prac-3',
        selectedService: 'svc-2',
        selectedDuration: 'dur-3',
        isLoading: true,
        error: 'New error',
        partialPayload: {'new': 'payload'},
      );

      // Assert
      expect(newState.practitioners, newPractitioners);
      expect(newState.serviceList, newServiceList);
      expect(newState.selectedPractitioner, 'prac-3');
      expect(newState.selectedService, 'svc-2');
      expect(newState.selectedDuration, 'dur-3');
      expect(newState.isLoading, true);
      expect(newState.error, 'New error');
      expect(newState.partialPayload, {'new': 'payload'});
      expect(newState.canProceed, true);
    });

    test('should maintain original values when copying with null', () {
      // Arrange
      final originalPractitioners = [
        {'id': 'prac-1', 'name': 'Dr. Original'},
      ];
      final originalServiceList = [
        {'id': 'svc-1', 'name': 'Original Service'},
      ];
      final originalPartialPayload = {'original': 'data'};

      final originalState = AppointmentState(
        practitioners: originalPractitioners,
        serviceList: originalServiceList,
        selectedPractitioner: 'prac-1',
        selectedService: 'svc-1',
        selectedDuration: 'dur-1',
        isLoading: true,
        error: 'Original error',
        partialPayload: originalPartialPayload,
      );

      // Act
      final newState = originalState.copyWith();

      // Assert
      expect(newState.practitioners, originalPractitioners);
      expect(newState.serviceList, originalServiceList);
      expect(newState.selectedPractitioner, 'prac-1');
      expect(newState.selectedService, 'svc-1');
      expect(newState.selectedDuration, 'dur-1');
      expect(newState.isLoading, true);
      expect(newState.error, 'Original error');
      expect(newState.partialPayload, originalPartialPayload);
    });

    test('should copy with partial values', () {
      // Arrange
      final originalState = AppointmentState(
        practitioners: [{'id': 'prac-1'}],
        serviceList: [{'id': 'svc-1'}],
        selectedPractitioner: 'prac-1',
        selectedService: 'svc-1',
        selectedDuration: 'dur-1',
        isLoading: true,
        error: 'Original error',
        partialPayload: {'original': 'data'},
      );

      // Act
      final newState = originalState.copyWith(
        selectedService: 'svc-2',
        isLoading: false,
      );

      // Assert
      expect(newState.practitioners, originalState.practitioners); // unchanged
      expect(newState.serviceList, originalState.serviceList); // unchanged
      expect(newState.selectedPractitioner, 'prac-1'); // unchanged
      expect(newState.selectedService, 'svc-2'); // changed
      expect(newState.selectedDuration, 'dur-1'); // unchanged
      expect(newState.isLoading, false); // changed
      expect(newState.error, 'Original error'); // unchanged
      expect(newState.partialPayload, originalState.partialPayload); // unchanged
    });

    test('should determine canProceed correctly', () {
      // Test case 1: All selections are empty
      const stateEmpty = AppointmentState();
      expect(stateEmpty.canProceed, false);

      // Test case 2: Only practitioner selected
      const stateOnlyPractitioner = AppointmentState(
        selectedPractitioner: 'prac-1',
      );
      expect(stateOnlyPractitioner.canProceed, false);

      // Test case 3: Practitioner and service selected
      const statePractitionerService = AppointmentState(
        selectedPractitioner: 'prac-1',
        selectedService: 'svc-1',
      );
      expect(statePractitionerService.canProceed, false);

      // Test case 4: All required selections made
      const stateComplete = AppointmentState(
        selectedPractitioner: 'prac-1',
        selectedService: 'svc-1',
        selectedDuration: 'dur-1',
      );
      expect(stateComplete.canProceed, true);

      // Test case 5: All selections but one is empty string
      const stateEmptyDuration = AppointmentState(
        selectedPractitioner: 'prac-1',
        selectedService: 'svc-1',
        selectedDuration: '',
      );
      expect(stateEmptyDuration.canProceed, false);
    });

    test('should handle selectedServiceData getter', () {
      // Arrange
      final serviceList = [
        {
          'id': 'svc-1',
          'name': 'Service 1',
          'durations': [
            {'id': 'dur-1', 'duration_minutes': 30},
          ],
        },
        {
          'id': 'svc-2',
          'name': 'Service 2',
          'durations': [
            {'id': 'dur-2', 'duration_minutes': 60},
          ],
        },
      ];

      // Test case 1: No service selected
      final stateNoSelection = AppointmentState(serviceList: serviceList);
      expect(stateNoSelection.selectedServiceData, isNull);

      // Test case 2: Service selected that exists
      final stateWithSelection = AppointmentState(
        serviceList: serviceList,
        selectedService: 'svc-1',
      );
      expect(stateWithSelection.selectedServiceData, isNotNull);
      expect(stateWithSelection.selectedServiceData!['id'], 'svc-1');
      expect(stateWithSelection.selectedServiceData!['name'], 'Service 1');

      // Test case 3: Service selected that doesn't exist
      final stateInvalidSelection = AppointmentState(
        serviceList: serviceList,
        selectedService: 'svc-999',
      );
      expect(stateInvalidSelection.selectedServiceData, isNull);
    });

    test('should handle large lists of practitioners and services', () {
      // Arrange
      final largePractitionerList = List.generate(100, (index) => {
        'id': 'prac-$index',
        'name': 'Dr. Practitioner $index',
        'email': 'dr$index@example.com',
        'location_schedules': [],
        'service_ids': ['service-${index % 5}'],
      });

      final largeServiceList = List.generate(50, (index) => {
        'id': 'svc-$index',
        'business_service_id': 'biz-svc-$index',
        'name': 'Service $index',
        'description': 'Description $index',
        'is_class': index % 3 == 0,
        'durations': [
          {'id': 'dur-$index', 'duration_minutes': 30 + index, 'price': 50.0 + index},
        ],
      });

      // Act
      final state = AppointmentState(
        practitioners: largePractitionerList,
        serviceList: largeServiceList,
      );

      // Assert
      expect(state.practitioners.length, 100);
      expect(state.serviceList.length, 50);
      expect(state.practitioners.first['id'], 'prac-0');
      expect(state.practitioners.last['id'], 'prac-99');
      expect(state.serviceList.first['id'], 'svc-0');
      expect(state.serviceList.last['id'], 'svc-49');
    });

    test('should handle complex partial payload data', () {
      // Arrange
      final complexPayload = {
        'appointment': {
          'business_id': 'biz-123',
          'location_id': 'loc-456',
          'date': '2024-01-15',
          'time_slot': {
            'start': '14:00',
            'end': '15:00',
          },
          'client': {
            'id': 'client-789',
            'preferences': ['morning', 'quiet'],
          },
        },
        'metadata': {
          'source': 'mobile_app',
          'version': '1.0.0',
          'timestamp': '2024-01-15T10:30:00Z',
        },
      };

      // Act
      final state = AppointmentState(partialPayload: complexPayload);

      // Assert
      expect(state.partialPayload, complexPayload);
      expect(state.partialPayload!['appointment']['business_id'], 'biz-123');
      expect(state.partialPayload!['metadata']['source'], 'mobile_app');
    });

    test('should handle different error scenarios', () {
      // Test different error types
      final errorScenarios = [
        null,
        '',
        'Network error',
        'Failed to load practitioners',
        'Service unavailable',
        'Invalid selection',
        'Server error 500',
        'Connection timeout',
      ];

      for (final error in errorScenarios) {
        final state = AppointmentState(error: error);
        expect(state.error, error);
      }
    });

    test('should handle clearing selections', () {
      // Arrange
      final originalState = AppointmentState(
        selectedPractitioner: 'prac-1',
        selectedService: 'svc-1',
        selectedDuration: 'dur-1',
      );

      // Act
      final clearedState = originalState.copyWith(
        selectedPractitioner: '',
        selectedService: '',
        selectedDuration: '',
      );

      // Assert
      expect(clearedState.selectedPractitioner, '');
      expect(clearedState.selectedService, '');
      expect(clearedState.selectedDuration, '');
      expect(clearedState.canProceed, false);
    });
  });
}
