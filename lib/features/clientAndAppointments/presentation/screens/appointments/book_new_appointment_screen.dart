
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/models/user_model.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/screens/appointments/book_new_appointment_screen_2.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/provider.dart';
import 'package:bookit_mobile_app/shared/calendar/appointments_calendar_day_wise.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button_custom.dart';
import 'package:bookit_mobile_app/shared/components/organisms/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookNewAppointmentScreen extends ConsumerStatefulWidget {
  const BookNewAppointmentScreen({super.key});

  @override
  ConsumerState<BookNewAppointmentScreen> createState() =>
      _BookNewAppointmentScreenState();
}

class _BookNewAppointmentScreenState
    extends ConsumerState<BookNewAppointmentScreen> {
  
  // Local UI state that doesn't belong in global state
  String selectedPractitioner = "";
  String selectedService = "";
  String selectedDuration = "";
  List<String> durationOptions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final appointmentController = ref.read(appointmentControllerProvider.notifier);
    final locationsNotifier = ref.read(locationsProvider.notifier);
    
    // Fetch services first
    await appointmentController.fetchServices();
    
    // Fetch locations if empty
    if (ref.read(locationsProvider).isEmpty) {
      await locationsNotifier.fetchLocations();
    }
    
    final locations = ref.read(locationsProvider);
    if (locations.isNotEmpty) {
      final activeLocation = ref.read(activeLocationProvider);
      final locationId = activeLocation.isNotEmpty ? activeLocation : locations[0]['id'];
      ref.read(activeLocationProvider.notifier).state = locationId;
      
      // Fetch practitioners for the location
      await appointmentController.fetchPractitioners(locationId);
    }
  }

  // Helper function to validate and format UTC time string
  String validateUtcTimeFormat(String utcTime) {
    try {
      // Expecting format like "HH:mm:ss" or "HH:mm"
      final parts = utcTime.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final second = parts.length > 2 ? int.parse(parts[2]) : 0;
        
        // Validate ranges
        if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59 && second >= 0 && second <= 59) {
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
        }
      }
    } catch (e) {
      print('Error validating UTC time format: $e');
    }
    return utcTime;
  }

  // Helper function to add minutes to a time string
  String addMinutesToTime(String timeString, int minutesToAdd) {
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    final totalMinutes = hours * 60 + minutes + minutesToAdd;
    final newHours = totalMinutes ~/ 60;
    final newMinutes = totalMinutes % 60;

    return '${newHours.toString().padLeft(2, '0')}:${newMinutes.toString().padLeft(2, '0')}:00';
  }

  // Helper function to calculate time difference in minutes
  int getTimeDifferenceInMinutes(String startTime, String endTime) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    return endMinutes - startMinutes;
  }

  // Generate time slots based on duration
  List<Map<String, String>> generateTimeSlots(
    String startTime,
    String endTime,
    int durationMinutes,
  ) {
    List<Map<String, String>> slots = [];

    // Convert UTC times to local times for slot generation
    final startTimeLocal = _convertUtcTimeToLocalTimeString(startTime);
    final endTimeLocal = _convertUtcTimeToLocalTimeString(endTime);

    final totalMinutes = getTimeDifferenceInMinutes(startTimeLocal, endTimeLocal);
    final numberOfSlots = totalMinutes ~/ durationMinutes;

    String currentStartTime = startTimeLocal;

    for (int i = 0; i < numberOfSlots; i++) {
      final slotEndTime = addMinutesToTime(currentStartTime, durationMinutes);

      slots.add({'start': currentStartTime, 'end': slotEndTime});

      currentStartTime = slotEndTime;
    }

    return slots;
  }

  // Helper function to convert UTC time string to local time string
  String _convertUtcTimeToLocalTimeString(String utcTimeString) {
    try {
      final parts = utcTimeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Create a UTC DateTime with today's date and the given time
      final now = DateTime.now().toUtc();
      final utcDateTime = DateTime.utc(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      
      // Convert to local time
      final localDateTime = utcDateTime.toLocal();
      
      return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}:00';
    } catch (e) {
      print('Error converting UTC time to local: $e');
      return utcTimeString; // Fallback to original string
    }
  }

  // Convert API data to calendar widget format
  List<Map<String, dynamic>> generateCalendarData() {
    final appointmentState = ref.read(appointmentControllerProvider);

    if (appointmentState.practitioners.isEmpty ||
        selectedService.isEmpty ||
        selectedDuration.isEmpty) {
      return [];
    }

    final selectedServiceData = appointmentState.serviceList.firstWhere(
      (service) => service['id'] == selectedService,
      orElse: () => <String, dynamic>{},
    );

    if (selectedServiceData.isEmpty) return [];

    final selectedDurationData = (selectedServiceData['durations'] as List)
        .firstWhere(
          (duration) =>
              duration['duration_minutes'].toString() == selectedDuration,
          orElse: () => <String, dynamic>{},
        );

    if (selectedDurationData.isEmpty) return [];

    final durationMinutes = selectedDurationData['duration_minutes'] as int;
    final activeLocation = ref.read(activeLocationProvider);

    List<Map<String, dynamic>> calendarData = [];

    for (final practitioner in appointmentState.practitioners) {
      // Filter by selected practitioner if one is selected
      if (selectedPractitioner.isNotEmpty &&
          practitioner['id'] != selectedPractitioner) {
        continue;
      }

      final locationSchedules = practitioner['location_schedules'] as List;

      // Filter schedules for the active location
      final relevantSchedules =
          locationSchedules
              .where((schedule) => schedule['location_id'] == activeLocation)
              .toList();

      if (relevantSchedules.isEmpty) continue;

      List<Map<String, String>> allSlots = [];

      // Process each schedule for this practitioner
      for (final schedule in relevantSchedules) {
        final day = schedule['day'] as String;
        final fromTime = schedule['from'] as String;
        final toTime = schedule['to'] as String;

        // Generate time slots for this schedule
        final slots = generateTimeSlots(fromTime, toTime, durationMinutes);

        // Add day information to each slot
        for (final slot in slots) {
          allSlots.add({
            'day':
                day.toLowerCase() == 'monday'
                    ? 'Monday'
                    : day.toLowerCase() == 'tuesday'
                    ? 'Tuesday'
                    : day.toLowerCase() == 'wednesday'
                    ? 'Wednesday'
                    : day.toLowerCase() == 'thursday'
                    ? 'Thursday'
                    : day.toLowerCase() == 'friday'
                    ? 'Friday'
                    : day.toLowerCase() == 'saturday'
                    ? 'Saturday'
                    : day.toLowerCase() == 'sunday'
                    ? 'Sunday'
                    : day,
            'start': slot['start']!,
            'end': slot['end']!,
          });
        }
      }

      if (allSlots.isNotEmpty) {
        calendarData.add({
          "practitioner_id" : practitioner['id'],
          'practitioner_name': practitioner['name'],
          'service_name': selectedServiceData['name'],
          'business_service_id': selectedServiceData['business_service_id'], // Use original business service ID
          'slots': allSlots,
        });
      }
    }
    return calendarData;
  }

   void _handleAppointmentTap(Appointment tappedAppointment) async{

     String formatUtcIsoWithoutMilliseconds(DateTime dt) {
    // Convert to ISO string: "2023-10-27T14:00:00.123Z"
    final iso = dt.toUtc().toIso8601String();
    // Find the dot and take the substring before it, then add 'Z' back
    return iso.substring(0, iso.indexOf('.')) + 'Z';
  }

  // --- NEW: Helper function to format DateTime to UTC time only (HH:mm:ss) ---
  String formatUtcTimeOnly(DateTime dt) {
    final utc = dt.toUtc();
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
    // 1. Get all the data available on this screen.
    final activeLocationId = ref.read(activeLocationProvider);
    final UserModel user = await AuthStorageService().getUserDetails();
    final userId = user.id;
    final businessId = await ActiveBusinessService().getActiveBusiness();

    // 2. Construct the payload with available data.
    final Map<String, dynamic> appointmentPayload = {
      'business_id': businessId,
      'location_id': activeLocationId,
      'business_service_id': tappedAppointment.businessServiceId,
      'status': 'booked', // Default status for a new booking
      'practitioner': tappedAppointment.practitionerId,
      'date': formatUtcIsoWithoutMilliseconds(tappedAppointment.startTime), // YYYY-MM-DDTHH:mm:ssZ
      'start_from': formatUtcTimeOnly(tappedAppointment.startTime),         // HH:mm:ss (UTC)
      'end_at': formatUtcTimeOnly(tappedAppointment.endTime),   
      'user_id':userId, 
      'rescheduled_from': "",
      'status_reason': "",
      'class_id': "",
      'is_cancelled': "",
      'duration_minutes': tappedAppointment.duration.inMinutes,
      'service_name': tappedAppointment.title,
      'practitioner_name': tappedAppointment.practitionerName,
    };

    // 4. Navigate to the next screen, passing the payload.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookNewAppointmentScreen2(
          partialPayload: appointmentPayload,
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locations = ref.watch(locationsProvider);
    final activeLocation = ref.watch(activeLocationProvider);
    final appointmentState = ref.watch(appointmentControllerProvider);
    final appointmentController = ref.read(appointmentControllerProvider.notifier);

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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    AppTranslationsDelegate.of(context).text("book_a_new_appointment"),
                    style: AppTypography.headingLg,
                  ),
                  const SizedBox(height: 16),
                  // Location selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ...locations.map((location) {
                          return GestureDetector(
                            onTap: () async {
                              ref.read(activeLocationProvider.notifier).state =
                                  location['id'];
                              setState(() {
                                selectedPractitioner = ""; // Reset practitioner when location changes
                              });
                              await appointmentController.fetchPractitioners(location['id']);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      activeLocation == location['id']
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
                  Text(AppTranslationsDelegate.of(context).text("choose_practitioner"), style: AppTypography.headingSm),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPractitioner = "";
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 32),
                            decoration: BoxDecoration(
                              border:
                                  selectedPractitioner.isEmpty
                                      ? Border(
                                        bottom: BorderSide(
                                          color: theme.colorScheme.primary,
                                          width: 2,
                                        ),
                                      )
                                      : null,
                            ),
                            child: Text(
                              "All Practitioners",
                              style: AppTypography.bodyMedium.copyWith(
                                color:
                                    selectedPractitioner.isEmpty
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                fontWeight:
                                    selectedPractitioner.isEmpty
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        ...appointmentState.practitioners.map((practitioner) {
                          final isSelected =
                              selectedPractitioner == practitioner['id'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedPractitioner = practitioner['id'];
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 32),
                              decoration: BoxDecoration(
                                border:
                                    isSelected
                                        ? Border(
                                          bottom: BorderSide(
                                            color: theme.colorScheme.primary,
                                            width: 2,
                                          ),
                                        )
                                        : null,
                              ),
                              child: Text(
                                practitioner["name"],
                                style: AppTypography.bodyMedium.copyWith(
                                  color:
                                      isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(AppTranslationsDelegate.of(context).text("choose_service"), style: AppTypography.headingSm),
                  const SizedBox(height: 8),
                  DropDown(
                    items: appointmentState.serviceList,
                    onChanged: (item) {
                      setState(() {
                        selectedService = item['id'];
                        selectedDuration = ""; // Reset duration when service changes
                        durationOptions = []; // Clear duration options first
                        
                        if (selectedService.isNotEmpty) {
                          final selected = appointmentState.serviceList.firstWhere(
                            (item) => item['id'] == selectedService,
                            orElse: () => <String, dynamic>{},
                          );

                          if (selected.isNotEmpty &&
                              selected['durations'] != null) {
                            durationOptions = List<String>.from(
                              (selected['durations'] as List).map(
                                (d) => d['duration_minutes'].toString(),
                              ),
                            );
                          }
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  if (selectedService.isNotEmpty) ...[
                    Text(AppTranslationsDelegate.of(context).text("select_duration"), style: AppTypography.headingSm),
                    const SizedBox(height: 8),
                    if (durationOptions.isNotEmpty)
                      RadioButtonCustom(
                        key: ValueKey('duration-$selectedService'), 
                        options: durationOptions, 
                        initialValue: selectedDuration.isNotEmpty ? selectedDuration : null,
                        textSuffix: " min",
                        onChanged: (value) {
                          setState(() {
                            selectedDuration = value; 
                          });
                        },
                      ),
                    const SizedBox(height: 32),
                  ],
                  Text(AppTranslationsDelegate.of(context).text("calendar_heading"), style: AppTypography.headingSm),
                  const SizedBox(height: 8),
                  if (selectedService.isEmpty || selectedDuration.isEmpty)
                    Container(
                      height: 200,
                      child: Center(
                        child: Text(
                          AppTranslationsDelegate.of(context).text("please_select_service_and_duration"),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.appLightGrayFont,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 424,
                      child: MyCalenderWidgetDayWise(
                        key: ValueKey('$selectedPractitioner-$selectedService-$selectedDuration'),
                        calenderData: generateCalendarData(),
                        onAppointmentTap: _handleAppointmentTap,
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
