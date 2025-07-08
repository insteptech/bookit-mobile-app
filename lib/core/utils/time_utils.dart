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
