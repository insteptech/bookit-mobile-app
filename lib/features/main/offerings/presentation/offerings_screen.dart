import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
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

class _OfferingsScreenState extends State<OfferingsScreen> with SingleTickerProviderStateMixin {
  late OfferingsController _controller;
  Map<String, dynamic>? _offeringsData;
  bool _isLoadingOfferings = false;
  final Set<String> _expandedCategories = {};
  
  // Tab and scroll controller for category navigation
  TabController? _tabController;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};
  List<String> _rootCategoryNames = [];

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
    super.dispose();
  }

  Future<void> _fetchOfferings() async {
    setState(() {
      _isLoadingOfferings = true;
    });
    
    try {
      final data = await APIRepository.getBusinessOfferings();
      setState(() {
        _offeringsData = data;
        _isLoadingOfferings = false;
      });
    } catch (e) {
      // TODO: Handle error properly (e.g., show error message to user)
      setState(() {
        _isLoadingOfferings = false;
      });
    }
  }

  Widget _buildOfferingsContent() {
    if (_isLoadingOfferings) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_offeringsData == null || _offeringsData!['data'] == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No offerings available'),
        ),
      );
    }

    final data = _offeringsData!['data'];
    final offerings = data['offerings'] as List<dynamic>? ?? [];

    if (offerings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No offerings found'),
        ),
      );
    }

    // Group offerings by their root parent category (level 0)
    final Map<String, List<Map<String, dynamic>>> groupedOfferings = {};
    
    for (final offering in offerings) {
      final category = offering['category'];
      final rootParent = category?['root_parent'];
      
      // Use root_parent if available, otherwise find level 0 parent or use current category
      String rootParentId;
      String rootParentName;
      
      if (rootParent != null) {
        rootParentId = rootParent['id'] ?? 'other';
        rootParentName = rootParent['name'] ?? 'Other';
      } else if (category?['level'] == 0) {
        // Current category is level 0
        rootParentId = category['id'] ?? 'other';
        rootParentName = category['name'] ?? 'Other';
      } else {
        // Find level 0 parent by traversing up the parent chain
        var currentCategory = category;
        while (currentCategory != null && currentCategory['level'] != 0) {
          currentCategory = currentCategory['parent'];
        }
        if (currentCategory != null) {
          rootParentId = currentCategory['id'] ?? 'other';
          rootParentName = currentCategory['name'] ?? 'Other';
        } else {
          rootParentId = 'other';
          rootParentName = 'Other';
        }
      }
      
      final rootKey = '$rootParentId|$rootParentName';
      
      if (!groupedOfferings.containsKey(rootKey)) {
        groupedOfferings[rootKey] = [];
      }
      groupedOfferings[rootKey]!.add(offering);
    }

    // Update root category names and initialize tab controller
    _rootCategoryNames = groupedOfferings.keys.map((key) => key.split('|')[1]).toList();
    
    // Initialize tab controller if not already done or if categories changed
    if (_tabController == null || _tabController!.length != _rootCategoryNames.length) {
      _tabController?.dispose();
      _tabController = TabController(length: _rootCategoryNames.length, vsync: this);
    }

    // Create global keys for each category section
    _categoryKeys.clear();
    for (final key in groupedOfferings.keys) {
      _categoryKeys[key] = GlobalKey();
    }

    return Column(
      children: [
        // Tab bar for category navigation - only show when there are multiple root categories
        if (_rootCategoryNames.length > 1) ...[
  Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide.none, // Remove any bottom border
      ),
    ),
    child: TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: Theme.of(context).primaryColor,
      labelColor: Theme.of(context).primaryColor,
      // unselectedLabelColor: Colors.grey[600],
      indicatorWeight: 2,
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: const EdgeInsets.fromLTRB(0, 0, 32, 0),
      dividerColor: Colors.transparent, 
      overlayColor: WidgetStateProperty.all(Colors.transparent), 
      splashFactory: NoSplash.splashFactory,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      onTap: (index) {
        _scrollToCategoryAtIndex(index, groupedOfferings);
      },
      tabs: _rootCategoryNames.map((name) => Tab(text: name)).toList(),
    ),
  ),
  const SizedBox(height: 24),
],
        // Category sections
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: groupedOfferings.entries.map<Widget>((entry) {
                final rootKey = entry.key;
                final rootParentName = rootKey.split('|')[1];
                final rootParentId = rootKey.split('|')[0];
                final offeringsInCategory = entry.value;
                
                return Container(
                  key: _categoryKeys[rootKey],
                  child: _buildRootCategorySection(
                    rootParentId: rootParentId,
                    rootParentName: rootParentName,
                    offerings: offeringsInCategory,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _scrollToCategoryAtIndex(int index, Map<String, List<Map<String, dynamic>>> groupedOfferings) {
    final keys = groupedOfferings.keys.toList();
    if (index < keys.length) {
      final targetKey = keys[index];
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
    required List<Map<String, dynamic>> offerings,
  }) {
    // Check if any subcategories under this root category are expanded
    final anySubcategoryExpanded = offerings.any((offering) {
      final serviceDetails = offering['service_details'] as List<dynamic>? ?? [];
      return serviceDetails.isNotEmpty && _expandedCategories.contains(offering['id'] ?? '');
    });
    
    // Create a hierarchical structure to properly handle nesting
    final Map<String, Map<String, dynamic>> categoryHierarchy = {};
    
    // First, organize all categories in the hierarchy
    for (final offering in offerings) {
      final category = offering['category'];
      final categoryId = category?['id'] ?? 'unknown';
      final categoryName = category?['name'] ?? 'Unknown';
      final categoryLevel = category?['level'] ?? 0;
      final parentCategory = category?['parent'];
      
      final categoryKey = '$categoryId|$categoryName|$categoryLevel';
      
      if (!categoryHierarchy.containsKey(categoryKey)) {
        categoryHierarchy[categoryKey] = {
          'id': categoryId,
          'name': categoryName,
          'level': categoryLevel,
          'parent': parentCategory,
          'offerings': <Map<String, dynamic>>[],
          'children': <String>[],
        };
      }
      
      categoryHierarchy[categoryKey]!['offerings'].add(offering);
    }
    
    // Build parent-child relationships
    for (final entry in categoryHierarchy.entries) {
      final categoryData = entry.value;
      final parentCategory = categoryData['parent'];
      
      if (parentCategory != null) {
        final parentKey = '${parentCategory['id']}|${parentCategory['name']}|${parentCategory['level']}';
        if (categoryHierarchy.containsKey(parentKey)) {
          (categoryHierarchy[parentKey]!['children'] as List<String>).add(entry.key);
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
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (anySubcategoryExpanded) {
                    // Collapse all subcategories under this root category
                    for (final offering in offerings) {
                      _expandedCategories.remove(offering['id'] ?? '');
                    }
                  } else {
                    // Expand all subcategories under this root category that have services
                    for (final offering in offerings) {
                      final serviceDetails = offering['service_details'] as List<dynamic>? ?? [];
                      if (serviceDetails.isNotEmpty) {
                        _expandedCategories.add(offering['id'] ?? '');
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
        if (_rootCategoryNames.length > 1) ...[
          const SizedBox(height: 16),
          _buildAddServiceButton(rootParentId, rootParentName, offerings),
        ],
        
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _buildCategoryHierarchy(Map<String, Map<String, dynamic>> categoryHierarchy, int targetLevel, BuildContext context) {
    final List<Widget> widgets = [];
    
    // Find categories at the target level
    final categoriesAtLevel = categoryHierarchy.entries
        .where((entry) => entry.value['level'] == targetLevel)
        .toList();
    
    for (final entry in categoriesAtLevel) {
      final categoryData = entry.value;
      final categoryId = categoryData['id'] as String;
      final categoryName = categoryData['name'] as String;
      final categoryLevel = categoryData['level'] as int;
      final offerings = categoryData['offerings'] as List<Map<String, dynamic>>;
      final children = categoryData['children'] as List<String>;
      
      // Add the current category
      widgets.add(_buildCategoryItem(
        categoryId: categoryId,
        categoryName: categoryName,
        categoryLevel: categoryLevel,
        offerings: offerings,
        hasChildren: children.isNotEmpty,
        context: context, // Pass context for theme access
      ));
      
      // Add children recursively without indentation
      if (children.isNotEmpty) {
        final childHierarchy = Map<String, Map<String, dynamic>>.fromEntries(
          children.map((childKey) => MapEntry(childKey, categoryHierarchy[childKey]!))
        );
        
        final childWidgets = _buildCategoryHierarchy(childHierarchy, targetLevel + 1, context);
        widgets.addAll(childWidgets); // Add directly without padding
      }
    }
    
    return widgets;
  }

  Widget _buildCategoryItem({
    required String categoryId,
    required String categoryName,
    required int categoryLevel,
    required List<Map<String, dynamic>> offerings,
    required bool hasChildren,
    required BuildContext context,
  }) {
    // If this category has direct offerings (services), show them expandable
    final directOfferings = offerings.where((offering) {
      final offeringCategory = offering['category'];
      return offeringCategory?['id'] == categoryId;
    }).toList();
    
    if (directOfferings.isNotEmpty) {
      // This category has services - make it expandable
      return Column(
        children: directOfferings.map<Widget>((offering) => _buildOfferingItem(offering)).toList(),
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
                fontWeight: categoryLevel == 1 ? FontWeight.w600 : FontWeight.w500,
                // Make text blue only if it has children (multiple nestings)
                color: hasChildren ? AppColors.secondaryFontColor : Colors.black,
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

  Widget _buildAddServiceButton(String categoryId, String categoryName, List<Map<String, dynamic>> offerings) {
    // Determine if this category contains classes or services
    final bool isClass = offerings.isNotEmpty && offerings.first['is_class'] == true;
    final String buttonText = isClass ? "Add class" : "Add service";
    
    return Consumer<OfferingsController>(
      builder: (context, controller, child) {
        return PrimaryButton(
          onPressed: controller.isLoading ? null : () => _handleAddServiceForCategory(categoryId, categoryName, isClass),
          isDisabled: controller.isLoading,
          text: controller.isLoading ? "Loading..." : buttonText,
          isHollow: true,
        );
      },
    );
  }

  Future<void> _handleAddServiceForCategory(String categoryId, String categoryName, bool isClass) async {
    // Navigate directly to add service with the specific level 0 category and is_class parameter
    context.push(
      '/add_service_categories?categoryId=$categoryId&categoryName=$categoryName&isClass=$isClass',
    );
  }

  Widget _buildOfferingItem(Map<String, dynamic> offering) {
    final categoryName = offering['category']?['name'] ?? 'Unknown Category';
    final categoryLevel = offering['category']?['level'] ?? 0;
    final serviceDetails = offering['service_details'] as List<dynamic>? ?? [];
    final offeringId = offering['id'] ?? '';
    final isExpanded = _expandedCategories.contains(offeringId);
    final isClass = offering['is_class'] == true;

    // We need to determine if this category has children by checking the hierarchy
    // For now, we'll use a simpler approach: only make it blue if it's level 1 AND has no services
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
              isParentWithChildren ? categoryName.toString().toUpperCase() : categoryName,
              style: AppTypography.headingSm.copyWith(
                // Make parent categories blue only if they're level 1 AND have no services (indicating they have subcategories)
                color: isParentWithChildren ? AppColors.secondaryFontColor : Colors.black,
                fontWeight: isParentWithChildren ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            // Show icon for all categories except parent categories with children
            if (!isParentWithChildren)
              Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey[600],
              ),
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
                style: AppTypography.headingSm.copyWith(
                  // Keep default black color for categories with services
                  color: Colors.black,
                ),
              ),
              // Show expand/collapse icon for all categories with services
              Icon(
                isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          ...serviceDetails.map<Widget>((service) => _buildServiceCard(service, isClass, categoryName)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, bool isClass, String categoryName) {
    final serviceName = service['name'] ?? 'Unknown Service';
    final serviceDescription = service['description'] ?? '';
    final durations = service['durations'] as List<dynamic>? ?? [];

    // Create duration text
    String durationText = '';
    if (durations.isNotEmpty) {
      final durationMinutes = durations.map((d) => d['duration_minutes'] ?? 0).toList();
      durationMinutes.sort();
      if (durationMinutes.length == 1) {
        durationText = '${durationMinutes[0]} min';
      } else if (durationMinutes.length > 1) {
        durationText = durationMinutes.map((d) => '$d min').join(' | ');
      }
    }

    if (isClass) {
      // Class card design - with image placeholder and expandable content
     return Container(
  margin: const EdgeInsets.only(bottom: 8),
  child: Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage("https://dims.apnews.com/dims4/default/e40c94b/2147483647/strip/true/crop/7773x5182+0+0/resize/599x399!/quality/90/?url=https%3A%2F%2Fassets.apnews.com%2F16%2Fc9%2F0eecec78d44f016ffae1915e26c3%2F304c692a6f0b431aa8f954a4fdb5d7b5"), // or AssetImage
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
                        color: Colors.black87,
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
);
    } else {
      // Service card design - rounded border, simple layout
      return Container(
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
                          style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500)
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
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)
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
                    const SizedBox(height: 8),
                    Text(
                      durationText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
          ],
        ),
      );
    }
  }

  

  Future<void> _handleAddService() async {
    // Fetch business categories first
    await _controller.fetchBusinessCategories();
    
    if (!mounted) return;
    
    // Determine if category contains classes
    bool isClass = false;
    if (_offeringsData != null && _offeringsData!['data'] != null) {
      final offerings = _offeringsData!['data']['offerings'] as List<dynamic>? ?? [];
      if (offerings.isNotEmpty && offerings.first['is_class'] == true) {
        isClass = true;
      }
    }
    
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
              // Fixed header content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    Row(
                      children: [
                        Text("Offerings", style: AppTypography.headingLg),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 24),
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
              if (_rootCategoryNames.length == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
                  child: Consumer<OfferingsController>(
                    builder: (context, controller, child) {
                      // Determine button text based on offerings data
                      String buttonText = "Add service";
                      if (_offeringsData != null && _offeringsData!['data'] != null) {
                        final offerings = _offeringsData!['data']['offerings'] as List<dynamic>? ?? [];
                        if (offerings.isNotEmpty && offerings.first['is_class'] == true) {
                          buttonText = "Add class";
                        }
                      }
                      
                      return PrimaryButton(
                        onPressed: controller.isLoading ? null : _handleAddService,
                        isDisabled: controller.isLoading,
                        text: controller.isLoading ? "Loading..." : buttonText,
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
