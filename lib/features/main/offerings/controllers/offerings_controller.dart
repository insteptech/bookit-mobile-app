import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';

/// Category model to represent the API response structure
class CategoryData {
  final String id;
  final String categoryId;
  final String businessId;
  final CategoryInfo category;

  CategoryData({
    required this.id,
    required this.categoryId,
    required this.businessId,
    required this.category,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'] ?? '',
      categoryId: json['category']['id'] ?? '',
      businessId: json['business_id'] ?? '',
      category: CategoryInfo.fromJson(json['category']),
    );
  }
}

class CategoryInfo {
  final String id;
  final bool? isClass;
  final String name;
  final String description;
  final List<RelatedCategory> related;

  CategoryInfo({
    required this.id,
    this.isClass,
    required this.name,
    required this.description,
    required this.related,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    // Generate fallback ID if not provided by API (backup for older API versions)
    String categoryId = json['id']?.toString() ?? '';
    if (categoryId.isEmpty && json['name'] != null) {
      categoryId = json['name'].toString().toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('&', 'and')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    }
    
    return CategoryInfo(
      id: categoryId,
      isClass: json['is_class'] ?? false,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      related: (json['related'] as List<dynamic>?)
              ?.map((e) => RelatedCategory.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RelatedCategory {
  final String id;
  final RelatedCategoryInfo relatedCategory;

  RelatedCategory({
    required this.id,
    required this.relatedCategory,
  });

  factory RelatedCategory.fromJson(Map<String, dynamic> json) {
    return RelatedCategory(
      id: json['id'] ?? '',
      relatedCategory: RelatedCategoryInfo.fromJson(json['related_category']),
    );
  }
}

class RelatedCategoryInfo {
  final String id;
  final String name;
  final String slug;
  final String description;
  final bool? isClass;

  RelatedCategoryInfo({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.isClass,
  });

  factory RelatedCategoryInfo.fromJson(Map<String, dynamic> json) {
    // Generate fallback ID if not provided by API (backup for older API versions)
    String categoryId = json['id']?.toString() ?? '';
    if (categoryId.isEmpty && json['name'] != null) {
      categoryId = json['name'].toString().toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('&', 'and')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    }
    
    return RelatedCategoryInfo(
      id: categoryId,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

/// Simplified category data for UI rendering
class UniqueCategory {
  final String id;
  final String name;
  final String description;
  final bool? isClass;

  UniqueCategory({
    required this.id,
    required this.name,
    required this.description,
    this.isClass,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UniqueCategory &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(id, name, description);

  @override
  String toString() => 'UniqueCategory(id: $id, name: $name)';
}

class OfferingsController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<CategoryData> _businessCategories = [];
  final Set<UniqueCategory> _uniqueCategories = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CategoryData> get businessCategories => _businessCategories;

  /// Fetch business categories from API
  Future<void> fetchBusinessCategories() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await APIRepository.getBusinessCategories();
      
      if (response['statusCode'] == 200 && response['status'] == true) {
        final List<dynamic> dataList = response['data'] ?? [];
        _businessCategories = dataList
            .map((item) => CategoryData.fromJson(item))
            .toList();
        
        _processUniqueCategories();
      } else {
        _error = response['message'] ?? 'Failed to fetch categories';
      }
    } catch (e) {
      _error = 'Error fetching business categories: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Process categories and related categories to create a unique set
  void _processUniqueCategories() {
    _uniqueCategories.clear();

    for (final categoryData in _businessCategories) {
      final category = categoryData.category;
      
      // Add the main category
      final mainCategory = UniqueCategory(
        id: category.id,
        name: category.name,
        description: category.description,
        isClass: category.isClass,
      );
      _uniqueCategories.add(mainCategory);

      // Add all related categories
      for (final related in category.related) {
        final relatedCategory = UniqueCategory(
          id: related.relatedCategory.id,
          name: related.relatedCategory.name,
          description: related.relatedCategory.description,
        );
        _uniqueCategories.add(relatedCategory);
      }
    }
  }

  /// Get all unique categories as a list for UI
  List<Map<String, dynamic>> getAllRelatedCategories() {
    return _uniqueCategories
        .map((category) => {
              'id': category.id,
              'name': category.name,
              'description': category.description,
              'is_class': category.isClass ?? false,
            })
        .toList();
  }

  /// Check if navigation should go directly to add service or show category selection
  /// Returns null if should show category selection, returns category data if should navigate directly
  UniqueCategory? shouldNavigateDirectly() {
    if (_uniqueCategories.length == 1) {
      return _uniqueCategories.first;
    }
    return null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}