import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/utils/data_comparison_utils.dart';
import 'package:bookit_mobile_app/core/services/cache_service.dart';
import 'package:intl/intl.dart';

// State class for classes
class ClassesState {
  final Map<String, List<dynamic>> classesByLocationAndDay;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const ClassesState({
    this.classesByLocationAndDay = const {},
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  ClassesState copyWith({
    Map<String, List<dynamic>>? classesByLocationAndDay,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return ClassesState(
      classesByLocationAndDay: classesByLocationAndDay ?? this.classesByLocationAndDay,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error ?? this.error,
    );
  }

  List<dynamic> getClassesForLocationAndDay(String locationId, String day) {
    final key = '${locationId}_$day';
    return classesByLocationAndDay[key] ?? [];
  }
}

// Classes Controller
class ClassesController extends StateNotifier<ClassesState> {
  final CacheService _cacheService = CacheService();
  
  ClassesController() : super(const ClassesState());

  Future<void> fetchClassesForDate(String? locationId, DateTime date) async {
    final dayName = DateFormat('EEEE').format(date);
    final effectiveLocationId = locationId ?? 'all';
    final cacheKey = '${effectiveLocationId}_$dayName';
    
    // First, try to load from cache
    final cachedClasses = await _cacheService.getCachedClasses(effectiveLocationId, dayName);
    
    // If cache exists, show it immediately (no loading state)
    if (cachedClasses != null) {
      final updatedMap = Map<String, List<dynamic>>.from(state.classesByLocationAndDay);
      updatedMap[cacheKey] = cachedClasses;
      
      state = state.copyWith(
        classesByLocationAndDay: updatedMap,
        isLoading: false,
      );
      
      // ALWAYS fetch fresh data in parallel (background refresh)
      _fetchClassesFromAPI(effectiveLocationId, dayName, showBackgroundRefresh: true);
    } else {
      // No cache exists, show loading and fetch immediately
      state = state.copyWith(isLoading: true, error: null);
      await _fetchClassesFromAPI(effectiveLocationId, dayName, showBackgroundRefresh: false);
    }
  }

  Future<void> _fetchClassesFromAPI(String locationId, String dayName, {bool showBackgroundRefresh = false}) async {
    final cacheKey = '${locationId}_$dayName';
    
    if (showBackgroundRefresh) {
      state = state.copyWith(isRefreshing: true);
    }

    try {
      List<dynamic> allClasses = [];
      
      if (locationId != 'all') {
        // Fetch classes for specific location
        final response = await APIRepository.getClassSchedulesByLocationAndDay(locationId, dayName);
        allClasses = _processClassesResponse(response, dayName);
      } else {
        // Fetch all classes for the day
        final response = await APIRepository.getClassesByBusinessAndDay(dayName);
        allClasses = _processClassesResponse(response, dayName);
      }
      
      // Cache the fresh data
      await _cacheService.cacheClasses(locationId, dayName, allClasses);
      
      // Only update UI if data has changed
      final currentClasses = state.getClassesForLocationAndDay(locationId, dayName);
      if (DataComparisonUtils.hasDataChanged(currentClasses, allClasses)) {
        final updatedMap = Map<String, List<dynamic>>.from(state.classesByLocationAndDay);
        updatedMap[cacheKey] = allClasses;
        
        state = state.copyWith(
          classesByLocationAndDay: updatedMap,
          isLoading: false,
          isRefreshing: false,
        );
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
      // Debug logging - remove in production
      // debugPrint("Error fetching classes: $e");
    }
  }

  List<dynamic> _processClassesResponse(dynamic response, String dayName) {
    if (response == null || response['data'] == null) return [];
    
    List<dynamic> allClasses = [];
    
    for (var classData in response['data']['data']) {
      if (classData['full_data'] != null && classData['full_data']['schedules'] != null) {
        for (var schedule in classData['full_data']['schedules']) {
          if (schedule['day_of_week'].toString().toLowerCase() == dayName.toLowerCase()) {
            allClasses.add({
              'service_name': classData['service_name'],
              'category_id': schedule['class_id'],
              'schedule': schedule,
              'full_data': classData['full_data'],
            });
          }
        }
      }
    }
    
    // Sort by start time
    allClasses.sort((a, b) => a['schedule']['start_time'].compareTo(b['schedule']['start_time']));
    
    return allClasses;
  }

  void clearClasses() {
    state = const ClassesState();
  }
}

// Provider
final classesControllerProvider = StateNotifierProvider<ClassesController, ClassesState>((ref) {
  return ClassesController();
});

// Convenience providers
final classesForDateProvider = Provider.family<List<dynamic>, Map<String, dynamic>>((ref, params) {
  final locationId = params['locationId'] as String?;
  final date = params['date'] as DateTime;
  final dayName = DateFormat('EEEE').format(date);
  final effectiveLocationId = locationId ?? 'all';
  
  return ref.watch(classesControllerProvider).getClassesForLocationAndDay(effectiveLocationId, dayName);
});

final classesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(classesControllerProvider).isLoading;
});

final classesRefreshingProvider = Provider<bool>((ref) {
  return ref.watch(classesControllerProvider).isRefreshing;
});