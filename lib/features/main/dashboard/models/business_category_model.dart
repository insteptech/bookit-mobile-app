class BusinessCategoryModel {
  final String id;
  final CategoryDetail category;

  BusinessCategoryModel({
    required this.id,
    required this.category,
  });

  factory BusinessCategoryModel.fromJson(Map<String, dynamic> json) {
    return BusinessCategoryModel(
      id: json['id'] ?? '',
      category: CategoryDetail.fromJson(json['category'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.toJson(),
    };
  }
}

class CategoryDetail {
  final bool isClass;
  final String name;
  final List<RelatedCategory> related;

  CategoryDetail({
    required this.isClass,
    required this.name,
    required this.related,
  });

  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    return CategoryDetail(
      isClass: json['is_class'] ?? false,
      name: json['name'] ?? '',
      related: (json['related'] as List? ?? [])
          .map((item) => RelatedCategory.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_class': isClass,
      'name': name,
      'related': related.map((item) => item.toJson()).toList(),
    };
  }
}

class RelatedCategory {
  final String id;
  final RelatedCategoryDetail relatedCategory;

  RelatedCategory({
    required this.id,
    required this.relatedCategory,
  });

  factory RelatedCategory.fromJson(Map<String, dynamic> json) {
    return RelatedCategory(
      id: json['id'] ?? '',
      relatedCategory: RelatedCategoryDetail.fromJson(json['related_category'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'related_category': relatedCategory.toJson(),
    };
  }
}

class RelatedCategoryDetail {
  final String id;
  final String name;
  final String slug;

  RelatedCategoryDetail({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory RelatedCategoryDetail.fromJson(Map<String, dynamic> json) {
    return RelatedCategoryDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}

enum BusinessType {
  appointmentOnly,  // Only non-class categories
  classOnly,        // Only class categories
  both              // Both class and non-class categories
}
