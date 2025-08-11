import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/practitioner.dart';

void main() {
  group('Practitioner Entity Tests', () {
    test('should create a Practitioner with all fields', () {
      // Arrange
      final locationSchedules = [
        {
          'location_id': 'loc-1',
          'schedule': [
            {'day': 'monday', 'start': '09:00', 'end': '17:00'},
            {'day': 'tuesday', 'start': '09:00', 'end': '17:00'},
          ]
        }
      ];
      final serviceIds = ['service-1', 'service-2', 'service-3'];

      // Act
      final practitioner = Practitioner(
        id: 'prac-1',
        name: 'Dr. John Smith',
        email: 'dr.smith@example.com',
        locationSchedules: locationSchedules,
        serviceIds: serviceIds,
      );

      // Assert
      expect(practitioner.id, 'prac-1');
      expect(practitioner.name, 'Dr. John Smith');
      expect(practitioner.email, 'dr.smith@example.com');
      expect(practitioner.locationSchedules, locationSchedules);
      expect(practitioner.serviceIds, serviceIds);
    });

    test('should create a Practitioner with empty schedules and services', () {
      // Arrange & Act
      final practitioner = Practitioner(
        id: 'prac-2',
        name: 'Dr. Jane Doe',
        email: 'dr.doe@example.com',
        locationSchedules: [],
        serviceIds: [],
      );

      // Assert
      expect(practitioner.id, 'prac-2');
      expect(practitioner.name, 'Dr. Jane Doe');
      expect(practitioner.email, 'dr.doe@example.com');
      expect(practitioner.locationSchedules, isEmpty);
      expect(practitioner.serviceIds, isEmpty);
    });

    test('should copy with new values', () {
      // Arrange
      final originalPractitioner = Practitioner(
        id: 'prac-1',
        name: 'Dr. John Smith',
        email: 'dr.smith@example.com',
        locationSchedules: [
          {'location_id': 'loc-1', 'schedule': []}
        ],
        serviceIds: ['service-1'],
      );

      final newLocationSchedules = [
        {
          'location_id': 'loc-2',
          'schedule': [
            {'day': 'wednesday', 'start': '10:00', 'end': '18:00'}
          ]
        }
      ];
      final newServiceIds = ['service-2', 'service-3'];

      // Act
      final updatedPractitioner = originalPractitioner.copyWith(
        name: 'Dr. John H. Smith',
        email: 'johnsmith@newclinic.com',
        locationSchedules: newLocationSchedules,
        serviceIds: newServiceIds,
      );

      // Assert
      expect(updatedPractitioner.id, 'prac-1'); // unchanged
      expect(updatedPractitioner.name, 'Dr. John H. Smith'); // changed
      expect(updatedPractitioner.email, 'johnsmith@newclinic.com'); // changed
      expect(updatedPractitioner.locationSchedules, newLocationSchedules); // changed
      expect(updatedPractitioner.serviceIds, newServiceIds); // changed
    });

    test('should copy with all fields', () {
      // Arrange
      final originalPractitioner = Practitioner(
        id: 'prac-1',
        name: 'Dr. John Smith',
        email: 'dr.smith@example.com',
        locationSchedules: [],
        serviceIds: [],
      );

      final newLocationSchedules = [
        {
          'location_id': 'loc-3',
          'schedule': [
            {'day': 'monday', 'start': '08:00', 'end': '16:00'},
            {'day': 'friday', 'start': '08:00', 'end': '12:00'},
          ]
        }
      ];
      final newServiceIds = ['service-4', 'service-5', 'service-6'];

      // Act
      final updatedPractitioner = originalPractitioner.copyWith(
        id: 'prac-2',
        name: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@clinic.com',
        locationSchedules: newLocationSchedules,
        serviceIds: newServiceIds,
      );

      // Assert
      expect(updatedPractitioner.id, 'prac-2');
      expect(updatedPractitioner.name, 'Dr. Sarah Johnson');
      expect(updatedPractitioner.email, 'sarah.johnson@clinic.com');
      expect(updatedPractitioner.locationSchedules, newLocationSchedules);
      expect(updatedPractitioner.serviceIds, newServiceIds);
    });

    test('should maintain original values when copying with null', () {
      // Arrange
      final originalPractitioner = Practitioner(
        id: 'prac-1',
        name: 'Dr. John Smith',
        email: 'dr.smith@example.com',
        locationSchedules: [
          {
            'location_id': 'loc-1',
            'schedule': [
              {'day': 'monday', 'start': '09:00', 'end': '17:00'}
            ]
          }
        ],
        serviceIds: ['service-1', 'service-2'],
      );

      // Act
      final copiedPractitioner = originalPractitioner.copyWith();

      // Assert
      expect(copiedPractitioner.id, originalPractitioner.id);
      expect(copiedPractitioner.name, originalPractitioner.name);
      expect(copiedPractitioner.email, originalPractitioner.email);
      expect(copiedPractitioner.locationSchedules, originalPractitioner.locationSchedules);
      expect(copiedPractitioner.serviceIds, originalPractitioner.serviceIds);
    });

    test('should handle complex location schedules', () {
      // Arrange
      final complexLocationSchedules = [
        {
          'location_id': 'loc-1',
          'schedule': [
            {'day': 'monday', 'start': '09:00', 'end': '17:00'},
            {'day': 'tuesday', 'start': '09:00', 'end': '17:00'},
            {'day': 'wednesday', 'start': '09:00', 'end': '17:00'},
          ]
        },
        {
          'location_id': 'loc-2',
          'schedule': [
            {'day': 'thursday', 'start': '08:00', 'end': '16:00'},
            {'day': 'friday', 'start': '08:00', 'end': '14:00'},
          ]
        }
      ];

      // Act
      final practitioner = Practitioner(
        id: 'prac-1',
        name: 'Dr. Multi Location',
        email: 'multilocation@example.com',
        locationSchedules: complexLocationSchedules,
        serviceIds: ['service-1', 'service-2', 'service-3', 'service-4'],
      );

      // Assert
      expect(practitioner.locationSchedules.length, 2);
      expect(practitioner.locationSchedules[0]['location_id'], 'loc-1');
      expect(practitioner.locationSchedules[1]['location_id'], 'loc-2');
      expect(practitioner.serviceIds.length, 4);
    });

    test('should handle multiple service IDs', () {
      // Arrange
      final manyServiceIds = List.generate(10, (index) => 'service-${index + 1}');

      // Act
      final practitioner = Practitioner(
        id: 'prac-1',
        name: 'Dr. Multi Service',
        email: 'multiservice@example.com',
        locationSchedules: [],
        serviceIds: manyServiceIds,
      );

      // Assert
      expect(practitioner.serviceIds.length, 10);
      expect(practitioner.serviceIds.first, 'service-1');
      expect(practitioner.serviceIds.last, 'service-10');
    });
  });
}
