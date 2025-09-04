import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/entities/client.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/get_clients.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/create_client.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/create_client_and_book_appointment.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/application/controllers/client_controller.dart';

class MockGetClients extends Mock implements GetClients {}
class MockCreateClient extends Mock implements CreateClient {}
class MockCreateClientAndBookAppointment extends Mock implements CreateClientAndBookAppointment {}

void main() {
  group('ClientController Tests', () {
    late ClientController controller;
    late MockGetClients mockGetClients;
    late MockCreateClient mockCreateClient;
    late MockCreateClientAndBookAppointment mockCreateClientAndBookAppointment;
    late ProviderContainer container;

    setUp(() {
      mockGetClients = MockGetClients();
      mockCreateClient = MockCreateClient();
      mockCreateClientAndBookAppointment = MockCreateClientAndBookAppointment();
      controller = ClientController(mockGetClients, mockCreateClient, mockCreateClientAndBookAppointment);
      container = ProviderContainer();
    });

    tearDown(() {
      controller.dispose();
      container.dispose();
    });

    test('should have initial state', () {
      // Assert
      expect(controller.state.filteredClients, isEmpty);
      expect(controller.state.selectedClient, isNull);
      expect(controller.state.isSearching, false);
      expect(controller.state.showDropdown, false);
      expect(controller.state.isLoading, false);
      expect(controller.state.error, isNull);
      expect(controller.state.searchQuery, '');
      expect(controller.state.hasSelectedClient, false);
    });

    group('updateSearchQuery', () {
      test('should update search query and clear filtered clients when query is empty', () {
        // Arrange
        const query = '';

        // Act
        controller.updateSearchQuery(query);

        // Assert
        expect(controller.state.searchQuery, query);
        expect(controller.state.filteredClients, isEmpty);
        expect(controller.state.showDropdown, false);
      });

      test('should update search query without clearing when query is not empty', () {
        // Arrange
        const query = 'john';

        // Act
        controller.updateSearchQuery(query);

        // Assert
        expect(controller.state.searchQuery, query);
        // filteredClients and showDropdown should remain unchanged
      });
    });

    group('setShowDropdown', () {
      test('should set showDropdown to true', () {
        // Act
        controller.setShowDropdown(true);

        // Assert
        expect(controller.state.showDropdown, true);
      });

      test('should set showDropdown to false', () {
        // Act
        controller.setShowDropdown(false);

        // Assert
        expect(controller.state.showDropdown, false);
      });
    });

    group('selectClient', () {
      test('should select client and hide dropdown', () {
        // Arrange
        final client = {
          'id': '1',
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'john.doe@example.com',
          'phone_number': '+1234567890',
          'full_name': 'John Doe',
        };

        // Act
        controller.selectClient(client);

        // Assert
        expect(controller.state.selectedClient, client);
        expect(controller.state.showDropdown, false);
        expect(controller.state.hasSelectedClient, true);
      });
    });

    group('clearSelection', () {
      test('should clear selected client', () {
        // Arrange
        final client = {
          'id': '1',
          'first_name': 'John',
          'last_name': 'Doe',
        };
        controller.selectClient(client);

        // Act
        controller.clearSelection();

        // Assert
        expect(controller.state.selectedClient, isNull);
        expect(controller.state.hasSelectedClient, false);
      });
    });

    group('searchClients', () {
      test('should search clients successfully', () async {
        // Arrange
        const query = 'john';
        final clients = [
          Client(
            id: '1',
            firstName: 'John',
            lastName: 'Doe',
            email: 'john.doe@example.com',
            phoneNumber: '+1234567890',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ];

        when(mockGetClients(searchQuery: query))
            .thenAnswer((_) async => clients);

        // Act
        await controller.searchClients(query);

        // Assert
        expect(controller.state.isSearching, false);
        expect(controller.state.showDropdown, true);
        expect(controller.state.filteredClients.length, 1);
        expect(controller.state.filteredClients.first['id'], '1');
        expect(controller.state.filteredClients.first['first_name'], 'John');
        expect(controller.state.filteredClients.first['last_name'], 'Doe');
        expect(controller.state.filteredClients.first['email'], 'john.doe@example.com');
        expect(controller.state.filteredClients.first['phone_number'], '+1234567890');
        expect(controller.state.filteredClients.first['full_name'], 'John Doe');
        expect(controller.state.error, isNull);

        verify(mockGetClients(searchQuery: query)).called(1);
      });

      test('should handle search clients error', () async {
        // Arrange
        const query = 'john';
        final exception = Exception('Network error');

        when(mockGetClients(searchQuery: query))
            .thenThrow(exception);

        // Act
        await controller.searchClients(query);

        // Assert
        expect(controller.state.isSearching, false);
        expect(controller.state.filteredClients, isEmpty);
        expect(controller.state.error, exception.toString());

        verify(mockGetClients(searchQuery: query)).called(1);
      });

      test('should not search if already searching', () async {
        // Arrange
        const query = 'john';
        
        // Manually set isSearching to true
        controller.state = controller.state.copyWith(isSearching: true);

        // Act
        await controller.searchClients(query);

        // Assert
        verifyNever(mockGetClients(searchQuery: query));
      });

      test('should search with multiple clients', () async {
        // Arrange
        const query = 'smith';
        final clients = [
          Client(
            id: '1',
            firstName: 'John',
            lastName: 'Smith',
            email: 'john.smith@example.com',
            phoneNumber: '+1111111111',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          Client(
            id: '2',
            firstName: 'Jane',
            lastName: 'Smith',
            email: 'jane.smith@example.com',
            phoneNumber: '+2222222222',
            createdAt: DateTime(2024, 1, 2),
            updatedAt: DateTime(2024, 1, 2),
          ),
        ];

        when(mockGetClients(searchQuery: query))
            .thenAnswer((_) async => clients);

        // Act
        await controller.searchClients(query);

        // Assert
        expect(controller.state.filteredClients.length, 2);
        expect(controller.state.filteredClients[0]['first_name'], 'John');
        expect(controller.state.filteredClients[1]['first_name'], 'Jane');
        expect(controller.state.filteredClients[0]['full_name'], 'John Smith');
        expect(controller.state.filteredClients[1]['full_name'], 'Jane Smith');
      });
    });

    group('createClient', () {
      test('should create client successfully', () async {
        // Arrange
        const name = 'John Doe';
        const email = 'john.doe@example.com';
        const phone = '+1234567890';

        final createdClient = Client(
          id: 'client-1',
          firstName: 'John',
          lastName: 'Doe',
          email: email,
          phoneNumber: phone,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockCreateClient(
          firstName: 'John',
          lastName: 'Doe',
          email: email,
          phoneNumber: phone,
        )).thenAnswer((_) async => createdClient);

        // Act
        final result = await controller.createClient(
          name: name,
          email: email,
          phone: phone,
        );

        // Assert
        expect(controller.state.isLoading, false);
        expect(result['id'], 'client-1');
        expect(result['first_name'], 'John');
        expect(result['last_name'], 'Doe');
        expect(result['email'], email);
        expect(result['phone_number'], phone);

        verify(mockCreateClient(
          firstName: 'John',
          lastName: 'Doe',
          email: email,
          phoneNumber: phone,
        )).called(1);
      });

      test('should create client with single name', () async {
        // Arrange
        const name = 'Madonna';
        const email = 'madonna@example.com';
        const phone = '+1111111111';

        final createdClient = Client(
          id: 'client-2',
          firstName: 'Madonna',
          lastName: '',
          email: email,
          phoneNumber: phone,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockCreateClient(
          firstName: 'Madonna',
          lastName: '',
          email: email,
          phoneNumber: phone,
        )).thenAnswer((_) async => createdClient);

        // Act
        final result = await controller.createClient(
          name: name,
          email: email,
          phone: phone,
        );

        // Assert
        expect(result['first_name'], 'Madonna');
        expect(result['last_name'], '');

        verify(mockCreateClient(
          firstName: 'Madonna',
          lastName: '',
          email: email,
          phoneNumber: phone,
        )).called(1);
      });

      test('should create client with multiple name parts', () async {
        // Arrange
        const name = 'Jean-François de la Cruz';
        const email = 'jean@example.com';
        const phone = '+1234567890';

        final createdClient = Client(
          id: 'client-3',
          firstName: 'Jean-François',
          lastName: 'de la Cruz',
          email: email,
          phoneNumber: phone,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockCreateClient(
          firstName: 'Jean-François',
          lastName: 'de la Cruz',
          email: email,
          phoneNumber: phone,
        )).thenAnswer((_) async => createdClient);

        // Act
        final result = await controller.createClient(
          name: name,
          email: email,
          phone: phone,
        );

        // Assert
        expect(result['first_name'], 'Jean-François');
        expect(result['last_name'], 'de la Cruz');

        verify(mockCreateClient(
          firstName: 'Jean-François',
          lastName: 'de la Cruz',
          email: email,
          phoneNumber: phone,
        )).called(1);
      });

      test('should handle create client error', () async {
        // Arrange
        const name = 'John Doe';
        const email = 'john.doe@example.com';
        const phone = '+1234567890';
        final exception = Exception('Failed to create client');

        when(mockCreateClient(
          firstName: 'John',
          lastName: 'Doe',
          email: email,
          phoneNumber: phone,
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () async => await controller.createClient(
            name: name,
            email: email,
            phone: phone,
          ),
          throwsA(exception),
        );

        expect(controller.state.isLoading, false);
        expect(controller.state.error, exception.toString());

        verify(mockCreateClient(
          firstName: 'John',
          lastName: 'Doe',
          email: email,
          phoneNumber: phone,
        )).called(1);
      });

      test('should handle empty name gracefully', () async {
        // Arrange
        const name = '';
        const email = 'test@example.com';
        const phone = '+1234567890';

        final createdClient = Client(
          id: 'client-4',
          firstName: '',
          lastName: '',
          email: email,
          phoneNumber: phone,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockCreateClient(
          firstName: '',
          lastName: '',
          email: email,
          phoneNumber: phone,
        )).thenAnswer((_) async => createdClient);

        // Act
        final result = await controller.createClient(
          name: name,
          email: email,
          phone: phone,
        );

        // Assert
        expect(result['first_name'], '');
        expect(result['last_name'], '');

        verify(mockCreateClient(
          firstName: '',
          lastName: '',
          email: email,
          phoneNumber: phone,
        )).called(1);
      });

      test('should handle name with extra whitespace', () async {
        // Arrange
        const name = '  John   Doe  ';
        const email = 'john.doe@example.com';
        const phone = '+1234567890';

        final createdClient = Client(
          id: 'client-5',
          firstName: 'John',
          lastName: 'Doe',
          email: email,
          phoneNumber: phone,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockCreateClient(
          firstName: 'John',
          lastName: 'Doe',
          email: email,
          phoneNumber: phone,
        )).thenAnswer((_) async => createdClient);

        // Act
        final result = await controller.createClient(
          name: name,
          email: email,
          phone: phone,
        );

        // Assert
        expect(result['first_name'], 'John');
        expect(result['last_name'], 'Doe');

        verify(mockCreateClient(
          firstName: 'John',
          lastName: 'Doe',
          email: email,
          phoneNumber: phone,
        )).called(1);
      });
    });

    test('should handle state transitions correctly during operations', () async {
      // Test that loading states are handled correctly
      const query = 'test';
      final clients = <Client>[];

      when(mockGetClients(searchQuery: query))
          .thenAnswer((_) async {
            // Simulate delay
            await Future.delayed(const Duration(milliseconds: 10));
            return clients;
          });

      // Act
      final searchFuture = controller.searchClients(query);
      
      // Check intermediate state
      expect(controller.state.isSearching, true);
      expect(controller.state.showDropdown, true);
      expect(controller.state.error, isNull);

      await searchFuture;

      // Check final state
      expect(controller.state.isSearching, false);
      expect(controller.state.showDropdown, true);
    });
  });
}
