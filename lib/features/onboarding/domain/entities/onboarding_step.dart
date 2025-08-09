/// Represents different steps in the onboarding process
enum OnboardingStep {
  aboutYou('about_you'),
  locations('locations'),
  categories('categories'),
  services('services'),
  serviceDetails('service_details');

  const OnboardingStep(this.value);
  final String value;
}

/// Base class for onboarding step data
abstract class OnboardingStepData {
  Map<String, dynamic> toJson();
}

/// Business information step data
class BusinessInfoStepData extends OnboardingStepData {
  final String? businessId;
  final String name;
  final String email;
  final String phone;
  final String? website;
  final String? activeStep;

  BusinessInfoStepData({
    this.businessId,
    required this.name,
    required this.email,
    required this.phone,
    this.website,
    this.activeStep,
  });

  @override
  Map<String, dynamic> toJson() => {
    'business_id': businessId,
    'name': name,
    'email': email,
    'phone': phone,
    'website': website,
    'active_step': activeStep,
  };
}

/// Location information step data
class LocationStepData extends OnboardingStepData {
  final String businessId;
  final List<Map<String, dynamic>> locations;

  LocationStepData({
    required this.businessId,
    required this.locations,
  });

  @override
  Map<String, dynamic> toJson() => {
    'business_id': businessId,
    'locations': locations,
  };
}

/// Category information step data
class CategoryStepData extends OnboardingStepData {
  final String? id;
  final String businessId;
  final String categoryId;

  CategoryStepData({
    this.id,
    required this.businessId,
    required this.categoryId,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'business_id': businessId,
    'category_id': categoryId,
  };
}

/// Services step data
class ServicesStepData extends OnboardingStepData {
  final List<Map<String, dynamic>> services;

  ServicesStepData({required this.services});

  @override
  Map<String, dynamic> toJson() => {
    'services': services,
  };
}

/// Service details step data
class ServiceDetailsStepData extends OnboardingStepData {
  final List<Map<String, dynamic>> details;

  ServiceDetailsStepData({required this.details});

  @override
  Map<String, dynamic> toJson() => {
    'details': details,
  };
}
