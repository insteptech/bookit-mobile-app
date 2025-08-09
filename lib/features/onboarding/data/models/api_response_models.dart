/// API response models for onboarding endpoints
class OnboardingApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  OnboardingApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory OnboardingApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return OnboardingApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errors: json['errors'],
    );
  }
}

class BusinessApiResponse {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? website;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessApiResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.website,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessApiResponse.fromJson(Map<String, dynamic> json) {
    return BusinessApiResponse(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class CategoryApiResponse {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final int level;
  final bool isActive;

  CategoryApiResponse({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    required this.level,
    required this.isActive,
  });

  factory CategoryApiResponse.fromJson(Map<String, dynamic> json) {
    return CategoryApiResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      parentId: json['parent_id'],
      level: json['level'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class CategoriesListApiResponse {
  final List<CategoryApiResponse> categories;

  CategoriesListApiResponse({required this.categories});

  factory CategoriesListApiResponse.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as List;
    return CategoriesListApiResponse(
      categories: categoriesJson
          .map((e) => CategoryApiResponse.fromJson(e))
          .toList(),
    );
  }
}
