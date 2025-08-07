import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/models/staff_profile_request_model.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:flutter/material.dart';

import 'category_selector.dart';
import 'location_selector.dart';
import 'profile_photo_picker.dart';
import 'gender_selector.dart'; // <- Import the GenderSelector

class AddMemberForm extends StatefulWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onDelete;
  final bool? isClass; // Made optional
  final Function(StaffProfile)? onDataChanged;

  const AddMemberForm({
    super.key,
    this.onAdd,
    this.onDelete,
    this.onDataChanged,
    this.isClass, // Optional parameter
  });

  @override
  State<AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _categorySelectorKey = GlobalKey<CategorySelectorState>();
  final _locationSelectorKey = GlobalKey<LocationSelectorState>();
  final _profilePickerKey = GlobalKey<ProfilePhotoPickerState>();
  final _genderSelectorKey = GlobalKey<GenderSelectorState>();

  /// Checks if the current form has all required fields filled
  bool get isFormValid {
    final categoryIds = _categorySelectorKey.currentState?.selectedCategories ?? {};
    final locationIds = _locationSelectorKey.currentState?.selectedLocations ?? {};
    final gender = _genderSelectorKey.currentState?.selectedGenderValue ?? '';

    return _nameController.text.trim().isNotEmpty &&
           _emailController.text.trim().isNotEmpty &&
           _phoneController.text.trim().isNotEmpty &&
           gender.trim().isNotEmpty &&
           categoryIds.isNotEmpty &&
           locationIds.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onDataChanged);
    _emailController.addListener(_onDataChanged);
    _phoneController.addListener(_onDataChanged);
  }

  void _onDataChanged() async {
    if (widget.onDataChanged != null) {
      final categoryIds = _categorySelectorKey.currentState?.selectedCategories.toList() ?? [];
      final locationIds = _locationSelectorKey.currentState?.selectedLocations.toList() ?? [];
      final profileImage = _profilePickerKey.currentState?.selectedImage;
      final gender = _genderSelectorKey.currentState?.selectedGenderValue ?? '';

      // Always send profile data to controller for validation tracking
      widget.onDataChanged!(
        StaffProfile(
          userId: '',
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          gender: gender,
          categoryIds: categoryIds,
          locationIds: locationIds,
          profileImage: profileImage,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Staff member information", style: AppTypography.headingSm),
            if (widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: widget.onDelete,
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Profile Photo
        ProfilePhotoPicker(
          key: _profilePickerKey,
          onImageChanged: _onDataChanged,
        ),
        const SizedBox(height: 16),

        // Name field
        Text("Full name", style: AppTypography.bodyMedium),
        const SizedBox(height: 8),
        InputField(hintText: "Full name", controller: _nameController),

        const SizedBox(height: 16),
        Text("Email", style: AppTypography.bodyMedium),
        const SizedBox(height: 8),
        InputField(hintText: "email@yourbusiness.com", controller: _emailController),

        const SizedBox(height: 16),
        Text("Mobile phone", style: AppTypography.bodyMedium),
        const SizedBox(height: 8),
        InputField(hintText: "Mobile phone", controller: _phoneController),

        const SizedBox(height: 16),
        GenderSelector(
          key: _genderSelectorKey,
          onSelectionChanged: _onDataChanged,
        ),

        const SizedBox(height: 16),
        CategorySelector(
          key: _categorySelectorKey,
          onSelectionChanged: _onDataChanged,
          isClass: widget.isClass, // Pass the optional isClass directly
        ),
        const SizedBox(height: 16),

        LocationSelector(
          key: _locationSelectorKey,
          onSelectionChanged: _onDataChanged,
        ),
      ],
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
