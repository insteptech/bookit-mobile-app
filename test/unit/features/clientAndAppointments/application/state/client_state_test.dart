import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/application/state/client_state.dart';

void main() {
  group('ClientState Tests', () {
    test('should create ClientState with default values', () {
      // Act
      const state = ClientState();

      // Assert
      expect(state.filteredClients, isEmpty);
      expect(state.selectedClient, isNull);
      expect(state.isSearching, false);
      expect(state.showDropdown, false);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.searchQuery, '');
      expect(state.hasSelectedClient, false);
    });

    test('should create ClientState with custom values', () {
      // Arrange
      final filteredClients = [
        {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'},
        {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com'},
      ];
      final selectedClient = {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'};

      // Act
      final state = ClientState(
        filteredClients: filteredClients,
        selectedClient: selectedClient,
        isSearching: true,
        showDropdown: true,
        isLoading: true,
        error: 'Test error',
        searchQuery: 'john',
      );

      // Assert
      expect(state.filteredClients, filteredClients);
      expect(state.selectedClient, selectedClient);
      expect(state.isSearching, true);
      expect(state.showDropdown, true);
      expect(state.isLoading, true);
      expect(state.error, 'Test error');
      expect(state.searchQuery, 'john');
      expect(state.hasSelectedClient, true);
    });

    test('should copy with new values', () {
      // Arrange
      const originalState = ClientState();
      final newFilteredClients = [
        {'id': '3', 'name': 'Bob Wilson', 'email': 'bob@example.com'},
      ];
      final newSelectedClient = {'id': '3', 'name': 'Bob Wilson', 'email': 'bob@example.com'};

      // Act
      final newState = originalState.copyWith(
        filteredClients: newFilteredClients,
        selectedClient: newSelectedClient,
        isSearching: true,
        showDropdown: true,
        isLoading: true,
        error: 'New error',
        searchQuery: 'bob',
      );

      // Assert
      expect(newState.filteredClients, newFilteredClients);
      expect(newState.selectedClient, newSelectedClient);
      expect(newState.isSearching, true);
      expect(newState.showDropdown, true);
      expect(newState.isLoading, true);
      expect(newState.error, 'New error');
      expect(newState.searchQuery, 'bob');
      expect(newState.hasSelectedClient, true);
    });

    test('should set values to null when explicitly passed null', () {
      // Arrange
      final state = ClientState(
        selectedClient: {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'},
        isLoading: true,
        error: 'Some error',
      );

      // Act
      final newState = state.copyWith(
        selectedClient: null,
        error: null,
      );

      // Assert
      expect(newState.selectedClient, isNull);
      expect(newState.isLoading, isTrue); // This should maintain original value
      expect(newState.error, isNull);
    });

    test('should copy with partial values', () {
      // Arrange
      final originalState = ClientState(
        filteredClients: [{'id': '1', 'name': 'John'}],
        selectedClient: {'id': '1', 'name': 'John'},
        isSearching: true,
        showDropdown: true,
        isLoading: true,
        error: 'Original error',
        searchQuery: 'original',
      );

      // Act - only update specific fields
      final newState = originalState.copyWith(
        isSearching: false,
        selectedClient: {'id': '1', 'name': 'Jane'}, // Explicitly provide new value
        error: 'Updated error',
      );

      // Assert
      expect(newState.filteredClients, originalState.filteredClients); // unchanged
      expect(newState.selectedClient, equals({'id': '1', 'name': 'Jane'})); // changed
      expect(newState.isSearching, false); // changed
      expect(newState.showDropdown, true); // unchanged
      expect(newState.isLoading, true); // unchanged
      expect(newState.error, 'Updated error'); // changed
      expect(newState.searchQuery, 'original'); // unchanged
    });

    test('should handle clearing selected client', () {
      // Arrange
      final originalState = ClientState(
        selectedClient: {'id': '1', 'name': 'John Doe'},
      );

      // Act
      final newState = originalState.copyWith(selectedClient: null);

      // Assert
      expect(newState.selectedClient, isNull);
      expect(newState.hasSelectedClient, false);
    });

    test('should handle setting selected client from null', () {
      // Arrange
      const originalState = ClientState(); // selectedClient is null by default
      final selectedClient = {'id': '1', 'name': 'John Doe'};

      // Act
      final newState = originalState.copyWith(selectedClient: selectedClient);

      // Assert
      expect(newState.selectedClient, selectedClient);
      expect(newState.hasSelectedClient, true);
    });

    test('should handle multiple filtered clients', () {
      // Arrange
      final manyClients = List.generate(50, (index) => {
        'id': 'client-$index',
        'first_name': 'First$index',
        'last_name': 'Last$index',
        'email': 'client$index@example.com',
        'phone_number': '+123456789$index',
        'full_name': 'First$index Last$index',
      });

      // Act
      final state = ClientState(filteredClients: manyClients);

      // Assert
      expect(state.filteredClients.length, 50);
      expect(state.filteredClients.first['id'], 'client-0');
      expect(state.filteredClients.last['id'], 'client-49');
    });

    test('should handle different search query formats', () {
      // Test different search query scenarios
      final testQueries = [
        '',
        'j',
        'john',
        'John Doe',
        'john.doe@example.com',
        '+1234567890',
        'JOHN DOE',
        'john doe',
        '   john   ',
        'john@',
        '123',
      ];

      for (final query in testQueries) {
        final state = ClientState(searchQuery: query);
        expect(state.searchQuery, query);
      }
    });

    test('should handle different error scenarios', () {
      // Test different error types
      final errorScenarios = [
        null,
        '',
        'Network error',
        'Client not found',
        'Server error 500',
        'Connection timeout',
        'Validation failed: Invalid email format',
      ];

      for (final error in errorScenarios) {
        final state = ClientState(error: error);
        expect(state.error, error);
      }
    });

    test('should handle all boolean state combinations', () {
      // Test all combinations of boolean states
      final booleanCombinations = [
        {'isSearching': false, 'showDropdown': false, 'isLoading': false},
        {'isSearching': true, 'showDropdown': false, 'isLoading': false},
        {'isSearching': false, 'showDropdown': true, 'isLoading': false},
        {'isSearching': false, 'showDropdown': false, 'isLoading': true},
        {'isSearching': true, 'showDropdown': true, 'isLoading': false},
        {'isSearching': true, 'showDropdown': false, 'isLoading': true},
        {'isSearching': false, 'showDropdown': true, 'isLoading': true},
        {'isSearching': true, 'showDropdown': true, 'isLoading': true},
      ];

      for (final combination in booleanCombinations) {
        final state = ClientState(
          isSearching: combination['isSearching'] as bool,
          showDropdown: combination['showDropdown'] as bool,
          isLoading: combination['isLoading'] as bool,
        );

        expect(state.isSearching, combination['isSearching']);
        expect(state.showDropdown, combination['showDropdown']);
        expect(state.isLoading, combination['isLoading']);
      }
    });

    test('should correctly determine hasSelectedClient', () {
      // Test with null selectedClient
      const stateWithNull = ClientState(selectedClient: null);
      expect(stateWithNull.hasSelectedClient, false);

      // Test with empty map selectedClient
      const stateWithEmpty = ClientState(selectedClient: {});
      expect(stateWithEmpty.hasSelectedClient, true); // Empty map is not null

      // Test with populated selectedClient
      final stateWithClient = ClientState(
        selectedClient: {'id': '1', 'name': 'John Doe'},
      );
      expect(stateWithClient.hasSelectedClient, true);
    });
  });
}
