import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/features/offerings/controllers/offerings_controller.dart';
import 'package:bookit_mobile_app/features/offerings/presentation/category_selection_screen.dart';
import 'package:bookit_mobile_app/features/offerings/models/business_offerings_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class OfferingsScreen extends StatefulWidget {
  const OfferingsScreen({super.key});

  @override
  State<OfferingsScreen> createState() => _OfferingsScreenState();
}

class _OfferingsScreenState extends State<OfferingsScreen>
    with SingleTickerProviderStateMixin {
  late OfferingsController _controller;
  final Set<String> _expandedCategories = {};

  // Tab and scroll controller for category navigation
  TabController? _tabController;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};

  // Search bar UI state (visual only; no business logic wired)
  final LayerLink _searchFieldLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  void _initOrUpdateTabController(int length) {
    if (_tabController == null || _tabController!.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = OfferingsController();
    _fetchOfferings();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController?.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchOfferings() async {
    await _controller.fetchOfferings();
  }

  Widget _buildOfferingsContent() {
    return Consumer<OfferingsController>(
      builder: (context, controller, child) {
        if (controller.isLoadingOfferings) {
          return const Center(
            child: Padding(
              padding: AppConstants.fieldContentPadding,
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!controller.isOfferingsSuccess || !controller.hasOfferings) {
          return const Center(
            child: Padding(
              padding: AppConstants.fieldContentPadding,
              child: Text('No offerings available'),
            ),
          );
        }

        final groupedOfferings = controller.groupedOfferings;
        final rootCategoryNames = controller.rootCategoryNames;

        if (groupedOfferings.isEmpty) {
          return const Center(
            child: Padding(
              padding: AppConstants.fieldContentPadding,
              child: Text('No offerings found'),
            ),
          );
        }

        // Initialize tab controller if not already done or if categories changed
        if (_tabController == null ||
            _tabController!.length != rootCategoryNames.length) {
          _tabController?.dispose();
          _tabController = TabController(
            length: rootCategoryNames.length,
            vsync: this,
          );
        }

        // Create global keys for each category section
        _categoryKeys.clear();
        for (final group in groupedOfferings) {
          final rootKey = '${group.rootParentId}|${group.rootParentName}';
          _categoryKeys[rootKey] = GlobalKey();
        }

        return Column(
          children: [
            // Category sections
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children:
                      groupedOfferings.map<Widget>((group) {
                        final rootKey =
                            '${group.rootParentId}|${group.rootParentName}';

                        return Container(
                          key: _categoryKeys[rootKey],
                          child: _buildRootCategorySection(
                            rootParentId: group.rootParentId,
                            rootParentName: group.rootParentName,
                            offerings: group.offerings,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _scrollToCategoryAtIndex(
    int index,
    List<GroupedOfferings> groupedOfferings,
  ) {
    if (index < groupedOfferings.length) {
      final group = groupedOfferings[index];
      final targetKey = '${group.rootParentId}|${group.rootParentName}';
      final targetContext = _categoryKeys[targetKey]?.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Widget _buildRootCategorySection({
    required String rootParentId,
    required String rootParentName,
    required List<OfferingItem> offerings,
  }) {
    // Check if any subcategories under this root category are expanded
    final anySubcategoryExpanded = offerings.any((offering) {
      return offering.serviceDetails.isNotEmpty &&
          _expandedCategories.contains(offering.id);
    });

    // Create a hierarchical structure to properly handle nesting
    final Map<String, Map<String, dynamic>> categoryHierarchy = {};

    // First, organize all categories in the hierarchy
    for (final offering in offerings) {
      final category = offering.category;
      final categoryId = category.id;
      final categoryName = category.name;
      final categoryLevel = category.level;
      final parentCategory = category.parent;

      final categoryKey = '$categoryId|$categoryName|$categoryLevel';

      if (!categoryHierarchy.containsKey(categoryKey)) {
        categoryHierarchy[categoryKey] = {
          'id': categoryId,
          'name': categoryName,
          'level': categoryLevel,
          'parent': parentCategory,
          'offerings': <OfferingItem>[],
          'children': <String>[],
        };
      }

      (categoryHierarchy[categoryKey]!['offerings'] as List<OfferingItem>).add(
        offering,
      );
    }

    // Build parent-child relationships
    for (final entry in categoryHierarchy.entries) {
      final categoryData = entry.value;
      final parentCategory = categoryData['parent'] as CategoryDetails?;

      if (parentCategory != null) {
        final parentKey =
            '${parentCategory.id}|${parentCategory.name}|${parentCategory.level}';
        if (categoryHierarchy.containsKey(parentKey)) {
          (categoryHierarchy[parentKey]!['children'] as List<String>).add(
            entry.key,
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              rootParentName,
              style: AppTypography.headingMd.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (anySubcategoryExpanded) {
                    // Collapse all subcategories under this root category
                    for (final offering in offerings) {
                      _expandedCategories.remove(offering.id);
                    }
                  } else {
                    // Expand all subcategories under this root category that have services
                    for (final offering in offerings) {
                      if (offering.serviceDetails.isNotEmpty) {
                        _expandedCategories.add(offering.id);
                      }
                    }
                  }
                });
              },
              child: Text(
                anySubcategoryExpanded ? 'Collapse' : 'Expand',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Render hierarchical categories starting from level 1 (direct children of root)
        ..._buildCategoryHierarchy(categoryHierarchy, 1, context),

        // Add service button for each category when multiple level 0 categories exist
        Consumer<OfferingsController>(
          builder: (context, controller, child) {
            if (controller.rootCategoryNames.length > 1) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  _buildAddServiceButton(
                    rootParentId,
                    rootParentName,
                    offerings,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _buildCategoryHierarchy(
    Map<String, Map<String, dynamic>> categoryHierarchy,
    int targetLevel,
    BuildContext context,
  ) {
    final List<Widget> widgets = [];

    // Find categories at the target level
    final categoriesAtLevel =
        categoryHierarchy.entries
            .where((entry) => entry.value['level'] == targetLevel)
            .toList();

    for (final entry in categoriesAtLevel) {
      final categoryData = entry.value;
      final categoryId = categoryData['id'] as String;
      final categoryName = categoryData['name'] as String;
      final categoryLevel = categoryData['level'] as int;
      final offerings = categoryData['offerings'] as List<OfferingItem>;
      final children = categoryData['children'] as List<String>;

      // Add the current category
      widgets.add(
        _buildCategoryItem(
          categoryId: categoryId,
          categoryName: categoryName,
          categoryLevel: categoryLevel,
          offerings: offerings,
          hasChildren: children.isNotEmpty,
          context: context, // Pass context for theme access
        ),
      );

      // Add children recursively without indentation
      if (children.isNotEmpty) {
        final childHierarchy = Map<String, Map<String, dynamic>>.fromEntries(
          children.map(
            (childKey) => MapEntry(childKey, categoryHierarchy[childKey]!),
          ),
        );

        final childWidgets = _buildCategoryHierarchy(
          childHierarchy,
          targetLevel + 1,
          context,
        );
        widgets.addAll(childWidgets); // Add directly without padding
      }
    }

    return widgets;
  }

  Widget _buildCategoryItem({
    required String categoryId,
    required String categoryName,
    required int categoryLevel,
    required List<OfferingItem> offerings,
    required bool hasChildren,
    required BuildContext context,
  }) {
    // If this category has direct offerings (services), show them expandable
    final directOfferings =
        offerings.where((offering) {
          return offering.category.id == categoryId;
        }).toList();

    if (directOfferings.isNotEmpty) {
      // This category has services - make it expandable
      return Column(
        children:
            directOfferings
                .map<Widget>((offering) => _buildOfferingItem(offering))
                .toList(),
      );
    } else if (hasChildren) {
      // This is a parent category with only subcategories - show as header without arrow
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hasChildren ? categoryName : categoryName,
              style: AppTypography.headingSm.copyWith(
                fontWeight:
                    categoryLevel == 1 ? FontWeight.w600 : FontWeight.w500,
                // Make text secondary font color only if it has children (multiple nestings)
                color: Colors.black,
              ),
            ),
            // No arrow icon for parent categories with children
          ],
        ),
      );
    } else {
      // Empty category - don't show it
      return const SizedBox.shrink();
    }
  }

  Widget _buildAddServiceButton(
    String categoryId,
    String categoryName,
    List<OfferingItem> offerings,
  ) {
    // Determine if this category contains classes or services
    final bool isClass = offerings.isNotEmpty && offerings.first.isClass;
    final String buttonText = isClass ? "Add class" : "Add service";

    return Consumer<OfferingsController>(
      builder: (context, controller, child) {
        return PrimaryButton(
          onPressed:
              controller.isLoading
                  ? null
                  : () => _handleAddServiceForCategory(
                    categoryId,
                    categoryName,
                    isClass,
                  ),
          isDisabled: controller.isLoading,
          text: controller.isLoading ? "Loading..." : buttonText,
          isHollow: true,
        );
      },
    );
  }

  Future<void> _handleAddServiceForCategory(
    String categoryId,
    String categoryName,
    bool isClass,
  ) async {
    // Navigate directly to add service with the specific level 0 category and is_class parameter
    context.push(
      '/add_service_categories?categoryId=$categoryId&categoryName=$categoryName&isClass=$isClass',
    );
  }

  Widget _buildOfferingItem(OfferingItem offering) {
    final categoryName = offering.category.name;
    final categoryLevel = offering.category.level;
    final serviceDetails = offering.serviceDetails;
    final offeringId = offering.id;
    final isExpanded = _expandedCategories.contains(offeringId);
    final isClass = offering.isClass;

    // We need to determine if this category has children by checking the hierarchy
    // For now, we'll use a simpler approach: only make it secondary font color if it's level 1 AND has no services
    // (indicating it's a parent category that only exists to group subcategories)
    final isParentWithChildren = categoryLevel == 1 && serviceDetails.isEmpty;

    // If no service details, show just the category name (non-expandable)
    if (serviceDetails.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryName,
              style: AppTypography.headingSm.copyWith(
                color: Colors.black,
                fontWeight:
                    isParentWithChildren ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            // Show icon for all categories except parent categories with children
            if (!isParentWithChildren)
              Icon(Icons.keyboard_arrow_right, color: Color(0xFF202733)),
          ],
        ),
      );
    }

    // Always show the category name, but services are shown/hidden based on expansion
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCategories.remove(offeringId);
              } else {
                _expandedCategories.add(offeringId);
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: AppTypography.headingSm.copyWith(color: Colors.black),
              ),
              // Show expand/collapse icon for all categories with services
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                color: Color(0xFF202733),
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          ...serviceDetails.map<Widget>(
            (service) => _buildServiceCard(service, offering, isClass, categoryName),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildServiceCard(
    ServiceDetail service,
    OfferingItem offering,
    bool isClass,
    String categoryName,
  ) {
    final serviceName = service.name;
    final serviceDescription = service.description;
    final durations = service.durations;

    // Create duration text
    String durationText = '';
    if (durations.isNotEmpty) {
      final durationMinutes = durations.map((d) => d.durationMinutes).toList();
      durationMinutes.sort();
      if (durationMinutes.length == 1) {
        durationText = '${durationMinutes[0]} min';
      } else if (durationMinutes.length > 1) {
        durationText = durationMinutes.map((d) => '$d min').join(' | ');
      }
    }

    if (isClass) {
      // Class card design - with image placeholder and expandable content
      return GestureDetector(
        onTap: () {
          // Navigate to edit screen - use offering ID for classes, service detail ID for services
          if (isClass) {
            // For classes, use the root offering ID
            final classId = offering.id;
            final className = service.name;
            context.push(
              '/add_edit_class_and_schedule',
              extra: {
                'classId': classId, 
                'className': className, 
                'isEditing': true
              },
            );
          } else {
            // For services, use service detail ID (existing behavior)
            final serviceDetailId = service.id;
            context.push('/edit_offerings?serviceDetailId=$serviceDetailId');
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(0),
            color: Color(0xFFF8F9FA),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Image and headings
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service image
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://dims.apnews.com/dims4/default/e40c94b/2147483647/strip/true/crop/7773x5182+0+0/resize/599x399!/quality/90/?url=https%3A%2F%2Fassets.apnews.com%2F16%2Fc9%2F0eecec78d44f016ffae1915e26c3%2F304c692a6f0b431aa8f954a4fdb5d7b5",
                            ), // or AssetImage
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Headings column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category name (blue text)
                            Text(
                              categoryName,
                              style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Service name (bold black text)
                            Text(
                              serviceName,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF343A40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Bottom section: Description and duration
                  const SizedBox(height: 16),
                  // Service description
                  if (serviceDescription.isNotEmpty) ...[
                    Text(
                      serviceDescription,
                      style: AppTypography.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Duration
                  if (durationText.isNotEmpty)
                    Text(
                      durationText,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Service card design - rounded border, simple layout
      return GestureDetector(
        onTap: () {
          // Navigate to edit screen - use offering ID for classes, service detail ID for services
          if (isClass) {
            // For classes, use the root offering ID
            final classId = offering.id;
            final className = service.name;
            context.push(
              '/add_edit_class_and_schedule',
              extra: {
                'classId': classId, 
                'className': className, 
                'isEditing': true
              },
            );
          } else {
            // For services, use service detail ID (existing behavior)
            final serviceDetailId = service.id;
            context.push('/edit_offerings?serviceDetailId=$serviceDetailId');
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Service header
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            categoryName,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            serviceName,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (serviceDescription.isNotEmpty) ...[
                      Text(
                        serviceDescription,
                        style: AppTypography.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (durationText.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(durationText, style: AppTypography.bodyMedium),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _handleAddService() async {
    // Fetch business categories first
    await _controller.fetchBusinessCategories();

    if (!mounted) return;

    // Get the isClass flag from controller
    final bool isClass = _controller.getCategoryIsClass();

    // Check if we should navigate directly or show category selection
    final directCategory = _controller.shouldNavigateDirectly();

    if (directCategory != null) {
      // Navigate directly to add service with the single category and is_class parameter
      context.push(
        '/add_service_categories?categoryId=${directCategory.id}&categoryName=${directCategory.name}&isClass=$isClass',
      );
    } else {
      // Navigate to category selection screen with the controller
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChangeNotifierProvider.value(
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
              // Fixed header content
              Padding(
                padding: AppConstants.defaultScaffoldPadding,
                child: Column(
                  children: [
                    const SizedBox(height: AppConstants.scaffoldTopSpacing),
                    Row(
                      children: [
                        Text("Offerings", style: AppTypography.headingLg),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar (shared component styling)
                    SearchableClientField(
                      layerLink: _searchFieldLink,
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      hintText: 'Search here',
                    ),
                    // Design-specific spacing below search based on category count
                    Consumer<OfferingsController>(
                      builder: (context, controller, _) {
                        final rootCategoryNames = controller.rootCategoryNames;
                        if (rootCategoryNames.length > 1) {
                          _initOrUpdateTabController(rootCategoryNames.length);
                          return Column(
                            children: [
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide.none),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  isScrollable: true,
                                  tabAlignment: TabAlignment.start,
                                  // Figma: underline #790077 at 1.5px under selected tab
                                  indicatorColor: AppColors.primary,
                                  labelColor: AppColors.primary,
                                  unselectedLabelColor: Colors.black,
                                  indicatorWeight: 1.5,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  labelPadding: EdgeInsets.only(right: 32),
                                  dividerColor: Colors.transparent,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  unselectedLabelStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  onTap: (index) {
                                    _scrollToCategoryAtIndex(
                                      index,
                                      controller.groupedOfferings,
                                    );
                                  },
                                  tabs:
                                      rootCategoryNames
                                          .map((name) => Tab(text: name))
                                          .toList(),
                                ),
                              ),
                              // Add 24 inside header so with header bottom padding (24) total becomes 48
                              SizedBox(height: AppConstants.sectionSpacing),
                            ],
                          );
                        } else if (rootCategoryNames.length == 1) {
                          // Add 24 inside header so with header bottom padding (24) total becomes 48
                          return SizedBox(height: AppConstants.sectionSpacing);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              // Scrollable content with tabs and offerings
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: _buildOfferingsContent(),
                ),
              ),
              // Add Service Button - only show when single level 0 category
              Consumer<OfferingsController>(
                builder: (context, controller, child) {
                  if (controller.rootCategoryNames.length == 1) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 34,
                        vertical: 24,
                      ),
                      child: Consumer<OfferingsController>(
                        builder: (context, controller, child) {
                          // Get button text from controller
                          final buttonText =
                              controller.getAddServiceButtonText();

                          return PrimaryButton(
                            onPressed:
                                controller.isLoading ? null : _handleAddService,
                            isDisabled: controller.isLoading,
                            text:
                                controller.isLoading
                                    ? "Loading..."
                                    : buttonText,
                            // isHollow: true,
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
