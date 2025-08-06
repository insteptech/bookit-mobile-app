import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/features/onboarding/application/onboard_offerings_controller.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/features/onboarding/scaffolds/onboard_scaffold_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardOfferingsScreen extends ConsumerStatefulWidget {
  const OnboardOfferingsScreen({super.key});

  @override
  ConsumerState<OnboardOfferingsScreen> createState() =>
      _OnboardOfferingsScreenState();
}

class _OnboardOfferingsScreenState
    extends ConsumerState<OnboardOfferingsScreen> {

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(onboardOfferingsControllerProvider);
    final theme = Theme.of(context);

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(AppTranslationsDelegate.of(context).text("failed_to_load_categories")),
        ),
      );
    }

    final categories = controller.categories ?? [];

    return OnboardScaffoldLayout(
      heading: AppTranslationsDelegate.of(context).text("select_your_offerings"),
      subheading: AppTranslationsDelegate.of(context).text("select_offerings_description"),
      backButtonDisabled: false,
      body: Column(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RadioButton(
              heading: category.name,
              description: category.description ?? "",
              rememberMe: controller.selectedCategoryId == category.id,
              onChanged: (value) {
                controller.selectCategory(category.id);
              },
              bgColor: theme.scaffoldBackgroundColor,
            ),
          );
        }).toList(),
      ),
      onNext: () => controller.handleNext(context),
      nextButtonText: AppTranslationsDelegate.of(context).text("next_add_services"),
      nextButtonDisabled: controller.isNextButtonDisabled,
      currentStep: 2,
    );
  }
}
