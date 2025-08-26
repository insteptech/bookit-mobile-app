import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/onboarding_api_service.dart';
import 'package:bookit_mobile_app/features/offerings/widgets/offerings_add_service_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SelectServicesScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;
  final bool isClass;
  
  const SelectServicesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.isClass = false,
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
        // If it's a class category, allow only one selection
        if (widget.isClass) {
          selectedIds.clear(); // Clear all existing selections
        }
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

    final businessId = await ActiveBusinessService().getActiveBusiness();
    print(businessId);

    setState(() {
      isButtonDisabled = true;
    });

    try {
      final categories = await futureCategories;
      final selected = categories.where((c) => selectedIds.contains(c.id));
      
      
      final List<Map<String, dynamic>> servicesPayload = selected
          .map(
            (e) => {
              "business_id": businessId,
              "category_id": e.id,
              "title": e.name,
              "description": e.description ?? "",
              "parent_id": e.parentId,
              "is_active": true,
              "category_level": e.level,
              "is_class": e.isClass,
              "category_level_0_id": widget.categoryId, // Level 0 category
              "category_level_1_id": e.level == 1 ? e.id : (e.parentId ?? ''), // Level 1 category
              "category_level_2_id": e.level == 2 ? e.id : null, // Level 2 category (optional)
            },
          )
          .toList();
        if (mounted) {
          // Check if any of the selected services are classes
          final hasClassServices = servicesPayload.any((service) => service['is_class'] == true);
          
          if (hasClassServices) {
            // If there are class services, navigate to the new class and schedule screen
            // For now, we'll take the first class service as the primary one
            final classService = servicesPayload.firstWhere((service) => service['is_class'] == true);
            
            context.push('/add_edit_class_and_schedule', extra: {
              'serviceData': classService,
              'isEditing': false,
            });
          } else {
            // For regular services, use the existing flow
            context.push('/add_offering_service_details', extra: {
              'services': servicesPayload,
              'categoryName': widget.categoryName,
            });
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
          return OfferingsAddServiceScaffold(
            title: widget.isClass ? widget.categoryName : '${widget.categoryName} service',
            subtitle: widget.isClass ? 'Select category of your new class' : 'Select category of your new service',
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return OfferingsAddServiceScaffold(
            title: widget.isClass ? widget.categoryName : '${widget.categoryName} service',
            subtitle: widget.isClass ? 'Select category of your new class' : 'Select category of your new service',
            body: Center(
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
          );
        }

        final categories = snapshot.data!;
        final level1 = categories.where(
          (e) => e.level == 1 && e.parentId == widget.categoryId,
        );

        return OfferingsAddServiceScaffold(
          title: widget.isClass ? widget.categoryName : '${widget.categoryName} service',
          subtitle: widget.isClass ? 'Select category of your new class' : 'Select category of your new service',
          body: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
          bottomButton: PrimaryButton(
            onPressed: selectedIds.isNotEmpty && !isButtonDisabled ? _onNext : null,
            isDisabled: selectedIds.isEmpty || isButtonDisabled,
            text: isButtonDisabled ? "Next" : "Next",
            isHollow: false,
          ),
        );
      },
    );
  }
}