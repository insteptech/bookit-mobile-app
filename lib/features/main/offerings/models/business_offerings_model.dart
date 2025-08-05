class BusinessOfferingsResponse {
  final bool success;
  final BusinessOfferingsData data;

  BusinessOfferingsResponse({
    required this.success,
    required this.data,
  });

  factory BusinessOfferingsResponse.fromJson(Map<String, dynamic> json) {
    return BusinessOfferingsResponse(
      success: json['success'] ?? false,
      data: BusinessOfferingsData.fromJson(json['data'] ?? {}),
    );
  }
}

class BusinessOfferingsData {
  final List<OfferingItem> offerings;

  BusinessOfferingsData({
    required this.offerings,
  });

  factory BusinessOfferingsData.fromJson(Map<String, dynamic> json) {
    return BusinessOfferingsData(
      offerings: (json['offerings'] as List<dynamic>?)
              ?.map((item) => OfferingItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OfferingItem {
  final String id;
  final String businessId;
  final String categoryId;
  final bool isClass;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryDetails category;
  final List<ServiceDetail> serviceDetails;

  OfferingItem({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.isClass,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.serviceDetails,
  });

  factory OfferingItem.fromJson(Map<String, dynamic> json) {
    return OfferingItem(
      id: json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      isClass: json['is_class'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      category: CategoryDetails.fromJson(json['category'] ?? {}),
      serviceDetails: (json['service_details'] as List<dynamic>?)
              ?.map((item) => ServiceDetail.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CategoryDetails {
  final String id;
  final String name;
  final int level;
  final CategoryDetails? parent;
  final CategoryDetails? rootParent;
  final bool? isClass;

  CategoryDetails({
    required this.id,
    required this.name,
    required this.level,
    this.parent,
    this.rootParent,
    this.isClass,
  });

  factory CategoryDetails.fromJson(Map<String, dynamic> json) {
    return CategoryDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? 0,
      parent: json['parent'] != null ? CategoryDetails.fromJson(json['parent']) : null,
      rootParent: json['root_parent'] != null ? CategoryDetails.fromJson(json['root_parent']) : null,
      isClass: json['is_class'],
    );
  }
}

class ServiceDetail {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ServiceDuration> durations;

  ServiceDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.durations,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      durations: (json['durations'] as List<dynamic>?)
              ?.map((item) => ServiceDuration.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ServiceDuration {
  final String id;
  final int durationMinutes;
  final String price;
  final String? packageAmount;
  final int? packagePerson;

  ServiceDuration({
    required this.id,
    required this.durationMinutes,
    required this.price,
    this.packageAmount,
    this.packagePerson,
  });

  factory ServiceDuration.fromJson(Map<String, dynamic> json) {
    return ServiceDuration(
      id: json['id'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      price: json['price'] ?? '0.00',
      packageAmount: json['package_amount'],
      packagePerson: json['package_person'],
    );
  }

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      if (minutes == 0) {
        return '$hours ${hours == 1 ? 'hr' : 'hrs'}';
      } else {
        return '$hours ${hours == 1 ? 'hr' : 'hrs'} $minutes min';
      }
    }
  }
}
