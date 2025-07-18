/// Represents a staff schedule entry for a specific location.
/// 
/// Time Format:
/// - daySchedules contains time in UTC format (HH:mm:ss) for backend compatibility
/// - UI conversion is handled automatically by ScheduleSelector widget
class LocationScheduleEntry {
  String? locationId;
  Set<String> selectedServices = {};
  
  /// List of daily schedules with UTC time format.
  /// Each entry contains: {"day": "monday", "from": "09:00:00", "to": "17:00:00"}
  List<Map<String, String>> daySchedules = [];
  bool isAvailable;

  LocationScheduleEntry({this.locationId, this.isAvailable = true});
}

class StaffScheduleController {
  List<LocationScheduleEntry> entries = [];

  void addNewEntry() {
    entries.add(LocationScheduleEntry());
  }

  void updateLocation(int index, String id) {
    entries[index].locationId = id;
  }

  void toggleService(int index, String serviceId) {
    final services = entries[index].selectedServices;
    if (services.contains(serviceId)) {
      services.remove(serviceId);
    } else {
      services.add(serviceId);
    }
  }

  void updateDaySchedule(int index, List<Map<String, String>> schedule) {
    entries[index].daySchedules = schedule;
  }

  void updateAvailability(int index, bool value) {
    entries[index].isAvailable = value;
  }

  /// Builds the final payload for backend submission.
  /// 
  /// Returns a payload with time values in UTC format (HH:mm:ss) as required by backend.
  /// Example payload structure:
  /// ```json
  /// {
  ///   "locations": [
  ///     {
  ///       "id": "1",
  ///       "is_available": true,
  ///       "services": ["service1", "service2"],
  ///       "days_schedule": [
  ///         {
  ///           "day": "monday",
  ///           "from": "09:00:00",  // UTC format
  ///           "to": "17:00:00"     // UTC format
  ///         }
  ///       ]
  ///     }
  ///   ]
  /// }
  /// ```
  Map<String, dynamic> buildFinalPayload() {
    return {
      "locations":
          entries.map((entry) {
            return {
              "id": entry.locationId,
              "is_available": entry.isAvailable,
              "services": entry.selectedServices.toList(),
              "days_schedule": entry.daySchedules,
            };
          }).toList(),
    };
  }

  void removeEntry(int index) {
    if (index >= 0 && index < entries.length) {
      entries.removeAt(index);
    }
  }

  List<Map<String, String>> getAvailableLocations(
    int currentIndex,
    List<Map<String, String>> allLocations,
  ) {
    // Collect selected location IDs from all other entries
    final usedLocationIds =
        entries
            .asMap()
            .entries
            .where(
              (entry) =>
                  entry.key != currentIndex && entry.value.locationId != null,
            )
            .map((entry) => entry.value.locationId!)
            .toSet();

    // Filter out used locations
    return allLocations
        .where((loc) => !usedLocationIds.contains(loc['id']))
        .toList();
  }
}
