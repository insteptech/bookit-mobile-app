/// API request models for onboarding endpoints
class OnboardingApiRequest {
  final String step;
  final Map<String, dynamic> data;

  OnboardingApiRequest({
    required this.step,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'step': step,
    'data': data,
  };
}

class BusinessInfoApiRequest {
  final String name;
  final String email;
  final String phone;
  final String? website;
  final String? businessId;
  final String? activeStep;

  BusinessInfoApiRequest({
    required this.name,
    required this.email,
    required this.phone,
    this.website,
    this.businessId,
    this.activeStep,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    if (website != null) 'website': website,
    if (businessId != null) 'business_id': businessId,
    if (activeStep != null) 'active_step': activeStep,
  };
}

class LocationInfoApiRequest {
  final String businessId;
  final List<Map<String, dynamic>> locations;

  LocationInfoApiRequest({
    required this.businessId,
    required this.locations,
  });

  Map<String, dynamic> toJson() => {
    'business_id': businessId,
    'locations': locations,
  };
}

class CategoryUpdateApiRequest {
  final String? id;
  final String businessId;
  final String categoryId;

  CategoryUpdateApiRequest({
    this.id,
    required this.businessId,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'business_id': businessId,
    'category_id': categoryId,
  };
}

class ServicesApiRequest {
  final List<Map<String, dynamic>> services;

  ServicesApiRequest({required this.services});

  Map<String, dynamic> toJson() => {
    'services': services,
  };
}

class ServiceDetailsApiRequest {
  final List<Map<String, dynamic>> details;

  ServiceDetailsApiRequest({required this.details});

  Map<String, dynamic> toJson() => {
    'details': details,
  };
}
