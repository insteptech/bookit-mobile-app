import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widgets/class_schedule_calendar.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 44),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 32),
              ),
              const SizedBox(height: 9),
              const Text("Schedule", style: AppTypography.headingLg),
              const SizedBox(height: 8),
              const Text(
                "To modify a class's schedule, simply click on it.",
                style: AppTypography.bodyMedium,
              ),
              SizedBox(height: 32),
              ClassScheduleCalendar(showCalendarHeader: true,),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(34, 20, 34, 20),
        child: PrimaryButton(
          text: "Add new class schedule",
          onPressed: () {
            context.push("/class_schedule", extra: {'className': '', 'classId': ''});
          },
          isDisabled: false,
        ),
      ),
    );;
  }
}