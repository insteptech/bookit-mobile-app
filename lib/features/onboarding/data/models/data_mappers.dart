import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/features/onboarding/data/models/api_response_models.dart';

/// Maps between data layer models and domain/core models
class OnboardingDataMappers {
  /// Maps API response to domain BusinessModel
  static BusinessModel mapBusinessResponse(BusinessApiResponse apiResponse) {
    return BusinessModel(
      id: apiResponse.id,
      userId: '', // Will need to be populated from context
      name: apiResponse.name,
      email: apiResponse.email,
      phone: apiResponse.phone,
      website: apiResponse.website,
      activeStep: apiResponse.status, // Map status to activeStep
      isOnboardingComplete: false, // Default for onboarding flow
      locations: [], // Will be populated separately if needed
      businessCategories: [], // Will be populated separately if needed
      businessServices: [], // Will be populated separately if needed
    );
  }

  /// Maps API response to domain CategoryModel
  static CategoryModel mapCategoryResponse(CategoryApiResponse apiResponse) {
    return CategoryModel(
      id: apiResponse.id,
      parentId: apiResponse.parentId,
      slug: apiResponse.id, // Use id as slug if not provided
      name: apiResponse.name,
      description: apiResponse.description,
      level: apiResponse.level,
      isActive: apiResponse.isActive,
      createdAt: null, // Not provided in API response
      updatedAt: null, // Not provided in API response
    );
  }

  /// Maps list of category API responses
  static List<CategoryModel> mapCategoryList(List<CategoryApiResponse> apiResponses) {
    return apiResponses.map(mapCategoryResponse).toList();
  }

  /// Maps categories list API response to list of CategoryModel
  static List<CategoryModel> mapCategoriesListResponse(CategoriesListApiResponse apiResponse) {
    return mapCategoryList(apiResponse.categories);
  }
}
