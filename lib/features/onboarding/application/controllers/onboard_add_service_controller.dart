import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/features/onboarding/data/data.dart';
import 'package:bookit_mobile_app/features/onboarding/application/providers.dart';

class OnboardAddServiceController extends ChangeNotifier {
  final Ref ref;
  late final OnboardingRepository _repository;

  // State
  Set<String> _selectedIds = {};
  Set<String> _expandedIds = {};
  List<CategoryModel>? _categories;
  bool _isLoading = true;
  bool _isButtonDisabled = false;
  String _categoryId = '';
  String? _errorMessage;

  // Services
  final UserService _userService = UserService();

  OnboardAddServiceController(this.ref) {
    _repository = ref.read(onboardingRepositoryProvider);
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

      final categories = await _repository.getCategories();
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
    final List<CategoryModel> children =
        categories.where((e) => e.parentId == id).toList();

    final bool hasChildren = children.isNotEmpty;
    final bool isCurrentlySelected = _selectedIds.contains(id);

    if (hasChildren) {
      // Parent selection logic: toggle parent + manage first child
      final bool anyChildSelected =
          children.any((child) => _selectedIds.contains(child.id));

      if (isCurrentlySelected || anyChildSelected) {
        // Deselect parent and all children
        _selectedIds.remove(id);
        for (final child in children) {
          _selectedIds.remove(child.id);
        }
      } else {
        // Select parent and the first child automatically
        _selectedIds.add(id);
        _selectedIds.add(children.first.id);
      }
    } else {
      // Leaf selection toggles as usual
      if (isCurrentlySelected) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    }
    notifyListeners();
  }

  // Child selection toggle that keeps parent in sync
  void toggleChildSelection(String childId, List<CategoryModel> categories) {
    final CategoryModel child = categories.firstWhere(
      (c) => c.id == childId,
      orElse: () => CategoryModel(
        id: childId,
        parentId: null,
        slug: '',
        name: '',
        level: 0,
        isActive: true,
      ),
    );

    final String? parentId = child.parentId;

    if (_selectedIds.contains(childId)) {
      _selectedIds.remove(childId);
      // If no more children selected under this parent, unselect the parent
      if (parentId != null) {
        final siblings = categories.where((e) => e.parentId == parentId);
        final bool anySiblingSelected =
            siblings.any((s) => _selectedIds.contains(s.id));
        if (!anySiblingSelected) {
          _selectedIds.remove(parentId);
        }
      }
    } else {
      _selectedIds.add(childId);
      // Ensure parent appears selected when any child is selected
      if (parentId != null) {
        _selectedIds.add(parentId);
      }
    }
    notifyListeners();
  }

  // Visual state for parent tiles: selected if parent or any of its children are selected
  bool isParentVisuallySelected(String parentId, List<CategoryModel> categories) {
    if (_selectedIds.contains(parentId)) return true;
    final children = categories.where((e) => e.parentId == parentId);
    return children.any((c) => _selectedIds.contains(c.id));
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
      await _repository.createServices(services: servicesPayload);
      
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
