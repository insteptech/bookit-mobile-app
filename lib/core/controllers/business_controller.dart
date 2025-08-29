import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/dashboard/models/business_category_model.dart';
import 'package:bookit_mobile_app/core/services/cache_service.dart';
import 'package:flutter/foundation.dart';

// State classes
class BusinessState {
  final List<dynamic> businessCategories;
  final BusinessType businessType;
  final bool isLoading;
  final bool isLoaded;
  final String? error;

  const BusinessState({
    this.businessCategories = const [],
    this.businessType = BusinessType.both,
    this.isLoading = false,
    this.isLoaded = false,
    this.error,
  });

  BusinessState copyWith({
    List<dynamic>? businessCategories,
    BusinessType? businessType,
    bool? isLoading,
    bool? isLoaded,
    String? error,
  }) {
    return BusinessState(
      businessCategories: businessCategories ?? this.businessCategories,
      businessType: businessType ?? this.businessType,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error ?? this.error,
    );
  }
}

// Business Controller
class BusinessController extends StateNotifier<BusinessState> {
  final CacheService _cacheService = CacheService();
  
  BusinessController() : super(const BusinessState());

  Future<void> fetchBusinessCategories() async {
    // Start with cached data if available and not loading
    if (!state.isLoading) {
      await _loadCachedBusinessType();
    }
    
    // Don't set loading if we already have cached data to avoid UI flicker
    if (state.businessCategories.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }
    
    try {
      final response = await APIRepository.getBusinessLevel0Categories()
          .timeout(const Duration(seconds: 10));
      
      final businessData = response.data;
      final categories = businessData['data']['level0_categories'] as List? ?? [];
      final businessType = _determineBusinessTypeFromLevel0Categories(categories);
      
      // Check if data has changed compared to cached version
      final cachedData = await _cacheService.getCachedBusinessType();
      final hasDataChanged = _hasBusinessDataChanged(cachedData, businessData);
      
      if (hasDataChanged || state.businessCategories.isEmpty) {
        // Cache the new data
        await _cacheService.cacheBusinessType(businessData);
        
        state = state.copyWith(
          businessCategories: categories,
          businessType: businessType,
          isLoading: false,
          isLoaded: true,
        );
        
        debugPrint("Business categories updated: ${categories.length} categories, type: $businessType");
      } else {
        // Data hasn't changed, just update loading state
        state = state.copyWith(isLoading: false, isLoaded: true);
        debugPrint("Business data unchanged, using cached data");
      }
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoaded: true,
        error: e.toString(),
      );
      debugPrint("Error fetching business categories: $e");
    }
  }

  Future<void> _loadCachedBusinessType() async {
    final cachedData = await _cacheService.getCachedBusinessType();
    if (cachedData != null) {
      final categories = cachedData['data']['level0_categories'] as List? ?? [];
      final businessType = _determineBusinessTypeFromLevel0Categories(categories);
      
      state = state.copyWith(
        businessCategories: categories,
        businessType: businessType,
        isLoaded: true,
      );
      
      debugPrint("Loaded cached business type: $businessType");
    }
  }

  bool _hasBusinessDataChanged(Map<String, dynamic>? cachedData, Map<String, dynamic> newData) {
    if (cachedData == null) return true;
    
    final cachedCategories = cachedData['data']['level0_categories'] as List? ?? [];
    final newCategories = newData['data']['level0_categories'] as List? ?? [];
    
    if (cachedCategories.length != newCategories.length) return true;
    
    // Simple comparison based on IDs and key fields
    for (int i = 0; i < newCategories.length; i++) {
      final cached = cachedCategories.firstWhere(
        (item) => item['id'] == newCategories[i]['id'],
        orElse: () => {},
      );
      
      if (cached.isEmpty) return true; // New category
      
      if (cached['name'] != newCategories[i]['name'] ||
          cached['is_class'] != newCategories[i]['is_class']) {
        return true;
      }
    }
    
    return false;
  }

  BusinessType _determineBusinessTypeFromLevel0Categories(List<dynamic> categories) {
    if (categories.isEmpty) {
      return BusinessType.both; // Default fallback
    }

    bool hasClassCategory = false;
    bool hasNonClassCategory = false;

    for (final categoryData in categories) {
      final isClass = categoryData['is_class'] as bool? ?? false;
      
      if (isClass) {
        hasClassCategory = true;
        debugPrint("Found class category: ${categoryData['name']}");
      } else {
        hasNonClassCategory = true;
        debugPrint("Found non-class category: ${categoryData['name']}");
      }
    }

    BusinessType result;
    if (hasClassCategory && hasNonClassCategory) {
      result = BusinessType.both;
      debugPrint("Business type determined: BOTH");
    } else if (hasClassCategory) {
      result = BusinessType.classOnly;
      debugPrint("Business type determined: CLASS ONLY");
    } else {
      result = BusinessType.appointmentOnly;
      debugPrint("Business type determined: APPOINTMENT ONLY");
    }
    
    return result;
  }

  void reset() {
    state = const BusinessState();
  }

  Future<void> clearCache() async {
    await _cacheService.clearBusinessTypeCache();
  }
}

// Provider
final businessControllerProvider = StateNotifierProvider<BusinessController, BusinessState>((ref) {
  return BusinessController();
});

// Convenience providers
final businessTypeProvider = Provider<BusinessType>((ref) {
  return ref.watch(businessControllerProvider).businessType;
});

final businessCategoriesProvider = Provider<List<dynamic>>((ref) {
  return ref.watch(businessControllerProvider).businessCategories;
});

final businessLoadingProvider = Provider<bool>((ref) {
  return ref.watch(businessControllerProvider).isLoading;
});

final businessLoadedProvider = Provider<bool>((ref) {
  return ref.watch(businessControllerProvider).isLoaded;
});
