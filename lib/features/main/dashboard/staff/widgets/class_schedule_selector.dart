import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/utils/time_utils.dart';
import 'package:bookit_mobile_app/shared/components/organisms/drop_down.dart';
import 'package:flutter/material.dart';
import 'dropdown_time_picker.dart';

/// Schedule selector widget that handles time input and staff assignment for class schedules.
/// 
/// Time Handling:
/// - UI displays time in local format (12-hour with AM/PM)
/// - Converts local time to actual UTC time before sending to backend
/// - Backend communication uses UTC format (24-hour HH:mm:ss)
/// - When receiving data from backend, converts UTC time back to local for display
class ClassScheduleSelector extends StatefulWidget {
  
  final List<Map<String, dynamic>> staffMembers;
  final Function(List<Map<String, dynamic>>) onScheduleUpdate;
  final List<Map<String, String>>? initialSchedules;

  const ClassScheduleSelector({
    Key? key,
    required this.staffMembers,
    required this.onScheduleUpdate,
    this.initialSchedules,
  }) : super(key: key);

  @override
  State<ClassScheduleSelector> createState() => _ClassScheduleSelectorState();
}

class _ClassScheduleSelectorState extends State<ClassScheduleSelector> {
  final List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> fullDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  
  List<bool> selectedDays = List.generate(7, (_) => false);
  Map<int, TimeRange> timeRanges = {};
  Map<int, String?> selectedStaff = {};

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
    _initializeFromSchedules();
  }

  void _initializeFromSchedules() {
    if (widget.initialSchedules != null) {
      for (var schedule in widget.initialSchedules!) {
        final day = schedule['day'];
        final from = schedule['from'];
        final to = schedule['to'];
        
        if (day != null && from != null && to != null) {
          final dayIndex = fullDays.indexWhere(
            (d) => d.toLowerCase() == day.toLowerCase()
          );
          
          if (dayIndex != -1) {
            try {
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
    try {
      return parseUtcTimeFormatToLocal(timeStr);
    } catch (e) {
      return _parseTimeString(timeStr);
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final cleanTimeStr = timeStr.replaceAll(' ', '').toLowerCase();
    
    try {
      return parseTime(cleanTimeStr);
    } catch (e) {
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

  void _updateSchedule() {
    final List<Map<String, dynamic>> schedules = [];

    for (int index = 0; index < 7; index++) {
      if (selectedDays[index] && timeRanges[index] != null) {
        final range = timeRanges[index]!;
        schedules.add({
          "day": fullDays[index].toLowerCase(),
          "startTime": timeOfDayToUtcFormatWithTimezone(range.start),
          "endTime": timeOfDayToUtcFormatWithTimezone(range.end),
          "staffId": selectedStaff[index],
        });
      }
    }

    widget.onScheduleUpdate(schedules);
  }

  // Convert staff members to the format expected by your DropDown component
  List<Map<String, dynamic>> _getStaffDropdownItems() {
    return widget.staffMembers.map((staff) => {
      'id': staff['id'].toString(),
      'name': staff['name'] ?? '',
    }).toList();
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
        // Day selector
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
                        selectedStaff.remove(index);
                      }
                      _updateSchedule();
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
        
        // Schedule details for selected days
        ...List.generate(7, (index) {
          if (!selectedDays[index]) return const SizedBox.shrink();
          
          final time = timeRanges[index];
          
          return Column(
            children: [
              // Day name and time pickers row
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
                            _updateSchedule();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('to'),
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
                            _updateSchedule();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Staff dropdown (full width row) - Using your custom DropDown component
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: DropDown(
                  items: _getStaffDropdownItems(),
                  hintText: 'Select staff',
                  onChanged: (selectedStaffItem) {
                    setState(() {
                      selectedStaff[index] = selectedStaffItem['id'];
                      _updateSchedule();
                    });
                  },
                ),
              ),
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