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
  // Add initial values to preserve state
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialGender;
  final List<String>? initialCategoryIds;

  const AddMemberForm({
    super.key,
    this.onAdd,
    this.onDelete,
    this.onDataChanged,
    this.isClass,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.initialGender,
    this.initialCategoryIds,
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
    
    // Initialize controllers with preserved values
    _nameController.text = widget.initialName ?? '';
    _emailController.text = widget.initialEmail ?? '';
    _phoneController.text = widget.initialPhone ?? '';
    
    _nameController.addListener(_onDataChanged);
    _emailController.addListener(_onDataChanged);
    _phoneController.addListener(_onDataChanged);
  }

  void _setupSelectedCategories() {
    // Use initial category IDs if provided (for prefilled data)
    if (widget.initialCategoryIds != null && widget.initialCategoryIds!.isNotEmpty) {
      selectedCategoryIds.addAll(widget.initialCategoryIds!);
    } 
    // Otherwise, auto-select categories based on isClass parameter
    else if (widget.isClass != null) {
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
          id: '',
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
    // If we have initial category IDs (prefilled data), preserve them
    if (widget.initialCategoryIds != null && widget.initialCategoryIds!.isNotEmpty) {
      // Keep the prefilled categories, don't override them
      if (selectedCategoryIds.isEmpty) {
        selectedCategoryIds.addAll(widget.initialCategoryIds!);
      }
    }
    // Otherwise, ensure the correct categories are selected based on isClass
    else if (widget.isClass != null) {
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
          initialValue: widget.initialGender,
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