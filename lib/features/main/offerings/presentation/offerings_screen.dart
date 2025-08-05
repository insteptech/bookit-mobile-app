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

class _OfferingsScreenState extends State<OfferingsScreen> {
  late OfferingsController _controller;
  Map<String, dynamic>? _offeringsData;
  bool _isLoadingOfferings = false;
  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _controller = OfferingsController();
    _fetchOfferings();
  }

  @override
  void dispose() {
    _controller.dispose();
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

    return Column(
      children: groupedOfferings.entries.map<Widget>((entry) {
        final rootKey = entry.key;
        final rootParentName = rootKey.split('|')[1];
        final rootParentId = rootKey.split('|')[0];
        final offeringsInCategory = entry.value;
        
        return _buildRootCategorySection(
          rootParentId: rootParentId,
          rootParentName: rootParentName,
          offerings: offeringsInCategory,
        );
      }).toList(),
    );
  }

  Widget _buildRootCategorySection({
    required String rootParentId,
    required String rootParentName,
    required List<Map<String, dynamic>> offerings,
  }) {
    final isExpanded = _expandedCategories.contains(rootParentId);
    
    // Group offerings by their immediate category (level 1, 2, etc.)
    final Map<String, List<Map<String, dynamic>>> groupedByCategory = {};
    
    for (final offering in offerings) {
      final category = offering['category'];
      final categoryId = category?['id'] ?? 'unknown';
      final categoryName = category?['name'] ?? 'Unknown';
      final categoryLevel = category?['level'] ?? 0;
      
      final categoryKey = '$categoryId|$categoryName|$categoryLevel';
      
      if (!groupedByCategory.containsKey(categoryKey)) {
        groupedByCategory[categoryKey] = [];
      }
      groupedByCategory[categoryKey]!.add(offering);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              rootParentName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (isExpanded) {
                    _expandedCategories.remove(rootParentId);
                  } else {
                    _expandedCategories.add(rootParentId);
                  }
                });
              },
              child: Text(
                isExpanded ? 'Collapse' : 'Expand',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          ...groupedByCategory.entries.map<Widget>((entry) {
            final categoryInfo = entry.key.split('|');
            final categoryId = categoryInfo[0];
            final categoryName = categoryInfo[1];
            final categoryLevel = int.parse(categoryInfo[2]);
            final categoryOfferings = entry.value;
            
            return _buildCategoryGroup(
              categoryId: categoryId,
              categoryName: categoryName,
              categoryLevel: categoryLevel,
              offerings: categoryOfferings,
            );
          }),
          const SizedBox(height: 24),
        ] else
          const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryGroup({
    required String categoryId,
    required String categoryName,
    required int categoryLevel,
    required List<Map<String, dynamic>> offerings,
  }) {
    // Only show categories that have services
    final hasServices = offerings.any((offering) => 
      (offering['service_details'] as List<dynamic>? ?? []).isNotEmpty
    );
    
    if (hasServices) {
      // Show as expandable subcategories
      return Column(
        children: offerings.map<Widget>((offering) => _buildOfferingItem(offering)).toList(),
      );
    } else {
      // Don't show empty categories
      return const SizedBox.shrink();
    }
  }

  Widget _buildOfferingItem(Map<String, dynamic> offering) {
    final categoryName = offering['category']?['name'] ?? 'Unknown Category';
    final serviceDetails = offering['service_details'] as List<dynamic>? ?? [];
    final offeringId = offering['id'] ?? '';
    final isExpanded = _expandedCategories.contains(offeringId);
    final isClass = offering['is_class'] == true;

    // If no service details, don't show anything
    if (serviceDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isClass) {
      // For classes - show as expandable section with different styling
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
                  style: AppTypography.headingSm,
                ),
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
    } else {
      // For services - show as expandable section
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
                  style: AppTypography.headingSm
                ),
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
    
    // Check if we should navigate directly or show category selection
    final directCategory = _controller.shouldNavigateDirectly();
    
    if (directCategory != null) {
      // Navigate directly to add service with the single category
      context.push(
        '/add_service?categoryId=${directCategory.id}&categoryName=${directCategory.name}',
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
              Expanded(
                child: SingleChildScrollView(
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
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 24),
                      // Display the fetched offerings
                      _buildOfferingsContent(),
                    ],
                  ),
                ),
              ),
              // Add Service Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
                child: Consumer<OfferingsController>(
                  builder: (context, controller, child) {
                    return PrimaryButton(
                      onPressed: controller.isLoading ? null : _handleAddService,
                      isDisabled: controller.isLoading,
                      text: controller.isLoading ? "Loading..." : "Add service",
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
