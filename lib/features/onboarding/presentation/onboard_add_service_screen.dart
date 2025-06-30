import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/core/services/onboarding_api_service.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboard_scaffold_layout.dart';
import 'package:go_router/go_router.dart';

class OnboardAddServiceScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  const OnboardAddServiceScreen({super.key, this.categoryId});

  @override
  ConsumerState<OnboardAddServiceScreen> createState() =>
      _OnboardAddServiceScreenState();
}

class _OnboardAddServiceScreenState
    extends ConsumerState<OnboardAddServiceScreen> {
  Set<String> selectedIds = {};
  Set<String> expandedIds = {};
  late Future<List<CategoryModel>> futureCategories;

  late String categoryId;

  @override
  void initState() {
    super.initState();

    final business = ref.read(businessProvider);

    categoryId =
        (business?.businessCategories.isNotEmpty == true
            ? business!.businessCategories.first.category.id
            : '');

    futureCategories = OnboardingApiService().getCategories();

    print("business details: $business");
    print("categoryId: $categoryId");
  }

  void toggleSelection(String id, List<CategoryModel> categories) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
        final children = categories.where((e) => e.parentId == id);
        for (var child in children) {
          selectedIds.remove(child.id);
        }
      } else {
        selectedIds.add(id);
      }
    });
  }

  void toggleExpansion(String id) {
    setState(() {
      if (expandedIds.contains(id)) {
        expandedIds.remove(id);
      } else {
        expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<CategoryModel>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Failed to load services")),
          );
        }

        final categories = snapshot.data!;
        final level1 = categories.where(
          (e) => e.level == 1 && e.parentId == categoryId,
        );

        return OnboardScaffoldLayout(
          heading: "Select your services",
          subheading: "Choose all services you offer under this category.",
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                level1.map((parent) {
                  final level2 = categories.where(
                    (e) => e.level == 2 && e.parentId == parent.id,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioButton(
                        heading: parent.name,
                        rememberMe: selectedIds.contains(parent.id),
                        onChanged: (_) {
                          toggleSelection(parent.id, categories);
                          toggleExpansion(parent.id);
                        },
                        bgColor: theme.scaffoldBackgroundColor,
                      ),
                      SizedBox(height: 8,),
                      if (expandedIds.contains(parent.id))
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            children:
                                level2
                                    .map(
                                      (child) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: RadioButton(
                                          heading: child.name,
                                          rememberMe: selectedIds.contains(
                                            child.id,
                                          ),
                                          onChanged:
                                              (_) => toggleSelection(
                                                child.id,
                                                categories,
                                              ),
                                          bgColor:
                                              theme.scaffoldBackgroundColor,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                    ],
                  );
                }).toList(),
          ),
          onNext: () async {
            final business = ref.read(businessProvider);
            if (business == null ||
                business.id == null ||
                business.id!.isEmpty) {
              print("Business data is missing");
              return;
            }
            final selected = categories.where(
              (c) => selectedIds.contains(c.id),
            );
            final List<Map<String, dynamic>> servicesPayload =
                selected
                    .map(
                      (e) => {
                        "business_id": business.id,
                        "category_id": e.id,
                        "title": e.name,
                        "description": e.description ?? "",
                        "is_active": true,
                      },
                    )
                    .toList();

            if (servicesPayload.isNotEmpty) {
              await OnboardingApiService().createServices(
                services: servicesPayload,
              );
              final businessDetails = await UserService().fetchBusinessDetails(
                businessId: business.id,
              );
              ref.read(businessProvider.notifier).state = businessDetails;
              context.go("/services_details");
            }
          },
          nextButtonText: "Next",
          nextButtonDisabled: selectedIds.isEmpty,
          currentStep: 3,
        );
      },
    );
  }
}
