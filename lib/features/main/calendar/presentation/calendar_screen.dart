import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';
import 'package:bookit_mobile_app/core/utils/appointment_utils.dart';
import 'package:bookit_mobile_app/features/main/calendar/widgets/upcoming_appointments.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/class_schedule_calendar.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/add_staff_and_availability_box.dart';
import 'package:bookit_mobile_app/features/main/dashboard/models/business_category_model.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/location_selector_widget.dart';
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 24,
                ),
                children: [
                  const SizedBox(height: 98),
                  const SizedBox(height: 16),
                  Text(
                    AppTranslationsDelegate.of(context).text("calendar_title"),
                    style: AppTypography.headingLg,
                  ),
                  const SizedBox(height: 8),
                  const LocationSelectorWidget(),
                  const SizedBox(height: 48),
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
          const SizedBox(height: 20),
          AddStaffAndAvailabilityBox(isClass: isClassContext),
          const SizedBox(height: 20),
        ],
      );
    }

    return Column(
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
          const SizedBox(height: 16),
          AppointmentsWidget(
            staffAppointments: appointments,
            maxAppointments: 3,
            isLoading: isLoading,
            showBottomOptions: true,
          ),
          const SizedBox(height: 48),
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
          const SizedBox(height: 12),
          ClassScheduleCalendar(
            locationId: activeLocation,
            showCalendarHeader: true,
            numberOfClasses: 4,
          ),
        ],
      ],
    );
  }
}