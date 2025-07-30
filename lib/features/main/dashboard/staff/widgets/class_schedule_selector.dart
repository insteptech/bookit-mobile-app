import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/utils/time_utils.dart';
import 'package:bookit_mobile_app/shared/components/organisms/drop_down.dart';
import 'package:flutter/material.dart';
import 'dropdown_time_picker.dart';

/// Represents a daily class schedule entry with multiple instructors support.
class DailyClassSchedule {
  String day;
  String startTime; // UTC format (HH:mm:ss)
  String endTime;   // UTC format (HH:mm:ss)
  List<String> instructors; // Support multiple instructors

  DailyClassSchedule({
    required this.day,
    required this.startTime,
    required this.endTime,
    List<String>? instructors,
  }) : instructors = instructors ?? [];

  Map<String, dynamic> toJson() {
    return {
      'day': day[0].toUpperCase() + day.substring(1), // Capitalize first letter
      'start_time': startTime.length > 5 ? startTime.substring(0, 5) : startTime, // Remove seconds if present
      'end_time': endTime.length > 5 ? endTime.substring(0, 5) : endTime,
      'instructors': instructors,
    };
  }

  // For backward compatibility with the old format
  Map<String, dynamic> toLegacyJson() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'staffId': instructors.isNotEmpty ? instructors.first : null,
    };
  }
}

/// Controller for managing class schedules with multiple staff assignments.
class ClassScheduleController {
  List<DailyClassSchedule> schedules = [];

  /// Updates the schedule for a specific day.
  void updateDaySchedule(List<Map<String, String>> daySchedules) {
    // Clear existing schedules
    schedules.clear();
    
    // Add new schedules from daySchedules
    for (var schedule in daySchedules) {
      final day = schedule['day'];
      final from = schedule['from'];
      final to = schedule['to'];
      
      if (day != null && from != null && to != null) {
        schedules.add(DailyClassSchedule(
          day: day,
          startTime: from,
          endTime: to,
          instructors: [], // Empty initially, will be populated later
        ));
      }
    }
  }

  

  /// Updates staff assignment for a specific day - supports multiple staff.
  void updateStaffForDay(String day, List<String> staffIds) {
    try {
      final schedule = schedules.firstWhere(
        (s) => s.day.toLowerCase() == day.toLowerCase(),
      );
      schedule.instructors = List.from(staffIds);
    } catch (e) {
      // Schedule not found, ignore
    }
  }

  /// Adds a single staff member to a specific day.
  void addStaffToDay(String day, String staffId) {
    try {
      final schedule = schedules.firstWhere(
        (s) => s.day.toLowerCase() == day.toLowerCase(),
      );
      if (!schedule.instructors.contains(staffId)) {
        schedule.instructors.add(staffId);
      }
    } catch (e) {
      // Schedule not found, ignore
    }
  }

  /// Removes a staff member from a specific day.
  void removeStaffFromDay(String day, String staffId) {
    try {
      final schedule = schedules.firstWhere(
        (s) => s.day.toLowerCase() == day.toLowerCase(),
      );
      schedule.instructors.remove(staffId);
    } catch (e) {
      // Schedule not found, ignore
    }
  }

  /// Builds the final payload for backend submission in the correct format.
  Map<String, dynamic> buildBackendPayload({
    required String businessId,
    required String classId,
    required String locationId,
    double? price,
    double? packageAmount,
    int? packagePerson,
  }) {
    return {
      'business_id': businessId,
      'class_id': classId,
      'location_schedules': [
        {
          'location_id': locationId,
          'price': price ?? 400,
          'package_amount': packageAmount ?? 3000,
          'package_person': packagePerson ?? 10,
          'schedule': schedules.map((schedule) => schedule.toJson()).toList(),
        }
      ]
    };
  }

  /// Gets schedules in legacy format for backward compatibility.
  List<Map<String, dynamic>> getLegacyFormat() {
    return schedules.map((schedule) => schedule.toLegacyJson()).toList();
  }

  /// Gets staff IDs for a specific day.
  List<String> getStaffForDay(String day) {
    try {
      final schedule = schedules.firstWhere(
        (s) => s.day.toLowerCase() == day.toLowerCase(),
      );
      return List.from(schedule.instructors);
    } catch (e) {
      return [];
    }
  }

  /// Checks if all schedules have at least one instructor assigned.
  bool get isValid {
    return schedules.isNotEmpty && 
           schedules.every((schedule) => schedule.instructors.isNotEmpty);
  }

  /// Clears all schedules.
  void clear() {
    schedules.clear();
  }
}

/// Schedule selector widget that handles time input and staff assignment for class schedules.
/// 
/// Time Handling:
/// - UI displays time in local format (12-hour with AM/PM)
/// - Converts local time to actual UTC time before sending to backend
/// - Backend communication uses UTC format (24-hour HH:mm:ss)
/// - When receiving data from backend, converts UTC time back to local for display
class ClassScheduleSelector extends StatefulWidget {
  final List<Map<String, dynamic>> staffMembers;
  final Function(List<Map<String, dynamic>>) onScheduleUpdate; // Keep legacy callback for now
  final List<Map<String, String>>? initialSchedules;
  final bool enableMultipleStaff; // Feature flag for multiple staff support

  const ClassScheduleSelector({
    Key? key,
    required this.staffMembers,
    required this.onScheduleUpdate,
    this.initialSchedules,
    this.enableMultipleStaff = false, // Default to single staff for now
  }) : super(key: key);

  @override
  State<ClassScheduleSelector> createState() => ClassScheduleSelectorState();
}

class ClassScheduleSelectorState extends State<ClassScheduleSelector> {
  late ClassScheduleController _scheduleController;
  
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
  Map<int, List<String>> selectedStaffPerDay = {}; // Support multiple staff per day

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
    _scheduleController = ClassScheduleController();
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

  // Add this method to ClassScheduleSelectorState class
void initializeWithExistingData(List<Map<String, String>> schedules, List<dynamic> originalSchedules) {
  debugPrint("Initializing ClassScheduleSelector with existing data:");
  debugPrint("Schedules: $schedules");
  debugPrint("Original schedules: $originalSchedules");
  
  // Clear existing state
  selectedDays = List.generate(7, (_) => false);
  timeRanges.clear();
  selectedStaffPerDay.clear();
  
  for (int i = 0; i < schedules.length && i < originalSchedules.length; i++) {
    final schedule = schedules[i];
    final originalSchedule = originalSchedules[i];
    final day = schedule['day'];
    final from = schedule['from'];
    final to = schedule['to'];
    
    debugPrint("Processing schedule $i: day=$day, from=$from, to=$to");
    
    if (day != null && from != null && to != null) {
      final dayIndex = fullDays.indexWhere(
        (d) => d.toLowerCase() == day.toLowerCase()
      );
      
      debugPrint("Day index for $day: $dayIndex");
      
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
            
            // Set instructors - this is the key part that was missing
            if (originalSchedule['instructors'] != null) {
              final instructors = originalSchedule['instructors'] as List<dynamic>;
              selectedStaffPerDay[dayIndex] = instructors.map((e) => e.toString()).toList();
              debugPrint("Set staff for day $day (index $dayIndex): ${selectedStaffPerDay[dayIndex]}");
            }
          });
        } catch (e) {
          debugPrint('Error parsing existing schedule: $e');
        }
      }
    }
  }
  
  // Update the controller with the loaded data
  _updateSchedule();
  debugPrint("Finished initializing with existing data");
  debugPrint("Selected staff per day: $selectedStaffPerDay");
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
    // Update the internal controller with current UI state
    final List<Map<String, String>> daySchedules = [];

    for (int index = 0; index < 7; index++) {
      if (selectedDays[index] && timeRanges[index] != null) {
        final range = timeRanges[index]!;
        daySchedules.add({
          "day": fullDays[index].toLowerCase(),
          "from": timeOfDayToUtcFormatWithTimezone(range.start),
          "to": timeOfDayToUtcFormatWithTimezone(range.end),
        });
      }
    }

    // Update controller with day schedules
    _scheduleController.updateDaySchedule(daySchedules);

    // Update staff assignments
    for (int index = 0; index < 7; index++) {
      if (selectedDays[index] && selectedStaffPerDay[index] != null) {
        _scheduleController.updateStaffForDay(
          fullDays[index].toLowerCase(),
          selectedStaffPerDay[index]!,
        );
      }
    }

    // For backward compatibility, also send the legacy format
    final legacyFormat = _scheduleController.getLegacyFormat();
    widget.onScheduleUpdate(legacyFormat);
  }

  // Convert staff members to the format expected by your DropDown component
  List<Map<String, dynamic>> _getStaffDropdownItems() {
    return widget.staffMembers.map((staff) => {
      'id': staff['id'].toString(),
      'name': staff['name'] ?? '',
    }).toList();
  }

  Widget _buildStaffSelection(int dayIndex) {
  if (widget.enableMultipleStaff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select instructors for ${fullDays[dayIndex]}:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.staffMembers.map((staff) {
            final staffId = staff['id']?.toString() ?? '';
            final staffName = staff['name']?.toString() ?? 'Unknown';
            final isSelected = selectedStaffPerDay[dayIndex]?.contains(staffId) ?? false;
            
            return FilterChip(
              label: Text(staffName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedStaffPerDay[dayIndex] ??= [];
                  if (selected) {
                    selectedStaffPerDay[dayIndex]!.add(staffId);
                  } else {
                    selectedStaffPerDay[dayIndex]!.remove(staffId);
                  }
                  _updateSchedule();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  } else {
    // Single select - show selected staff
    final selectedStaffIds = selectedStaffPerDay[dayIndex] ?? [];
    final selectedStaffId = selectedStaffIds.isNotEmpty ? selectedStaffIds.first : null;
    
    // Find the selected staff item
    Map<String, dynamic>? selectedStaffItem;
    if (selectedStaffId != null) {
      try {
        selectedStaffItem = widget.staffMembers.firstWhere(
          (staff) => staff['id']?.toString() == selectedStaffId,
        );
      } catch (e) {
        debugPrint("Selected staff not found in current staff list: $selectedStaffId");
      }
    }
    
    debugPrint("Day $dayIndex staff selection - selectedStaffId: $selectedStaffId, selectedStaffItem: $selectedStaffItem");
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select instructor for ${fullDays[dayIndex]}:'),
        const SizedBox(height: 8),
        DropDown(
          items: _getStaffDropdownItems(),
          hintText: selectedStaffItem != null ? selectedStaffItem['name'] : 'Select staff',
          onChanged: (selectedStaffItem) {
            debugPrint("Staff selected for day $dayIndex: $selectedStaffItem");
            setState(() {
              final staffId = selectedStaffItem['id'];
              selectedStaffPerDay[dayIndex] = staffId != null ? [staffId] : [];
              _updateSchedule();
            });
          },
        ),
      ],
    );
  }
}

  // Expose the controller for parent widgets that want to use the new format
  ClassScheduleController get controller => _scheduleController;
  
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
                        selectedStaffPerDay.remove(index);
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
                            _updateSchedule();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Staff selection (single or multiple based on feature flag)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: _buildStaffSelection(index),
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