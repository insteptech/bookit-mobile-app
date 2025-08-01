// Helper functions for staff and appointment checking

/// Checks if there are any staff members based on appointment data structure
/// The appointments data structure typically contains staff information, 
/// so if appointments array is empty, it usually means no staff are added yet
bool hasStaffMembers(List<Map<String, dynamic>> staffAppointments) {
  return staffAppointments.isNotEmpty;
}

/// Checks if there are appointments for today specifically
bool hasTodaysAppointments(List<Map<String, dynamic>> todaysAppointments) {
  if (todaysAppointments.isEmpty) return false;
  
  // Check if any staff member has appointments for today
  for (var staff in todaysAppointments) {
    final appointments = staff['appointments'] as List<dynamic>? ?? [];
    if (appointments.isNotEmpty) {
      return true;
    }
  }
  return false;
}

/// Checks if there are any appointments at all (regardless of date)
bool hasAnyAppointments(List<Map<String, dynamic>> allStaffAppointments) {
  if (allStaffAppointments.isEmpty) return false;
  
  for (var staff in allStaffAppointments) {
    final appointments = staff['appointments'] as List<dynamic>? ?? [];
    if (appointments.isNotEmpty) {
      return true;
    }
  }
  return false;
}

/// Gets the total count of staff members
int getStaffCount(List<Map<String, dynamic>> staffAppointments) {
  return staffAppointments.length;
}

/// Gets the total count of all appointments across all staff
int getTotalAppointmentCount(List<Map<String, dynamic>> staffAppointments) {
  int total = 0;
  for (var staff in staffAppointments) {
    final appointments = staff['appointments'] as List<dynamic>? ?? [];
    total += appointments.length;
  }
  return total;
}
