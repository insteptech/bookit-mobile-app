import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';
import 'package:bookit_mobile_app/core/controllers/staff_controller.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/location_selector_widget.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/dashboard_content_widget.dart';
import 'package:bookit_mobile_app/features/dashboard/models/business_category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final bool refresh;
  
  const DashboardScreen({super.key, this.refresh = false});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    // Initialize dashboard data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.refresh) {
        // Force refresh of appointments if refresh parameter is true
        _refreshDashboard();
      } else {
        _initializeDashboard();
      }
    });
  }

  Future<void> _refreshDashboard() async {
    // Parallel fetch business type and staff data
    final businessController = ref.read(businessControllerProvider.notifier);
    final staffController = ref.read(staffControllerProvider.notifier);
    
    final businessFuture = businessController.fetchBusinessCategories();
    final staffFuture = staffController.fetchStaffList();
    
    // Wait for both business type and staff data
    await Future.wait([businessFuture, staffFuture]);
    
    // After business type and staff are loaded, handle appointments/classes
    await _handleDataBasedFlow();
  }

  Future<void> _initializeDashboard() async {
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

  Future<void> fetchClasses(String locationId) async {
    try {
      await APIRepository.getAllClassesDetails();
    } catch (e) {
      debugPrint("Error fetching classes: $e");
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.notifications_outlined, size: 28),
                    ],
                  ),
                  SizedBox(height: AppConstants.contentSpacing),
                  Text(
                    AppTranslationsDelegate.of(context).text("welcome_back"),
                    style: AppTypography.headingLg,
                  ),
                  SizedBox(height: AppConstants.titleToSubtitleSpacing),
                  const LocationSelectorWidget(),
                  SizedBox(height: AppConstants.headerToContentSpacing),
                  Text(
                    DateFormat('EEE MMM d').format(DateTime.now()),
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppConstants.contentSpacing),
                  const DashboardContentWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}