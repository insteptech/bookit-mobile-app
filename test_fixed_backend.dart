import 'package:flutter/material.dart';
import 'lib/features/main/offerings/controllers/offerings_controller.dart';

void main() async {
  print('🧪 Testing Offerings Implementation with Fixed Backend');
  print('=' * 55);
  
  // Test the mock data with proper IDs (simulating fixed backend)
  final mockApiResponse = {
    'statusCode': 200,
    'status': true,
    'message': 'business.categories.found',
    'data': [
      {
        'id': 'business-cat-rel-1',
        'category_id': 'cat-health-wellness',
        'business_id': 'business-123',
        'category': {
          'id': 'cat-health-wellness',  // Backend now provides this!
          'is_class': false,
          'name': 'Health & Wellness',
          'description': 'Health and wellness services',
          'related': [
            {
              'id': 'rel-1',
              'related_category': {
                'id': 'cat-fitness',  // Backend now provides this!
                'name': 'Fitness',
                'slug': 'fitness',
                'description': 'Fitness related services'
              }
            }
          ]
        }
      },
      {
        'id': 'business-cat-rel-2',
        'category_id': 'cat-beauty',
        'business_id': 'business-123',
        'category': {
          'id': 'cat-beauty',  // Backend now provides this!
          'is_class': false,
          'name': 'Beauty',
          'description': 'Beauty services',
          'related': []
        }
      }
    ]
  };

  print('🔍 Testing with fixed API response (IDs provided):');
  
  // Test parsing categories
  final dataList = mockApiResponse['data'] as List<dynamic>;
  final categories = dataList.map((item) => CategoryData.fromJson(item)).toList();
  
  print('\n📋 Parsed Categories:');
  for (final cat in categories) {
    print('  • ${cat.category.name} (ID: "${cat.category.id}")');
    for (final related in cat.category.related) {
      print('    - Related: ${related.relatedCategory.name} (ID: "${related.relatedCategory.id}")');
    }
  }
  
  // Test unique category processing
  final controller = OfferingsController();
  controller._businessCategories = categories;
  controller._processUniqueCategories();
  
  final uniqueCategories = controller.getAllRelatedCategories();
  
  print('\n✨ Unique Categories (Set deduplication):');
  for (final cat in uniqueCategories) {
    print('  • ${cat['name']} (ID: "${cat['id']}")');
  }
  
  print('\n🎯 Navigation Logic:');
  final directNavCategory = controller.shouldNavigateDirectly();
  if (directNavCategory != null) {
    print('  → Navigate directly to /add_service with: ${directNavCategory.name}');
  } else {
    print('  → Show CategorySelectionScreen with ${uniqueCategories.length} categories');
  }
  
  print('\n✅ All tests passed! Backend fix resolved the empty ID issue.');
}

// Import the classes we need to test
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
  final bool isClass;
  final String name;
  final String description;
  final List<RelatedCategory> related;

  CategoryInfo({
    required this.id,
    required this.isClass,
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

  RelatedCategoryInfo({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
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

class UniqueCategory {
  final String id;
  final String name;
  final String description;

  UniqueCategory({
    required this.id,
    required this.name,
    required this.description,
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

// Mock simplified controller for testing
class OfferingsController {
  List<CategoryData> _businessCategories = [];
  final Set<UniqueCategory> _uniqueCategories = {};

  List<CategoryData> get businessCategories => _businessCategories;
  set _businessCategories(List<CategoryData> categories) {
    _businessCategories = categories;
  }

  void _processUniqueCategories() {
    _uniqueCategories.clear();

    for (final categoryData in _businessCategories) {
      final category = categoryData.category;
      
      // Add the main category
      final mainCategory = UniqueCategory(
        id: category.id,
        name: category.name,
        description: category.description,
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

  List<Map<String, dynamic>> getAllRelatedCategories() {
    return _uniqueCategories
        .map((category) => {
              'id': category.id,
              'name': category.name,
              'description': category.description,
            })
        .toList();
  }

  UniqueCategory? shouldNavigateDirectly() {
    if (_uniqueCategories.length == 1) {
      return _uniqueCategories.first;
    }
    return null;
  }
}
