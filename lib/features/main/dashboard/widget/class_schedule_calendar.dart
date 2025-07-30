import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClassScheduleCalendar extends StatefulWidget {
  final bool? showCalendarHeader;
  final bool? showOnlyTodaysClasses;
  const ClassScheduleCalendar({super.key, this.showCalendarHeader, this.showOnlyTodaysClasses});

  @override
  State<ClassScheduleCalendar> createState() => _ClassScheduleCalendarState();
}

class _ClassScheduleCalendarState extends State<ClassScheduleCalendar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            context.push("/add_staff?isClass=true");
          },
          child: Container(
            height: 88,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrayBoxColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Time and Duration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "7:30am",
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            AppColors
                                .secondaryFontColor, // Assuming you want the blue color
                      ),
                    ),
                    Text(
                      "60min",
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color:
                            AppColors
                                .secondaryFontColor, // Assuming you want the blue color
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24), // Increased spacing
                // Right column - Class details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Advanced Animal F...",
                        style: AppTypography.appBarHeading.copyWith(
                          color:
                              AppColors
                                  .secondaryFontColor, // Assuming you want the blue color
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Green room",
                        style: AppTypography.bodySmall.copyWith(
                          color:
                              AppColors
                                  .secondaryFontColor, // Assuming you want the blue color
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Aicha Niazy",
                        style: AppTypography.bodySmall.copyWith(
                          color:
                              Colors.grey, 
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
