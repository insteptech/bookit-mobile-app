import 'dart:convert';

import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/models/user_model.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/calendar/presentation/book_new_appointment_screen_2.dart';
import 'package:bookit_mobile_app/features/main/dashboard/widget/my_calender_widget_day_wise.dart';
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
  List<Map<String, dynamic>> practitioners = [];
  List<Map<String, dynamic>> serviceList = [];
  List<String> durationOptions = [];

  String selectedPractitioner = "";
  String selectedService = "";
  String selectedDuration = "";
  bool isLoading = true;

  Future<void> fetchData(String locationId) async {
    final data = await APIRepository.getPractitioners(locationId);
    setState(() {
      practitioners = List<Map<String, dynamic>>.from(data['profiles']);
    });
  }

  Future<void> fetchServices() async {
    final data = await APIRepository.getServiceList();
    final List<dynamic> rawList = data['business_services_details'];
    final List<Map<String, dynamic>> extractedList =
        rawList.map<Map<String, dynamic>>((item) {
          return {
            "name": item['name'],
            "description": item['description'],
            "id": item['business_service']['id'],
            "durations":
                (item['durations'] as List)
                    .map(
                      (d) => {
                        "duration_minutes": d['duration_minutes'],
                        "price": d['price'],
                        "id": d['id'],
                      },
                    )
                    .toList(),
          };
        }).toList();
    setState(() {
      serviceList = extractedList;
    });
  }

  // Helper function to convert time format from "3:00 PM" to "15:00:00"
  String convertTo24HourFormat(String time12Hour) {
    try {
      final parts = time12Hour.split(' ');
      final timePart = parts[0];
      final period = parts[1].toUpperCase();

      final timeParts = timePart.split(':');
      int hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? timeParts[1] : '00';

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:${minute.padLeft(2, '0')}:00';
    } catch (e) {
      print('Error converting time: $e');
      return time12Hour;
    }
  }

  // Helper function to convert minutes to hours and minutes
  String minutesToHoursMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
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

    final startTime24 = convertTo24HourFormat(startTime);
    final endTime24 = convertTo24HourFormat(endTime);

    final totalMinutes = getTimeDifferenceInMinutes(startTime24, endTime24);
    final numberOfSlots = totalMinutes ~/ durationMinutes;

    String currentStartTime = startTime24;

    for (int i = 0; i < numberOfSlots; i++) {
      final slotEndTime = addMinutesToTime(currentStartTime, durationMinutes);

      slots.add({'start': currentStartTime, 'end': slotEndTime});

      currentStartTime = slotEndTime;
    }

    return slots;
  }

  // Convert API data to calendar widget format
  List<Map<String, dynamic>> generateCalendarData() {
    if (practitioners.isEmpty ||
        selectedService.isEmpty ||
        selectedDuration.isEmpty) {
      return [];
    }

    final selectedServiceData = serviceList.firstWhere(
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

    for (final practitioner in practitioners) {
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
          'business_service_id': selectedService,
          'slots': allSlots,
        });
      }
    }
    return calendarData;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    fetchServices();
    final notifier = ref.read(locationsProvider.notifier);
    if (ref.read(locationsProvider).isEmpty) {
      await notifier.fetchLocations();
    }
    final locations = ref.read(locationsProvider);
    if (locations.isNotEmpty) {
      final activeLocation = ref.read(activeLocationProvider);
      final locationId =
          activeLocation.isNotEmpty ? activeLocation : locations[0]['id'];
      ref.read(activeLocationProvider.notifier).state = locationId;
      setState(() {
        isLoading = true;
      });
      await fetchData(locationId);
      setState(() {
        isLoading = false;
      });
    }
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
      'booked_by': null, //to be filled on next screen
      'business_service_id': tappedAppointment.businessServiceId,
      'status': 'booked', // Default status for a new booking
      'practitioner': tappedAppointment.practitionerId,
      'date': formatUtcIsoWithoutMilliseconds(tappedAppointment.startTime), // YYYY-MM-DDTHH:mm:ssZ
      'start_from': formatUtcTimeOnly(tappedAppointment.startTime),         // HH:mm:ss (UTC)
      'end_at': formatUtcTimeOnly(tappedAppointment.endTime),   
      'user_id':userId, 
      'rescheduled_from': null,
      'status_reason': null,
      'class_id': null,
      'is_cancelled': false,
      'duration_minutes': tappedAppointment.duration.inMinutes,
      'service_name': tappedAppointment.title,
      'practitioner_name': tappedAppointment.practitionerName,
    };

    // 3. Print the payload for verification.
    // Using json.encode for pretty printing
    // final prettyPayload = const JsonEncoder.withIndent('  ').convert(appointmentPayload);
    // print('--- Appointment Payload (Ready for next screen) ---');
    // print(prettyPayload);
    // print('----------------------------------------------------');

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
                  const Text(
                    "Book a new appointment",
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
                              await fetchData(location['id']);
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
                  Text("Choose practitioner", style: AppTypography.headingSm),
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
                        ...practitioners.map((practitioner) {
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
                  Text("Choose service", style: AppTypography.headingSm),
                  const SizedBox(height: 8),
                  DropDown(
                    items: serviceList,
                    onChanged: (item) {
                      setState(() {
                        selectedService = item['id'];
                        selectedDuration =
                            ""; // Reset duration when service changes
                        if (selectedService.isNotEmpty) {
                          final selected = serviceList.firstWhere(
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
                    Text("Select duration", style: AppTypography.headingSm),
                    const SizedBox(height: 8),
                    if (durationOptions.isNotEmpty)
                      RadioButtonCustom(
                        options:
                            durationOptions
                                .map((duration) => '$duration')
                                .toList(),
                        initialValue:
                            selectedDuration.isNotEmpty
                                ? '$selectedDuration min'
                                : '',
                        onChanged: (value) {
                          setState(() {
                            selectedDuration = value.replaceAll(' min', '');
                          });
                        },
                      ),
                    const SizedBox(height: 32),
                  ],
                  Text("Calendar", style: AppTypography.headingSm),
                  const SizedBox(height: 8),
                  if (selectedService.isEmpty || selectedDuration.isEmpty)
                    Container(
                      height: 200,
                      child: Center(
                        child: Text(
                          "Please select a service and duration to view available slots",
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
