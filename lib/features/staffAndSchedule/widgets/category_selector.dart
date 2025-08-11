import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/shared/components/molecules/checkbox_list_item.dart';
import 'package:dio/dio.dart';

class CategorySelector extends StatefulWidget {
  final VoidCallback? onSelectionChanged;
  final bool? isClass; 
  
  const CategorySelector({super.key, this.onSelectionChanged, this.isClass}); 

  @override
  State<CategorySelector> createState() => CategorySelectorState();
}

class CategorySelectorState extends State<CategorySelector> {
  List<Map<String, dynamic>> categories = [];
  Set<String> selectedCategoryIds = {};

  /// Public getter for selected category IDs
  Set<String> get selectedCategories => selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    fetchCategories();
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
        print('=== API Error: Failed to load categories - Status: ${data['status']}, Success: ${data['success']} ===');
      }
    } catch (e) {
      print('=== Error fetching categories: $e ===');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select their categories", style: AppTypography.headingSm),
        const SizedBox(height: 8),
        
        if (categories.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          ...categories.where((category) {
            // If isClass is null, show all categories
            // If isClass is not null, filter by matching isClass value
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
                widget.onSelectionChanged?.call();
              },
            ),
          ),
      ],
    );
  }
}