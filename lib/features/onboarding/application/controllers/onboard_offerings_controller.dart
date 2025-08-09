import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/features/onboarding/data/data.dart';
import 'package:bookit_mobile_app/features/onboarding/application/providers.dart';

class OnboardOfferingsController extends ChangeNotifier {
  final Ref ref;
  late final OnboardingRepository _repository;

  // State
  String? _selectedCategoryId;
  List<CategoryModel>? _categories;
  bool _isLoading = true;
  bool _isButtonDisabled = false;
  String? _errorMessage;

  // Services
  final UserService _userService = UserService();

  OnboardOfferingsController(this.ref) {
    _repository = ref.read(onboardingRepositoryProvider);
    _initializeFromBusiness();
    _fetchCategories();
  }

  // Getters
  String? get selectedCategoryId => _selectedCategoryId;
  List<CategoryModel>? get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isButtonDisabled => _isButtonDisabled;
  String? get errorMessage => _errorMessage;
  bool get isNextButtonDisabled => _selectedCategoryId == null || _isButtonDisabled;

  void _initializeFromBusiness() {
    final business = ref.read(businessProvider);
    if (business != null && business.businessCategories.isNotEmpty) {
      _selectedCategoryId = business.businessCategories.first.categoryId;
    }
  }

  Future<void> _fetchCategories() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final categories = await _repository.getCategories(categoryLevel: "0");
      
      // Sort categories in reverse alphabetical order
      categories.sort((a, b) => b.name.compareTo(a.name));
      
      _categories = categories;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to load categories";
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> handleNext(BuildContext context) async {
    final business = ref.read(businessProvider);
    final businessId = business?.id;

    if (businessId == null || _selectedCategoryId == null) {
      return;
    }

    final preSelectedCategoryPrimaryId = 
      (business!.businessCategories.isNotEmpty) 
        ? business.businessCategories[0].id 
        : null;

    _isButtonDisabled = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateCategory(
        id: preSelectedCategoryPrimaryId,
        businessId: businessId,
        categoryId: _selectedCategoryId!,
      );

      final updatedBusiness = await _userService.fetchBusinessDetails(
        businessId: businessId,
      );

      ref.read(businessProvider.notifier).state = updatedBusiness;

      if (context.mounted) {
        context.push("/add_services/?category_id=$_selectedCategoryId");
      }
    } catch (e) {
      _errorMessage = "Failed to update category";
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslationsDelegate.of(context).text("failed_to_update_category")),
          ),
        );
      }
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
