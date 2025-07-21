import 'package:flutter/material.dart';

void main() {
  print('=== DEBUG TIMEZONE CONVERSION ===');
  print('Current timezone: ${DateTime.now().timeZoneName}');
  print('Current time: ${DateTime.now()}');
  print('');
  
  // Test the conversion function that we added to book_new_appointment_screen.dart
  String convertUtcTimeToLocalTimeString(String utcTimeString) {
    try {
      final parts = utcTimeString.split(':');
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
      
      return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}:00';
    } catch (e) {
      print('Error converting UTC time to local: $e');
      return utcTimeString; // Fallback to original string
    }
  }
  
  // Test some typical scenarios
  final testTimes = [
    '09:00:00', // 9 AM UTC
    '14:30:00', // 2:30 PM UTC
    '00:00:00', // Midnight UTC
    '23:59:00', // 11:59 PM UTC
  ];
  
  for (final utcTime in testTimes) {
    final localTime = convertUtcTimeToLocalTimeString(utcTime);
    print('UTC: $utcTime -> Local: $localTime');
  }
  
  print('');
  print('=== TEST COMPLETED ===');
}
