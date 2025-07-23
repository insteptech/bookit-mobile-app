import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/onboarding_api_service.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectServicesScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;
  
  const SelectServicesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<SelectServicesScreen> createState() => _SelectServicesScreenState();
}

class _SelectServicesScreenState extends ConsumerState<SelectServicesScreen> {
  Set<String> selectedIds = {};
  Set<String> expandedIds = {};
  late Future<List<CategoryModel>> futureCategories;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    futureCategories = OnboardingApiService().getCategories();
  }

  void toggleSelection(String id, List<CategoryModel> categories) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
        // Remove children when parent is deselected
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

  Future<void> _onNext() async {
    if (selectedIds.isEmpty) return;

    final business = ref.read(businessProvider);
    if (business == null || business.id.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business not found. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      isButtonDisabled = true;
    });

    try {
      final categories = await futureCategories;
      final selected = categories.where((c) => selectedIds.contains(c.id));
      
      final List<Map<String, dynamic>> servicesPayload = selected
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
        
        // Fetch updated business details and update provider
        final businessDetails = await UserService()
            .fetchBusinessDetails(businessId: business.id);
        ref.read(businessProvider.notifier).state = businessDetails;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${selected.length} services created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating services: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<CategoryModel>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load services'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          futureCategories = OnboardingApiService().getCategories();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final categories = snapshot.data!;
        final level1 = categories.where(
          (e) => e.level == 1 && e.parentId == widget.categoryId,
        );

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Column(
                children: [
                  // Header with back button and title
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back, size: 32),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            '${widget.categoryName} service',
                            style: AppTypography.headingLg,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Select category of your new service',
                            style: AppTypography.bodyMedium,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Text(widget.categoryId)
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),                  // Services list
                  Expanded(
                    child: ListView.builder(
                      itemCount: level1.length,
                      itemBuilder: (context, index) {
                        final parent = level1.elementAt(index);
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
                                // Auto-expand when parent is selected and has children
                                if (level2.isNotEmpty) {
                                  toggleExpansion(parent.id);
                                }
                              },
                              bgColor: theme.scaffoldBackgroundColor,
                            ),
                            const SizedBox(height: 8),
                            if (expandedIds.contains(parent.id))
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  children: level2
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
                                            onChanged: (_) => toggleSelection(
                                              child.id,
                                              categories,
                                            ),
                                            bgColor: theme.scaffoldBackgroundColor,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Next Button
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                    child: PrimaryButton(
                      onPressed: selectedIds.isNotEmpty && !isButtonDisabled ? _onNext : null,
                      isDisabled: selectedIds.isEmpty || isButtonDisabled,
                      text: isButtonDisabled ? "Next" : "Next",
                      isHollow: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}