// /// Represents a daily class schedule entry.
// /// 
// /// Time Format:
// /// - Contains time in UTC format (HH:mm:ss) for backend compatibility
// /// - UI conversion is handled automatically by ClassScheduleSelector widget
// class DailyClassSchedule {
//   String day;
//   String startTime; // UTC format (HH:mm:ss)
//   String endTime;   // UTC format (HH:mm:ss)
//   String? staffId;

//   DailyClassSchedule({
//     required this.day,
//     required this.startTime,
//     required this.endTime,
//     this.staffId,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'day': day,
//       'start_time': startTime,
//       'end_time': endTime,
//       'staff_id': staffId,
//     };
//   }
// }

// /// Controller for managing class schedules with staff assignments.
// /// 
// /// Time Handling:
// /// - Stores time in UTC format (HH:mm:ss) for backend compatibility
// /// - UI components handle conversion between local display and UTC storage
// class ClassScheduleController {
//   List<DailyClassSchedule> schedules = [];

//   /// Updates the schedule for a specific day.
//   /// 
//   /// [daySchedules] should contain time in UTC format from the UI component.
//   /// Format: [{"day": "monday", "from": "09:00:00", "to": "17:00:00"}]
//   void updateDaySchedule(List<Map<String, String>> daySchedules) {
//     // Clear existing schedules
//     schedules.clear();
    
//     // Add new schedules from daySchedules
//     for (var schedule in daySchedules) {
//       final day = schedule['day'];
//       final from = schedule['from'];
//       final to = schedule['to'];
      
//       if (day != null && from != null && to != null) {
//         schedules.add(DailyClassSchedule(
//           day: day,
//           startTime: from,
//           endTime: to,
//         ));
//       }
//     }
//   }

//   /// Updates staff assignment for a specific day.
//   void updateStaffForDay(String day, String? staffId) {
//     final schedule = schedules.firstWhere(
//       (s) => s.day.toLowerCase() == day.toLowerCase(),
//       orElse: () => throw Exception('Schedule not found for day: $day'),
//     );
//     schedule.staffId = staffId;
//   }

//   /// Gets the current day schedules in the format expected by ClassScheduleSelector.
//   /// Returns time in UTC format for backend compatibility.
//   List<Map<String, String>> get daySchedules {
//     return schedules.map((schedule) {
//       return {
//         'day': schedule.day,
//         'from': schedule.startTime,
//         'to': schedule.endTime,
//       };
//     }).toList();
//   }

//   /// Builds the final payload for backend submission.
//   /// 
//   /// Returns schedules with time values in UTC format (HH:mm:ss) as required by backend.
//   /// Example payload structure:
//   /// ```json
//   /// {
//   ///   "schedules": [
//   ///     {
//   ///       "day": "monday",
//   ///       "start_time": "09:00:00",  // UTC format
//   ///       "end_time": "17:00:00",    // UTC format
//   ///       "staff_id": "123"
//   ///     }
//   ///   ]
//   /// }
//   /// ```
//   Map<String, dynamic> buildFinalPayload() {
//     return {
//       "schedules": schedules.map((schedule) => schedule.toJson()).toList(),
//     };
//   }

//   /// Removes schedule for a specific day.
//   void removeScheduleForDay(String day) {
//     schedules.removeWhere(
//       (schedule) => schedule.day.toLowerCase() == day.toLowerCase(),
//     );
//   }

//   /// Gets staff ID for a specific day.
//   String? getStaffForDay(String day) {
//     try {
//       final schedule = schedules.firstWhere(
//         (s) => s.day.toLowerCase() == day.toLowerCase(),
//       );
//       return schedule.staffId;
//     } catch (e) {
//       return null;
//     }
//   }

//   /// Clears all schedules.
//   void clear() {
//     schedules.clear();
//   }
// }
/// Represents a daily class schedule entry with multiple instructors support.
// class DailyClassSchedule {
//   String day;
//   String startTime; // UTC format (HH:mm:ss)
//   String endTime;   // UTC format (HH:mm:ss)
//   List<String> instructors; // Support multiple instructors

//   DailyClassSchedule({
//     required this.day,
//     required this.startTime,
//     required this.endTime,
//     List<String>? instructors,
//   }) : instructors = instructors ?? [];

//   Map<String, dynamic> toJson() {
//     return {
//       'day': day[0].toUpperCase() + day.substring(1), // Capitalize first letter
//       'start_time': startTime.length > 5 ? startTime.substring(0, 5) : startTime, // Remove seconds if present
//       'end_time': endTime.length > 5 ? endTime.substring(0, 5) : endTime,
//       'instructors': instructors,
//     };
//   }
// }

// /// Controller for managing class schedules with multiple staff assignments.
// class ClassScheduleController {
//   List<DailyClassSchedule> schedules = [];

//   /// Updates the schedule for a specific day.
//   void updateDaySchedule(List<Map<String, String>> daySchedules) {
//     // Clear existing schedules
//     schedules.clear();
    
//     // Add new schedules from daySchedules
//     for (var schedule in daySchedules) {
//       final day = schedule['day'];
//       final from = schedule['from'];
//       final to = schedule['to'];
      
//       if (day != null && from != null && to != null) {
//         schedules.add(DailyClassSchedule(
//           day: day,
//           startTime: from,
//           endTime: to,
//           instructors: [], // Empty initially, will be populated later
//         ));
//       }
//     }
//   }

//   /// Updates staff assignment for a specific day - supports multiple staff.
//   void updateStaffForDay(String day, List<String> staffIds) {
//     final schedule = schedules.firstWhere(
//       (s) => s.day.toLowerCase() == day.toLowerCase(),
//       orElse: () => throw Exception('Schedule not found for day: $day'),
//     );
//     schedule.instructors = List.from(staffIds);
//   }

//   /// Adds a single staff member to a specific day.
//   void addStaffToDay(String day, String staffId) {
//     final schedule = schedules.firstWhere(
//       (s) => s.day.toLowerCase() == day.toLowerCase(),
//       orElse: () => throw Exception('Schedule not found for day: $day'),
//     );
//     if (!schedule.instructors.contains(staffId)) {
//       schedule.instructors.add(staffId);
//     }
//   }

//   /// Removes a staff member from a specific day.
//   void removeStaffFromDay(String day, String staffId) {
//     final schedule = schedules.firstWhere(
//       (s) => s.day.toLowerCase() == day.toLowerCase(),
//       orElse: () => throw Exception('Schedule not found for day: $day'),
//     );
//     schedule.instructors.remove(staffId);
//   }

//   /// Builds the final payload for backend submission in the correct format.
//   Map<String, dynamic> buildBackendPayload({
//     required String businessId,
//     required String classId,
//     required String locationId,
//     double? price,
//     double? packageAmount,
//     int? packagePerson,
//   }) {
//     return {
//       'business_id': businessId,
//       'class_id': classId,
//       'location_schedules': [
//         {
//           'location_id': locationId,
//           'price': price ?? 400,
//           'package_amount': packageAmount ?? 3000,
//           'package_person': packagePerson ?? 10,
//           'schedule': schedules.map((schedule) => schedule.toJson()).toList(),
//         }
//       ]
//     };
//   }

//   /// Gets staff IDs for a specific day.
//   List<String> getStaffForDay(String day) {
//     try {
//       final schedule = schedules.firstWhere(
//         (s) => s.day.toLowerCase() == day.toLowerCase(),
//       );
//       return List.from(schedule.instructors);
//     } catch (e) {
//       return [];
//     }
//   }

//   /// Checks if all schedules have at least one instructor assigned.
//   bool get isValid {
//     return schedules.isNotEmpty && 
//            schedules.every((schedule) => schedule.instructors.isNotEmpty);
//   }

//   /// Clears all schedules.
//   void clear() {
//     schedules.clear();
//   }
// }

class DailyClassSchedule {
  String? id; // Can be null for new schedules
  String day;
  String startTime;
  String endTime;
  List<String> instructors;

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
      'day': day[0].toUpperCase() + day.substring(1),
      'start_time': startTime.length > 5 ? startTime.substring(0, 5) : startTime,
      'end_time': endTime.length > 5 ? endTime.substring(0, 5) : endTime,
      'instructors': instructors,
    };
  }
}

class ClassScheduleController {
  List<DailyClassSchedule> schedules = [];

  void updateDaySchedule(List<Map<String, String>> daySchedules) {
    schedules.clear();
    
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
          instructors: [],
        ));
      }
    }
  }

  /// Initialize from existing data with instructor IDs
  void initializeFromExistingData(List<Map<String, dynamic>> schedulesWithIds) {
    schedules.clear();
    
    for (var scheduleData in schedulesWithIds) {
      final id = scheduleData['id']?.toString(); // Get schedule ID
      final day = scheduleData['day']?.toString().toLowerCase();
      final startTime = scheduleData['start_time']?.toString();
      final endTime = scheduleData['end_time']?.toString();
      
      // Handle instructor IDs - they might be in different formats
      List<String> instructorIds = [];
      
      if (scheduleData['instructor_ids'] != null) {
        final ids = scheduleData['instructor_ids'];
        if (ids is List) {
          instructorIds = ids.map((id) => id.toString()).toList();
        } else if (ids is String) {
          instructorIds = [ids];
        }
      } else if (scheduleData['instructors'] != null) {
        // Extract IDs from instructor objects
        final instructors = scheduleData['instructors'] as List<dynamic>? ?? [];
        for (var instructor in instructors) {
          if (instructor is Map<String, dynamic> && instructor['id'] != null) {
            instructorIds.add(instructor['id'].toString());
          } else if (instructor is String) {
            instructorIds.add(instructor);
          }
        }
      }
      
      if (day != null && startTime != null && endTime != null) {
        schedules.add(DailyClassSchedule(
          id: id, // Include the schedule ID
          day: day,
          startTime: startTime,
          endTime: endTime,
          instructors: instructorIds,
        ));
      }
    }
    
  }

  void updateStaffForDay(String day, List<String> staffIds) {
    try {
      final schedule = schedules.firstWhere(
        (s) => s.day.toLowerCase() == day.toLowerCase(),
      );
      schedule.instructors = List.from(staffIds);
    } catch (e) {
      print("Schedule not found for day: $day");
    }
  }

  void addStaffToDay(String day, String staffId) {
    try {
      final schedule = schedules.firstWhere(
        (s) => s.day.toLowerCase() == day.toLowerCase(),
      );
      if (!schedule.instructors.contains(staffId)) {
        schedule.instructors.add(staffId);
      }
    } catch (e) {
      print("Schedule not found for day: $day");
    }
  }

  void removeStaffFromDay(String day, String staffId) {
    try {
      final schedule = schedules.firstWhere(
        (s) => s.day.toLowerCase() == day.toLowerCase(),
      );
      schedule.instructors.remove(staffId);
    } catch (e) {
      print("Schedule not found for day: $day");
    }
  }

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

  bool get isValid {
    return schedules.isNotEmpty && 
           schedules.every((schedule) => schedule.instructors.isNotEmpty);
  }

  void clear() {
    schedules.clear();
  }
}