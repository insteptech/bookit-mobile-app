import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/features/main/offerings/controllers/offerings_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  String? selectedCategoryId;
  Map<String, dynamic>? selectedCategory;
  late OfferingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OfferingsController();
    _fetchCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  Future<void> _fetchCategories() async {
    await _controller.fetchBusinessCategories();
  }

  void _onCategorySelected(Map<String, dynamic> category) {
    setState(() {
      selectedCategoryId = category['id'];
      selectedCategory = category;
    });
  }

  void _onNext() {
    if (selectedCategory != null) {
      context.push(
        '/add_service_categories?categoryId=${selectedCategory!['id']}&categoryName=${selectedCategory!['name']}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header with consistent styling
              Padding(
                padding: const EdgeInsets.fromLTRB(34, 70, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 32),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      "Choose service type",
                      style: AppTypography.headingLg,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Content
              Expanded(
                child: Consumer<OfferingsController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${controller.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchCategories,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final categories = controller.getAllRelatedCategories();

                    if (categories.isEmpty) {
                      return const Center(
                        child: Text('No categories available'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategoryId == category['id'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RadioButton(
                            heading: category['name'],
                            description: category['description'],
                            rememberMe: isSelected,
                            onChanged: (_) => _onCategorySelected(category),
                            bgColor: theme.scaffoldBackgroundColor,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Next Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: PrimaryButton(
                  onPressed: selectedCategory != null ? _onNext : null,
                  isDisabled: selectedCategory == null,
                  text: "Next",
                  isHollow: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
