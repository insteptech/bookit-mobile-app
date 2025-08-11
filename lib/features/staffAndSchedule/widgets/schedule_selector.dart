import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'dropdown_time_picker.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/staff_schedule_controller.dart';

/// Schedule selector widget that handles time input for staff schedules.
/// 
/// Time Handling:
/// - UI displays time in local format (12-hour with AM/PM)
/// - Converts local time to actual UTC time before sending to backend
/// - Backend communication uses UTC format (24-hour HH:mm:ss)
/// - When receiving data from backend, converts UTC time back to local for display
class ScheduleSelector extends StatefulWidget {
  final int index;
  final StaffScheduleController controller;

  const ScheduleSelector({
    Key? key,
    required this.index,
    required this.controller,
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
    _initializeFromController();
  }

  void _initializeFromController() {
    // Get the existing schedule from the controller
    if (widget.index < widget.controller.entries.length) {
      final entry = widget.controller.entries[widget.index];
      final daySchedules = entry.daySchedules;
      
      // Initialize the UI state from the existing schedule
      for (var schedule in daySchedules) {
        final day = schedule['day'];
        final from = schedule['from'];
        final to = schedule['to'];
        
        if (day != null && from != null && to != null) {
          // Find the day index
          final dayIndex = fullDays.indexWhere(
            (d) => d.toLowerCase() == day.toLowerCase()
          );
          
          if (dayIndex != -1) {
            try {
              // Parse the time strings - backend sends UTC format (HH:mm:ss)
              final startTime = _parseTimeFromBackend(from);
              final endTime = _parseTimeFromBackend(to);
              
              setState(() {
                selectedDays[dayIndex] = true;
                timeRanges[dayIndex] = TimeRange(
                  start: startTime,
                  end: endTime,
                );
              });
            } catch (e) {
              print('Error parsing time for $day: $from - $to, Error: $e');
            }
          }
        }
      }
    }
  }

  TimeOfDay _parseTimeFromBackend(String timeStr) {
    // First try to parse as UTC format (HH:mm:ss) from backend and convert to local
    try {
      return parseUtcTimeFormatToLocal(timeStr); // Converts UTC to local time
    } catch (e) {
      // Fallback to existing parsing for legacy format
      return _parseTimeString(timeStr);
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
      if (selectedDays[index] && timeRanges[index] != null) {
        final range = timeRanges[index]!;
        daysSchedule.add({
          "day": fullDays[index].toLowerCase(),
          "from": timeOfDayToUtcFormatWithTimezone(range.start), // Now converts local to UTC
          "to": timeOfDayToUtcFormatWithTimezone(range.end),     // Now converts local to UTC
        });
      }
    }

    widget.controller.updateDaySchedule(widget.index, daysSchedule);
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
          return Padding(
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