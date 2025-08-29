import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/services/cache_service.dart';

// State classes
class StaffState {
  final List<Map<String, dynamic>> allStaff;
  final List<Map<String, dynamic>> appointmentStaff; // for_class: false
  final List<Map<String, dynamic>> classStaff; // for_class: true
  final bool isLoading;
  final bool isLoaded;
  final String? error;

  const StaffState({
    this.allStaff = const [],
    this.appointmentStaff = const [],
    this.classStaff = const [],
    this.isLoading = false,
    this.isLoaded = false,
    this.error,
  });

  StaffState copyWith({
    List<Map<String, dynamic>>? allStaff,
    List<Map<String, dynamic>>? appointmentStaff,
    List<Map<String, dynamic>>? classStaff,
    bool? isLoading,
    bool? isLoaded,
    String? error,
  }) {
    return StaffState(
      allStaff: allStaff ?? this.allStaff,
      appointmentStaff: appointmentStaff ?? this.appointmentStaff,
      classStaff: classStaff ?? this.classStaff,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error ?? this.error,
    );
  }

  bool get hasAppointmentStaff => appointmentStaff.isNotEmpty;
  bool get hasClassStaff => classStaff.isNotEmpty;
}

// Staff Controller
class StaffController extends StateNotifier<StaffState> {
  final CacheService _cacheService = CacheService();
  
  StaffController() : super(const StaffState());

  Future<void> fetchStaffList() async {
    // Start with cached data if available and not loading
    if (!state.isLoading) {
      await _loadCachedStaff();
    }
    
    // Don't set loading if we already have cached data to avoid UI flicker
    if (state.allStaff.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }
    
    try {
      final response = await APIRepository.getStaffList();
      final List<Map<String, dynamic>> staffList = 
          List<Map<String, dynamic>>.from(response.data['data']['profiles'] ?? []);
      
      // Check if data has changed compared to cached version
      final cachedStaff = await _cacheService.getCachedStaffData();
      final hasDataChanged = _hasStaffDataChanged(cachedStaff, staffList);
      
      if (hasDataChanged || state.allStaff.isEmpty) {
        // Cache the new data
        await _cacheService.cacheStaffData(staffList);
        
        // Filter staff
        final appointmentStaff = _filterStaffByClass(staffList, false);
        final classStaff = _filterStaffByClass(staffList, true);
        
        state = state.copyWith(
          allStaff: staffList,
          appointmentStaff: appointmentStaff,
          classStaff: classStaff,
          isLoading: false,
          isLoaded: true,
        );
        
        debugPrint("Staff list updated: ${staffList.length} total, "
            "${appointmentStaff.length} appointment staff, ${classStaff.length} class staff");
      } else {
        // Data hasn't changed, just update loading state
        state = state.copyWith(isLoading: false, isLoaded: true);
        debugPrint("Staff data unchanged, using cached data");
      }
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoaded: true,
        error: e.toString(),
      );
      debugPrint("Error fetching staff list: $e");
    }
  }

  Future<void> _loadCachedStaff() async {
    final cachedStaff = await _cacheService.getCachedStaffData();
    if (cachedStaff != null && cachedStaff.isNotEmpty) {
      final appointmentStaff = _filterStaffByClass(cachedStaff, false);
      final classStaff = _filterStaffByClass(cachedStaff, true);
      
      state = state.copyWith(
        allStaff: cachedStaff,
        appointmentStaff: appointmentStaff,
        classStaff: classStaff,
        isLoaded: true,
      );
      
      debugPrint("Loaded cached staff: ${cachedStaff.length} total");
    }
  }

  List<Map<String, dynamic>> _filterStaffByClass(List<Map<String, dynamic>> staff, bool forClass) {
    return staff.where((staffMember) {
      final staffForClass = staffMember['for_class'] as bool? ?? false;
      return staffForClass == forClass;
    }).toList();
  }

  bool _hasStaffDataChanged(List<Map<String, dynamic>>? cachedData, List<Map<String, dynamic>> newData) {
    if (cachedData == null) return true;
    if (cachedData.length != newData.length) return true;
    
    // Simple comparison based on IDs and key fields
    for (int i = 0; i < newData.length; i++) {
      final cached = cachedData.firstWhere(
        (item) => item['id'] == newData[i]['id'],
        orElse: () => {},
      );
      
      if (cached.isEmpty) return true; // New staff member
      
      // Check if key fields have changed
      if (cached['name'] != newData[i]['name'] ||
          cached['email'] != newData[i]['email'] ||
          cached['for_class'] != newData[i]['for_class'] ||
          cached['is_available'] != newData[i]['is_available']) {
        return true;
      }
    }
    
    return false;
  }

  void reset() {
    state = const StaffState();
  }

  Future<void> clearCache() async {
    await _cacheService.clearStaffCache();
  }
}

// Provider
final staffControllerProvider = StateNotifierProvider<StaffController, StaffState>((ref) {
  return StaffController();
});

// Convenience providers
final allStaffProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(staffControllerProvider).allStaff;
});

final appointmentStaffProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(staffControllerProvider).appointmentStaff;
});

final classStaffProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(staffControllerProvider).classStaff;
});

final hasAppointmentStaffProvider = Provider<bool>((ref) {
  return ref.watch(staffControllerProvider).hasAppointmentStaff;
});

final hasClassStaffProvider = Provider<bool>((ref) {
  return ref.watch(staffControllerProvider).hasClassStaff;
});

final staffLoadingProvider = Provider<bool>((ref) {
  return ref.watch(staffControllerProvider).isLoading;
});