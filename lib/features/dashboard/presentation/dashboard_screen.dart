import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';
import 'package:bookit_mobile_app/core/controllers/staff_controller.dart';
import 'package:bookit_mobile_app/core/controllers/classes_controller.dart';
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
        final classesController = ref.read(classesControllerProvider.notifier);
        await classesController.fetchClassesForDate(activeLocation, DateTime.now());
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
        final classesController = ref.read(classesControllerProvider.notifier);
        futures.add(classesController.fetchClassesForDate(activeLocation, DateTime.now()));
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
      final classesController = ref.read(classesControllerProvider.notifier);
      await classesController.fetchClassesForDate(locationId, DateTime.now());
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
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 180.0,
              collapsedHeight: 100.0,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: theme.colorScheme.onSurface,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final expandedHeight = 180.0;
                  final collapsedHeight = 100.0;
                  final currentHeight = constraints.maxHeight;
                  final progress = ((expandedHeight - currentHeight) / 
                      (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
                  
                  return Container(
                    padding: AppConstants.defaultScaffoldPadding,
                    child: _buildAnimatedHeader(progress),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: AppConstants.defaultScaffoldPadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    DateFormat('EEE MMM d').format(DateTime.now()),
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppConstants.contentSpacing),
                  const DashboardContentWidget(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedHeader(double progress) {
    final textSize = 32.0 - (8.0 * progress); // 32 -> 24
    
    // Calculate smooth positions for notification icon
    final notificationTopPosition = AppConstants.scaffoldTopSpacing * (1 - progress);
    final notificationRightPosition = 0.0;
    
    // Calculate smooth positions for welcome text
    final welcomeTopPosition = (AppConstants.scaffoldTopSpacing + AppConstants.contentSpacing + 28) * (1 - progress);
    final welcomeLeftPosition = 0.0;
    
    // Calculate location selector position with extra spacing
    final locationTopPosition = welcomeTopPosition + textSize + AppConstants.titleToSubtitleSpacing + 8.0;
    
    return SizedBox(
      height: double.infinity,
      child: Stack(
        children: [
          // Notification icon - smoothly animated position
          Positioned(
            top: notificationTopPosition,
            right: notificationRightPosition,
            child: const Icon(Icons.notifications_outlined, size: 28),
          ),
          
          // Welcome text - smoothly animated position and size
          Positioned(
            top: welcomeTopPosition,
            left: welcomeLeftPosition,
            right: 40, // Leave space for notification icon
            child: Text(
              AppTranslationsDelegate.of(context).text("welcome_back"),
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
              ),
            ),
          ),
          
          // Location selector - smoothly follows welcome text
          Positioned(
            top: locationTopPosition,
            left: 0,
            right: 0,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: LocationSelectorWidget(),
            ),
          ),
        ],
      ),
    );
  }
}