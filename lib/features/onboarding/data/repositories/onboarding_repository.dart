import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';

/// Abstract repository interface for onboarding operations.
/// This defines the contract for onboarding data operations.
abstract class OnboardingRepository {
  /// Submits business information during onboarding.
  Future<BusinessModel> submitBusinessInfo({
    required String name,
    required String email,
    required String phone,
    String? website,
    String? businessId,
  });

  /// Fetches business details by ID.
  Future<BusinessModel> getBusinessDetails({String? businessId});

  /// Submits location information for the business.
  Future<void> submitLocationInfo({
    required String businessId,
    required List<Map<String, dynamic>> locations,
  });

  /// Fetches categories with optional level filtering.
  Future<List<CategoryModel>> getCategories({String? categoryLevel});

  /// Updates category information for the business.
  Future<void> updateCategory({
    String? id,
    required String businessId,
    required String categoryId,
  });

  /// Creates services during the onboarding process.
  Future<void> createServices({
    required List<Map<String, dynamic>> services,
  });

  /// Updates service details during the onboarding process.
  Future<void> updateService({
    required List<Map<String, dynamic>> allDetails,
  });
}
