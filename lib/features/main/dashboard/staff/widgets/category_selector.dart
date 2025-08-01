import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:dio/dio.dart';

// 4. Modified CategorySelector to expose selected data
class CategorySelector extends StatefulWidget {
  final VoidCallback? onSelectionChanged;
  final bool? isClass; // Made optional
  
  const CategorySelector({super.key, this.onSelectionChanged, this.isClass}); // isClass is now optional

  @override
  State<CategorySelector> createState() => CategorySelectorState();
}

class CategorySelectorState extends State<CategorySelector> {
  List<Map<String, dynamic>> categories = [];
  Set<String> selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final Response response = await APIRepository.getUserDataForStaffRegistration();
      final data = response.data;
      if (data['status'] == 200 && data['success'] == true) {
        final List<dynamic> categoryData = data['data']['categories'];
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
            (category) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  Checkbox(
                    value: selectedCategoryIds.contains(category['id']),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedCategoryIds.add(category['id']);
                        } else {
                          selectedCategoryIds.remove(category['id']);
                        }
                      });
                      widget.onSelectionChanged?.call();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category['name'] ?? '',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}