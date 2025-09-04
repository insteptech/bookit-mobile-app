import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/repositories/appointment_repository.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/book_appointment.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  group('BookAppointment UseCase Tests', () {
    late BookAppointment useCase;
    late MockAppointmentRepository mockRepository;

    setUp(() {
      mockRepository = MockAppointmentRepository();
      useCase = BookAppointment(mockRepository);
    });

    test('should book appointment with all required fields', () async {
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

      when(mockRepository.bookAppointment(
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
      await useCase(
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
      verify(mockRepository.bookAppointment(
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

      when(mockRepository.bookAppointment(
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
      await useCase(
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
      verify(mockRepository.bookAppointment(
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

    test('should handle repository exception during appointment booking', () async {
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

      when(mockRepository.bookAppointment(
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
        () async => await useCase(
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
      verify(mockRepository.bookAppointment(
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

    test('should book appointment with different time slots', () async {
      // Arrange
      const businessId = 'biz-1';
      const locationId = 'loc-1';
      const businessServiceId = 'biz-svc-1';
      const practitionerId = 'prac-1';
      final date = DateTime(2024, 1, 15);
      const userId = 'user-1';
      const serviceName = 'Massage';
      const practitionerName = 'Dr. Johnson';

      final timeSlots = [
        {'start': '09:00', 'end': '09:30', 'duration': 30},
        {'start': '10:00', 'end': '11:00', 'duration': 60},
        {'start': '14:30', 'end': '16:00', 'duration': 90},
        {'start': '16:15', 'end': '18:15', 'duration': 120},
      ];

      for (final slot in timeSlots) {
        when(mockRepository.bookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: slot['start'] as String,
          endTime: slot['end'] as String,
          userId: userId,
          durationMinutes: slot['duration'] as int,
          serviceName: serviceName,
          practitionerName: practitionerName,
        )).thenAnswer((_) async => {});

        // Act
        await useCase(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: slot['start'] as String,
          endTime: slot['end'] as String,
          userId: userId,
          durationMinutes: slot['duration'] as int,
          serviceName: serviceName,
          practitionerName: practitionerName,
        );

        // Assert
        verify(mockRepository.bookAppointment(
          businessId: businessId,
          locationId: locationId,
          businessServiceId: businessServiceId,
          practitionerId: practitionerId,
          date: date,
          startTime: slot['start'] as String,
          endTime: slot['end'] as String,
          userId: userId,
          durationMinutes: slot['duration'] as int,
          serviceName: serviceName,
          practitionerName: practitionerName,
        )).called(1);
      }
    });

    test('should book appointment with different dates', () async {
      // Arrange
      const businessId = 'biz-1';
      const locationId = 'loc-1';
      const businessServiceId = 'biz-svc-1';
      const practitionerId = 'prac-1';
      const startTime = '10:00';
      const endTime = '11:00';
      const userId = 'user-1';
      const durationMinutes = 60;
      const serviceName = 'Consultation';
      const practitionerName = 'Dr. Wilson';

      final dates = [
        DateTime(2024, 1, 15), // Monday
        DateTime(2024, 1, 16), // Tuesday
        DateTime(2024, 1, 20), // Saturday
        DateTime(2024, 2, 1),  // Next month
        DateTime(2024, 12, 31), // End of year
      ];

      for (final date in dates) {
        when(mockRepository.bookAppointment(
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
        await useCase(
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
        verify(mockRepository.bookAppointment(
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
      }
    });

    test('should book appointment with different services and practitioners', () async {
      // Arrange
      final date = DateTime(2024, 1, 15);
      const startTime = '14:00';
      const endTime = '15:00';
      const userId = 'user-1';
      const durationMinutes = 60;

      final appointments = [
        {
          'businessId': 'biz-1',
          'locationId': 'loc-1',
          'businessServiceId': 'biz-svc-1',
          'practitionerId': 'prac-1',
          'serviceName': 'Massage Therapy',
          'practitionerName': 'Dr. Smith'
        },
        {
          'businessId': 'biz-2',
          'locationId': 'loc-2',
          'businessServiceId': 'biz-svc-2',
          'practitionerId': 'prac-2',
          'serviceName': 'Acupuncture',
          'practitionerName': 'Dr. Johnson'
        },
        {
          'businessId': 'biz-3',
          'locationId': 'loc-3',
          'businessServiceId': 'biz-svc-3',
          'practitionerId': 'prac-3',
          'serviceName': 'Physiotherapy',
          'practitionerName': 'Dr. Williams'
        },
      ];

      for (final apt in appointments) {
        when(mockRepository.bookAppointment(
          businessId: apt['businessId'] as String,
          locationId: apt['locationId'] as String,
          businessServiceId: apt['businessServiceId'] as String,
          practitionerId: apt['practitionerId'] as String,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: apt['serviceName'] as String,
          practitionerName: apt['practitionerName'] as String,
        )).thenAnswer((_) async => {});

        // Act
        await useCase(
          businessId: apt['businessId'] as String,
          locationId: apt['locationId'] as String,
          businessServiceId: apt['businessServiceId'] as String,
          practitionerId: apt['practitionerId'] as String,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: apt['serviceName'] as String,
          practitionerName: apt['practitionerName'] as String,
        );

        // Assert
        verify(mockRepository.bookAppointment(
          businessId: apt['businessId'] as String,
          locationId: apt['locationId'] as String,
          businessServiceId: apt['businessServiceId'] as String,
          practitionerId: apt['practitionerId'] as String,
          date: date,
          startTime: startTime,
          endTime: endTime,
          userId: userId,
          durationMinutes: durationMinutes,
          serviceName: apt['serviceName'] as String,
          practitionerName: apt['practitionerName'] as String,
        )).called(1);
      }
    });
  });
}
