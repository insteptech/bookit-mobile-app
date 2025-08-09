import 'onboarding_step.dart';

/// Generic onboarding request that encapsulates step and data
class OnboardingRequest {
  final OnboardingStep step;
  final OnboardingStepData data;

  OnboardingRequest({
    required this.step,
    required this.data,
  });

  /// Converts the request to JSON payload for API
  Map<String, dynamic> toJson() => {
    'step': step.value,
    'data': data.toJson(),
  };
}

/// Factory for creating onboarding requests
class OnboardingRequestFactory {
  static OnboardingRequest createBusinessInfoRequest({
    required String name,
    required String email,
    required String phone,
    String? website,
    String? businessId,
  }) =>
      OnboardingRequest(
        step: OnboardingStep.aboutYou,
        data: BusinessInfoStepData(
          businessId: businessId,
          name: name,
          email: email,
          phone: phone,
          website: website,
          activeStep: 'locations',
        ),
      );

  static OnboardingRequest createLocationRequest({
    required String businessId,
    required List<Map<String, dynamic>> locations,
  }) =>
      OnboardingRequest(
        step: OnboardingStep.locations,
        data: LocationStepData(
          businessId: businessId,
          locations: locations,
        ),
      );

  static OnboardingRequest createCategoryRequest({
    String? id,
    required String businessId,
    required String categoryId,
  }) =>
      OnboardingRequest(
        step: OnboardingStep.categories,
        data: CategoryStepData(
          id: id,
          businessId: businessId,
          categoryId: categoryId,
        ),
      );

  static OnboardingRequest createServicesRequest({
    required List<Map<String, dynamic>> services,
  }) =>
      OnboardingRequest(
        step: OnboardingStep.services,
        data: ServicesStepData(services: services),
      );

  static OnboardingRequest createServiceDetailsRequest({
    required List<Map<String, dynamic>> details,
  }) =>
      OnboardingRequest(
        step: OnboardingStep.serviceDetails,
        data: ServiceDetailsStepData(details: details),
      );
}
