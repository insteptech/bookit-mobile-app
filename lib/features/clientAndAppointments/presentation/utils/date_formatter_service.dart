import 'package:intl/intl.dart';

class DateFormatterService {
  /// Formats a DateTime to user-friendly time format (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Formats a DateTime to user-friendly date format (e.g., "Monday, January 15, 2024")
  static String formatDate(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
  }

  /// Formats a DateTime to short date format (e.g., "Jan 15, 2024")
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Formats a DateTime to a combined date and time format
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
  }

  /// Safely parses a date string and converts to local time
  static DateTime? parseAndConvertToLocal(String? dateString) {
    try {
      if (dateString == null || dateString.isEmpty) return null;
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      return null;
    }
  }

  /// Formats appointment summary with error handling
  static String formatAppointmentSummary({
    required String? dateString,
    required dynamic duration,
    required String? serviceName,
    required String? practitionerName,
    String fallbackMessage = "Could not load appointment details",
  }) {
    try {
      final startTime = parseAndConvertToLocal(dateString);
      if (startTime == null) return fallbackMessage;
      
      final formattedTime = formatTime(startTime);
      final formattedDate = formatDate(startTime);

      return "$duration min - $serviceName at [$formattedTime] on [$formattedDate] with $practitionerName";
    } catch (e) {
      return fallbackMessage;
    }
  }
}
