import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/add_staff_and_availability_box.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/class_schedule_calendar.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/my_calender_widget.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/no_classes_box.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/no_upcoming_appointments_box.dart';
import 'package:bookit_mobile_app/features/main/dashboard/models/business_category_model.dart';
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
  List<dynamic> businessCategoris = [];
  bool isLoading = true;
  bool isCategoriesLoading = true;
  bool isCategoriesLoaded = false;

Future<void> fetchAppointments(String locationId) async {
  setState(() {
    isLoading = true;
  });

  final data = await APIRepository.getAppointments(locationId);
  final List<Map<String, dynamic>> appointmentsList =
      List<Map<String, dynamic>>.from(data['data']);

  setState(() {
    isLoading = false;
    allStaffAppointments = appointmentsList;
  });

  filterAppointments();
}

Future<void> fetchClasses(String locationId) async {
  try {
    final classesData =  await APIRepository.getAllClassesDetails();
    (classesData['data']);
  } catch (e) {
    debugPrint("Error fetching classes: $e");
  }
}


  Future<void> fetchBusinessCategories(String businessId) async {
    setState(() {
      isCategoriesLoading = true;
      isCategoriesLoaded = false;
    });
    
    try {
      // Add timeout to prevent indefinite loading
      final data = await APIRepository.getBusinessCategories()
          .timeout(const Duration(seconds: 10));
      setState(() {
        businessCategoris = data['data'] ?? [];
        isCategoriesLoading = false;
        isCategoriesLoaded = true;
      });
      print("Business categories fetched: ${businessCategoris.length} categories");
      for (var category in businessCategoris) {
        print("Category: ${category['category']['name']}, is_class: ${category['category']['is_class']}");
      }
    } catch (e) {
      setState(() {
        isCategoriesLoading = false;
        isCategoriesLoaded = true; // Set to true even on error to show default UI
      });
      print("Error fetching business categories: $e");
    }
  }

  BusinessType getBusinessType() {
    // Only return actual business type if categories are loaded
    if (!isCategoriesLoaded || businessCategoris.isEmpty) {
      return BusinessType.both; // Default fallback while loading or if empty
    }

    bool hasClassCategory = false;
    bool hasNonClassCategory = false;

    for (final categoryData in businessCategoris) {
      final category = categoryData['category'];
      if (category != null) {
        if (category['is_class'] == true) {
          hasClassCategory = true;
          print("Found class category: ${category['name']}");
        } else {
          hasNonClassCategory = true;
          print("Found non-class category: ${category['name']}");
        }
      }
    }

    BusinessType result;
    if (hasClassCategory && hasNonClassCategory) {
      result = BusinessType.both;
      print("Business type determined: BOTH");
    } else if (hasClassCategory) {
      result = BusinessType.classOnly;
      print("Business type determined: CLASS ONLY");
    } else {
      result = BusinessType.appointmentOnly;
      print("Business type determined: APPOINTMENT ONLY");
    }
    
    return result;
  }

  void filterAppointments() {
    // Use local time boundaries for today's appointments
    final now = DateTime.now(); // Local time
    final todayStart = DateTime(now.year, now.month, now.day); // Local midnight
    final todayEnd = todayStart.add(const Duration(days: 1)); // Local midnight tomorrow

    final filtered = allStaffAppointments.map((staff) {
      final appointments = (staff['appointments'] as List).where((appointment) {
        try {
          // Parse UTC time from backend and convert to local time
          final utcStartTime = DateTime.parse(appointment['start_time']);
          final localStartTime = utcStartTime.toLocal();
          
          print("Appointment: ${appointment['start_time']} (UTC) -> ${localStartTime.toString()} (Local)");
          
          // Check if appointment falls within today's local time boundaries
          final isToday = localStartTime.isAfter(todayStart) && localStartTime.isBefore(todayEnd);
          print("Is today: $isToday");
          
          return isToday;
        } catch (e) {
          print("Error parsing appointment start_time: ${appointment['start_time']}, Error: $e");
          return false; // Skip invalid appointment times
        }
      }).toList();

      return {
        ...staff,
        'appointments': appointments,
      };
    }).where((staff) => (staff['appointments'] as List).isNotEmpty).toList();
    
    print("Filtered appointments: $filtered");

    setState(() {
      todaysStaffAppointments = filtered;
    });
  }

@override
void initState() {
  super.initState();

  // Show cached locations instantly and start loading
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeDashboard();
  });
}

Future<void> _initializeDashboard() async {
  final locations = ref.read(locationsProvider);
  
  // Start fetching business categories immediately
  final categoriesFuture = _fetchBusinessCategories();
  
  if (locations.isNotEmpty) {
    final activeLocation = ref.read(activeLocationProvider);
    // Select first location if no active location exists or if it's empty
    final locationId = (activeLocation.isEmpty) ? locations[0]['id'] : activeLocation;
    ref.read(activeLocationProvider.notifier).state = locationId;
    
    // Start fetching appointments in parallel with categories
    final appointmentsFuture = fetchAppointments(locationId);
   
    
    // Wait for both to complete
    await Future.wait([categoriesFuture, appointmentsFuture]);
  } else {
    // Only wait for categories if no locations
    await categoriesFuture;
  }
  
  // Fetch fresh locations in background and update provider
  _fetchFreshLocations();
}

Future<void> _fetchBusinessCategories() async {
  try {
    await fetchBusinessCategories("");
  } catch (e) {
    // Handle error silently or show a snackbar
    print("Error fetching business categories: $e");
    // Ensure loading state is cleared even on error
    setState(() {
      isCategoriesLoading = false;
      isCategoriesLoaded = true;
    });
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

  Widget _buildAppointmentSection({bool isFullScreen = false}) {
    if (isLoading) {
       return Center(
          child: Column(
            children:  [
              SizedBox(height: 16,),
              SizedBox(height: isFullScreen ? 400 : 250,),
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
          height: isFullScreen ? 400 : 250,
          child: ClipRRect(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: MyCalenderWidget(
                appointments: todaysStaffAppointments, 
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

  Widget _buildLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildClassScheduleSection() {
    if (allStaffAppointments.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 16),
          AddStaffAndAvailabilityBox(),
          const SizedBox(height: 24),
        ],
      );
    }
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
      ClassScheduleCalendar(locationId: ref.watch(activeLocationProvider), showCalendarHeader: false,)
        
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
                              print("Fetching for location ${location['id']}");
                              fetchClasses(location['id']);
                              // Fetch categories only if not already loaded
                              if (!isCategoriesLoaded) {
                                await _fetchBusinessCategories();
                              }
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
                  // Show loading content until categories are loaded with smooth transition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isCategoriesLoading 
                      ? _buildLoadingContent()
                      : Container(
                          key: const ValueKey('dashboard_content'),
                          child: Column(
                            children: () {
                              final businessType = getBusinessType();
                              List<Widget> widgets = [];
                              
                              // Show appointments section if it's appointment-only or both
                              if (businessType == BusinessType.appointmentOnly || businessType == BusinessType.both) {
                                widgets.addAll([
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
                                  _buildAppointmentSection(isFullScreen: businessType == BusinessType.appointmentOnly),
                                ]);
                              }
                              
                              // Show class schedule section if it's class-only or both
                              if (businessType == BusinessType.classOnly || businessType == BusinessType.both) {
                                widgets.add(_buildClassScheduleSection());
                              }
                              
                              // If only appointments, return widgets as-is (full screen)
                              if (businessType == BusinessType.appointmentOnly) {
                                return widgets;
                              }
                              
                              // If only classes, show only class schedule with expanded height
                              if (businessType == BusinessType.classOnly) {
                                // return [
                                //   Row(
                                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       Text(
                                //         AppTranslationsDelegate.of(context).text("todays_class_schedule"),
                                //         style: AppTypography.headingMd.copyWith(
                                //           fontWeight: FontWeight.w500,
                                //         ),
                                //       ),
                                //       const Icon(Icons.arrow_forward),
                                //     ],
                                //   ),
                                //   const SizedBox(height: 12),
                                //   GestureDetector(
                                //     onTap: () {
                                //       context.push("/add_staff?isClass=true");
                                //     },
                                //     child: Container(
                                //       height: 400, // Expanded height for class-only view
                                //       alignment: Alignment.center,
                                //       padding: const EdgeInsets.symmetric(horizontal: 32),
                                //       decoration: BoxDecoration(
                                //         color: AppColors.lightGrayBoxColor,
                                //         borderRadius: BorderRadius.circular(12),
                                //       ),
                                //       child: Text(
                                //         AppTranslationsDelegate.of(context).text("click_to_add_staff_and_class_schedules"),
                                //         textAlign: TextAlign.center,
                                //         style: AppTypography.bodyMedium.copyWith(
                                //           fontWeight: FontWeight.w500,
                                //           color: theme.colorScheme.primary,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                //   ClassScheduleCalendar(locationId: activeLocation, showCalendarHeader: false,)
                                // ];
                              }
                              
                              return widgets;
                            }(),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}