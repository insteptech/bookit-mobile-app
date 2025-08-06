import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/location_selector_widget.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/dashboard_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    // Initialize dashboard data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  Future<void> _initializeDashboard() async {
    final locations = ref.read(locationsProvider);
    
    // Start fetching business categories immediately
    final businessController = ref.read(businessControllerProvider.notifier);
    final categoriesFuture = businessController.fetchBusinessCategories();

    
    if (locations.isNotEmpty) {
      final activeLocation = ref.read(activeLocationProvider);
      // Select first location if no active location exists or if it's empty
      final locationId = (activeLocation.isEmpty) ? locations[0]['id'] : activeLocation;
      ref.read(activeLocationProvider.notifier).state = locationId;
      
      // Start fetching appointments in parallel with categories
      final appointmentsController = ref.read(appointmentsControllerProvider.notifier);
      final appointmentsFuture = appointmentsController.fetchAppointments(locationId);
      
      // Wait for both to complete
      await Future.wait([categoriesFuture, appointmentsFuture]);
    } else {
      // Only wait for categories if no locations
      await categoriesFuture;
    }
    
    // Fetch fresh locations in background and update provider
    _fetchFreshLocations();
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
      final classesData = await APIRepository.getAllClassesDetails();
    } catch (e) {
      print("Error fetching classes: $e");
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
                  const SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.notifications_outlined, size: 28),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppTranslationsDelegate.of(context).text("welcome_back"),
                    style: AppTypography.headingLg,
                  ),
                  const SizedBox(height: 8),
                  const LocationSelectorWidget(),
                  const SizedBox(height: 48),
                  Text(
                    DateFormat('EEE MMM d').format(DateTime.now()),
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
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