import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/features/main/offerings/controllers/offerings_controller.dart';
import 'package:bookit_mobile_app/features/main/offerings/presentation/category_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class OfferingsScreen extends StatefulWidget {
  const OfferingsScreen({super.key});

  @override
  State<OfferingsScreen> createState() => _OfferingsScreenState();
}

class _OfferingsScreenState extends State<OfferingsScreen> {
  late OfferingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OfferingsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAddService() async {
    // Fetch business categories first
    await _controller.fetchBusinessCategories();
    
    if (!mounted) return;
    
    // Check if we should navigate directly or show category selection
    final directCategory = _controller.shouldNavigateDirectly();
    
    if (directCategory != null) {
      // Navigate directly to add service with the single category
      context.push(
        '/add_service?categoryId=${directCategory.id}&categoryName=${directCategory.name}',
      );
    } else {
      // Navigate to category selection screen with the controller
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: _controller,
            child: const CategorySelectionScreen(),
          ),
        ),
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 34,
                    vertical: 24,
                  ),
                  children: [
                    const SizedBox(height: 98),
                    const SizedBox(height: 16),
                    Text("Offerings", style: AppTypography.headingLg),
                    const SizedBox(height: 8),
                    const SizedBox(height: 48),
                   
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
                child: Consumer<OfferingsController>(
                  builder: (context, controller, child) {
                    return PrimaryButton(
                      onPressed: controller.isLoading ? null : _handleAddService,
                      isDisabled: controller.isLoading,
                      text: controller.isLoading ? "Loading..." : "Add service",
                      isHollow: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}