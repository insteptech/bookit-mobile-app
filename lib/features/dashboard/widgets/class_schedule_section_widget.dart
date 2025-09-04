import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/controllers/staff_controller.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/add_staff_and_availability_box.dart';
import 'package:bookit_mobile_app/shared/calendar/class_schedule_calendar.dart';

class ClassScheduleSectionWidget extends ConsumerWidget {
  const ClassScheduleSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffState = ref.watch(staffControllerProvider);
    final activeLocation = ref.watch(activeLocationProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppTranslationsDelegate.of(context).text("todays_class_schedule"),
              style: AppTypography.headingMd.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.arrow_forward),
          ],
        ),
        const SizedBox(height: 12),
        _buildClassScheduleContent(context, staffState, activeLocation),
      ],
    );
  }

  Widget _buildClassScheduleContent(
    BuildContext context,
    staffState,
    String activeLocation,
  ) {
    // Check if there are any class staff members using the staff controller
    if (!staffState.hasClassStaff) {
      return Column(
        children: [
          AddStaffAndAvailabilityBox(isClass: true),
          const SizedBox(height: 24),
        ],
      );
    }

    return ClassScheduleCalendar(
      locationId: activeLocation,
      showCalendarHeader: false,
    );
  }
}
