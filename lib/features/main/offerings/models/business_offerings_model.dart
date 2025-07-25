class BusinessOfferingsResponse {
  final int statusCode;
  final bool status;
  final String message;
  final BusinessOfferingsData data;
  final String? token;

  BusinessOfferingsResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
    this.token,
  });

  factory BusinessOfferingsResponse.fromJson(Map<String, dynamic> json) {
    return BusinessOfferingsResponse(
      statusCode: json['statusCode'] ?? 0,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: BusinessOfferingsData.fromJson(json['data'] ?? {}),
      token: json['token'],
    );
  }
}

class BusinessOfferingsData {
  final OfferingsDataDetail data;

  BusinessOfferingsData({
    required this.data,
  });

  factory BusinessOfferingsData.fromJson(Map<String, dynamic> json) {
    return BusinessOfferingsData(
      data: OfferingsDataDetail.fromJson(json['data'] ?? {}),
    );
  }
}

class OfferingsDataDetail {
  final List<BusinessCategoryItem> businessCategories;
  final List<BusinessServiceItem> businessServices;

  OfferingsDataDetail({
    required this.businessCategories,
    required this.businessServices,
  });

  factory OfferingsDataDetail.fromJson(Map<String, dynamic> json) {
    return OfferingsDataDetail(
      businessCategories: (json['business_categories'] as List<dynamic>?)
              ?.map((item) => BusinessCategoryItem.fromJson(item))
              .toList() ??
          [],
      businessServices: (json['business_services'] as List<dynamic>?)
              ?.map((item) => BusinessServiceItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class BusinessCategoryItem {
  final String id;
  final String businessId;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryDetails category;

  BusinessCategoryItem({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory BusinessCategoryItem.fromJson(Map<String, dynamic> json) {
    return BusinessCategoryItem(
      id: json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      category: CategoryDetails.fromJson(json['category'] ?? {}),
    );
  }
}

class CategoryDetails {
  final String id;
  final String name;

  CategoryDetails({
    required this.id,
    required this.name,
  });

  factory CategoryDetails.fromJson(Map<String, dynamic> json) {
    return CategoryDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class BusinessServiceItem {
  final String id;
  final String businessId;
  final String categoryId;
  final bool isClass;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryDetails category;
  final List<ServiceDetail> serviceDetails;

  BusinessServiceItem({
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

  factory BusinessServiceItem.fromJson(Map<String, dynamic> json) {
    return BusinessServiceItem(
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

class ServiceDetail {
  final String id;
  final String businessId;
  final String serviceId;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ServiceDuration> durations;

  ServiceDetail({
    required this.id,
    required this.businessId,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.durations,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      id: json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      serviceId: json['service_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      durations: (json['durations'] as List<dynamic>?)
              ?.map((item) => ServiceDuration.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ServiceDuration {
  final String id;
  final String businessId;
  final String serviceDetailId;
  final int durationMinutes;
  final String price;
  final String packageAmount;
  final int packagePerson;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceDuration({
    required this.id,
    required this.businessId,
    required this.serviceDetailId,
    required this.durationMinutes,
    required this.price,
    required this.packageAmount,
    required this.packagePerson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceDuration.fromJson(Map<String, dynamic> json) {
    return ServiceDuration(
      id: json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      serviceDetailId: json['service_detail_id'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      price: json['price'] ?? '0.00',
      packageAmount: json['package_amount'] ?? '0.00',
      packagePerson: json['package_person'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
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
