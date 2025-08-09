import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:bookit_mobile_app/features/onboarding/data/services/onboarding_api_service.dart';
import 'package:bookit_mobile_app/features/onboarding/domain/domain.dart';

/// Implementation of OnboardingRepository that delegates to OnboardingApiService.
/// This class acts as a bridge between the application layer and the data source.
/// It handles business logic for payload creation using domain entities.
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingApiService _apiService;

  OnboardingRepositoryImpl(this._apiService);

  @override
  Future<BusinessModel> submitBusinessInfo({
    required String name,
    required String email,
    required String phone,
    String? website,
    String? businessId,
  }) async {
    final request = OnboardingRequestFactory.createBusinessInfoRequest(
      name: name,
      email: email,
      phone: phone,
      website: website,
      businessId: businessId,
    );
    
    return await _apiService.submitOnboardingStep(
      payload: request.toJson(),
    );
  }

  @override
  Future<BusinessModel> getBusinessDetails({String? businessId}) {
    return _apiService.getBusinessDetails(businessId: businessId);
  }

  @override
  Future<void> submitLocationInfo({
    required String businessId,
    required List<Map<String, dynamic>> locations,
  }) async {
    final request = OnboardingRequestFactory.createLocationRequest(
      businessId: businessId,
      locations: locations,
    );
    
    await _apiService.submitOnboardingStepVoid(
      payload: request.toJson(),
    );
  }

  @override
  Future<List<CategoryModel>> getCategories({String? categoryLevel}) {
    return _apiService.getCategories(categoryLevel: categoryLevel);
  }

  @override
  Future<void> updateCategory({
    String? id,
    required String businessId,
    required String categoryId,
  }) async {
    final request = OnboardingRequestFactory.createCategoryRequest(
      id: id,
      businessId: businessId,
      categoryId: categoryId,
    );
    
    await _apiService.submitOnboardingStepVoid(
      payload: request.toJson(),
    );
  }

  @override
  Future<void> createServices({
    required List<Map<String, dynamic>> services,
  }) async {
    final request = OnboardingRequestFactory.createServicesRequest(
      services: services,
    );
    
    await _apiService.submitOnboardingStepVoid(
      payload: request.toJson(),
    );
  }

  @override
  Future<void> updateService({
    required List<Map<String, dynamic>> allDetails,
  }) async {
    final request = OnboardingRequestFactory.createServiceDetailsRequest(
      details: allDetails,
    );
    
    await _apiService.submitOnboardingStepVoid(
      payload: request.toJson(),
    );
  }
}
