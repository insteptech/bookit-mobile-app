import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/shared/components/molecules/onboard_business_info_form.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/scaffolds/onboard_scaffold_layout.dart';
import 'package:bookit_mobile_app/features/onboarding/application/application.dart';

class OnboardAboutScreen extends ConsumerWidget {
  const OnboardAboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(onboardAboutControllerProvider);
    final theme = Theme.of(context);
    final localizations = AppTranslationsDelegate.of(context);


    return OnboardScaffoldLayout(
      heading: localizations.text("onboard_about_title"),
      subheading: localizations.text("onboard_about_description"),
      backButtonDisabled: false,
      body: Column(
        children: [
          RadioButton(
            heading: localizations.text("onboard_about_radio_new_title"),
            description: localizations.text(
              "onboard_about_radio_new_description",
            ),
            bgColor: theme.scaffoldBackgroundColor,
            rememberMe: controller.isFormOpen,
            onChanged: (value) {
              controller.updateFormOpen(value);
            },
            topRightLabel: "Coming soon",
          ),
          if (controller.isFormOpen)
            const SizedBox(height: 16),
          if (controller.isFormOpen)
            OnboardBusinessInfoForm(
              nameController: controller.nameController,
              emailController: controller.emailController,
              mobileController: controller.mobileController,
              websiteController: controller.websiteController,
            ),
          const SizedBox(height: 16),
          RadioButton(
            heading: localizations.text("onboard_about_radio_existing_title"),
            description: localizations.text(
              "onboard_about_radio_existing_description",
            ),
            bgColor: const Color(0xFF3A0039),
            rememberMe: false,
            onChanged: (value) {},
            topRightLabel: localizations.text(
              "onboard_about_radio_coming_soon_label",
            ),
            isDisabled: true,
          ),
        ],
      ),
      onNext: () {
        controller.handleBusinessInfoSubmission(context);
      },
      nextButtonText: localizations.text("onboard_next_button_address_details"),
      nextButtonDisabled: controller.isButtonDisabled || controller.isLoading,
      currentStep: 0,
    );
  }
}
