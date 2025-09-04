/// Helper service for time-related operations
/// This is a simple utility service that doesn't need full Clean Architecture
class TimeUtilService {
  
  /// Validates and formats UTC time string
  static String validateUtcTimeFormat(String utcTime) {
    try {
      final parts = utcTime.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final second = parts.length > 2 ? int.parse(parts[2]) : 0;
        
        if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59 && second >= 0 && second <= 59) {
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
        }
      }
    } catch (e) {
      // Return original if validation fails
    }
    return utcTime;
  }

  /// Converts UTC time string to local time string
  static String convertUtcTimeToLocalTimeString(String utcTimeString) {
    try {
      final parts = utcTimeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Create a UTC DateTime with today's date and the given time
      final now = DateTime.now().toUtc();
      final utcDateTime = DateTime.utc(now.year, now.month, now.day, hour, minute);
      
      // Convert to local time
      final localDateTime = utcDateTime.toLocal();
      
      return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}:00';
    } catch (e) {
      return utcTimeString; // Fallback to original string
    }
  }

  /// Adds minutes to a time string
  static String addMinutesToTime(String timeString, int minutesToAdd) {
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    final totalMinutes = hours * 60 + minutes + minutesToAdd;
    final newHours = totalMinutes ~/ 60;
    final newMinutes = totalMinutes % 60;

    return '${newHours.toString().padLeft(2, '0')}:${newMinutes.toString().padLeft(2, '0')}:00';
  }

  /// Calculates time difference in minutes
  static int getTimeDifferenceInMinutes(String startTime, String endTime) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    return endMinutes - startMinutes;
  }

  /// Formats ISO date string without milliseconds
  static String formatUtcIsoWithoutMilliseconds(DateTime dt) {
    final iso = dt.toUtc().toIso8601String();
    return iso.substring(0, iso.indexOf('.')) + 'Z';
  }

  /// Formats DateTime to UTC time only (HH:mm:ss)
  static String formatUtcTimeOnly(DateTime dt) {
    final utc = dt.toUtc();
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
