import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/client.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/repositories/client_repository.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/create_client.dart';

class MockClientRepository extends Mock implements ClientRepository {}

void main() {
  group('CreateClient UseCase Tests', () {
    late CreateClient useCase;
    late MockClientRepository mockRepository;

    setUp(() {
      mockRepository = MockClientRepository();
      useCase = CreateClient(mockRepository);
    });

    test('should create client with all required fields', () async {
      // Arrange
      const firstName = 'John';
      const lastName = 'Doe';
      const email = 'john.doe@example.com';
      const phoneNumber = '+1234567890';

      final expectedClient = Client(
        id: 'client-1',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      )).thenAnswer((_) async => expectedClient);

      // Act
      final result = await useCase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      // Assert
      expect(result, expectedClient);
      expect(result.firstName, firstName);
      expect(result.lastName, lastName);
      expect(result.email, email);
      expect(result.phoneNumber, phoneNumber);
      verify(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      )).called(1);
    });

    test('should create client with all optional fields', () async {
      // Arrange
      const firstName = 'Jane';
      const lastName = 'Smith';
      const email = 'jane.smith@example.com';
      const phoneNumber = '+1987654321';
      final dateOfBirth = DateTime(1990, 5, 15);
      const address = '123 Main St, City, State';
      const notes = 'Prefers morning appointments';

      final expectedClient = Client(
        id: 'client-2',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        notes: notes,
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      );

      when(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        notes: notes,
      )).thenAnswer((_) async => expectedClient);

      // Act
      final result = await useCase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        notes: notes,
      );

      // Assert
      expect(result, expectedClient);
      expect(result.firstName, firstName);
      expect(result.lastName, lastName);
      expect(result.email, email);
      expect(result.phoneNumber, phoneNumber);
      expect(result.dateOfBirth, dateOfBirth);
      expect(result.address, address);
      expect(result.notes, notes);
      verify(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        notes: notes,
      )).called(1);
    });

    test('should handle repository exception during client creation', () async {
      // Arrange
      const firstName = 'John';
      const lastName = 'Doe';
      const email = 'john.doe@example.com';
      const phoneNumber = '+1234567890';
      final exception = Exception('Failed to create client');

      when(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      )).thenThrow(exception);

      // Act & Assert
      expect(
        () async => await useCase(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
        ),
        throwsA(exception),
      );
      verify(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      )).called(1);
    });

    test('should create client with empty optional fields', () async {
      // Arrange
      const firstName = 'Test';
      const lastName = 'User';
      const email = 'test.user@example.com';
      const phoneNumber = '+1111111111';

      final expectedClient = Client(
        id: 'client-3',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime(2024, 1, 3),
        updatedAt: DateTime(2024, 1, 3),
      );

      when(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: null,
        address: null,
        notes: null,
      )).thenAnswer((_) async => expectedClient);

      // Act
      final result = await useCase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: null,
        address: null,
        notes: null,
      );

      // Assert
      expect(result, expectedClient);
      expect(result.dateOfBirth, isNull);
      expect(result.address, isNull);
      expect(result.notes, isNull);
      verify(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: null,
        address: null,
        notes: null,
      )).called(1);
    });

    test('should create client with single character names', () async {
      // Arrange
      const firstName = 'A';
      const lastName = 'B';
      const email = 'a.b@example.com';
      const phoneNumber = '+1000000000';

      final expectedClient = Client(
        id: 'client-4',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime(2024, 1, 4),
        updatedAt: DateTime(2024, 1, 4),
      );

      when(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      )).thenAnswer((_) async => expectedClient);

      // Act
      final result = await useCase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      // Assert
      expect(result.firstName, firstName);
      expect(result.lastName, lastName);
      expect(result.fullName, 'A B');
      verify(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      )).called(1);
    });

    test('should create client with long names and information', () async {
      // Arrange
      const firstName = 'VeryLongFirstNameThatExceedsNormalLength';
      const lastName = 'VeryLongLastNameThatExceedsNormalLength';
      const email = 'verylongemailaddress@verylongdomainname.com';
      const phoneNumber = '+123456789012345';
      const longAddress = '1234 Very Long Street Name That Goes On And On, Very Long City Name, Very Long State Name, Very Long Country Name';
      const longNotes = 'These are very long notes that contain a lot of information about the client including their preferences, medical history, and other important details that need to be stored.';

      final expectedClient = Client(
        id: 'client-5',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: longAddress,
        notes: longNotes,
        createdAt: DateTime(2024, 1, 5),
        updatedAt: DateTime(2024, 1, 5),
      );

      when(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: longAddress,
        notes: longNotes,
      )).thenAnswer((_) async => expectedClient);

      // Act
      final result = await useCase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: longAddress,
        notes: longNotes,
      );

      // Assert
      expect(result.firstName, firstName);
      expect(result.lastName, lastName);
      expect(result.email, email);
      expect(result.phoneNumber, phoneNumber);
      expect(result.address, longAddress);
      expect(result.notes, longNotes);
      verify(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: longAddress,
        notes: longNotes,
      )).called(1);
    });

    test('should create client with special characters in names', () async {
      // Arrange
      const firstName = "Jean-François";
      const lastName = "O'Connor-Smith";
      const email = 'jean.francois@example.com';
      const phoneNumber = '+1234567890';

      final expectedClient = Client(
        id: 'client-6',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime(2024, 1, 6),
        updatedAt: DateTime(2024, 1, 6),
      );

      when(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      )).thenAnswer((_) async => expectedClient);

      // Act
      final result = await useCase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      // Assert
      expect(result.firstName, firstName);
      expect(result.lastName, lastName);
      expect(result.fullName, "Jean-François O'Connor-Smith");
      verify(mockRepository.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      )).called(1);
    });
  });
}
