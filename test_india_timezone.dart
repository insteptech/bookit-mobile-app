import 'package:flutter/material.dart';
import 'lib/core/utils/time_utils.dart';

void main() {
  print('=== INDIA TIMEZONE CONVERSION TEST ===');
  print('Current timezone: ${DateTime.now().timeZoneName}');
  print('Current time: ${DateTime.now()}');
  print('');
  
  // Test Monday schedule: 12:00 AM to 1:30 AM (IST)
  print('--- MONDAY SCHEDULE ---');
  final mondayStart = TimeOfDay(hour: 0, minute: 0);   // 12:00 AM IST
  final mondayEnd = TimeOfDay(hour: 1, minute: 30);    // 1:30 AM IST
  
  final mondayStartUtc = timeOfDayToUtcFormatWithTimezone(mondayStart);
  final mondayEndUtc = timeOfDayToUtcFormatWithTimezone(mondayEnd);
  
  print('Local (IST): ${formatTimeOfDayForDisplay(mondayStart)} to ${formatTimeOfDayForDisplay(mondayEnd)}');
  print('Database (UTC): $mondayStartUtc to $mondayEndUtc');
  print('');
  
  // Test Tuesday schedule: 12:00 AM to 3:00 PM (IST)
  print('--- TUESDAY SCHEDULE ---');
  final tuesdayStart = TimeOfDay(hour: 0, minute: 0);   // 12:00 AM IST
  final tuesdayEnd = TimeOfDay(hour: 15, minute: 0);    // 3:00 PM IST
  
  final tuesdayStartUtc = timeOfDayToUtcFormatWithTimezone(tuesdayStart);
  final tuesdayEndUtc = timeOfDayToUtcFormatWithTimezone(tuesdayEnd);
  
  print('Local (IST): ${formatTimeOfDayForDisplay(tuesdayStart)} to ${formatTimeOfDayForDisplay(tuesdayEnd)}');
  print('Database (UTC): $tuesdayStartUtc to $tuesdayEndUtc');
  print('');
  
  // Test reverse conversion (what happens when loading from database)
  print('--- REVERSE CONVERSION (Loading from DB) ---');
  final loadedStart = parseUtcTimeFormatToLocal(mondayStartUtc);
  final loadedEnd = parseUtcTimeFormatToLocal(mondayEndUtc);
  
  print('From Database (UTC): $mondayStartUtc to $mondayEndUtc');
  print('Displayed to User (IST): ${formatTimeOfDayForDisplay(loadedStart)} to ${formatTimeOfDayForDisplay(loadedEnd)}');
}
