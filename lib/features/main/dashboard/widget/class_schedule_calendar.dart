import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClassScheduleCalendar extends StatefulWidget {
  final bool? showCalendarHeader;
  final bool? showOnlyTodaysClasses;
  final String locationId;
  final int? numberOfClasses;
  const ClassScheduleCalendar({super.key, this.showCalendarHeader, this.showOnlyTodaysClasses, required this.locationId, this.numberOfClasses});

  @override
  State<ClassScheduleCalendar> createState() => _ClassScheduleCalendarState();
}

class _ClassScheduleCalendarState extends State<ClassScheduleCalendar> {
  Future<void> _fetchClassesBasedOnDayAndLocation(String dayName, String locationId) async {
    await APIRepository.getClassSchedulesByLocationAndDay(locationId, dayName);
  }
  Future<void> _fetchAllClassesOnDayBases(String locationId) async {
    // Fetch all locations classes
  }
  Future<void> _fetchAllClassesPagination(int page, int count) async {
    // Fetch all classes based on the day
    await APIRepository.getClassScheduleByPagination(page, count);
  }
  @override
  void initState() {
    super.initState();
    // Fetch today's classes when the widget is initialized
    if(widget.locationId.isNotEmpty) {
      _fetchClassesBasedOnDayAndLocation("Sunday", widget.locationId);
    } else {
      // Handle the case where locationId is null
      print("Location ID is null, cannot fetch classes.");
    }
    _fetchAllClassesOnDayBases("Sunday");
  }

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
