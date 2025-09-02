import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/menu/models/staff_category_model.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:bookit_mobile_app/features/menu/widgets/staff_category_section.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffMembersScreen extends StatefulWidget {
  const StaffMembersScreen({super.key});

  @override
  State<StaffMembersScreen> createState() => _StaffMembersScreenState();
}

class _StaffMembersScreenState extends State<StaffMembersScreen> {
  bool isLoading = true;
  StaffCategoryData? staffData;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _searchLayerLink = LayerLink();
  List<StaffCategory> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchStaffMembers();
    _searchController.addListener(_filterStaffMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchStaffMembers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await APIRepository.getAllStaffList();
      
      if (response.data != null && response.data['success'] == true) {
        final staffResponse = StaffCategoryResponse.fromJson(response.data);
        setState(() {
          staffData = staffResponse.data;
          filteredCategories = staffResponse.data.categories;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load staff members';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading staff members: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _filterStaffMembers() {
    if (staffData == null) return;

    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        filteredCategories = staffData!.categories;
      });
      return;
    }

    setState(() {
      filteredCategories = staffData!.categories
          .map((category) {
            final filteredStaff = category.staffMembers
                .where((staff) => staff.name.toLowerCase().contains(query))
                .toList();
            
            if (filteredStaff.isNotEmpty) {
              return StaffCategory(
                categoryName: category.categoryName,
                categoryId: category.categoryId,
                staffMembers: filteredStaff,
              );
            }
            return null;
          })
          .where((category) => category != null)
          .cast<StaffCategory>()
          .toList();
    });
  }

  void _onStaffMemberTap(StaffMember staffMember) {
    // Navigate to staff member details or schedule
    // context.push("/set_schedule", extra: {
    //   'staffId': staffMember.id,
    //   'staffName': staffMember.name,
    // });
    // context.push("/add_staff", extra: {
    //   'staffId': staffMember.id,
    //   'staffName': staffMember.name,
    // });
    context.push("/add_staff/?isClass=${staffMember.forClass}&staffId=${staffMember.id}&staffName=${Uri.encodeComponent(staffMember.name)}");

  }

  void _onCategoryTap(StaffCategory category) {
    // Navigate to category-specific staff view
    context.push("/staff_category", extra: {
      'categoryId': category.categoryId,
      'categoryName': category.categoryName,
      'staffMembers': category.staffMembers,
    });
  }

  Future<void> _handleAddMember() async {
    try {
      // Fetch business categories instead of using staff categories
      final response = await APIRepository.getBusinessLevel0Categories();
      
      if (!mounted) return;
      
      if (response.data != null && response.data['success'] == true) {
        final responseData = response.data;
        final categoriesData = responseData['data']['level0_categories'] as List<dynamic>;
        
        if (categoriesData.isEmpty) {
          // No categories available, show error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No categories available. Please add a category first.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        
        if (categoriesData.length == 1) {
          // Single category - navigate directly to add staff
          final category = categoriesData.first;
          final String categoryId = category['id'] as String;
          final bool isClass = category['is_class'] as bool;
          
          context.push(
            "/add_staff/?buttonMode=saveOnly&categoryId=$categoryId&isClass=$isClass"
          );
        } else {
          // Multiple categories - navigate to category selection screen
          context.push("/staff_category_selection");
        }
      } else {
        // Failed to fetch categories
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load categories. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Error fetching categories
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: AppTypography.headingSm,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchStaffMembers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (staffData == null || filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No staff members found',
              style: AppTypography.headingSm,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty 
                  ? 'Try adjusting your search'
                  : 'Add your first staff member to get started',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredCategories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return StaffCategorySection(
          category: category,
          onCategoryTap: () => _onCategoryTap(category),
          onStaffMemberTap: _onStaffMemberTap,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MenuScreenScaffold(
      title: "Staff members",
      showTitle: true,
      headerWidget: SearchableClientField(
        layerLink: _searchLayerLink,
        controller: _searchController,
        focusNode: _searchFocusNode,
        hintText: "Search here",
        showSearchIcon: true,
      ),
      placeHeaderWidgetAfterSubtitle: false,
      content: _buildContent(),
      buttonText: "Add member",
      onButtonPressed: _handleAddMember,
    );
  }
}