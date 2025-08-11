class AppointmentState {
  final List<Map<String, dynamic>> practitioners;
  final List<Map<String, dynamic>> serviceList;
  final List<String> durationOptions;
  final String selectedPractitioner;
  final String selectedService;
  final String selectedDuration;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? partialPayload;

  const AppointmentState({
    this.practitioners = const [],
    this.serviceList = const [],
    this.durationOptions = const [],
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
    List<String>? durationOptions,
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
      durationOptions: durationOptions ?? this.durationOptions,
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
}
