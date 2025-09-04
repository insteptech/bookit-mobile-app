import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/utils/data_comparison_utils.dart';
import 'package:bookit_mobile_app/core/services/cache_service.dart';

// State class for appointments
class AppointmentsState {
  final List<Map<String, dynamic>> allStaffAppointments;
  final List<Map<String, dynamic>> todaysStaffAppointments;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const AppointmentsState({
    this.allStaffAppointments = const [],
    this.todaysStaffAppointments = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  AppointmentsState copyWith({
    List<Map<String, dynamic>>? allStaffAppointments,
    List<Map<String, dynamic>>? todaysStaffAppointments,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return AppointmentsState(
      allStaffAppointments: allStaffAppointments ?? this.allStaffAppointments,
      todaysStaffAppointments: todaysStaffAppointments ?? this.todaysStaffAppointments,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error ?? this.error,
    );
  }
}

// Appointments Controller
class AppointmentsController extends StateNotifier<AppointmentsState> {
  final CacheService _cacheService = CacheService();
  
  AppointmentsController() : super(const AppointmentsState());


  Future<void> fetchAppointments(String locationId) async {
    // First, try to load from cache
    final cachedAppointments = await _cacheService.getCachedAppointments(locationId);
    
    // If cache exists, show it immediately (no loading state)
    if (cachedAppointments != null) {
      state = state.copyWith(
        allStaffAppointments: cachedAppointments,
        isLoading: false,
      );
      _filterTodaysAppointments();
      
      // ALWAYS fetch fresh data in parallel (background refresh)
      _fetchAppointmentsFromAPI(locationId, showBackgroundRefresh: true);
    } else {
      // No cache exists, show loading and fetch immediately
      state = state.copyWith(isLoading: true, error: null);
      await _fetchAppointmentsFromAPI(locationId, showBackgroundRefresh: false);
    }
  }

  Future<void> _fetchAppointmentsFromAPI(String locationId, {bool showBackgroundRefresh = false}) async {
    if (showBackgroundRefresh) {
      state = state.copyWith(isRefreshing: true);
    }

    try {
      final data = await APIRepository.getAppointments(locationId);
      final List<Map<String, dynamic>> appointmentsList =
          List<Map<String, dynamic>>.from(data['data']);
    
      // Cache the fresh data
      await _cacheService.cacheAppointments(locationId, appointmentsList);
      
      // Only update UI if data has changed
      if (DataComparisonUtils.hasDataChanged(state.allStaffAppointments, appointmentsList)) {
        state = state.copyWith(
          allStaffAppointments: appointmentsList,
          isLoading: false,
          isRefreshing: false,
        );
        _filterTodaysAppointments();
      } else {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
      // debugPrint("Error fetching appointments: $e");
    }
  }

  // Keep the old method for backward compatibility/forced refresh
  Future<void> fetchAppointmentsForced(String locationId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await APIRepository.getAppointments(locationId);
      final List<Map<String, dynamic>> appointmentsList =
          List<Map<String, dynamic>>.from(data['data']);
    
      // Cache the data
      await _cacheService.cacheAppointments(locationId, appointmentsList);
      
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
      // debugPrint("Error fetching appointments: $e");
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
          // debugPrint("Error parsing appointment start_time: ${appointment['start_time']}, Error: $e");
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
