import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';
import 'package:bookit_mobile_app/core/controllers/staff_controller.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/calendar/widgets/upcoming_appointments.dart';
import 'package:bookit_mobile_app/shared/calendar/class_schedule_calendar.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/add_staff_and_availability_box.dart';
import 'package:bookit_mobile_app/features/dashboard/models/business_category_model.dart';
import 'package:bookit_mobile_app/shared/components/molecules/location_selector_dropdown.dart';
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
    // Initialize calendar data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCalendar();
    });
  }

  Future<void> _initializeCalendar() async {
    final locations = ref.read(locationsProvider);
    
    // Set active location if locations are available
    if (locations.isNotEmpty) {
      final activeLocation = ref.read(activeLocationProvider);
      final locationId = (activeLocation.isEmpty) ? locations[0]['id'] : activeLocation;
      ref.read(activeLocationProvider.notifier).state = locationId;
    }
    
    // Step 1 & 2: Parallel fetch business type and staff data (most important)
    final businessController = ref.read(businessControllerProvider.notifier);
    final staffController = ref.read(staffControllerProvider.notifier);
    
    final businessFuture = businessController.fetchBusinessCategories();
    final staffFuture = staffController.fetchStaffList();
    
    // Wait for both business type and staff data
    await Future.wait([businessFuture, staffFuture]);
    
    // Step 3: After business type and staff are loaded, handle appointments/classes based on the new flow
    await _handleDataBasedFlow();
    
    // Fetch fresh locations in background and update provider
    _fetchFreshLocations();
  }

  Future<void> _handleDataBasedFlow() async {
    final businessState = ref.read(businessControllerProvider);
    final staffState = ref.read(staffControllerProvider);
    final activeLocation = ref.read(activeLocationProvider);
    
    if (activeLocation.isEmpty) return;
    
    final businessType = businessState.businessType;
    
    if (businessType == BusinessType.appointmentOnly) {
      // Business is appointments only
      if (staffState.hasAppointmentStaff) {
        // Staff for appointments exist - fetch appointments
        final appointmentsController = ref.read(appointmentsControllerProvider.notifier);
        await appointmentsController.fetchAppointments(activeLocation);
      }
      // If no appointment staff, UI will show "add staff" box
    } else if (businessType == BusinessType.classOnly) {
      // Business is class only
      if (staffState.hasClassStaff) {
        // Staff for classes exist - fetch class schedules
        await APIRepository.getAllClassesDetails();
      }
      // If no class staff, UI will show "add coach and schedule class" box
    } else if (businessType == BusinessType.both) {
      // Business has both types - handle both
      final futures = <Future>[];
      
      if (staffState.hasAppointmentStaff) {
        final appointmentsController = ref.read(appointmentsControllerProvider.notifier);
        futures.add(appointmentsController.fetchAppointments(activeLocation));
      }
      
      if (staffState.hasClassStaff) {
        futures.add(APIRepository.getAllClassesDetails());
      }
      
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
    }
  }

  Future<void> _fetchFreshLocations() async {
    final notifier = ref.read(locationsProvider.notifier);
    await notifier.fetchLocations();
    final locations = ref.read(locationsProvider);

    if (locations.isNotEmpty) {
      final activeLocation = ref.read(activeLocationProvider);
      
      // If no active location exists, set it to the first location
      if (activeLocation.isEmpty) {
        final firstLocationId = locations[0]['id'];
        ref.read(activeLocationProvider.notifier).state = firstLocationId;
        await ref.read(appointmentsControllerProvider.notifier)
            .fetchAppointments(firstLocationId);
      } else {
        // Check if the current active location still exists in the updated locations list
        final locationExists = locations.any((location) => location['id'] == activeLocation);
        
        if (!locationExists) {
          // If active location no longer exists, select the first one
          final firstLocationId = locations[0]['id'];
          ref.read(activeLocationProvider.notifier).state = firstLocationId;
          await ref.read(appointmentsControllerProvider.notifier)
              .fetchAppointments(firstLocationId);
        }
        // If location exists and hasn't changed, do nothing (appointments already loaded)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 120.0,
              collapsedHeight: 60.0,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: theme.colorScheme.onSurface,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final expandedHeight = 120.0;
                  final collapsedHeight = 60.0;
                  final currentHeight = constraints.maxHeight;
                  final progress = ((expandedHeight - currentHeight) / 
                      (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
                  
                  return Container(
                    padding: AppConstants.defaultScaffoldPadding.copyWith(
                      top: AppConstants.scaffoldTopSpacing,
                      bottom: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.12),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: _buildAnimatedCalendarHeader(progress),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: AppConstants.defaultScaffoldPadding.copyWith(
                top: 20.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCalendarContent(context, ref),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedCalendarHeader(double progress) {
    final textSize = 32.0 - (6.0 * progress); // 32 -> 26
    
    // Calculate smooth positions for title
    final titleTopPosition = 0.0; // Title stays at top
    final titleLeftPosition = 0.0; // Title stays on left
    
    // Calculate smooth positions for location selector
    // When expanded: below title on left 
    // When collapsed: parallel/aligned with title on right side
    final locationTopPosition = progress > 0.5 
        ? 0.0 // Align with title when collapsed
        : textSize + 12.0; // Below title when expanded
    final locationLeftPosition = progress > 0.5 ? null : 0.0; // Left when expanded, null when collapsed
    final locationRightPosition = progress > 0.5 ? 0.0 : null; // Null when expanded, right when collapsed
    
    return SizedBox(
      height: double.infinity,
      child: Stack(
        children: [
          // Calendar title - smoothly animated size and position
          Positioned(
            top: titleTopPosition,
            left: titleLeftPosition,
            right: progress > 0.5 ? 120 : null, // Make space for location selector when collapsed
            child: Text(
              AppTranslationsDelegate.of(context).text("calendar_title"),
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
              ),
            ),
          ),
          
          // Location selector - smoothly animated position
          Positioned(
            top: locationTopPosition,
            left: locationLeftPosition,
            right: locationRightPosition,
            child: const LocationSelectorDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessControllerProvider);
    final staffState = ref.watch(staffControllerProvider);
    final appointmentsState = ref.watch(appointmentsControllerProvider);
    final activeLocation = ref.watch(activeLocationProvider);
    
    final businessType = businessState.businessType;
    final appointments = appointmentsState.allStaffAppointments;
    
    // Intelligent loading state logic
    final isInitialLoading = _shouldShowLoading(businessState, staffState, appointmentsState);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isInitialLoading 
        ? const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          )
        : Container(
            key: ValueKey('calendar_content_$activeLocation'),
            child: Column(
              children: _buildSectionsForBusinessTypeAndStaff(context, businessType, staffState, appointments, activeLocation),
            ),
          ),
    );
  }

  bool _shouldShowLoading(businessState, staffState, appointmentsState) {
    // Show loading only if:
    // 1. Business type is still loading AND no cached data
    // 2. Staff is still loading AND no cached data  
    // 3. If staff exists but appointments/classes are loading for the first time
    
    if (businessState.isLoading && businessState.businessCategories.isEmpty) {
      return true; // Business data not loaded yet
    }
    
    if (staffState.isLoading && staffState.allStaff.isEmpty) {
      return true; // Staff data not loaded yet
    }
    
    // If business type and staff are loaded, only show loading if:
    // - Business is appointment-only, has appointment staff, but appointments are loading for first time
    // - Business is class-only, has class staff, but classes are loading for first time
    // - Business is both and relevant data is loading for first time
    
    final businessType = businessState.businessType;
    
    if (businessType == BusinessType.appointmentOnly && 
        staffState.hasAppointmentStaff && 
        appointmentsState.isLoading && 
        appointmentsState.allStaffAppointments.isEmpty) {
      return true;
    }
    
    if (businessType == BusinessType.classOnly && 
        staffState.hasClassStaff) {
      // Would need class loading state here, but for now assume loading when staff exists
      // This is a simplified version
      return false;
    }
    
    if (businessType == BusinessType.both) {
      // For both type, show loading only if relevant staff exists but data is loading for first time
      if (staffState.hasAppointmentStaff && 
          appointmentsState.isLoading && 
          appointmentsState.allStaffAppointments.isEmpty) {
        return true;
      }
    }
    
    return false;
  }

  List<Widget> _buildSectionsForBusinessTypeAndStaff(
    BuildContext context, 
    BusinessType businessType, 
    staffState, 
    List<Map<String, dynamic>> appointments, 
    String activeLocation
  ) {
    List<Widget> widgets = [];
    
    // Show appointments section if it's appointment-only or both
    if (businessType == BusinessType.appointmentOnly || businessType == BusinessType.both) {
      widgets.add(_buildAppointmentSection(context, staffState, appointments));
      widgets.add(SizedBox(height: AppConstants.headerToContentSpacing));
    }
    
    // Show class schedule section if it's class-only or both
    if (businessType == BusinessType.classOnly || businessType == BusinessType.both) {
      widgets.add(_buildClassScheduleSection(context, staffState, activeLocation));
    }
    
    return widgets;
  }

  Widget _buildAppointmentSection(BuildContext context, staffState, List<Map<String, dynamic>> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        
        // Check if there are any appointment staff members using the staff controller
        if (!staffState.hasAppointmentStaff) 
          Column(
            children: [
              AddStaffAndAvailabilityBox(),
              SizedBox(height: AppConstants.contentSpacing),
            ],
          )
        else
          AppointmentsWidget(
            staffAppointments: appointments,
            maxAppointments: 3,
            isLoading: false,
            showBottomOptions: true,
          ),
      ],
    );
  }

  Widget _buildClassScheduleSection(BuildContext context, staffState, String activeLocation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        
        // Check if there are any class staff members using the staff controller
        if (!staffState.hasClassStaff)
          Column(
            children: [
              AddStaffAndAvailabilityBox(isClass: true),
              SizedBox(height: AppConstants.contentSpacing),
            ],
          )
        else
          ClassScheduleCalendar(
            locationId: activeLocation,
            showCalendarHeader: true,
            numberOfClasses: 4,
          ),
      ],
    );
  }
}