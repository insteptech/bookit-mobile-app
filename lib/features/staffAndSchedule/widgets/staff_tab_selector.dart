import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';

enum StaffTab { staffInfo, schedule }

class StaffTabSelector extends StatelessWidget {
  final StaffTab selectedTab;
  final Function(StaffTab) onTabChanged;

  const StaffTabSelector({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(StaffTab.staffInfo),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: selectedTab == StaffTab.staffInfo 
                    ? const Color(0xFFDBD4FF) 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20,
                      color: selectedTab == StaffTab.staffInfo 
                        ? Colors.black 
                        : const Color(0xFF202733),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Staff info',
                      style: selectedTab == StaffTab.staffInfo 
                        ? AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          )
                        : AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(StaffTab.schedule),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: selectedTab == StaffTab.schedule 
                    ? const Color(0xFFDBD4FF) 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: selectedTab == StaffTab.schedule 
                        ? Colors.black 
                        : const Color(0xFF202733),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Staff schedule',
                      style: selectedTab == StaffTab.schedule 
                        ? AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          )
                        : AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}