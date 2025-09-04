import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/features/dashboard/models/business_category_model.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';

class BusinessCategoriesProvider extends ChangeNotifier {
  static BusinessCategoriesProvider? _instance;
  static BusinessCategoriesProvider get instance {
    _instance ??= BusinessCategoriesProvider._internal();
    return _instance!;
  }
  
  BusinessCategoriesProvider._internal();

  List<BusinessCategoryModel> _businessCategories = [];
  bool _isLoading = false;
  String? _error;

  List<BusinessCategoryModel> get businessCategories => _businessCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get categories formatted for UI (id, name, isClass)
  List<Map<String, dynamic>> get categoriesForUI {
    return _businessCategories.map((category) => {
      'id': category.category.id,
      'name': category.category.name,
      'isClass': category.category.isClass,
    }).toList();
  }

  /// Get only service categories (isClass = false)
  List<Map<String, dynamic>> get serviceCategories {
    return categoriesForUI.where((cat) => cat['isClass'] == false).toList();
  }

  /// Get only class categories (isClass = true)
  List<Map<String, dynamic>> get classCategories {
    return categoriesForUI.where((cat) => cat['isClass'] == true).toList();
  }

  /// Fetch business categories from API
  Future<void> fetchBusinessCategories() async {
    if (_isLoading) return; // Prevent multiple simultaneous requests

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await APIRepository.getBusinessLevel0Categories();
      
      // Parse the new response structure
      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> categoriesData = responseData['data']['level0_categories'] ?? [];
        
        // Convert the new format to the existing BusinessCategoryModel format
        _businessCategories = categoriesData.map((item) {
          // Create a compatible structure for BusinessCategoryModel
          final categoryData = {
            'id': item['id'],
            'category': {
              'id': item['id'],
              'name': item['name'],
              'is_class': item['is_class'],
              'related': [], // No related categories in the new format
            }
          };
          return BusinessCategoryModel.fromJson(categoryData);
        }).toList();
      } else {
        _businessCategories = [];
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get categories based on isClass filter
  List<Map<String, dynamic>> getCategoriesByType({required bool isClass}) {
    return categoriesForUI.where((cat) => cat['isClass'] == isClass).toList();
  }

  /// Check if categories are available
  bool get hasCategories => _businessCategories.isNotEmpty;

  /// Clear all data
  void clear() {
    _businessCategories = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}