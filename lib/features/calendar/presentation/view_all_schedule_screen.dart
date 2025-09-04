import 'package:bookit_mobile_app/shared/calendar/class_schedule_calendar.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/organisms/sticky_header_scaffold.dart';
import 'package:bookit_mobile_app/core/providers/business_categories_provider.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/presentation/class_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewAllScheduleScreen extends StatefulWidget {
  const ViewAllScheduleScreen({super.key});

  @override
  State<ViewAllScheduleScreen> createState() => _ViewAllScheduleScreenState();
}

class _ViewAllScheduleScreenState extends State<ViewAllScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return StickyHeaderScaffold(
      title: "Schedule",
      subtitle: "To modify a class's schedule, simply click on it.",
      
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClassScheduleCalendar(showCalendarHeader: true),
          // Bottom padding to prevent content from being hidden behind fixed button
          const SizedBox(height: 80),
        ],
      ),
      bottomSheet: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            text: "Add new class schedule",
            onPressed: () async {
              final businessCategoriesProvider = BusinessCategoriesProvider.instance;
              
              // Ensure categories are loaded
              if (!businessCategoriesProvider.hasCategories) {
                await businessCategoriesProvider.fetchBusinessCategories();
              }
              
              final classCategories = businessCategoriesProvider.classCategories;
              
              if (!mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassSelectionScreen(),
                  ),
                );
            },
            isDisabled: false,
          ),
        ),
      ),
    );
  }
}