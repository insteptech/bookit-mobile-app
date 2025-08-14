import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/models/staff_profile_request_model.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/molecules/checkbox_list_item.dart';
import 'package:dio/dio.dart';
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

  List<Map<String, dynamic>> categories = [];
  Set<String> selectedCategoryIds = {};

  // Location selector variables (integrated)
  List<Map<String, String>> locations = [];
  Set<String> selectedLocationIds = {};

  bool get isFormValid {
    final gender = _genderSelectorKey.currentState?.selectedGenderValue ?? '';

    return _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        gender.trim().isNotEmpty &&
        selectedCategoryIds.isNotEmpty &&
        selectedLocationIds.isNotEmpty;
  }

  Future<void> fetchCategories() async {
    try {
      final Response response = await APIRepository.getUserDataForStaffRegistration();
      final data = response.data;
      if (data['success'] == true) {
        final List<dynamic> categoryData = data['data']['level0_categories'];
        setState(() {
          categories = categoryData
              .map((cat) => {
                    'id': cat['id'].toString(),
                    'name': cat['name'].toString(),
                    'isClass': cat['is_class'] ?? false,
                  })
              .toList();
        });
      } else {
        print(
            '=== API Error: Failed to load categories - Status: ${data['status']}, Success: ${data['success']} ===');
      }
    } catch (e) {
      print('=== Error fetching categories: $e ===');
    }
  }

  Future<void> fetchLocations() async {
    try {
      final response = await APIRepository.getBusinessLocations();
      final data = response;
      final List<dynamic> locationData = data['rows'];
      setState(() {
        locations = locationData
            .map((loc) => {
                  'id': loc['id'].toString(),
                  'title': loc['title'].toString(),
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchLocations(); // Added location fetching
    _nameController.addListener(_onDataChanged);
    _emailController.addListener(_onDataChanged);
    _phoneController.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (widget.onDataChanged != null) {
      final profileImage = _profilePickerKey.currentState?.selectedImage;
      final gender = _genderSelectorKey.currentState?.selectedGenderValue ?? '';

      widget.onDataChanged!(
        StaffProfile(
          userId: '',
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          gender: gender,
          categoryIds: selectedCategoryIds.toList(),
          locationIds: selectedLocationIds.toList(), // Updated to use integrated locations
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

        /// Categories
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select their categories", style: AppTypography.headingSm),
            const SizedBox(height: 8),
            if (categories.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...categories.where((category) {
                return widget.isClass == null || category['isClass'] == widget.isClass;
              }).map(
                (category) => CheckboxListItem(
                  title: category['name'] ?? '',
                  isSelected: selectedCategoryIds.contains(category['id']),
                  onChanged: (checked) {
                    setState(() {
                      if (checked) {
                        selectedCategoryIds.add(category['id']);
                      } else {
                        selectedCategoryIds.remove(category['id']);
                      }
                    });
                    _onDataChanged();
                  },
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        /// Location Selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose location", style: AppTypography.headingSm),
            const SizedBox(height: 8),

            if (locations.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...locations.map(
                (location) => CheckboxListItem(
                  title: location['title'] ?? '',
                  isSelected: selectedLocationIds.contains(location['id']),
                  onChanged: (checked) {
                    setState(() {
                      if (checked) {
                        selectedLocationIds.add(location['id']!);
                      } else {
                        selectedLocationIds.remove(location['id']);
                      }
                    });
                    _onDataChanged();
                  },
                ),
              ),
          ],
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