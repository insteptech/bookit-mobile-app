class AppointmentState {
  final List<Map<String, dynamic>> practitioners;
  final List<Map<String, dynamic>> serviceList;
  final String selectedPractitioner;
  final String selectedService;
  final String selectedDuration;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? partialPayload;

  const AppointmentState({
    this.practitioners = const [],
    this.serviceList = const [],
    this.selectedPractitioner = '',
    this.selectedService = '',
    this.selectedDuration = '',
    this.isLoading = false,
    this.error,
    this.partialPayload,
  });

  AppointmentState copyWith({
    List<Map<String, dynamic>>? practitioners,
    List<Map<String, dynamic>>? serviceList,
    String? selectedPractitioner,
    String? selectedService,
    String? selectedDuration,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? partialPayload,
  }) {
    return AppointmentState(
      practitioners: practitioners ?? this.practitioners,
      serviceList: serviceList ?? this.serviceList,
      selectedPractitioner: selectedPractitioner ?? this.selectedPractitioner,
      selectedService: selectedService ?? this.selectedService,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      partialPayload: partialPayload ?? this.partialPayload,
    );
  }

  bool get canProceed =>
      selectedPractitioner.isNotEmpty &&
      selectedService.isNotEmpty &&
      selectedDuration.isNotEmpty;

  // Helper getters for easier access
  Map<String, dynamic>? get selectedServiceData {
    if (selectedService.isEmpty) return null;
    try {
      return serviceList.firstWhere(
        (service) => service['id'] == selectedService,
        orElse: () => <String, dynamic>{},
      );
    } catch (e) {
      return null;
    }
  }

  List<String> get durationOptionsForSelectedService {
    final service = selectedServiceData;
    if (service == null || service['durations'] == null) return [];
    
    try {
      return List<String>.from(
        (service['durations'] as List).map(
          (d) => d['duration_minutes'].toString(),
        ),
      );
    } catch (e) {
      return [];
    }
  }
}
