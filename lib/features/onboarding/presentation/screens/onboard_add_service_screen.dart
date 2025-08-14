import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/scaffolds/onboard_scaffold_layout.dart';
import 'package:bookit_mobile_app/features/onboarding/application/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardAddServiceScreen extends ConsumerWidget {
  final String? categoryId;
  const OnboardAddServiceScreen({super.key, this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(onboardAddServiceControllerProvider);
    final theme = Theme.of(context);

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(AppTranslationsDelegate.of(context).text("failed_to_load_services")),
        ),
      );
    }

    final categories = controller.categories ?? [];
    final level1 = categories.where(
      (e) => e.level == 1 && e.parentId == controller.categoryId,
    );

    return OnboardScaffoldLayout(
      heading: "Select your services",
      subheading: "Choose all services you offer under this category.",
      backButtonDisabled: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: level1.map((parent) {
          // Previously computed to control expansion; no longer needed since UI has no drop icon

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level 1 parent category without drop icon; l2 auto-select logic handled in controller
              Row(
                children: [
                  Expanded(
                    child: RadioButton(
                      heading: parent.name,
                      description: parent.description ?? "",
                      rememberMe: controller.isParentVisuallySelected(parent.id, categories.toList()),
                      onChanged: (value) {
                        controller.toggleSelection(parent.id, categories);
                      },
                      bgColor: theme.scaffoldBackgroundColor,
                      // No expansion UX; tile tap mirrors checkbox selection
                      onTileTap: () => controller.toggleSelection(parent.id, categories),
                    ),
                  ),
                  // Drop icon removed per request when l2 is present
                ],
              ),
              const SizedBox(height: 8),
              // Show level 2 children as checklist when they exist; tapping a child selects it
              if(controller.selectedIds.contains(parent.id))...[
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  children: categories
                      .where((e) => e.level == 2 && e.parentId == parent.id)
                      .map(
                        (child) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: RadioButton(
                            heading: child.name,
                            description: child.description ?? "",
                            rememberMe: controller.selectedIds.contains(child.id),
                            onChanged: (value) {
                              controller.toggleChildSelection(child.id, categories);
                            },
                            bgColor: theme.scaffoldBackgroundColor,
                            onTileTap: () => controller.toggleChildSelection(child.id, categories),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              ],
            ],
          );
        }).toList(),
      ),
      onNext: () => controller.handleNext(context),
      nextButtonText: "Next",
      nextButtonDisabled: controller.selectedIds.isEmpty || controller.isButtonDisabled,
      currentStep: 3,
    );
  }
}
