import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/client_state.dart';
import '../../data/services/client_api_service.dart';

class ClientController extends StateNotifier<ClientState> {
  final ClientApiService _apiService;

  ClientController(this._apiService) : super(const ClientState());

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

      final data = await _apiService.fetchClients(fullName: query);
      final List<Map<String, dynamic>> clients =
          (data['profile'] != null)
              ? List<Map<String, dynamic>>.from(data['profile'])
              : [];

      state = state.copyWith(
        filteredClients: clients,
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
      final result = await _apiService.createClient(
        name: name,
        email: email,
        phone: phone,
      );
      state = state.copyWith(isLoading: false);
      return result;
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
