/// Represents a daily class schedule entry.
/// 
/// Time Format:
/// - Contains time in UTC format (HH:mm:ss) for backend compatibility
/// - UI conversion is handled automatically by ClassScheduleSelector widget
class DailyClassSchedule {
  String day;
  String startTime; // UTC format (HH:mm:ss)
  String endTime;   // UTC format (HH:mm:ss)
  String? staffId;

  DailyClassSchedule({
    required this.day,
    required this.startTime,
    required this.endTime,
    this.staffId,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'staff_id': staffId,
    };
  }
}

/// Controller for managing class schedules with staff assignments.
/// 
/// Time Handling:
/// - Stores time in UTC format (HH:mm:ss) for backend compatibility
/// - UI components handle conversion between local display and UTC storage
class ClassScheduleController {
  List<DailyClassSchedule> schedules = [];

  /// Updates the schedule for a specific day.
  /// 
  /// [daySchedules] should contain time in UTC format from the UI component.
  /// Format: [{"day": "monday", "from": "09:00:00", "to": "17:00:00"}]
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
        ));
      }
    }
  }

  /// Updates staff assignment for a specific day.
  void updateStaffForDay(String day, String? staffId) {
    final schedule = schedules.firstWhere(
      (s) => s.day.toLowerCase() == day.toLowerCase(),
      orElse: () => throw Exception('Schedule not found for day: $day'),
    );
    schedule.staffId = staffId;
  }

  /// Gets the current day schedules in the format expected by ClassScheduleSelector.
  /// Returns time in UTC format for backend compatibility.
  List<Map<String, String>> get daySchedules {
    return schedules.map((schedule) {
      return {
        'day': schedule.day,
        'from': schedule.startTime,
        'to': schedule.endTime,
      };
    }).toList();
  }

  /// Builds the final payload for backend submission.
  /// 
  /// Returns schedules with time values in UTC format (HH:mm:ss) as required by backend.
  /// Example payload structure:
  /// ```json
  /// {
  ///   "schedules": [
  ///     {
  ///       "day": "monday",
  ///       "start_time": "09:00:00",  // UTC format
  ///       "end_time": "17:00:00",    // UTC format
  ///       "staff_id": "123"
  ///     }
  ///   ]
  /// }
  /// ```
  Map<String, dynamic> buildFinalPayload() {
    return {
      "schedules": schedules.map((schedule) => schedule.toJson()).toList(),
    };
  }

  /// Removes schedule for a specific day.
  void removeScheduleForDay(String day) {
    schedules.removeWhere(
      (schedule) => schedule.day.toLowerCase() == day.toLowerCase(),
    );
  }

  /// Gets staff ID for a specific day.
  String? getStaffForDay(String day) {
    try {
      final schedule = schedules.firstWhere(
        (s) => s.day.toLowerCase() == day.toLowerCase(),
      );
      return schedule.staffId;
    } catch (e) {
      return null;
    }
  }

  /// Clears all schedules.
  void clear() {
    schedules.clear();
  }
}