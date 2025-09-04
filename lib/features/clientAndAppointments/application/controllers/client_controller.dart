import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_clients.dart';
import '../../domain/usecases/create_client.dart';
import '../state/client_state.dart';

class ClientController extends StateNotifier<ClientState> {
  final GetClients _getClients;
  final CreateClient _createClient;

  ClientController(
    this._getClients,
    this._createClient,
  ) : super(const ClientState());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      state = state.copyWith(
        filteredClients: [],
        showDropdown: false,
      );
    }
  }

  void setShowDropdown(bool show) {
    state = state.copyWith(showDropdown: show);
  }

  void selectClient(Map<String, dynamic> client) {
    state = state.copyWith(
      selectedClient: client,
      showDropdown: false,
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedClient: null);
  }

  Future<void> searchClients(String query) async {
    if (state.isSearching) return;

    try {
      state = state.copyWith(
        isSearching: true,
        showDropdown: true,
        error: null,
      );

      final clients = await _getClients(searchQuery: query);
      final clientMaps = clients.map((c) => {
        'id': c.id,
        'first_name': c.firstName,
        'last_name': c.lastName,
        'email': c.email,
        'phone_number': c.phoneNumber,
        'full_name': c.fullName,
      }).toList();

      state = state.copyWith(
        filteredClients: clientMaps,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        filteredClients: [],
        isSearching: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> createClient({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Split name into first and last name
      final nameParts = name.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      final client = await _createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phone,
      );
      
      state = state.copyWith(isLoading: false);
      
      return {
        'id': client.id,
        'first_name': client.firstName,
        'last_name': client.lastName,
        'email': client.email,
        'phone_number': client.phoneNumber,
        'full_name': client.fullName,
      };
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = const ClientState();
  }
}
