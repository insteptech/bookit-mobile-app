import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/staff_member_row.dart';
import 'package:bookit_mobile_app/features/menu/models/staff_category_model.dart';
import 'package:flutter/material.dart';

class StaffCategorySection extends StatelessWidget {
  final StaffCategory category;
  final VoidCallback? onCategoryTap;
  final Function(StaffMember)? onStaffMemberTap;

  const StaffCategorySection({
    super.key,
    required this.category,
    this.onCategoryTap,
    this.onStaffMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header with arrow
        GestureDetector(
          onTap: onCategoryTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.categoryName,
                  style: AppTypography.headingSm,
                ),
                const Icon(
                  Icons.keyboard_arrow_right,
                  size: 24,
                  color: Color(0xFF202733),
                ),
              ],
            ),
          ),
        ),
        
        // Staff members list
        ...category.staffMembers.map(
          (staffMember) => StaffMemberRow(
            staffName: staffMember.name,
            staffId: staffMember.id,
            staffImageUrl: staffMember.profilePhotoUrl ?? '',
            onClick: () => onStaffMemberTap?.call(staffMember),
          ),
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }
}
