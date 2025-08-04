import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/dashboard/models/business_category_model.dart';

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
  BusinessController() : super(const BusinessState());

  Future<void> fetchBusinessCategories() async {
    //Todo: refine this logic, its not making the fresh calls
    // if (state.isLoaded) return; // Don't fetch if already loaded

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Add timeout to prevent indefinite loading
      final data = await APIRepository.getBusinessServiceCategories()
          .timeout(const Duration(seconds: 10));
      
      // Extract business_services from the nested structure
      final businessServices = data['data']?['data']?['business_services'] ?? [];
      final businessType = _determineBusinessType(businessServices);
      
      state = state.copyWith(
        businessCategories: businessServices,
        businessType: businessType,
        isLoading: false,
        isLoaded: true,
      );
      
      print("Business categories fetched: ${businessServices.length} categories");
      for (var service in businessServices) {
        print("Category: ${service['category']['name']}, is_class: ${service['is_class']}");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoaded: true,
        error: e.toString(),
      );
      print("Error fetching business categories: $e");
    }
  }

  BusinessType _determineBusinessType(List<dynamic> businessServices) {
    if (businessServices.isEmpty) {
      return BusinessType.both; // Default fallback
    }

    bool hasClassCategory = false;
    bool hasNonClassCategory = false;

    for (final serviceData in businessServices) {
      final category = serviceData['category'];
      final isClass = serviceData['is_class'];
      
      if (category != null) {
        if (isClass == true) {
          hasClassCategory = true;
          print("Found class category: ${category['name']}");
        } else {
          hasNonClassCategory = true;
          print("Found non-class category: ${category['name']}");
        }
      }
    }

    BusinessType result;
    if (hasClassCategory && hasNonClassCategory) {
      result = BusinessType.both;
      print("Business type determined: BOTH");
    } else if (hasClassCategory) {
      result = BusinessType.classOnly;
      print("Business type determined: CLASS ONLY");
    } else {
      result = BusinessType.appointmentOnly;
      print("Business type determined: APPOINTMENT ONLY");
    }
    
    return result;
  }

  void reset() {
    state = const BusinessState();
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
