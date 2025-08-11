import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/dashboard/models/business_category_model.dart';

class DashboardController extends ChangeNotifier {
  List<BusinessCategoryModel> _businessCategories = [];
  BusinessType _businessType = BusinessType.both;
  bool _isLoadingCategories = false;
  String? _error;

  List<BusinessCategoryModel> get businessCategories => _businessCategories;
  BusinessType get businessType => _businessType;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get error => _error;

  // Getters for UI conditional rendering
  bool get showAppointmentsOnly => _businessType == BusinessType.appointmentOnly;
  bool get showClassesOnly => _businessType == BusinessType.classOnly;
  bool get showBoth => _businessType == BusinessType.both;

  /// Fetches business categories and determines the business type
  Future<void> fetchBusinessCategories() async {
    _isLoadingCategories = true;
    _error = null;
    notifyListeners();

    try {
      final data = await APIRepository.getBusinessCategories();
      
      // Parse the response
      final List<dynamic> categoriesData = data['data'] ?? [];
      _businessCategories = categoriesData
          .map((item) => BusinessCategoryModel.fromJson(item))
          .toList();

      // Determine business type based on categories
      _businessType = _determinateBusinessType(_businessCategories);
      
      _isLoadingCategories = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Determines the business type based on categories
  BusinessType _determinateBusinessType(List<BusinessCategoryModel> categories) {
    if (categories.isEmpty) {
      return BusinessType.both; // Default fallback
    }

    bool hasClassCategory = false;
    bool hasNonClassCategory = false;

    for (final category in categories) {
      if (category.category.isClass) {
        hasClassCategory = true;
      } else {
        hasNonClassCategory = true;
      }
    }

    if (hasClassCategory && hasNonClassCategory) {
      return BusinessType.both;
    } else if (hasClassCategory) {
      return BusinessType.classOnly;
    } else {
      return BusinessType.appointmentOnly;
    }
  }

  /// Reset controller state
  void reset() {
    _businessCategories = [];
    _businessType = BusinessType.both;
    _isLoadingCategories = false;
    _error = null;
    notifyListeners();
  }
}
