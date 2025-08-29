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
  Map<String, bool> categoryIsClassMap = {};

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

      final response = await APIRepository.getBusinessLevel0Categories();
      
      if (response.data != null && response.data['success'] == true) {
        // Convert the new API response to the existing StaffCategoryData format
        final responseData = response.data;
        final categoriesData = responseData['data']['level0_categories'] as List<dynamic>;
        
        // Create StaffCategory objects from level0_categories
        final categories = categoriesData.map((cat) {
          final categoryId = cat['id'] as String;
          final isClass = cat['is_class'] as bool;
          
          // Store the is_class information for later use
          categoryIsClassMap[categoryId] = isClass;
          
          return StaffCategory(
            categoryName: cat['name'],
            categoryId: categoryId,
            staffMembers: [], // Empty since this is just for category selection
          );
        }).toList();
        
        final staffCategoryData = StaffCategoryData(
          businessId: responseData['data']['business_id'],
          totalCategories: responseData['data']['total_level0_categories'],
          totalStaff: 0, // Not relevant for category selection
          categories: categories,
        );
        
        setState(() {
          staffData = staffCategoryData;
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
      final bool isClass = categoryIsClassMap[selectedCategory!.categoryId] ?? false;
      
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
        Expanded(
          child: ListView.builder(
            itemCount: staffData!.categories.length,
            itemBuilder: (context, index) {
              final category = staffData!.categories[index];
              final isSelected = selectedCategoryId == category.categoryId;
              final bool isClass = categoryIsClassMap[category.categoryId] ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RadioButton(
                  heading: category.categoryName,
                  description: isClass ? 'Add coach for ${category.categoryName}' : 'Add staff member for ${category.categoryName} service',
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
      subtitle: "Please choose category in which you want to add the staff member or coach",
      showTitle: true,
      showBackButton: true,
      content: _buildContent(),
      buttonText: selectedCategory != null 
          ? (categoryIsClassMap[selectedCategory!.categoryId] == true 
              ? "Add coach" 
              : "Add member")
          : "Add member",
      onButtonPressed: selectedCategory != null ? _onAddMember : null,
      isButtonDisabled: selectedCategory == null,
    );
  }
}