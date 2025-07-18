import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/add_staff_and_availability_box.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/my_calender_widget.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/no_upcoming_appointments_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<Map<String, dynamic>> todaysStaffAppointments = [];
  List<Map<String, dynamic>> allStaffAppointments = [];
  bool isLoading = true;

  Future<void> fetchAppointments(String locationId) async {
    setState(() {
      isLoading = true;
    });
    final data = await APIRepository.getAppointments(locationId);
    setState(() {
      isLoading = false;
    });
    // print("data for $locationId : $data");
    setState(() {
      allStaffAppointments = List<Map<String, dynamic>>.from(data['data']);
    });
    filterAppointments();
  }

  void filterAppointments() {
    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final filtered = allStaffAppointments.map((staff) {
      final appointments = (staff['appointments'] as List).where((appointment) {
        final startTime = DateTime.parse(appointment['start_time']);
        return startTime.isAfter(todayStart) && startTime.isBefore(todayEnd);
      }).toList();

      return {
        ...staff,
        'appointments': appointments,
      };
    }).where((staff) => (staff['appointments'] as List).isNotEmpty).toList();

    setState(() {
      todaysStaffAppointments = filtered;
    });
  }

@override
void initState() {
  super.initState();

  // Show cached locations instantly
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final locations = ref.read(locationsProvider);
    if (locations.isNotEmpty) {
      final activeLocation = ref.read(activeLocationProvider);
      // Select first location if no active location exists or if it's empty
      final locationId = (activeLocation.isEmpty) ? locations[0]['id'] : activeLocation;
      ref.read(activeLocationProvider.notifier).state = locationId;
      fetchAppointments(locationId);
    }
    // Fetch fresh locations in background and update provider
    _fetchFreshLocations();
  });
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
      await fetchAppointments(firstLocationId);
    } else {
      // Check if the current active location still exists in the updated locations list
      final locationExists = locations.any((location) => location['id'] == activeLocation);
      
      if (!locationExists) {
        // If active location no longer exists, select the first one
        final firstLocationId = locations[0]['id'];
        ref.read(activeLocationProvider.notifier).state = firstLocationId;
        await fetchAppointments(firstLocationId);
      }
      // If location exists and hasn't changed, do nothing (appointments already loaded)
    }
  }
}

  Widget _buildAppointmentSection() {
    if (isLoading) {
       return Center(
          child: Column(
            children: [
              SizedBox(height: 16,),
              SizedBox(height: 250,),
              SizedBox(height: 24,)
            ],
          ),
       );
    }
    if (allStaffAppointments.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 16),
          AddStaffAndAvailabilityBox(),
          const SizedBox(height: 24),
        ],
      );
    }
    if (todaysStaffAppointments.isEmpty) {
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
          height: 250,
          child: ClipRRect(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: MyCalenderWidget(appointments: todaysStaffAppointments, isLoading: isLoading, viewportHeight: 250,),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locations = ref.watch(locationsProvider);
    final activeLocation = ref.watch(activeLocationProvider);

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
                  Text(AppTranslationsDelegate.of(context).text("welcome_back"), style: AppTypography.headingLg),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ...locations.map((location) {
                          return GestureDetector(
                            onTap: () async {
                              ref.read(activeLocationProvider.notifier).state = location['id'];
                              await fetchAppointments(location['id']);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: activeLocation == location['id']
                                      ? theme.colorScheme.onSurface
                                      : AppColors.appLightGrayFont,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(location["title"]),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    DateFormat('EEE MMM d').format(DateTime.now()),
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  _buildAppointmentSection(),
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
                  GestureDetector(
                    onTap: () {
                      context.push("/staff_list");
                    },
                    child: Container(
                      height: 160,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrayBoxColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppTranslationsDelegate.of(context).text("click_to_add_staff_and_class_schedules"),
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}