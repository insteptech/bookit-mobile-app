import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/providers/business_categories_provider.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/presentation/class_selection_screen.dart';
import 'package:flutter/material.dart';

class NoClassesBox extends StatelessWidget {
  final String? message;
  const NoClassesBox({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 160,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: AppColors.lightGrayBoxColor, 
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "You dont have any classes scheduled for $message. Click below to add class schedule.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),

          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: (){
            // Get the first class category from the cached business categories
            final businessCategoriesProvider = BusinessCategoriesProvider.instance;
            final classCategories = businessCategoriesProvider.classCategories;
         
            // if (classCategories.isNotEmpty) {
              // Navigate to class selection screen with the first class category ID
              // final firstClassCategoryId = classCategories.first['id'] as String;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassSelectionScreen(),
                ),
              );
            // } else {
            //   // Show error message if no class categories are available
            //   if (context.mounted) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(
            //         content: Text('No class categories available. Please set up your business categories first.'),
            //         backgroundColor: Colors.orange,
            //       ),
            //     );
            //   }
            // }
          },
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Edit class schedule",
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        ),
        SizedBox(height: 10,)
      ],
    );
  }
}