/// Represents a single staff schedule containing availability, services, classes, and day schedules.
/// 
/// Time Format:
/// - daySchedules contains time in UTC format (HH:mm:ss) for backend compatibility
/// - UI conversion is handled automatically by ScheduleSelector widget
class StaffSchedule {
  Set<String> selectedServices = {};
  /// List of daily schedules with UTC time format.
  /// Each entry contains: {"day": "monday", "from": "09:00:00", "to": "17:00:00"}
  List<Map<String, String>> daySchedules = [];
  bool isAvailable;

  StaffSchedule({this.isAvailable = true});
}

class StaffScheduleController {
  StaffSchedule schedule = StaffSchedule();

  void toggleService(String serviceId) {
    final services = schedule.selectedServices;
    if (services.contains(serviceId)) {
      services.remove(serviceId);
    } else {
      services.add(serviceId);
    }
  }

  void updateDaySchedule(List<Map<String, String>> daySchedule) {
    schedule.daySchedules = daySchedule;
  }

  void updateAvailability(bool value) {
    schedule.isAvailable = value;
  }

  /// Builds the final payload for backend submission.
  Map<String, dynamic> buildFinalPayload() {
    return {
      "is_available": schedule.isAvailable,
      "services": schedule.selectedServices.toList(),
      "days_schedule": schedule.daySchedules,
    };
  }

  Map<String, dynamic> getSchedulePayload() {
    return {
      "is_available": schedule.isAvailable,
      "services": schedule.selectedServices.toList(),
      "days_schedule": schedule.daySchedules,
    };
  }

  bool isValid(){
    return schedule.selectedServices.isNotEmpty &&
        schedule.daySchedules.isNotEmpty;
  }
}
