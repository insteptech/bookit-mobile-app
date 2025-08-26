import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/utils/time_utils.dart';
import 'package:bookit_mobile_app/shared/components/organisms/drop_down.dart';
import 'package:flutter/material.dart';
import 'dropdown_time_picker.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_schedule_controller.dart';

/// Schedule selector widget that handles time input for staff schedules.
/// 
/// Time Handling:
/// - UI displays time in local format (12-hour with AM/PM)
/// - Converts local time to actual UTC time before sending to backend
/// - Backend communication uses UTC format (24-hour HH:mm:ss)
/// - When receiving data from backend, converts UTC time back to local for display
class ScheduleSelector extends StatefulWidget {
  final StaffScheduleController controller;
  final List<Map<String, dynamic>>? dropdownContent;
  // Add parameters for state preservation
  final List<bool>? initialSelectedDays;
  final Map<int, dynamic>? initialTimeRanges;
  final List<dynamic>? initialSelectedLocations;
  final Function(List<bool>, Map<int, dynamic>, List<dynamic>)? onScheduleChanged;
  // Callback for notifying parent about any schedule changes (for button state)
  final VoidCallback? onScheduleUpdated;

  const ScheduleSelector({
    Key? key,
    required this.controller,
    this.dropdownContent,
    this.initialSelectedDays,
    this.initialTimeRanges,
    this.initialSelectedLocations,
    this.onScheduleChanged,
    this.onScheduleUpdated,
  }) : super(key: key);

  @override
  State<ScheduleSelector> createState() => _ScheduleSelectorState();
}

class _ScheduleSelectorState extends State<ScheduleSelector> {
  final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> fullDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  List<bool> selectedDays = List.generate(7, (_) => false);
  Map<int, TimeRange> timeRanges = {};

  // Holds the selected location for each day (index 0-6)
  final List<dynamic> selectedLocations = List.filled(7, null, growable: false);

  final List<String> allTimeOptions = List.generate(48, (index) {
    final hour = index ~/ 2;
    final minute = (index % 2) * 30;
    final period = hour < 12 ? 'am' : 'pm';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute == 0 ? '00' : '30';
    return "$displayHour:$displayMinute$period";
  });

  @override
  void initState() {
    super.initState();
    // Initialize with preserved state if available
    if (widget.initialSelectedDays != null) {
      selectedDays = List.from(widget.initialSelectedDays!);
    }
    if (widget.initialTimeRanges != null) {
      timeRanges = Map<int, TimeRange>.from(
        widget.initialTimeRanges!.map((key, value) {
          if (value is TimeRange) {
            return MapEntry(key, value);
          } else if (value is Map) {
            // Handle case where TimeRange was serialized as Map
            // Parse UTC time strings and convert to local TimeOfDay
            TimeOfDay startTime = TimeOfDay.now();
            TimeOfDay endTime = TimeOfDay.now();
            
            try {
              if (value['from'] != null) {
                startTime = _convertUtcTimeStringToLocalTimeOfDay(value['from']);
              } else if (value['start'] != null) {
                startTime = _convertUtcTimeStringToLocalTimeOfDay(value['start']);
              }
            } catch (e) {
              // Fallback to current time if parsing fails
              startTime = TimeOfDay.now();
            }
            
            try {
              if (value['to'] != null) {
                endTime = _convertUtcTimeStringToLocalTimeOfDay(value['to']);
              } else if (value['end'] != null) {
                endTime = _convertUtcTimeStringToLocalTimeOfDay(value['end']);
              }
            } catch (e) {
              // Fallback to current time if parsing fails
              endTime = TimeOfDay.now();
            }
            
            return MapEntry(key, TimeRange(
              start: startTime,
              end: endTime,
            ));
          }
          return MapEntry(key, value);
        })
      );
    }
    if (widget.initialSelectedLocations != null) {
      for (int i = 0; i < selectedLocations.length && i < widget.initialSelectedLocations!.length; i++) {
        selectedLocations[i] = widget.initialSelectedLocations![i];
      }
    }
  }

  /// Converts UTC time string to local TimeOfDay
  /// Handles both 12-hour format (e.g., "10:25 AM") and 24-hour format (e.g., "10:25:00")
  TimeOfDay _convertUtcTimeStringToLocalTimeOfDay(String utcTimeStr) {
    try {
      TimeOfDay utcTimeOfDay;
      
      // Check if the time string contains AM/PM (12-hour format)
      if (utcTimeStr.toLowerCase().contains('am') || utcTimeStr.toLowerCase().contains('pm')) {
        // Parse 12-hour format
        utcTimeOfDay = parseTime(utcTimeStr.toLowerCase().replaceAll(' ', ''));
      } else {
        // Handle 24-hour format
        final parts = utcTimeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        utcTimeOfDay = TimeOfDay(hour: hour, minute: minute);
      }
      
      // Convert UTC TimeOfDay to local TimeOfDay
      final now = DateTime.now().toUtc();
      final utcDateTime = DateTime.utc(
        now.year,
        now.month,
        now.day,
        utcTimeOfDay.hour,
        utcTimeOfDay.minute,
      );
      
      // Convert to local time
      final localDateTime = utcDateTime.toLocal();
      
      return TimeOfDay(hour: localDateTime.hour, minute: localDateTime.minute);
    } catch (e) {
      // Fallback to current time if parsing fails
      return TimeOfDay.now();
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    // Handle format like "12:00 AM" or "1:30 PM"
    final cleanTimeStr = timeStr.replaceAll(' ', '').toLowerCase();
    
    // Try the existing parseTime function first
    try {
      return parseTime(cleanTimeStr);
    } catch (e) {
      // If that fails, try parsing with space format
      final match = RegExp(r'^(\d+):(\d+)\s*(am|pm)$', caseSensitive: false).firstMatch(timeStr);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        final period = match.group(3)!.toLowerCase();
        
        if (period == 'pm' && hour != 12) hour += 12;
        if (period == 'am' && hour == 12) hour = 0;
        
        return TimeOfDay(hour: hour, minute: minute);
      }
      throw Exception('Unable to parse time: $timeStr');
    }
  }

  void _updateScheduleInController() {
    final List<Map<String, String>> daysSchedule = [];
    for (int index = 0; index < 7; index++) {
      if (selectedDays[index] && timeRanges[index] != null && selectedLocations[index] != null) {
        final range = timeRanges[index]!;
        final currentLoc = selectedLocations[index];
        daysSchedule.add({
          "location" : currentLoc.toString(),
          "day": fullDays[index].toLowerCase(),
          "from": timeOfDayToUtcFormatWithTimezone(range.start),
          "to": timeOfDayToUtcFormatWithTimezone(range.end),
        });
      }
    }
    // Update the single schedule with the day schedules
    widget.controller.updateDaySchedule(daysSchedule);
    
    // Notify parent about schedule changes for state preservation
    widget.onScheduleChanged?.call(selectedDays, timeRanges, selectedLocations);
    // Notify parent about schedule updates for button state
    widget.onScheduleUpdated?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Schedule',
            style: AppTypography.headingSm,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (index) {
              final isSelected = selectedDays[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDays[index] = !selectedDays[index];
                      if (!selectedDays[index]) {
                        timeRanges.remove(index);
                        selectedLocations[index] = null;
                      }
                      _updateScheduleInController();
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      days[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(7, (index) {
          if (!selectedDays[index]) return const SizedBox.shrink();
          final time = timeRanges[index];
          return Column(
            children: [
              Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    fullDays[index],
                    style: AppTypography.bodyMedium,
                  ),
                ),
                Expanded(
                  child: DropdownTimePicker(
                    value: time?.startStr(context),
                    options: allTimeOptions,
                    onSelected: (val) {
                      final parsed = parseTime(val);
                      setState(() {
                        final currentEnd = timeRanges[index]?.end;
                        if (currentEnd != null &&
                            !isValidRange(parsed, currentEnd)) {
                          timeRanges[index] = TimeRange(
                            start: parsed,
                            end: parsed,
                          );
                        } else {
                          timeRanges[index] =
                              timeRanges[index] == null
                                  ? TimeRange(start: parsed, end: parsed)
                                  : timeRanges[index]!.copyWith(start: parsed);
                        }
                        _updateScheduleInController();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(AppTranslationsDelegate.of(context).text("to")),
                ),
                Expanded(
                  child: DropdownTimePicker(
                    value: time?.endStr(context),
                    options: time?.start != null
                        ? filteredEndTimes(time!.start, allTimeOptions)
                        : [],
                    onSelected: (val) {
                      final parsed = parseTime(val);
                      setState(() {
                        timeRanges[index] =
                            timeRanges[index] == null
                                ? TimeRange(start: parsed, end: parsed)
                                : timeRanges[index]!.copyWith(end: parsed);
                        _updateScheduleInController();
                      });
                    },
                  ),
                ),

              ],
            ),
          ),
          DropDown(
            items: widget.dropdownContent ?? [],
            hintText: "Select location",
            initialSelectedItem: selectedLocations[index],
            onChanged: (val) {
              setState(() {
                selectedLocations[index] = val;
                _updateScheduleInController();
              });
            },
          )
            ],
          );
        }),
      ],
    );
  }


}

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({required this.start, required this.end});

  TimeRange copyWith({TimeOfDay? start, TimeOfDay? end}) {
    return TimeRange(start: start ?? this.start, end: end ?? this.end);
  }

  String startStr(BuildContext context) => start.format(context);
  String endStr(BuildContext context) => end.format(context);
}