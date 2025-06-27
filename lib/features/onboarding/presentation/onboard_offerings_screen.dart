import 'dart:async';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/services/onboarding_api_service.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboard_scaffold_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardOfferingsScreen extends ConsumerStatefulWidget {
  const OnboardOfferingsScreen({super.key});

  @override
  ConsumerState<OnboardOfferingsScreen> createState() =>
      _OnboardOfferingsScreenState();
}

class _OnboardOfferingsScreenState extends ConsumerState<OnboardOfferingsScreen> {
  String? selectedCategoryId;
  late Future<List<CategoryModel>> categoriesFuture;

  @override
  void initState() { 
    super.initState();

    // Pre-select category if it exists in business data
    final business = ref.read(businessProvider);
    if (business != null && business.businessCategories.isNotEmpty) {
      selectedCategoryId = business.businessCategories.first.categoryId;
    }

    // Fetch categories
    categoriesFuture = OnboardingApiService().getCategories(categoryLevel: "0");
  }

  Future<void> _handleNext() async {
    final businessId = ref.read(businessProvider)?.id;

    if (businessId == null || selectedCategoryId == null) {
      print("Missing business ID or selected category");
      return;
    }

    try {
      await OnboardingApiService().updateCategory(
        businessId: businessId,
        categoryId: selectedCategoryId!,
      );

      final updatedBusiness = await UserService().fetchBusinessDetails(
        businessId: businessId,
      );

      ref.read(businessProvider.notifier).state = updatedBusiness;

      context.go("/add_services/?category_id=$selectedCategoryId");
    } catch (e) {
      print("Error during category update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<CategoryModel>>(
      future: categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Failed to load categories."));
        }

        final categories = snapshot.data ?? [];

        return OnboardScaffoldLayout(
          heading: "Select your offerings",
          subheading:
              "To begin, please select the main service you offer. Don't worry, you can add all other services under 'Service Types' after onboarding.",
          body: Column(
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RadioButton(
                  heading: category.name,
                  description: category.description ?? "",
                  rememberMe: selectedCategoryId == category.id,
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = category.id;
                    });
                  },
                  bgColor: theme.scaffoldBackgroundColor,
                ),
              );
            }).toList(),
          ),
          onNext: _handleNext,
          nextButtonText: "Next: add services",
          nextButtonDisabled: selectedCategoryId == null,
          currentStep: 2,
        );
      },
    );
  }
}
