import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/core/utils/appointment_utils.dart';
import 'package:bookit_mobile_app/features/main/dashboard/models/business_category_model.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/add_staff_and_availability_box.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/my_calender_widget.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/no_upcoming_appointments_box.dart';

class AppointmentSectionWidget extends ConsumerWidget {
  final BusinessType businessType;

  const AppointmentSectionWidget({
    super.key,
    required this.businessType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(appointmentsControllerProvider);
    final isLoading = appointmentsState.isLoading;
    final allAppointments = appointmentsState.allStaffAppointments;
    final todaysAppointments = appointmentsState.todaysStaffAppointments;

    final isFullScreen = businessType == BusinessType.appointmentOnly;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppTranslationsDelegate.of(context).text("todays_appointments"),
              style: AppTypography.headingMd.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.arrow_forward),
          ],
        ),
        const SizedBox(height: 8),
        _buildAppointmentContent(
          context,
          isLoading: isLoading,
          allAppointments: allAppointments,
          todaysAppointments: todaysAppointments,
          isFullScreen: isFullScreen,
        ),
      ],
    );
  }

  Widget _buildAppointmentContent(
    BuildContext context, {
    required bool isLoading,
    required List<Map<String, dynamic>> allAppointments,
    required List<Map<String, dynamic>> todaysAppointments,
    required bool isFullScreen,
  }) {
    if (isLoading) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(height: isFullScreen ? 400 : 250),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    // Check if there are any staff members - using utility function for robust checking
    if (!hasStaffMembers(allAppointments)) {
      return Column(
        children: [
          const SizedBox(height: 16),
          AddStaffAndAvailabilityBox(),
          const SizedBox(height: 24),
        ],
      );
    }

    // If staff exists but no appointments for today, show no upcoming appointments
    if (!hasTodaysAppointments(todaysAppointments)) {
      return Column(
        children: [
          const SizedBox(height: 16),
          NoUpcomingAppointmentsBox(),
          const SizedBox(height: 24),
        ],
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: isFullScreen ? 400 : 250,
          child: ClipRRect(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: MyCalenderWidget(
                appointments: todaysAppointments,
                isLoading: isLoading,
                viewportHeight: isFullScreen ? 400 : 250,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
