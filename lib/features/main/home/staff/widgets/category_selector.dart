import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:dio/dio.dart';

// 4. Modified CategorySelector to expose selected data
class CategorySelector extends StatefulWidget {
  final VoidCallback? onSelectionChanged;
  
  const CategorySelector({super.key, this.onSelectionChanged});

  @override
  State<CategorySelector> createState() => CategorySelectorState();
}

class CategorySelectorState extends State<CategorySelector> {
  List<Map<String, String>> categories = [];
  String? selectedCategoryId;

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
                  })
              .toList();
        });
      } else {
        print('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
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
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  Checkbox(
                    value: selectedCategoryId == category['id'],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    onChanged: (checked) {
                      setState(() {
                        selectedCategoryId = checked == true ? category['id'] : null;
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