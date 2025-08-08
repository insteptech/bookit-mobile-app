import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';
import 'package:bookit_mobile_app/core/utils/appointment_utils.dart';
import 'package:bookit_mobile_app/features/main/calendar/widgets/upcoming_appointments.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widgets/class_schedule_calendar.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widgets/add_staff_and_availability_box.dart';
import 'package:bookit_mobile_app/features/main/dashboard/models/business_category_model.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widgets/location_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  
  @override
  void initState() {
    super.initState();
    // Delay the initialization to avoid modifying providers during build
    Future(() => _initializeData());
  }

  Future<void> _initializeData() async {
    final notifier = ref.read(locationsProvider.notifier);
    if (ref.read(locationsProvider).isEmpty) {
      await notifier.fetchLocations();
    }
    
    final locations = ref.read(locationsProvider);
    if (locations.isNotEmpty) {
      final activeLocation = ref.read(activeLocationProvider);
      final locationId = activeLocation.isNotEmpty ? activeLocation : locations[0]['id'];
      ref.read(activeLocationProvider.notifier).state = locationId;
      
      // Fetch appointments and business categories in parallel
      final appointmentsController = ref.read(appointmentsControllerProvider.notifier);
      final businessController = ref.read(businessControllerProvider.notifier);
      
      await Future.wait([
        appointmentsController.fetchAppointments(locationId),
        businessController.fetchBusinessCategories(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: AppConstants.defaultScaffoldPadding,
                children: [
                  SizedBox(height: AppConstants.scaffoldTopSpacing),
                  // SizedBox(height: AppConstants.contentSpacing),
                  Text(
                    AppTranslationsDelegate.of(context).text("calendar_title"),
                    style: AppTypography.headingLg,
                  ),
                  SizedBox(height: AppConstants.titleToSubtitleSpacing),
                  const LocationSelectorWidget(),
                  SizedBox(height: AppConstants.headerToContentSpacing),
                  _buildCalendarContent(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarContent(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessControllerProvider);
    final appointmentsState = ref.watch(appointmentsControllerProvider);
    final activeLocation = ref.watch(activeLocationProvider);
    
    final businessType = businessState.businessType;
    final appointments = appointmentsState.allStaffAppointments;
    final isLoading = appointmentsState.isLoading || businessState.isLoading;

    // Check if there are any staff members using utility function
    final hasStaff = hasStaffMembers(appointments);

    // If no staff, show the add staff box for both appointment and class businesses
    if (!isLoading && !hasStaff) {
      // Determine if we should show class version based on business type
      final isClassContext = businessType == BusinessType.classOnly;
      
      return Column(
        children: [
          SizedBox(height: AppConstants.contentSpacing + 4), // 20px equivalent
          AddStaffAndAvailabilityBox(isClass: isClassContext),
          SizedBox(height: AppConstants.contentSpacing + 4), // 20px equivalent
        ],
      );
    }

    return Container(
      key: ValueKey('calendar_content_$activeLocation'), // Include location in key to force rebuild
      child: Column(
        children: [
          // Show appointments section if business supports appointments
          if (businessType == BusinessType.appointmentOnly || businessType == BusinessType.both) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppTranslationsDelegate.of(context).text("appointments"),
                  style: AppTypography.headingMd.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.contentSpacing),
            AppointmentsWidget(
              staffAppointments: appointments,
              maxAppointments: 3,
              isLoading: isLoading,
              showBottomOptions: true,
            ),
            SizedBox(height: AppConstants.headerToContentSpacing),
          ],
          
          // Show class schedule section if business supports classes
          if (businessType == BusinessType.classOnly || businessType == BusinessType.both) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppTranslationsDelegate.of(context).text("schedule"),
                  style: AppTypography.headingMd.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.listItemSpacing),
            ClassScheduleCalendar(
              locationId: activeLocation,
              showCalendarHeader: true,
              numberOfClasses: 4,
            ),
          ],
        ],
      ),
    );
  }
}