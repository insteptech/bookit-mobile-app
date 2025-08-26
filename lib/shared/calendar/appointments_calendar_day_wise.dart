import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Definition for the callback function.
// It now provides a richer Appointment object that includes duration and UTC times.
typedef AppointmentTapCallback = void Function(Appointment appointment);

class MyCalenderWidgetDayWise extends StatefulWidget {
  final AppointmentTapCallback? onAppointmentTap;
  final calenderData;

  const MyCalenderWidgetDayWise({
    super.key,
    this.onAppointmentTap,
   required this.calenderData
  });

  @override
  State<MyCalenderWidgetDayWise> createState() => _MyCalenderWidgetDayWiseState();
}

class _MyCalenderWidgetDayWiseState extends State<MyCalenderWidgetDayWise> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _bodyHorizontalController = ScrollController();
  final bool showOnlyPractitionerName = true;

  // NEW DATA FORMAT: Day of week and time only
  // final List<Map<String, dynamic>> practitionerData = [
  //   {
  //     'practitioner_name': 'Fatima',
  //     'service_name': 'Sports & Deep Tissue Massage',
  //     'business_service_id': '23453454534',
  //     'slots': [
  //       {'day': 'Thursday', 'start': '14:00:00', 'end': '15:00:00'},
  //       {'day': 'Friday', 'start': '14:00:00', 'end': '15:00:00'},
  //       {'day': 'Friday', 'start': '15:00:00', 'end': '16:00:00'},
  //       // Added slot for today to test visualization
  //       {'day': _getDayName(DateTime.now()), 'start': '${DateTime.now().hour+1}:00:00', 'end': '${DateTime.now().hour+2}:00:00'},
  //     ],
  //   },
  //   {
  //     'practitioner_name': 'Manoj',
  //     'service_name': 'Therapeutic Massage',
  //     'business_service_id': '23453454535',
  //     'slots': [
  //       {'day': 'Thursday', 'start': '14:00:00', 'end': '15:00:00'},
  //       {'day': 'Friday', 'start': '15:00:00', 'end': '16:00:00'},
  //       {'day': 'Saturday', 'start': '10:00:00', 'end': '11:00:00'},
  //     ],
  //   },
  // ];

  List<Appointment> appointments = [];

  // Helper map to convert day names to DateTime weekdays (Monday=1, Sunday=7)
  static const Map<String, int> _dayNameToWeekday = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
    'Saturday': DateTime.saturday,
    'Sunday': DateTime.sunday,
  };

  // Helper to get the full day name (used for the added test data)
  static String _getDayName(DateTime date) {
   const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[date.weekday % 7];
  }

  // MODIFIED: Parses the new data format (Day/Time) and maps it to the next 7 specific dates.
  void _parseAppointments() {
    appointments.clear();
    final next7Days = _getNext7Days();
    final color = AppColors.secondary2;

    for (final practitioner in widget.calenderData) {
      print('DEBUG CALENDAR 5: Processing practitioner: ${practitioner['practitioner_name']}');
      for (final slot in practitioner['slots']) {
        print('DEBUG CALENDAR 6: Processing slot: $slot');
        final String dayName = slot['day'];
        final int? targetWeekday = _dayNameToWeekday[dayName];

        if (targetWeekday == null) {
          // Skip invalid day names
          continue;
        }

        // Find the specific date in the next 7 days that matches the target weekday
        for (final date in next7Days) {
          if (date.weekday == targetWeekday) {
            try {
              // Parse the time strings
              final startTimeOfDay = _parseTime(slot['start']);
              final endTimeOfDay = _parseTime(slot['end']);

              // Construct the full DateTime object for this specific date
              final startTime = DateTime(date.year, date.month, date.day, startTimeOfDay.hour, startTimeOfDay.minute);
              var endTime = DateTime(date.year, date.month, date.day, endTimeOfDay.hour, endTimeOfDay.minute);

              // Handle slots that might end on the next day (e.g., 23:00 to 01:00)
              if (endTime.isBefore(startTime)) {
                endTime = endTime.add(const Duration(days: 1));
              }

              appointments.add(Appointment(
                title: practitioner['service_name'],
                practitionerName: practitioner['practitioner_name'],
                practitionerId: practitioner['practitioner_id'],
                businessServiceId: practitioner['business_service_id'],
                startTime: startTime,
                endTime: endTime,
                color: color,
              ));
            } catch (e) {
              // Skip slots with invalid time format
            }
            // Optimization: Once we found the matching day in this week, break the inner loop
            break; 
          }
        }
      }
    }
  }

  // Helper function to parse "HH:mm:ss" string into TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    print('DEBUG CALENDAR 1: Parsing timeString: "$timeString"');
    final parts = timeString.split(':');
    print('DEBUG CALENDAR 2: Split parts: $parts');
    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      print('DEBUG CALENDAR 3: Parsed hour: $hour, minute: $minute');
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('DEBUG CALENDAR 4: ERROR parsing time - $e');
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _parseAppointments();
    _headerHorizontalController.addListener(_syncHeaderScroll);
    _bodyHorizontalController.addListener(_syncBodyScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final currentHour = now.hour;
      final scrollPosition = (currentHour - 6) * 60.0;
      if (scrollPosition > 0 && _verticalController.hasClients) {
        _verticalController.animateTo(
          scrollPosition, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut,
        );
      }
    });
  }

  void _syncHeaderScroll() {
    if (_bodyHorizontalController.hasClients && _bodyHorizontalController.offset != _headerHorizontalController.offset) {
      _bodyHorizontalController.jumpTo(_headerHorizontalController.offset);
    }
  }

  void _syncBodyScroll() {
    if (_headerHorizontalController.hasClients && _headerHorizontalController.offset != _bodyHorizontalController.offset) {
      _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
    }
  }

  @override
  void didUpdateWidget(MyCalenderWidgetDayWise oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-parse appointments if the calendar data has changed
    if (widget.calenderData != oldWidget.calenderData) {
      _parseAppointments();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _headerHorizontalController.removeListener(_syncHeaderScroll);
    _bodyHorizontalController.removeListener(_syncBodyScroll);
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    super.dispose();
  }

  List<DateTime> _getNext7Days() {
    final today = DateTime.now();
    // Start from the beginning of today
    final startOfToday = DateTime(today.year, today.month, today.day);
    return List.generate(7, (index) => startOfToday.add(Duration(days: index)));
  }

  String getDayAbbreviation(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String getMonthAbbreviation(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  List<List<Appointment>> getOverlappingGroups(List<Appointment> dayAppointments) {
    if (dayAppointments.isEmpty) return [];
    dayAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));
    List<List<Appointment>> groups = [];
    List<Appointment> currentGroup = [dayAppointments[0]];
    for (int i = 1; i < dayAppointments.length; i++) {
      bool overlaps = false;
      for (Appointment existing in currentGroup) {
        if (dayAppointments[i].startTime.isBefore(existing.endTime) &&
            dayAppointments[i].endTime.isAfter(existing.startTime)) {
          overlaps = true;
          break;
        }
      }
      if (overlaps) {
        currentGroup.add(dayAppointments[i]);
      } else {
        groups.add(List.from(currentGroup));
        currentGroup = [dayAppointments[i]];
      }
    }
    groups.add(currentGroup);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ensure we use the same list of days used in parsing
    final days = _getNext7Days(); 
    const double dayWidth = 120.0;
    const double hourHeight = 60.0;
    const double dayHorizontalPadding = 4.0;
    const double appointmentItemSpacing = 4.0;
    const double availableWidth = dayWidth - (dayHorizontalPadding * 2);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            height: 30,
            color: theme.scaffoldBackgroundColor,
            child: Row(
              children: [
                const SizedBox(width: 60, child: Center(child: Text(''))),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _headerHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: days.map((day) {
                        return SizedBox(
                          width: dayWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${getDayAbbreviation(day)} ${getMonthAbbreviation(day)} ${day.day}',
                                // Using standard TextTheme instead of AppTypography
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Calendar grid
          Expanded(
            child: SingleChildScrollView(
              controller: _verticalController,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time column
                  SizedBox(
                    width: 60,
                    child: Column(
                      children: List.generate(24, (hour) {
                        final time = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
                        final period = hour < 12 ? 'AM' : 'PM';
                        return Container(
                          height: hourHeight,
                          alignment: Alignment.center, // Center the time text
                          child: Text(
                            '$time $period',
                            // Using standard TextTheme instead of AppTypography
                             style: theme.textTheme.bodySmall,
                             ),
                        );
                      }),
                    ),
                  ),
                  // Days columns
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _bodyHorizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: days.map((day) {
                          // Filter appointments for this specific date
                          final dayAppointments = appointments.where((apt) =>
                              apt.startTime.day == day.day && apt.startTime.month == day.month && apt.startTime.year == day.year).toList();
                          
                          final overlappingGroups = getOverlappingGroups(dayAppointments);
                          
                          return Container(
                            width: dayWidth,
                            padding: const EdgeInsets.symmetric(horizontal: dayHorizontalPadding),
                            child: Stack(
                              children: [
                                // Grid lines (optional) and background
                                Column(
                                  children: List.generate(24, (i) => SizedBox(height: hourHeight)),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: const Color(0xFFF8F9FA),
                                    ),
                                    child: dayAppointments.isEmpty
                                        ? Center(
                                            child: Text(
                                              AppTranslationsDelegate.of(context).text("no_availability"),
                                              // Using standard TextTheme instead of AppTypography
                                               style: theme.textTheme.bodySmall,
                                              ),
                                          )
                                        : null,
                                  ),
                                ),
                                // Appointments
                                ...overlappingGroups.expand((group) {
                                  return group.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final appointment = entry.value;
                                    final groupSize = group.length;
                                    final startMinutes = appointment.startTime.hour * 60 + appointment.startTime.minute;
                                    
                                    final top = (startMinutes / 60) * hourHeight;
                                    final height = (appointment.duration.inMinutes / 60) * hourHeight;
                                    
                                    final double itemWidth = availableWidth / groupSize;
                                    final double itemLeft = index * itemWidth;
                                    
                                    return Positioned(
                                      left: itemLeft + (appointmentItemSpacing / 2),
                                      top: top,
                                      width: itemWidth - appointmentItemSpacing,
                                      height: height - 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.onAppointmentTap?.call(appointment);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: appointment.color,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          padding: const EdgeInsets.all(3),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} ${appointment.startTime.hour < 12 ? 'AM' : 'PM'}',
                                                // Using standard TextTheme instead of AppTypography
                                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                appointment.practitionerName,
                                                // Using standard TextTheme instead of AppTypography
                                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 1),
                                              if(!showOnlyPractitionerName)
                                              Expanded(
                                                child: Text(
                                                  appointment.title,
                                                  // Using standard TextTheme instead of AppTypography
                                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 9),
                                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                }),
                                // Current time indicator
                                if (day.day == DateTime.now().day && day.month == DateTime.now().month && day.year == DateTime.now().year)
                                  Positioned(
                                    top: (DateTime.now().hour * 60 + DateTime.now().minute) / 60 * hourHeight,
                                    left: 0, right: 0,
                                    child: Container(height: 2, color: theme.colorScheme.error),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Appointment {
  final String title; // Service Name
  final String practitionerName;
   final String practitionerId;
  final String businessServiceId;
  final DateTime startTime; // Local Time
  final DateTime endTime;   // Local Time
  final Color color;

  Appointment({
    required this.title,
    required this.practitionerName,
    required this.practitionerId,
    required this.businessServiceId,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  // ADDED: Helper getters for the required callback data
  Duration get duration => endTime.difference(startTime);
  DateTime get startTimeUtc => startTime.toUtc();
  DateTime get endTimeUtc => endTime.toUtc();
}