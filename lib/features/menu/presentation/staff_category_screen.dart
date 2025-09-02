import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/menu/models/staff_category_model.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/staff_member_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffCategoryScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final List<StaffMember> staffMembers;

  const StaffCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.staffMembers,
  });

  void _onStaffMemberTap(BuildContext context, StaffMember staffMember) {
    // Navigate to staff member details or schedule
    context.push("/add_staff", extra: {
      'staffId': staffMember.id,
      'staffName': staffMember.name,
      'edit': true
    });
  } 

  void _handleAddMember(BuildContext context) {
    final bool isClass = staffMembers.isNotEmpty 
        ? staffMembers.first.forClass 
        : false;
    
    context.push(
      "/add_staff/?buttonMode=saveOnly&categoryId=$categoryId&isClass=$isClass"
    );
  }

  Widget _buildContent(BuildContext context) {
    if (staffMembers.isEmpty) {
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
              'Add your first staff member to get started',
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
      itemCount: staffMembers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final staffMember = staffMembers[index];
        return StaffMemberRow(
          staffName: staffMember.name,
          staffId: staffMember.id,
          staffImageUrl: staffMember.profilePhotoUrl ?? '',
          onClick: () => _onStaffMemberTap(context, staffMember),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isClass = staffMembers.isNotEmpty 
        ? staffMembers.first.forClass 
        : false;
    
    return MenuScreenScaffold(
      title: categoryName,
      showTitle: true,
      showBackButton: true,
      content: _buildContent(context),
      buttonText: isClass ? "Add coach" : "Add member",
      onButtonPressed: () => _handleAddMember(context),
    );
  }
}