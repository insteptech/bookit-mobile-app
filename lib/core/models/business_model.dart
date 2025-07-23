class BusinessModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? website;
  final String activeStep;
  final bool isOnboardingComplete;
  final List<Location> locations;
  final List<BusinessCategory> businessCategories;
  final List<BusinessService> businessServices;

  BusinessModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.website,
    required this.activeStep,
    required this.isOnboardingComplete,
    required this.locations,
    required this.businessCategories,
    required this.businessServices,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      activeStep: json['active_step'],
      isOnboardingComplete: json['is_onboarding_complete'] ?? false,
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => Location.fromJson(e))
              .toList() ??
          [],
      businessCategories: (json['business_categories'] as List<dynamic>?)
              ?.map((e) => BusinessCategory.fromJson(e))
              .toList() ??
          [],
      businessServices: (json['business_services'] as List<dynamic>?)
              ?.map((e) => BusinessService.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'BusinessModel(id: $id, locations: $locations)';
  }
}

class Location {
  final String id;
  final String title;
  final String address;
  final String? floor;
  final String city;
  final String state;
  final String country;
  final String? instructions;
  final double? latitude;
  final double? longitude;

  Location({
    required this.id,
    required this.title,
    required this.address,
    this.floor,
    required this.city,
    required this.state,
    required this.country,
    this.instructions,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      floor: json['floor'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      instructions: json['instructions'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() {
    return '{title: $title, address: $address, city: $city, state: $state}';
  }
}

class BusinessCategory {
  final String id;
  final String businessId;
  final String categoryId;
  final Category category;

  BusinessCategory({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.category,
  });

  factory BusinessCategory.fromJson(Map<String, dynamic> json) {
    return BusinessCategory(
      id: json['id'],
      businessId: json['business_id'],
      categoryId: json['category_id'],
      category: Category.fromJson(json['category']),
    );
  }
}

class BusinessService {
  final String id;
  final String businessId;
  final String categoryId;
  final Category category;
  final List<Map<String, dynamic>> serviceDetails;

  BusinessService({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.category,
    required this.serviceDetails,
  });

  factory BusinessService.fromJson(Map<String, dynamic> json) {
    return BusinessService(
      id: json['id'],
      businessId: json['business_id'],
      categoryId: json['category_id'],
      category: Category.fromJson(json['category']),
      serviceDetails: (json['service_details'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
    );
  }
}

class Category {
  final String id;
  final String? parentId;
  final String name;
  final String? description;
  final String? slug;
  final int? level;
  final bool? isActive;
  final bool isClass;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    this.parentId,
    required this.name,
    this.description,
    this.slug,
    this.level,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.isClass,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      parentId: json['parent_id'],
      name: json['name'],
      description: json['description'],
      slug: json['slug'],
      level: json['level'],
      isActive: json['is_active'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      isClass: json['is_class']
    );
  }

  /// ✅ Used when you need a fallback or default value (e.g. in `.firstWhere`)
  factory Category.empty() {
    return Category(
      id: '',
      name: 'Unknown',
      level: 0,
      isActive: false,
      isClass: false,
    );
  }
}
