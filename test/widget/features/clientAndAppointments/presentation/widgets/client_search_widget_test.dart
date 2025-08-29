import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/widgets/client_search_widget.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/get_clients.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/create_client.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/domain/usecases/create_client_and_book_appointment.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/application/controllers/client_controller.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/application/state/client_state.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/provider.dart';

class MockGetClients extends Mock implements GetClients {}
class MockCreateClient extends Mock implements CreateClient {}
class MockCreateClientAndBookAppointment extends Mock implements CreateClientAndBookAppointment {}

void main() {
  group('ClientSearchWidget Tests', () {
    late MockGetClients mockGetClients;
    late MockCreateClient mockCreateClient;
    late MockCreateClientAndBookAppointment mockCreateClientAndBookAppointment;
    late TextEditingController textController;
    late FocusNode focusNode;
    late LayerLink layerLink;
    late List<Map<String, dynamic>> selectedClients;

    setUp(() {
      mockGetClients = MockGetClients();
      mockCreateClient = MockCreateClient();
      mockCreateClientAndBookAppointment = MockCreateClientAndBookAppointment();
      textController = TextEditingController();
      focusNode = FocusNode();
      layerLink = LayerLink();
      selectedClients = [];
    });

    tearDown(() {
      textController.dispose();
      focusNode.dispose();
    });

    Widget createTestWidget({ProviderContainer? container}) {
      return ProviderScope(
        parent: container,
        overrides: [
          clientControllerProvider.overrideWith((ref) => ClientController(
            mockGetClients,
            mockCreateClient,
            mockCreateClientAndBookAppointment,
          )),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CompositedTransformTarget(
              link: layerLink,
              child: ClientSearchWidget(
                layerLink: layerLink,
                controller: textController,
                focusNode: focusNode,
                onClientSelected: (client) {
                  selectedClients.add(client);
                },
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should display input field', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show loading indicator when searching', (tester) async {
      // Arrange
      when(mockGetClients(searchQuery: 'john'))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return [];
          });

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.enterText(find.byType(TextField), 'john');
      await tester.pump(); // Trigger the search

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show "No clients found" when search returns empty results', (tester) async {
      // Arrange
      when(mockGetClients(searchQuery: 'nonexistent'))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.tap(find.byType(TextField)); // Focus the field
      await tester.pumpAndSettle(); // Wait for search to complete

      // Assert
      expect(find.text('No clients found'), findsOneWidget);
    });

    testWidgets('should display search results', (tester) async {
      // Arrange
      final mockClients = [
        {
          'id': '1',
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'john.doe@example.com',
          'phone_number': '+1234567890',
          'full_name': 'John Doe',
        },
        {
          'id': '2',
          'first_name': 'Jane',
          'last_name': 'Smith',
          'email': 'jane.smith@example.com',
          'phone_number': '+1987654321',
          'full_name': 'Jane Smith',
        },
      ];

      // Mock the controller state directly
      final container = ProviderContainer();
      final controller = container.read(clientControllerProvider.notifier);
      
      // Set up the state manually
      controller.state = const ClientState(
        filteredClients: [],
        showDropdown: true,
        isSearching: false,
      );

      await tester.pumpWidget(createTestWidget(container: container));

      // Manually update the state to show results
      controller.state = ClientState(
        filteredClients: mockClients,
        showDropdown: true,
        isSearching: false,
      );

      await tester.tap(find.byType(TextField)); // Focus the field
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('jane.smith@example.com'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);

      container.dispose();
    });

    testWidgets('should call onClientSelected when client is tapped', (tester) async {
      // Arrange
      final mockClient = {
        'id': '1',
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'john.doe@example.com',
        'phone_number': '+1234567890',
        'full_name': 'John Doe',
      };

      final container = ProviderContainer();
      final controller = container.read(clientControllerProvider.notifier);
      
      controller.state = ClientState(
        filteredClients: [mockClient],
        showDropdown: true,
        isSearching: false,
      );

      await tester.pumpWidget(createTestWidget(container: container));

      await tester.tap(find.byType(TextField)); // Focus the field
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedClients, hasLength(1));
      expect(selectedClients.first['id'], '1');
      expect(selectedClients.first['full_name'], 'John Doe');

      container.dispose();
    });

    testWidgets('should update text field when client is selected', (tester) async {
      // Arrange
      final mockClient = {
        'id': '1',
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'john.doe@example.com',
        'phone_number': '+1234567890',
        'full_name': 'John Doe',
      };

      final container = ProviderContainer();
      final controller = container.read(clientControllerProvider.notifier);
      
      controller.state = ClientState(
        filteredClients: [mockClient],
        showDropdown: true,
        isSearching: false,
      );

      await tester.pumpWidget(createTestWidget(container: container));

      await tester.tap(find.byType(TextField)); // Focus the field
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Assert
      expect(textController.text, 'John Doe');

      container.dispose();
    });

    testWidgets('should show error message when search fails', (tester) async {
      // Arrange
      final container = ProviderContainer();
      final controller = container.read(clientControllerProvider.notifier);
      
      controller.state = const ClientState(
        error: 'Network error occurred',
        showDropdown: true,
        isSearching: false,
      );

      await tester.pumpWidget(createTestWidget(container: container));

      await tester.tap(find.byType(TextField)); // Focus the field
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Network error occurred'), findsOneWidget);

      container.dispose();
    });

    testWidgets('should hide dropdown when focus is lost', (tester) async {
      // Arrange
      final container = ProviderContainer();
      final controller = container.read(clientControllerProvider.notifier);
      
      controller.state = const ClientState(
        filteredClients: [],
        showDropdown: true,
        isSearching: false,
      );

      await tester.pumpWidget(createTestWidget(container: container));

      await tester.tap(find.byType(TextField)); // Focus the field
      await tester.pumpAndSettle();

      // Act
      focusNode.unfocus(); // Remove focus
      await tester.pumpAndSettle();

      // Assert
      expect(controller.state.showDropdown, false);

      container.dispose();
    });

    testWidgets('should clear search results when text is cleared', (tester) async {
      // Arrange
      final container = ProviderContainer();
      await tester.pumpWidget(createTestWidget(container: container));

      // Add some text first
      await tester.enterText(find.byType(TextField), 'john');
      await tester.pump();

      // Act
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Assert
      final controller = container.read(clientControllerProvider.notifier);
      expect(controller.state.filteredClients, isEmpty);
      expect(controller.state.showDropdown, false);

      container.dispose();
    });

    testWidgets('should handle multiple rapid searches correctly', (tester) async {
      // Arrange
      when(mockGetClients(searchQuery: anyNamed('searchQuery')))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return [];
          });

      await tester.pumpWidget(createTestWidget());

      // Act - Multiple rapid searches
      await tester.enterText(find.byType(TextField), 'j');
      await tester.enterText(find.byType(TextField), 'jo');
      await tester.enterText(find.byType(TextField), 'joh');
      await tester.enterText(find.byType(TextField), 'john');
      
      await tester.pumpAndSettle();

      // Assert - Should not crash and handle gracefully
      expect(find.byType(ClientSearchWidget), findsOneWidget);
    });
  });
}
