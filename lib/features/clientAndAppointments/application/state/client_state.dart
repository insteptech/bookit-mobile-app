class ClientState {
  final List<Map<String, dynamic>> filteredClients;
  final Map<String, dynamic>? selectedClient;
  final bool isSearching;
  final bool showDropdown;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const ClientState({
    this.filteredClients = const [],
    this.selectedClient,
    this.isSearching = false,
    this.showDropdown = false,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  ClientState copyWith({
    List<Map<String, dynamic>>? filteredClients,
    Map<String, dynamic>? selectedClient,
    bool? isSearching,
    bool? showDropdown,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return ClientState(
      filteredClients: filteredClients ?? this.filteredClients,
      selectedClient: selectedClient,
      isSearching: isSearching ?? this.isSearching,
      showDropdown: showDropdown ?? this.showDropdown,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasSelectedClient => selectedClient != null;
}
