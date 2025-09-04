import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/providers/business_categories_provider.dart';
import 'package:bookit_mobile_app/shared/components/organisms/sticky_header_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClassSelectionScreen extends StatefulWidget {
  final String? categoryId;
  
  const ClassSelectionScreen({
    super.key,
    this.categoryId,
  });

  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic> _apiResponse = {};
  final Set<String> _expandedCategories = {};
  String? _effectiveCategoryId;
  final BusinessCategoriesProvider _categoriesProvider = BusinessCategoriesProvider.instance;

  @override
  void initState() {
    super.initState();
    _initializeAndFetchClasses();
  }

  Future<void> _initializeAndFetchClasses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // If categoryId is provided, use it directly
      if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
        _effectiveCategoryId = widget.categoryId;
      } else {
        // Load business categories from cache or fetch fresh if empty
        if (!_categoriesProvider.hasCategories) {
          await _categoriesProvider.fetchBusinessCategories();
        }
        
        // Find the first category where is_class is true
        final classCategories = _categoriesProvider.classCategories;
        if (classCategories.isNotEmpty) {
          _effectiveCategoryId = classCategories.first['id'] as String;
        } else {
          setState(() {
            _error = 'No class categories available';
            _isLoading = false;
          });
          return;
        }
      }

      // Fetch classes for the determined category ID
      await _fetchClasses();
    } catch (e) {
      setState(() {
        _error = 'Error initializing: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _toggleAllCategories() {
    setState(() {
      final groupedCategories = _getGroupedCategories();
      final anyExpanded = groupedCategories.any((group) => _expandedCategories.contains(group['id']));
      
      if (anyExpanded) {
        // Collapse all categories
        for (var categoryGroup in groupedCategories) {
          _expandedCategories.remove(categoryGroup['id']);
        }
      } else {
        // Expand all categories
        for (var categoryGroup in groupedCategories) {
          _expandedCategories.add(categoryGroup['id']);
        }
      }
    });
  }

  Future<void> _fetchClasses() async {
    if (_effectiveCategoryId == null) {
      setState(() {
        _error = 'No category ID available';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await APIRepository.getServicesAndCategoriesOfBusiness(_effectiveCategoryId!);
      
      if (response.statusCode == 200 && response.data['status'] == true) {
        setState(() {
          _apiResponse = response.data;
          _isLoading = false;
          // Auto-expand all categories by default (as per Figma design)
          final groupedCategories = _getGroupedCategories();
          for (var categoryGroup in groupedCategories) {
            _expandedCategories.add(categoryGroup['id']);
          }
        });
      } else {
        setState(() {
          _error = 'Failed to load classes';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading classes: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getGroupedCategories() {
    if (_apiResponse['data'] == null || _apiResponse['data']['services'] == null) {
      return [];
    }

    final List<dynamic> services = _apiResponse['data']['services'];
    final Map<String, Map<String, dynamic>> categoryGroups = {};

    for (var service in services) {
      final businessService = service['businessService'];
      if (businessService == null || businessService['is_class'] != true) continue;

      final category = businessService['category'];
      if (category == null) continue;

      final categoryId = category['id'];
      final categoryName = category['name'];

      if (!categoryGroups.containsKey(categoryId)) {
        categoryGroups[categoryId] = {
          'id': categoryId,
          'name': categoryName,
          'classes': <Map<String, dynamic>>[],
        };
      }

      final serviceDetails = service['serviceDetails'] as List<dynamic>? ?? [];
      for (var detail in serviceDetails) {
        categoryGroups[categoryId]!['classes'].add({
          'id': detail['id'],
          'name': detail['name'],
          'description': detail['description'],
          'durations': detail['durations'],
          'categoryName': categoryName,
          'businessServiceId': businessService['id'],
        });
      }
    }

    return categoryGroups.values.where((group) => group['classes'].isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StickyHeaderScaffold(
      title: 'Pick a class to get started.',
      subtitle: "Wonderful! Next, you can input your class schedule. This is where you'll specify the times and days each class takes place. Remember, you can modify this information anytime in the 'Schedule' section.",
      backgroundColor: Colors.white,
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _initializeAndFetchClasses,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final groupedCategories = _getGroupedCategories();

    if (groupedCategories.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: Text(
            'No classes available',
            style: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: AppConstants.sectionSpacing),
        _buildFitnessClassesSection(groupedCategories),
      ],
    );
  }

  Widget _buildFitnessClassesSection(List<Map<String, dynamic>> groupedCategories) {
    if (groupedCategories.isEmpty) return const SizedBox.shrink();
    
    // Check if any categories are expanded
    final anyExpanded = groupedCategories.any((group) => _expandedCategories.contains(group['id']));
    
    return Column(
      children: [
        // Header row: "Fitness classes" with Collapse/Expand button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fitness classes',
              style: AppTypography.headingMd.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            TextButton(
              onPressed: _toggleAllCategories,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                anyExpanded ? 'Collapse' : 'Expand',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.contentSpacing),
        
        // All category sections
        ...groupedCategories.map((categoryGroup) => _buildCategorySection(categoryGroup)),
      ],
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> categoryGroup) {
    final categoryId = categoryGroup['id'];
    final categoryName = categoryGroup['name'];
    final classes = categoryGroup['classes'] as List<Map<String, dynamic>>;
    final isExpanded = _expandedCategories.contains(categoryId);

    return Column(
      children: [
        // Category dropdown header
        GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCategories.remove(categoryId);
              } else {
                _expandedCategories.add(categoryId);
              }
            });
          },
          child: SizedBox(
            width: double.infinity,
            height: 24,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: AppTypography.headingSm.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: AppConstants.contentSpacing),
          Column(
            children: classes.map((classData) => _buildClassCard(classData)).toList(),
          ),
        ],
        const SizedBox(height: AppConstants.contentSpacing),
      ],
    );
  }


  Widget _buildClassCard(Map<String, dynamic> classData) {
    final className = classData['name'] ?? '';
    final description = classData['description'] ?? '';
    final durations = classData['durations'] as List<dynamic>? ?? [];
    final categoryName = classData['categoryName'] ?? '';

    String durationText = '';
    if (durations.isNotEmpty) {
      final minutes = durations.first['duration_minutes'];
      durationText = '$minutes min';
    }

    return GestureDetector(
      onTap: () => _handleClassSelection(classData),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppConstants.smallContentSpacing),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://dims.apnews.com/dims4/default/e40c94b/2147483647/strip/true/crop/7773x5182+0+0/resize/599x399!/quality/90/?url=https%3A%2F%2Fassets.apnews.com%2F16%2Fc9%2F0eecec78d44f016ffae1915e26c3%2F304c692a6f0b431aa8f954a4fdb5d7b5',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        className,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF343A40),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 24),
            if (durationText.isNotEmpty)
              Text(
                durationText,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleClassSelection(Map<String, dynamic> classData) {
    // Navigate to add_edit_class_schedule_screen with the same parameters as offerings screen
    // Use service detail ID as classId (same as offerings screen uses service.id)
    context.push(
      '/add_edit_class_and_schedule',
      extra: {
        'classId': classData['id'],                 // Use service detail ID (same as offerings)
        'className': classData['name'],             // Use serviceDetail name (same as offerings)
        'isEditing': true
      },
    );
  }
}