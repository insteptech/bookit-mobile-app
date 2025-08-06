import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';

// State class for appointments
class AppointmentsState {
  final List<Map<String, dynamic>> allStaffAppointments;
  final List<Map<String, dynamic>> todaysStaffAppointments;
  final bool isLoading;
  final String? error;

  const AppointmentsState({
    this.allStaffAppointments = const [],
    this.todaysStaffAppointments = const [],
    this.isLoading = false,
    this.error,
  });

  AppointmentsState copyWith({
    List<Map<String, dynamic>>? allStaffAppointments,
    List<Map<String, dynamic>>? todaysStaffAppointments,
    bool? isLoading,
    String? error,
  }) {
    return AppointmentsState(
      allStaffAppointments: allStaffAppointments ?? this.allStaffAppointments,
      todaysStaffAppointments: todaysStaffAppointments ?? this.todaysStaffAppointments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Appointments Controller
class AppointmentsController extends StateNotifier<AppointmentsState> {
  AppointmentsController() : super(const AppointmentsState());


  Future<void> fetchAppointments(String locationId) async {
    await APIRepository.getStaffList();
    state = state.copyWith(isLoading: true, error: null);

    await APIRepository.getAllClassesDetails();
    try {
      final data = await APIRepository.getAppointments(locationId);
      final List<Map<String, dynamic>> appointmentsList =
          List<Map<String, dynamic>>.from(data['data']);

      state = state.copyWith(
        allStaffAppointments: appointmentsList,
        isLoading: false,
      );

      _filterTodaysAppointments();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      debugPrint("Error fetching appointments: $e");
    }
  }

  void _filterTodaysAppointments() {
    // Use local time boundaries for today's appointments
    final now = DateTime.now(); // Local time
    final todayStart = DateTime(now.year, now.month, now.day); // Local midnight
    final todayEnd = todayStart.add(const Duration(days: 1)); // Local midnight tomorrow

    final filtered = state.allStaffAppointments.map((staff) {
      final appointments = (staff['appointments'] as List).where((appointment) {
        try {
          // Parse UTC time from backend and convert to local time
          final utcStartTime = DateTime.parse(appointment['start_time']);
          final localStartTime = utcStartTime.toLocal();
          
          // Check if appointment falls within today's local time boundaries
          final isToday = localStartTime.isAfter(todayStart) && localStartTime.isBefore(todayEnd);
          
          return isToday;
        } catch (e) {
          debugPrint("Error parsing appointment start_time: ${appointment['start_time']}, Error: $e");
          return false; // Skip invalid appointment times
        }
      }).toList();

      return {
        ...staff,
        'appointments': appointments,
      };
    }).where((staff) => (staff['appointments'] as List).isNotEmpty).toList();
    

    state = state.copyWith(todaysStaffAppointments: filtered);
  }

  void clearAppointments() {
    state = const AppointmentsState();
  }
}

// Provider
final appointmentsControllerProvider = StateNotifierProvider<AppointmentsController, AppointmentsState>((ref) {
  return AppointmentsController();
});

// Convenience providers
final allAppointmentsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(appointmentsControllerProvider).allStaffAppointments;
});

final todaysAppointmentsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(appointmentsControllerProvider).todaysStaffAppointments;
});

final appointmentsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appointmentsControllerProvider).isLoading;
});
