import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/client.dart';

void main() {
  group('Client Entity Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 12, 0, 0);
    });

    test('should create a Client with required fields', () {
      // Arrange & Act
      final client = Client(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Assert
      expect(client.id, '1');
      expect(client.firstName, 'John');
      expect(client.lastName, 'Doe');
      expect(client.email, 'john.doe@example.com');
      expect(client.phoneNumber, '+1234567890');
      expect(client.dateOfBirth, isNull);
      expect(client.address, isNull);
      expect(client.notes, isNull);
      expect(client.createdAt, testDate);
      expect(client.updatedAt, testDate);
    });

    test('should create a Client with all fields', () {
      // Arrange
      final dateOfBirth = DateTime(1990, 5, 15);

      // Act
      final client = Client(
        id: '1',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        phoneNumber: '+1987654321',
        dateOfBirth: dateOfBirth,
        address: '123 Main St, City, State',
        notes: 'Prefers morning appointments',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Assert
      expect(client.id, '1');
      expect(client.firstName, 'Jane');
      expect(client.lastName, 'Smith');
      expect(client.email, 'jane.smith@example.com');
      expect(client.phoneNumber, '+1987654321');
      expect(client.dateOfBirth, dateOfBirth);
      expect(client.address, '123 Main St, City, State');
      expect(client.notes, 'Prefers morning appointments');
      expect(client.createdAt, testDate);
      expect(client.updatedAt, testDate);
    });

    test('should return correct full name', () {
      // Arrange
      final client = Client(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act & Assert
      expect(client.fullName, 'John Doe');
    });

    test('should return correct full name with single name', () {
      // Arrange
      final client = Client(
        id: '1',
        firstName: 'Madonna',
        lastName: '',
        email: 'madonna@example.com',
        phoneNumber: '+1234567890',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act & Assert
      expect(client.fullName, 'Madonna ');
    });

    test('should copy with new values', () {
      // Arrange
      final originalClient = Client(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final updatedClient = originalClient.copyWith(
        firstName: 'Jane',
        email: 'jane.doe@example.com',
        notes: 'Updated notes',
      );

      // Assert
      expect(updatedClient.id, '1'); // unchanged
      expect(updatedClient.firstName, 'Jane'); // changed
      expect(updatedClient.lastName, 'Doe'); // unchanged
      expect(updatedClient.email, 'jane.doe@example.com'); // changed
      expect(updatedClient.phoneNumber, '+1234567890'); // unchanged
      expect(updatedClient.notes, 'Updated notes'); // changed
      expect(updatedClient.createdAt, testDate); // unchanged
      expect(updatedClient.updatedAt, testDate); // unchanged
    });

    test('should copy with all fields', () {
      // Arrange
      final originalClient = Client(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final newDate = DateTime(2024, 2, 15, 12, 0, 0);
      final newDateOfBirth = DateTime(1985, 3, 20);

      // Act
      final updatedClient = originalClient.copyWith(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        phoneNumber: '+1987654321',
        dateOfBirth: newDateOfBirth,
        address: '456 Oak Ave',
        notes: 'New notes',
        createdAt: newDate,
        updatedAt: newDate,
      );

      // Assert
      expect(updatedClient.id, '2');
      expect(updatedClient.firstName, 'Jane');
      expect(updatedClient.lastName, 'Smith');
      expect(updatedClient.email, 'jane.smith@example.com');
      expect(updatedClient.phoneNumber, '+1987654321');
      expect(updatedClient.dateOfBirth, newDateOfBirth);
      expect(updatedClient.address, '456 Oak Ave');
      expect(updatedClient.notes, 'New notes');
      expect(updatedClient.createdAt, newDate);
      expect(updatedClient.updatedAt, newDate);
    });

    test('should maintain original values when copying with null', () {
      // Arrange
      final originalClient = Client(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        dateOfBirth: DateTime(1990, 1, 1),
        address: 'Original Address',
        notes: 'Original Notes',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final copiedClient = originalClient.copyWith();

      // Assert
      expect(copiedClient.id, originalClient.id);
      expect(copiedClient.firstName, originalClient.firstName);
      expect(copiedClient.lastName, originalClient.lastName);
      expect(copiedClient.email, originalClient.email);
      expect(copiedClient.phoneNumber, originalClient.phoneNumber);
      expect(copiedClient.dateOfBirth, originalClient.dateOfBirth);
      expect(copiedClient.address, originalClient.address);
      expect(copiedClient.notes, originalClient.notes);
      expect(copiedClient.createdAt, originalClient.createdAt);
      expect(copiedClient.updatedAt, originalClient.updatedAt);
    });
  });
}
