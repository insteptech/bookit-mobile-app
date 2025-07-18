import 'package:flutter/material.dart';

TimeOfDay parseTime(String timeStr) {
  final match = RegExp(r'^(\d+):(\d+)(am|pm)$').firstMatch(timeStr)!;
  int hour = int.parse(match[1]!);
  int minute = int.parse(match[2]!);
  final period = match[3]!;

  if (period == 'pm' && hour != 12) hour += 12;
  if (period == 'am' && hour == 12) hour = 0;

  return TimeOfDay(hour: hour, minute: minute);
}

double toDouble(TimeOfDay t) => t.hour + t.minute / 60.0;

bool isValidRange(TimeOfDay start, TimeOfDay end) {
  return toDouble(end) > toDouble(start);
}

List<String> filteredEndTimes(TimeOfDay start, List<String> allTimeOptions) {
  final startDouble = toDouble(start);
  return allTimeOptions.where((t) {
    final parsed = parseTime(t);
    return toDouble(parsed) > startDouble;
  }).toList();
}

/// Converts TimeOfDay to UTC time format (HH:mm:ss) that backend expects
/// Example: TimeOfDay(hour: 9, minute: 30) -> "09:30:00"
String timeOfDayToUtcFormat(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
}

/// Parses UTC time format (HH:mm:ss) to TimeOfDay
/// Example: "09:30:00" -> TimeOfDay(hour: 9, minute: 30)
TimeOfDay parseUtcTimeFormat(String utcTimeStr) {
  final parts = utcTimeStr.split(':');
  if (parts.length < 2) {
    throw Exception('Invalid UTC time format: $utcTimeStr');
  }
  
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  
  // Validate time ranges
  if (hour < 0 || hour > 23) {
    throw Exception('Invalid hour in UTC time format: $utcTimeStr (hour must be 0-23)');
  }
  if (minute < 0 || minute > 59) {
    throw Exception('Invalid minute in UTC time format: $utcTimeStr (minute must be 0-59)');
  }
  
  return TimeOfDay(hour: hour, minute: minute);
}

/// Converts local TimeOfDay to UTC format considering timezone offset
/// This is for when we need to send local time as UTC to backend
String timeOfDayToUtcFormatWithTimezone(TimeOfDay localTime) {
  // Create a DateTime with today's date and the given time
  final now = DateTime.now();
  final localDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    localTime.hour,
    localTime.minute,
  );
  
  // Convert to UTC
  final utcDateTime = localDateTime.toUtc();
  
  return '${utcDateTime.hour.toString().padLeft(2, '0')}:${utcDateTime.minute.toString().padLeft(2, '0')}:00';
}

/// Converts UTC time format to local TimeOfDay considering timezone offset
/// This is for when we receive UTC time from backend and need to display locally
TimeOfDay parseUtcTimeFormatToLocal(String utcTimeStr) {
  final parts = utcTimeStr.split(':');
  if (parts.length < 2) {
    throw Exception('Invalid UTC time format: $utcTimeStr');
  }
  
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  
  // Create a UTC DateTime with today's date and the given time
  final now = DateTime.now().toUtc();
  final utcDateTime = DateTime.utc(
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  
  // Convert to local time
  final localDateTime = utcDateTime.toLocal();
  
  return TimeOfDay(hour: localDateTime.hour, minute: localDateTime.minute);
}

/// Formats TimeOfDay to display format (12-hour with AM/PM)
/// Example: TimeOfDay(hour: 14, minute: 30) -> "2:30 PM"
String formatTimeOfDayForDisplay(TimeOfDay time) {
  final period = time.hour < 12 ? 'AM' : 'PM';
  int displayHour = time.hour % 12;
  if (displayHour == 0) displayHour = 12;
  
  if (time.minute == 0) {
    return '$displayHour $period';
  } else {
    return '$displayHour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
