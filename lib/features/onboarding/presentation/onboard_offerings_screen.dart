import 'dart:async';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/onboarding_api_service.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/features/onboarding/scaffolds/onboard_scaffold_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardOfferingsScreen extends ConsumerStatefulWidget {
  const OnboardOfferingsScreen({super.key});

  @override
  ConsumerState<OnboardOfferingsScreen> createState() =>
      _OnboardOfferingsScreenState();
}

class _OnboardOfferingsScreenState
    extends ConsumerState<OnboardOfferingsScreen> {
  String? selectedCategoryId;
  late Future<List<CategoryModel>> categoriesFuture;
  bool isButtonDisabled = false;

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
    print(categoriesFuture);
  }

  Future<void> _handleNext() async {
  final business = ref.read(businessProvider);
  final businessId = business?.id;

  if (businessId == null || selectedCategoryId == null) {
    return;
  }

  final preSelectedCategoryPrimaryId = 
    (business!.businessCategories.isNotEmpty) 
      ? business.businessCategories[0].id 
      : null;

  setState(() {
    isButtonDisabled = true;
  });

  try {
    await OnboardingApiService().updateCategory(
      id: preSelectedCategoryPrimaryId,
      businessId: businessId,
      categoryId: selectedCategoryId!,
    );

    final updatedBusiness = await UserService().fetchBusinessDetails(
      businessId: businessId,
    );

    ref.read(businessProvider.notifier).state = updatedBusiness;

    context.push("/add_services/?category_id=$selectedCategoryId");
  } catch (e) {
    // Handle error, e.g., show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppTranslationsDelegate.of(context).text("failed_to_update_category"))),
    );
  } finally {
    isButtonDisabled = false;
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<CategoryModel>>(
      future: categoriesFuture,
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return Center(child: Text(AppTranslationsDelegate.of(context).text("failed_to_load_categories")));
        }

        final categories = snapshot.data ?? [];

        return OnboardScaffoldLayout(
          heading: AppTranslationsDelegate.of(context).text("select_your_offerings"),
          subheading: AppTranslationsDelegate.of(context).text("select_offerings_description"),
          backButtonDisabled: false,
          body: Column(
  children: snapshot.connectionState == ConnectionState.waiting
      ? [Center(child: CircularProgressIndicator())]
      : (categories..sort((a, b) => b.name.compareTo(a.name))) // reverse alphabetical sort
          .map((category) {
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
          nextButtonText: AppTranslationsDelegate.of(context).text("next_add_services"),
          nextButtonDisabled: (selectedCategoryId == null) || isButtonDisabled,
          currentStep: 2,
        );
      },
    );
  }
}
