import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/appointment_state.dart';
import '../../data/services/appointment_api_service.dart';

class AppointmentController extends StateNotifier<AppointmentState> {
  final AppointmentApiService _apiService;

  AppointmentController(this._apiService) : super(const AppointmentState());

  void updateSelectedPractitioner(String practitioner) {
    state = state.copyWith(selectedPractitioner: practitioner);
  }

  void updateSelectedService(String service) {
    state = state.copyWith(selectedService: service);
  }

  void updateSelectedDuration(String duration) {
    state = state.copyWith(selectedDuration: duration);
  }

  void updatePartialPayload(Map<String, dynamic> payload) {
    state = state.copyWith(partialPayload: payload);
  }

  Future<void> fetchPractitioners(String locationId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final data = await _apiService.getPractitioners(locationId);
      final practitioners = List<Map<String, dynamic>>.from(data['profiles']);
      state = state.copyWith(
        practitioners: practitioners,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchServices() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final data = await _apiService.getServiceList();
      final List<dynamic> rawList = data['business_services_details'];
      final List<Map<String, dynamic>> extractedList =
          rawList.asMap().entries.map<Map<String, dynamic>>((entry) {
            final item = entry.value;
            return {
              'id': item['business_service_id'],
              'title': item['title'],
              'duration': item['duration'],
            };
          }).toList();

      final List<String> durationList = extractedList
          .map<String>((item) => item['duration'].toString())
          .toSet()
          .toList();

      state = state.copyWith(
        serviceList: extractedList,
        durationOptions: durationList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> bookAppointment(List<Map<String, dynamic>> payload) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _apiService.bookAppointment(payload: payload);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = const AppointmentState();
  }
}
