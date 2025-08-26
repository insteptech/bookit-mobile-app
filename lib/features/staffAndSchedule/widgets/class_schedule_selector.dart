import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/utils/time_utils.dart';
import 'package:bookit_mobile_app/shared/components/organisms/drop_down.dart';
import 'package:flutter/material.dart';
import 'dropdown_time_picker.dart';

/// Represents a daily class schedule entry with multiple instructors support.
class DailyClassSchedule {
  String? id; // Can be null for new schedules
  String day;
  String startTime; // UTC format (HH:mm:ss)
  String endTime;   // UTC format (HH:mm:ss)
  List<String> instructors; // Support multiple instructors

  DailyClassSchedule({
    this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    List<String>? instructors,
  }) : instructors = instructors ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '', // Empty string for new schedules, actual ID for existing ones
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
      final id = schedule['id']; // Get ID if it exists
      
      if (day != null && from != null && to != null) {
        schedules.add(DailyClassSchedule(
          id: id, // Will be null for new schedules
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

  /// Updates staff assignments for multiple days at once, preserving existing assignments for other days.
  void updateStaffForDays(Map<String, List<String>> staffAssignments) {
    for (var entry in staffAssignments.entries) {
      updateStaffForDay(entry.key, entry.value);
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
    final locationSchedule = <String, dynamic>{
      'location_id': locationId,
      'schedule': schedules.map((schedule) => schedule.toJson()).toList(),
    };
    
    // Only include pricing fields if they have values (truly optional)
    if (price != null) {
      locationSchedule['price'] = price;
    }
    if (packageAmount != null) {
      locationSchedule['package_amount'] = packageAmount;
    }
    if (packagePerson != null) {
      locationSchedule['package_person'] = packagePerson;
    }
    
    return {
      'business_id': businessId,
      'class_id': classId,
      'location_schedules': [locationSchedule]
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
  final int? classDurationMinutes; // Duration of the class in minutes

  const ClassScheduleSelector({
    Key? key,
    required this.staffMembers,
    required this.onScheduleUpdate,
    this.initialSchedules,
    this.enableMultipleStaff = false, // Default to single staff for now
    this.classDurationMinutes,
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
  Map<int, String?> scheduleIdsPerDay = {}; // Track schedule IDs for existing schedules

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
                
                // Initialize staff selection from initial schedules
                final staffId = schedule['staffId'];
                final instructorIds = schedule['instructor_ids'];
                
                if (staffId != null && staffId.toString().isNotEmpty) {
                  selectedStaffPerDay[dayIndex] = [staffId.toString()];
                } else if (instructorIds != null && instructorIds.toString().isNotEmpty) {
                  selectedStaffPerDay[dayIndex] = instructorIds.toString().split(',').where((id) => id.isNotEmpty).toList();
                }
              });
            } catch (e) {
              // Skip invalid time format
            }
          }
        }
      }
    }
  }

  // Add this method to ClassScheduleSelectorState class
void initializeWithExistingData(List<Map<String, String>> schedules, List<dynamic> originalSchedules) {

  
  // Clear existing state
  selectedDays = List.generate(7, (_) => false);
  timeRanges.clear();
  selectedStaffPerDay.clear();
  scheduleIdsPerDay.clear();
  
  
  for (int i = 0; i < schedules.length && i < originalSchedules.length; i++) {
    final schedule = schedules[i];
    final originalSchedule = originalSchedules[i];
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
            
            // Track schedule ID for this day
            scheduleIdsPerDay[dayIndex] = schedule['id'];
            
            // Set instructors - extract IDs from instructor objects
            if (originalSchedule['instructors'] != null) {
              final instructors = originalSchedule['instructors'] as List<dynamic>;
              final instructorIds = <String>[];
              
              for (var instructor in instructors) {
                if (instructor is Map<String, dynamic> && instructor['id'] != null) {
                  instructorIds.add(instructor['id'].toString());
                } else if (instructor is String) {
                  instructorIds.add(instructor);
                }
              }
              
              selectedStaffPerDay[dayIndex] = instructorIds;
            }
          });
        } catch (e) {
          debugPrint('Error parsing existing schedule: $e');
        }
      }
    }
  }
  
  // IMPORTANT: Initialize the controller with all the existing schedules
  // so they are preserved when new schedules are added
  final allExistingSchedules = <Map<String, String>>[];
  for (int i = 0; i < schedules.length; i++) {
    final schedule = schedules[i];
    if (schedule['day'] != null && schedule['from'] != null && schedule['to'] != null) {
      allExistingSchedules.add({
        'id': schedule['id'] ?? '',
        'day': schedule['day']!.toLowerCase(),
        'from': schedule['from']!,
        'to': schedule['to']!,
      });
    }
  }
  
  // Initialize controller with existing schedules
  _scheduleController.updateDaySchedule(allExistingSchedules);
  
  // Set staff assignments for existing schedules
  for (int i = 0; i < originalSchedules.length; i++) {
    final originalSchedule = originalSchedules[i];
    final day = schedules[i]['day'];
    
    if (day != null && originalSchedule['instructors'] != null) {
      final instructors = originalSchedule['instructors'] as List<dynamic>;
      final instructorIds = <String>[];
      
      for (var instructor in instructors) {
        if (instructor is Map<String, dynamic> && instructor['id'] != null) {
          instructorIds.add(instructor['id'].toString());
        } else if (instructor is String) {
          instructorIds.add(instructor);
        }
      }
      
      _scheduleController.updateStaffForDay(day.toLowerCase(), instructorIds);
    }
  }
}

// Add method to clear all schedule data
void clearAll() {
  setState(() {
    selectedDays = List.generate(7, (_) => false);
    timeRanges.clear();
    selectedStaffPerDay.clear();
    scheduleIdsPerDay.clear();
    _scheduleController.clear();
  });
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

  /// Calculates end time by adding class duration to start time
  TimeOfDay? _calculateEndTime(TimeOfDay startTime) {
    if (widget.classDurationMinutes == null) return null;
    
    final totalMinutes = startTime.hour * 60 + startTime.minute + widget.classDurationMinutes!;
    final endHour = (totalMinutes ~/ 60) % 24; // Handle overflow past midnight
    final endMinute = totalMinutes % 60;
    
    
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  /// Calculates start time by subtracting class duration from end time
  TimeOfDay? _calculateStartTime(TimeOfDay endTime) {
    if (widget.classDurationMinutes == null) return null;
    
    final totalMinutes = endTime.hour * 60 + endTime.minute - widget.classDurationMinutes!;
    
    // Handle negative time (previous day)
    if (totalMinutes < 0) {
      final adjustedMinutes = totalMinutes + (24 * 60); // Add 24 hours
      final startHour = (adjustedMinutes ~/ 60) % 24;
      final startMinute = adjustedMinutes % 60;
      final calculatedStartTime = TimeOfDay(hour: startHour, minute: startMinute);
      
      return calculatedStartTime;
    }
    
    final startHour = totalMinutes ~/ 60;
    final startMinute = totalMinutes % 60;
    final calculatedStartTime = TimeOfDay(hour: startHour, minute: startMinute);
    
    
    return calculatedStartTime;
  }

  void _updateSchedule() {
    // Collect ALL schedules: existing ones from controller + current UI state
    final List<Map<String, String>> allSchedules = [];
    
    // First, add existing schedules that are not currently being modified in the UI
    for (var existingSchedule in _scheduleController.schedules) {
      final dayIndex = fullDays.indexWhere(
        (d) => d.toLowerCase() == existingSchedule.day.toLowerCase()
      );
      
      // Only keep existing schedule if it's not currently selected in UI
      // (if it's selected, we'll add the updated version from UI state below)
      if (dayIndex == -1 || !selectedDays[dayIndex]) {
        allSchedules.add({
          "id": existingSchedule.id ?? '',
          "day": existingSchedule.day.toLowerCase(),
          "from": existingSchedule.startTime,
          "to": existingSchedule.endTime,
        });
      }
    }
    
    // Then, add schedules from current UI state (selected days)
    for (int index = 0; index < 7; index++) {
      if (selectedDays[index] && timeRanges[index] != null) {
        final range = timeRanges[index]!;
        allSchedules.add({
          "id": scheduleIdsPerDay[index] ?? '', // Include existing schedule ID or empty string for new
          "day": fullDays[index].toLowerCase(),
          "from": timeOfDayToUtcFormatWithTimezone(range.start),
          "to": timeOfDayToUtcFormatWithTimezone(range.end),
        });
      }
    }

    // Update controller with ALL schedules (existing + new/modified)
    _scheduleController.updateDaySchedule(allSchedules);

    // Update staff assignments for currently selected days
    for (int index = 0; index < 7; index++) {
      if (selectedDays[index] && selectedStaffPerDay[index] != null) {
        final dayName = fullDays[index].toLowerCase();
        final staffIds = selectedStaffPerDay[index]!;
        _scheduleController.updateStaffForDay(dayName, staffIds);
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
        // Text('Select instructors for ${fullDays[dayIndex]}:'),
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
        final foundStaff = widget.staffMembers.firstWhere(
          (staff) => staff['id']?.toString() == selectedStaffId,
        );
        // Convert to dropdown format
        selectedStaffItem = {
          'id': foundStaff['id'].toString(),
          'name': foundStaff['name'] ?? '',
        };
      } catch (e) {
        debugPrint("Selected staff not found in current staff list: $selectedStaffId");
        debugPrint("Available staff: ${widget.staffMembers.map((s) => '${s['id']}: ${s['name']}').toList()}");
      }
    }
    
    // debugPrint("Day $dayIndex staff selection - selectedStaffId: $selectedStaffId, selectedStaffItem: $selectedStaffItem");
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text('Select instructor for ${fullDays[dayIndex]}:'),
        // const SizedBox(height: 8),
        DropDown(
          key: ValueKey('staff_dropdown_${dayIndex}_${selectedStaffId ?? 'none'}'),
          items: _getStaffDropdownItems(),
          hintText: 'Select staff',
          initialSelectedItem: selectedStaffItem,
          onChanged: (selectedStaffItem) {
            // debugPrint("Staff selected for day $dayIndex: $selectedStaffItem");
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule',
                style: AppTypography.headingSm,
              ),
              if (widget.classDurationMinutes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Class duration: ${widget.classDurationMinutes} minutes',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
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
                            TimeOfDay endTime;
                            
                            // If we have class duration, calculate end time automatically
                            final calculatedEndTime = _calculateEndTime(parsed);
                            if (calculatedEndTime != null) {
                              endTime = calculatedEndTime;
                            } else {
                              // Fallback to existing logic if no duration
                              final currentEnd = timeRanges[index]?.end;
                              if (currentEnd != null && isValidRange(parsed, currentEnd)) {
                                endTime = currentEnd;
                              } else {
                                endTime = parsed;
                              }
                            }
                            
                            timeRanges[index] = TimeRange(
                              start: parsed,
                              end: endTime,
                            );
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
                            TimeOfDay startTime;
                            
                            // If we have class duration, calculate start time automatically
                            final calculatedStartTime = _calculateStartTime(parsed);
                            if (calculatedStartTime != null) {
                              startTime = calculatedStartTime;
                            } else {
                              // Fallback to existing logic if no duration
                              startTime = timeRanges[index]?.start ?? parsed;
                            }
                            
                            timeRanges[index] = TimeRange(
                              start: startTime,
                              end: parsed,
                            );
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