import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/menu/models/staff_category_model.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffCategorySelectionScreen extends StatefulWidget {
  const StaffCategorySelectionScreen({super.key});

  @override
  State<StaffCategorySelectionScreen> createState() => _StaffCategorySelectionScreenState();
}

class _StaffCategorySelectionScreenState extends State<StaffCategorySelectionScreen> {
  String? selectedCategoryId;
  StaffCategory? selectedCategory;
  bool isLoading = true;
  StaffCategoryData? staffData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStaffCategories();
  }

  Future<void> _fetchStaffCategories() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await APIRepository.getAllStaffList();
      
      if (response.data != null && response.data['success'] == true) {
        final staffResponse = StaffCategoryResponse.fromJson(response.data);
        setState(() {
          staffData = staffResponse.data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load staff categories';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading staff categories: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _onCategorySelected(StaffCategory category) {
    setState(() {
      selectedCategoryId = category.categoryId;
      selectedCategory = category;
    });
  }

  void _onAddMember() {
    if (selectedCategory != null) {
      final bool isClass = selectedCategory!.staffMembers.isNotEmpty 
          ? selectedCategory!.staffMembers.first.forClass 
          : false;
      
      context.push(
        '/add_staff/?buttonMode=saveOnly&categoryId=${selectedCategory!.categoryId}&isClass=$isClass',
      );
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: AppTypography.headingSm,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchStaffCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (staffData == null || staffData!.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: AppTypography.headingSm,
            ),
            const SizedBox(height: 8),
            Text(
              'Please add categories to continue',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Please choose category in which you want to add the staff member or coach',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: staffData!.categories.length,
            itemBuilder: (context, index) {
              final category = staffData!.categories[index];
              final isSelected = selectedCategoryId == category.categoryId;
              final bool isClass = category.staffMembers.isNotEmpty 
                  ? category.staffMembers.first.forClass 
                  : false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RadioButton(
                  heading: category.categoryName,
                  description: isClass ? 'For classes' : 'For services',
                  rememberMe: isSelected,
                  onChanged: (_) => _onCategorySelected(category),
                  bgColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MenuScreenScaffold(
      title: "Add staff member",
      showTitle: true,
      showBackButton: true,
      content: _buildContent(),
      buttonText: selectedCategory != null 
          ? (selectedCategory!.staffMembers.isNotEmpty && selectedCategory!.staffMembers.first.forClass 
              ? "Add coach" 
              : "Add member")
          : "Add member",
      onButtonPressed: selectedCategory != null ? _onAddMember : null,
      isButtonDisabled: selectedCategory == null,
    );
  }
}