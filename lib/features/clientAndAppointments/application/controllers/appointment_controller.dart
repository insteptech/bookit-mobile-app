import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_practitioners.dart';
import '../../domain/usecases/get_services.dart';
import '../../domain/usecases/book_appointment.dart';
import '../state/appointment_state.dart';

class AppointmentController extends StateNotifier<AppointmentState> {
  final GetPractitioners _getPractitioners;
  final GetServices _getServices;
  final BookAppointment _bookAppointment;

  AppointmentController(
    this._getPractitioners,
    this._getServices,
    this._bookAppointment,
  ) : super(const AppointmentState());

  void updateSelectedPractitioner(String practitioner) {
    state = state.copyWith(selectedPractitioner: practitioner);
  }

  void updateSelectedService(String service) {
    state = state.copyWith(
      selectedService: service,
      selectedDuration: '', // Reset duration when service changes
    );
  }

  void updateSelectedDuration(String duration) {
    state = state.copyWith(selectedDuration: duration);
  }

  void clearSelections() {
    state = state.copyWith(
      selectedPractitioner: '',
      selectedService: '',
      selectedDuration: '',
    );
  }

  void updatePartialPayload(Map<String, dynamic> payload) {
    state = state.copyWith(partialPayload: payload);
  }

  Future<void> fetchPractitioners(String locationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final practitioners = await _getPractitioners(locationId);
      state = state.copyWith(
        practitioners: practitioners.map((p) => {
          'id': p.id,
          'name': p.name,
          'email': p.email,
          'location_schedules': p.locationSchedules,
          'service_ids': p.serviceIds,
        }).toList(),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> fetchServices() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final services = await _getServices();
      state = state.copyWith(
        serviceList: services.map((s) => {
          'id': s.id,
          'business_service_id': s.businessServiceId,
          'name': s.name,
          'description': s.description,
          'is_class': s.isClass,
          'durations': s.durations.map((d) => {
            'id': d.id,
            'duration_minutes': d.durationMinutes,
            'price': d.price,
          }).toList(),
        }).toList(),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> bookAppointment({
    required String businessId,
    required String locationId,
    required String businessServiceId,
    required String practitionerId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String userId,
    required int durationMinutes,
    required String serviceName,
    required String practitionerName,
    String? clientId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _bookAppointment(
        businessId: businessId,
        locationId: locationId,
        businessServiceId: businessServiceId,
        practitionerId: practitionerId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        userId: userId,
        durationMinutes: durationMinutes,
        serviceName: serviceName,
        practitionerName: practitionerName,
        clientId: clientId,
      );
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = const AppointmentState();
  }

  // Helper method to check if we can proceed with booking
  bool get canProceedWithBooking => state.canProceed;

  // Helper method to get selected service data safely
  Map<String, dynamic>? get selectedServiceData => state.selectedServiceData;

  // Helper method to get duration options for selected service
  List<String> get durationOptions => state.durationOptionsForSelectedService;
}
