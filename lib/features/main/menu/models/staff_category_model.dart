class StaffCategoryResponse {
  final bool success;
  final StaffCategoryData data;

  StaffCategoryResponse({
    required this.success,
    required this.data,
  });

  factory StaffCategoryResponse.fromJson(Map<String, dynamic> json) {
    return StaffCategoryResponse(
      success: json['success'] ?? false,
      data: StaffCategoryData.fromJson(json['data'] ?? {}),
    );
  }
}

class StaffCategoryData {
  final String businessId;
  final int totalCategories;
  final int totalStaff;
  final List<StaffCategory> categories;

  StaffCategoryData({
    required this.businessId,
    required this.totalCategories,
    required this.totalStaff,
    required this.categories,
  });

  factory StaffCategoryData.fromJson(Map<String, dynamic> json) {
    return StaffCategoryData(
      businessId: json['business_id'] ?? '',
      totalCategories: json['total_categories'] ?? 0,
      totalStaff: json['total_staff'] ?? 0,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((category) => StaffCategory.fromJson(category))
              .toList() ??
          [],
    );
  }
}

class StaffCategory {
  final String categoryName;
  final String categoryId;
  final List<StaffMember> staffMembers;

  StaffCategory({
    required this.categoryName,
    required this.categoryId,
    required this.staffMembers,
  });

  factory StaffCategory.fromJson(Map<String, dynamic> json) {
    return StaffCategory(
      categoryName: json['category_name'] ?? '',
      categoryId: json['category_id'] ?? '',
      staffMembers: (json['staff_members'] as List<dynamic>?)
              ?.map((staff) => StaffMember.fromJson(staff))
              .toList() ??
          [],
    );
  }
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePhotoUrl;
  final String gender;
  final bool forClass;
  final bool isAvailable;
  final List<String> locationIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePhotoUrl,
    required this.gender,
    required this.forClass,
    required this.isAvailable,
    required this.locationIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePhotoUrl: json['profile_photo_url'],
      gender: json['gender'] ?? '',
      forClass: json['for_class'] ?? false,
      isAvailable: json['is_available'] ?? true,
      locationIds: (json['location_id'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
