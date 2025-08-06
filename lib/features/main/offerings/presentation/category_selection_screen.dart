import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/features/main/offerings/controllers/offerings_controller.dart';
import 'package:bookit_mobile_app/features/main/offerings/widgets/offerings_add_service_scaffold.dart';
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
        '/add_service_categories?categoryId=${selectedCategory!['id']}&categoryName=${selectedCategory!['name']}&isClass=${selectedCategory!['is_class']}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _controller,
      child: OfferingsAddServiceScaffold(
        title: "Choose service type",
        body: Consumer<OfferingsController>(
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
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
        bottomButton: PrimaryButton(
          onPressed: selectedCategory != null ? _onNext : null,
          isDisabled: selectedCategory == null,
          text: "Next",
          isHollow: false,
        ),
      ),
    );
  }

}
