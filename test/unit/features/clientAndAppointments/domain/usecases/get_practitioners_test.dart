import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/practitioner.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/repositories/appointment_repository.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/get_practitioners.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  group('GetPractitioners UseCase Tests', () {
    late GetPractitioners useCase;
    late MockAppointmentRepository mockRepository;

    setUp(() {
      mockRepository = MockAppointmentRepository();
      useCase = GetPractitioners(mockRepository);
    });

    test('should get practitioners from repository for given location', () async {
      // Arrange
      const locationId = 'loc-1';
      final testPractitioners = [
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

      when(mockRepository.getPractitioners(locationId))
          .thenAnswer((_) async => testPractitioners);

      // Act
      final result = await useCase(locationId);

      // Assert
      expect(result, testPractitioners);
      expect(result.length, 2);
      expect(result.first.name, 'Dr. Smith');
      expect(result.last.name, 'Dr. Johnson');
      verify(mockRepository.getPractitioners(locationId)).called(1);
    });

    test('should return empty list when no practitioners found for location', () async {
      // Arrange
      const locationId = 'loc-empty';
      final emptyPractitioners = <Practitioner>[];

      when(mockRepository.getPractitioners(locationId))
          .thenAnswer((_) async => emptyPractitioners);

      // Act
      final result = await useCase(locationId);

      // Assert
      expect(result, emptyPractitioners);
      expect(result.isEmpty, true);
      verify(mockRepository.getPractitioners(locationId)).called(1);
    });

    test('should handle repository exception', () async {
      // Arrange
      const locationId = 'loc-error';
      final exception = Exception('Failed to fetch practitioners');

      when(mockRepository.getPractitioners(locationId))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () async => await useCase(locationId),
        throwsA(exception),
      );
      verify(mockRepository.getPractitioners(locationId)).called(1);
    });

    test('should get practitioners with different location schedules', () async {
      // Arrange
      const locationId = 'loc-multi';
      final testPractitioners = [
        Practitioner(
          id: 'prac-multi',
          name: 'Dr. Multi Location',
          email: 'dr.multi@example.com',
          locationSchedules: [
            {
              'location_id': 'loc-1',
              'schedule': [
                {'day': 'monday', 'start': '09:00', 'end': '13:00'},
                {'day': 'wednesday', 'start': '09:00', 'end': '13:00'},
              ]
            },
            {
              'location_id': 'loc-2',
              'schedule': [
                {'day': 'tuesday', 'start': '14:00', 'end': '18:00'},
                {'day': 'thursday', 'start': '14:00', 'end': '18:00'},
              ]
            }
          ],
          serviceIds: ['service-1', 'service-2', 'service-3', 'service-4'],
        ),
      ];

      when(mockRepository.getPractitioners(locationId))
          .thenAnswer((_) async => testPractitioners);

      // Act
      final result = await useCase(locationId);

      // Assert
      expect(result.length, 1);
      expect(result.first.locationSchedules.length, 2);
      expect(result.first.serviceIds.length, 4);
      verify(mockRepository.getPractitioners(locationId)).called(1);
    });

    test('should get practitioners with no services', () async {
      // Arrange
      const locationId = 'loc-no-services';
      final testPractitioners = [
        Practitioner(
          id: 'prac-no-services',
          name: 'Dr. No Services',
          email: 'dr.noservices@example.com',
          locationSchedules: [
            {
              'location_id': locationId,
              'schedule': [
                {'day': 'friday', 'start': '10:00', 'end': '14:00'},
              ]
            }
          ],
          serviceIds: [],
        ),
      ];

      when(mockRepository.getPractitioners(locationId))
          .thenAnswer((_) async => testPractitioners);

      // Act
      final result = await useCase(locationId);

      // Assert
      expect(result.length, 1);
      expect(result.first.serviceIds, isEmpty);
      verify(mockRepository.getPractitioners(locationId)).called(1);
    });

    test('should get practitioners with many services', () async {
      // Arrange
      const locationId = 'loc-many-services';
      final manyServiceIds = List.generate(20, (index) => 'service-${index + 1}');
      final testPractitioners = [
        Practitioner(
          id: 'prac-many-services',
          name: 'Dr. Many Services',
          email: 'dr.manyservices@example.com',
          locationSchedules: [
            {
              'location_id': locationId,
              'schedule': [
                {'day': 'monday', 'start': '08:00', 'end': '18:00'},
                {'day': 'tuesday', 'start': '08:00', 'end': '18:00'},
                {'day': 'wednesday', 'start': '08:00', 'end': '18:00'},
                {'day': 'thursday', 'start': '08:00', 'end': '18:00'},
                {'day': 'friday', 'start': '08:00', 'end': '16:00'},
              ]
            }
          ],
          serviceIds: manyServiceIds,
        ),
      ];

      when(mockRepository.getPractitioners(locationId))
          .thenAnswer((_) async => testPractitioners);

      // Act
      final result = await useCase(locationId);

      // Assert
      expect(result.length, 1);
      expect(result.first.serviceIds.length, 20);
      expect(result.first.serviceIds.first, 'service-1');
      expect(result.first.serviceIds.last, 'service-20');
      verify(mockRepository.getPractitioners(locationId)).called(1);
    });

    test('should handle different location IDs', () async {
      // Test different location ID formats
      final locationIds = [
        'loc-1',
        'location-123',
        'main-clinic',
        'branch-office-downtown',
        'temp-location-2024',
      ];

      for (final locationId in locationIds) {
        // Arrange
        final testPractitioners = [
          Practitioner(
            id: 'prac-$locationId',
            name: 'Dr. Location $locationId',
            email: 'dr.$locationId@example.com',
            locationSchedules: [
              {
                'location_id': locationId,
                'schedule': [
                  {'day': 'monday', 'start': '09:00', 'end': '17:00'},
                ]
              }
            ],
            serviceIds: ['service-1'],
          ),
        ];

        when(mockRepository.getPractitioners(locationId))
            .thenAnswer((_) async => testPractitioners);

        // Act
        final result = await useCase(locationId);

        // Assert
        expect(result.length, 1);
        expect(result.first.name, 'Dr. Location $locationId');
        verify(mockRepository.getPractitioners(locationId)).called(1);
      }
    });

    test('should get large list of practitioners', () async {
      // Arrange
      const locationId = 'loc-large';
      final largePractitionerList = List.generate(50, (index) => Practitioner(
        id: 'prac-$index',
        name: 'Dr. Practitioner $index',
        email: 'dr.practitioner$index@example.com',
        locationSchedules: [
          {
            'location_id': locationId,
            'schedule': [
              {'day': 'monday', 'start': '09:00', 'end': '17:00'},
            ]
          }
        ],
        serviceIds: ['service-${index % 5 + 1}'],
      ));

      when(mockRepository.getPractitioners(locationId))
          .thenAnswer((_) async => largePractitionerList);

      // Act
      final result = await useCase(locationId);

      // Assert
      expect(result.length, 50);
      expect(result.first.name, 'Dr. Practitioner 0');
      expect(result.last.name, 'Dr. Practitioner 49');
      verify(mockRepository.getPractitioners(locationId)).called(1);
    });
  });
}
