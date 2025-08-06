import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/onboarding_api_service.dart';

class OnboardAddServiceController extends ChangeNotifier {
  final Ref ref;

  // State
  Set<String> _selectedIds = {};
  Set<String> _expandedIds = {};
  List<CategoryModel>? _categories;
  bool _isLoading = true;
  bool _isButtonDisabled = false;
  String _categoryId = '';
  String? _errorMessage;

  // Services
  final OnboardingApiService _onboardingApiService = OnboardingApiService();
  final UserService _userService = UserService();

  OnboardAddServiceController(this.ref) {
    _initializeFromBusiness();
    _fetchCategories();
  }

  // Getters
  Set<String> get selectedIds => _selectedIds;
  Set<String> get expandedIds => _expandedIds;
  List<CategoryModel>? get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isButtonDisabled => _isButtonDisabled;
  String get categoryId => _categoryId;
  String? get errorMessage => _errorMessage;
  bool get isNextButtonDisabled => _selectedIds.isEmpty || _isButtonDisabled;

  void _initializeFromBusiness() {
    final business = ref.read(businessProvider);
    _categoryId = (business?.businessCategories.isNotEmpty == true
        ? business!.businessCategories.first.category.id
        : '');
  }

  Future<void> _fetchCategories() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final categories = await _onboardingApiService.getCategories();
      _categories = categories;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to load services";
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(String id, List<CategoryModel> categories) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
      final children = categories.where((e) => e.parentId == id);
      for (var child in children) {
        _selectedIds.remove(child.id);
      }
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void toggleExpansion(String id) {
    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }
    notifyListeners();
  }

  Future<void> handleNext(BuildContext context) async {
    final business = ref.read(businessProvider);
    if (business?.id == null || business!.id.isEmpty) {
      return;
    }

    final selected = _categories?.where((c) => _selectedIds.contains(c.id));
    if (selected == null || selected.isEmpty) {
      return;
    }

    final List<Map<String, dynamic>> servicesPayload = selected
        .map((e) => {
              "business_id": business.id,
              "category_id": e.id,
              "title": e.name,
              "description": e.description ?? "",
              "is_active": true,
            })
        .toList();

    _isButtonDisabled = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _onboardingApiService.createServices(services: servicesPayload);
      
      final businessDetails = await _userService.fetchBusinessDetails(
        businessId: business.id,
      );
      
      ref.read(businessProvider.notifier).state = businessDetails;

      if (context.mounted) {
        context.push("/services_details");
      }
    } catch (e) {
      _errorMessage = "Failed to create services";
      // Error is logged in the original code, keeping same behavior
      print(e);
    } finally {
      _isButtonDisabled = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Provider for the add service controller
final onboardAddServiceControllerProvider = ChangeNotifierProvider.autoDispose<OnboardAddServiceController>(
  (ref) => OnboardAddServiceController(ref),
);
