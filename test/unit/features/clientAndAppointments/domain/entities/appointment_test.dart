import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/appointment.dart';

void main() {
  group('Appointment Entity Tests', () {
    late DateTime testStartTime;
    late DateTime testEndTime;

    setUp(() {
      testStartTime = DateTime(2024, 1, 15, 14, 0, 0);
      testEndTime = DateTime(2024, 1, 15, 15, 0, 0);
    });

    test('should create an Appointment with required fields', () {
      // Arrange & Act
      final appointment = Appointment(
        id: 'apt-1',
        businessId: 'biz-1',
        locationId: 'loc-1',
        businessServiceId: 'service-1',
        practitionerId: 'prac-1',
        practitionerName: 'Dr. Smith',
        serviceName: 'Consultation',
        durationMinutes: 60,
        startTime: testStartTime,
        endTime: testEndTime,
        status: 'confirmed',
      );

      // Assert
      expect(appointment.id, 'apt-1');
      expect(appointment.businessId, 'biz-1');
      expect(appointment.locationId, 'loc-1');
      expect(appointment.businessServiceId, 'service-1');
      expect(appointment.practitionerId, 'prac-1');
      expect(appointment.practitionerName, 'Dr. Smith');
      expect(appointment.serviceName, 'Consultation');
      expect(appointment.durationMinutes, 60);
      expect(appointment.startTime, testStartTime);
      expect(appointment.endTime, testEndTime);
      expect(appointment.status, 'confirmed');
      expect(appointment.clientId, isNull);
      expect(appointment.clientName, isNull);
    });

    test('should create an Appointment with all fields including client', () {
      // Arrange & Act
      final appointment = Appointment(
        id: 'apt-1',
        businessId: 'biz-1',
        locationId: 'loc-1',
        businessServiceId: 'service-1',
        practitionerId: 'prac-1',
        practitionerName: 'Dr. Smith',
        serviceName: 'Consultation',
        durationMinutes: 60,
        startTime: testStartTime,
        endTime: testEndTime,
        status: 'confirmed',
        clientId: 'client-1',
        clientName: 'John Doe',
      );

      // Assert
      expect(appointment.id, 'apt-1');
      expect(appointment.businessId, 'biz-1');
      expect(appointment.locationId, 'loc-1');
      expect(appointment.businessServiceId, 'service-1');
      expect(appointment.practitionerId, 'prac-1');
      expect(appointment.practitionerName, 'Dr. Smith');
      expect(appointment.serviceName, 'Consultation');
      expect(appointment.durationMinutes, 60);
      expect(appointment.startTime, testStartTime);
      expect(appointment.endTime, testEndTime);
      expect(appointment.status, 'confirmed');
      expect(appointment.clientId, 'client-1');
      expect(appointment.clientName, 'John Doe');
    });

    test('should copy with new values', () {
      // Arrange
      final originalAppointment = Appointment(
        id: 'apt-1',
        businessId: 'biz-1',
        locationId: 'loc-1',
        businessServiceId: 'service-1',
        practitionerId: 'prac-1',
        practitionerName: 'Dr. Smith',
        serviceName: 'Consultation',
        durationMinutes: 60,
        startTime: testStartTime,
        endTime: testEndTime,
        status: 'confirmed',
      );

      final newStartTime = DateTime(2024, 1, 16, 10, 0, 0);
      final newEndTime = DateTime(2024, 1, 16, 11, 30, 0);

      // Act
      final updatedAppointment = originalAppointment.copyWith(
        status: 'pending',
        durationMinutes: 90,
        startTime: newStartTime,
        endTime: newEndTime,
        clientId: 'client-1',
        clientName: 'Jane Doe',
      );

      // Assert
      expect(updatedAppointment.id, 'apt-1'); // unchanged
      expect(updatedAppointment.businessId, 'biz-1'); // unchanged
      expect(updatedAppointment.locationId, 'loc-1'); // unchanged
      expect(updatedAppointment.businessServiceId, 'service-1'); // unchanged
      expect(updatedAppointment.practitionerId, 'prac-1'); // unchanged
      expect(updatedAppointment.practitionerName, 'Dr. Smith'); // unchanged
      expect(updatedAppointment.serviceName, 'Consultation'); // unchanged
      expect(updatedAppointment.durationMinutes, 90); // changed
      expect(updatedAppointment.startTime, newStartTime); // changed
      expect(updatedAppointment.endTime, newEndTime); // changed
      expect(updatedAppointment.status, 'pending'); // changed
      expect(updatedAppointment.clientId, 'client-1'); // changed
      expect(updatedAppointment.clientName, 'Jane Doe'); // changed
    });

    test('should copy with all fields', () {
      // Arrange
      final originalAppointment = Appointment(
        id: 'apt-1',
        businessId: 'biz-1',
        locationId: 'loc-1',
        businessServiceId: 'service-1',
        practitionerId: 'prac-1',
        practitionerName: 'Dr. Smith',
        serviceName: 'Consultation',
        durationMinutes: 60,
        startTime: testStartTime,
        endTime: testEndTime,
        status: 'confirmed',
      );

      final newStartTime = DateTime(2024, 2, 1, 9, 0, 0);
      final newEndTime = DateTime(2024, 2, 1, 10, 0, 0);

      // Act
      final updatedAppointment = originalAppointment.copyWith(
        id: 'apt-2',
        businessId: 'biz-2',
        locationId: 'loc-2',
        businessServiceId: 'service-2',
        practitionerId: 'prac-2',
        practitionerName: 'Dr. Johnson',
        serviceName: 'Treatment',
        durationMinutes: 120,
        startTime: newStartTime,
        endTime: newEndTime,
        status: 'cancelled',
        clientId: 'client-2',
        clientName: 'Alice Smith',
      );

      // Assert
      expect(updatedAppointment.id, 'apt-2');
      expect(updatedAppointment.businessId, 'biz-2');
      expect(updatedAppointment.locationId, 'loc-2');
      expect(updatedAppointment.businessServiceId, 'service-2');
      expect(updatedAppointment.practitionerId, 'prac-2');
      expect(updatedAppointment.practitionerName, 'Dr. Johnson');
      expect(updatedAppointment.serviceName, 'Treatment');
      expect(updatedAppointment.durationMinutes, 120);
      expect(updatedAppointment.startTime, newStartTime);
      expect(updatedAppointment.endTime, newEndTime);
      expect(updatedAppointment.status, 'cancelled');
      expect(updatedAppointment.clientId, 'client-2');
      expect(updatedAppointment.clientName, 'Alice Smith');
    });

    test('should maintain original values when copying with null', () {
      // Arrange
      final originalAppointment = Appointment(
        id: 'apt-1',
        businessId: 'biz-1',
        locationId: 'loc-1',
        businessServiceId: 'service-1',
        practitionerId: 'prac-1',
        practitionerName: 'Dr. Smith',
        serviceName: 'Consultation',
        durationMinutes: 60,
        startTime: testStartTime,
        endTime: testEndTime,
        status: 'confirmed',
        clientId: 'client-1',
        clientName: 'John Doe',
      );

      // Act
      final copiedAppointment = originalAppointment.copyWith();

      // Assert
      expect(copiedAppointment.id, originalAppointment.id);
      expect(copiedAppointment.businessId, originalAppointment.businessId);
      expect(copiedAppointment.locationId, originalAppointment.locationId);
      expect(copiedAppointment.businessServiceId, originalAppointment.businessServiceId);
      expect(copiedAppointment.practitionerId, originalAppointment.practitionerId);
      expect(copiedAppointment.practitionerName, originalAppointment.practitionerName);
      expect(copiedAppointment.serviceName, originalAppointment.serviceName);
      expect(copiedAppointment.durationMinutes, originalAppointment.durationMinutes);
      expect(copiedAppointment.startTime, originalAppointment.startTime);
      expect(copiedAppointment.endTime, originalAppointment.endTime);
      expect(copiedAppointment.status, originalAppointment.status);
      expect(copiedAppointment.clientId, originalAppointment.clientId);
      expect(copiedAppointment.clientName, originalAppointment.clientName);
    });

    test('should handle different appointment statuses', () {
      // Test different status values
      final statuses = ['pending', 'confirmed', 'cancelled', 'completed', 'no-show'];

      for (final status in statuses) {
        final appointment = Appointment(
          id: 'apt-1',
          businessId: 'biz-1',
          locationId: 'loc-1',
          businessServiceId: 'service-1',
          practitionerId: 'prac-1',
          practitionerName: 'Dr. Smith',
          serviceName: 'Consultation',
          durationMinutes: 60,
          startTime: testStartTime,
          endTime: testEndTime,
          status: status,
        );

        expect(appointment.status, status);
      }
    });

    test('should handle different duration values', () {
      // Test different duration values
      final durations = [15, 30, 45, 60, 90, 120];

      for (final duration in durations) {
        final appointment = Appointment(
          id: 'apt-1',
          businessId: 'biz-1',
          locationId: 'loc-1',
          businessServiceId: 'service-1',
          practitionerId: 'prac-1',
          practitionerName: 'Dr. Smith',
          serviceName: 'Consultation',
          durationMinutes: duration,
          startTime: testStartTime,
          endTime: testStartTime.add(Duration(minutes: duration)),
          status: 'confirmed',
        );

        expect(appointment.durationMinutes, duration);
      }
    });
  });
}
