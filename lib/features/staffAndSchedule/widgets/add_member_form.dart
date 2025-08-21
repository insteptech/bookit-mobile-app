import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/providers/business_categories_provider.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/models/staff_profile_request_model.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/shared/components/atoms/delete_action.dart';

import 'profile_photo_picker.dart';
import 'gender_selector.dart';

class AddMemberForm extends StatefulWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onDelete;
  final bool? isClass;
  final Function(StaffProfile)? onDataChanged;

  const AddMemberForm({
    super.key,
    this.onAdd,
    this.onDelete,
    this.onDataChanged,
    this.isClass,
  });

  @override
  State<AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _profilePickerKey = GlobalKey<ProfilePhotoPickerState>();
  final _genderSelectorKey = GlobalKey<GenderSelectorState>();

  Set<String> selectedCategoryIds = {};
  final BusinessCategoriesProvider _categoriesProvider = BusinessCategoriesProvider.instance;

  // Location selector variables (integrated)
  List<Map<String, String>> locations = [];
  Set<String> selectedLocationIds = {};

  bool get isFormValid {
    final gender = _genderSelectorKey.currentState?.selectedGenderValue ?? '';

    return _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        gender.trim().isNotEmpty;
  }



  @override
  void initState() {
    super.initState();
    _setupSelectedCategories();
    _nameController.addListener(_onDataChanged);
    _emailController.addListener(_onDataChanged);
    _phoneController.addListener(_onDataChanged);
  }

  void _setupSelectedCategories() {
    // Auto-select categories based on isClass parameter
    if (widget.isClass != null) {
      final targetCategories = _categoriesProvider.getCategoriesByType(isClass: widget.isClass!);
      selectedCategoryIds.addAll(targetCategories.map((cat) => cat['id'].toString()));
    }
  }

  void _onDataChanged() {
    if (widget.onDataChanged != null) {
      final profileImage = _profilePickerKey.currentState?.selectedImage;
      final gender = _genderSelectorKey.currentState?.selectedGenderValue ?? '';

      // Ensure categories are auto-selected based on isClass
      _updateSelectedCategories();

      widget.onDataChanged!(
        StaffProfile(
          userId: '',
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          gender: gender,
          categoryIds: selectedCategoryIds.toList(),
          profileImage: profileImage,
        ),
      );
    }
  }

  void _updateSelectedCategories() {
    // Always ensure the correct categories are selected based on isClass
    if (widget.isClass != null) {
      selectedCategoryIds.clear();
      final targetCategories = _categoriesProvider.getCategoriesByType(isClass: widget.isClass!);
      selectedCategoryIds.addAll(targetCategories.map((cat) => cat['id'].toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Staff member information", style: AppTypography.headingSm),
            if (widget.onDelete != null)
              DeleteAction(
                onConfirm: widget.onDelete!,
              ),
          ],
        ),
        const SizedBox(height: 16),

        /// Profile Photo
        ProfilePhotoPicker(
          key: _profilePickerKey,
          onImageChanged: _onDataChanged,
        ),
        const SizedBox(height: 16),

        /// Name
        Text("Full name", style: AppTypography.bodyMedium),
        const SizedBox(height: 8),
        InputField(hintText: "Full name", controller: _nameController),

        const SizedBox(height: 16),

        /// Email
        Text("Email", style: AppTypography.bodyMedium),
        const SizedBox(height: 8),
        InputField(hintText: "email@yourbusiness.com", controller: _emailController),

        const SizedBox(height: 16),

        /// Phone
        Text("Mobile phone", style: AppTypography.bodyMedium),
        const SizedBox(height: 8),
        InputField(hintText: "Mobile phone", controller: _phoneController),

        const SizedBox(height: 16),

        /// Gender
        GenderSelector(
          key: _genderSelectorKey,
          onSelectionChanged: _onDataChanged,
        ),

        const SizedBox(height: 16),

        /// Categories Display
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category", style: AppTypography.headingSm),
            const SizedBox(height: 8),
            _buildCategoryDisplay(),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryDisplay() {
    if (widget.isClass == null) {
      return Text("No category specified", style: AppTypography.bodyMedium);
    }

    final targetCategories = _categoriesProvider.getCategoriesByType(isClass: widget.isClass!);
    
    if (targetCategories.isEmpty) {
      return Text(
        widget.isClass! ? "No class categories available" : "No service categories available",
        style: AppTypography.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: targetCategories.map((category) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            "• ${category['id']}",
            style: AppTypography.bodyMedium,
          ),
        ),
      ).toList(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}