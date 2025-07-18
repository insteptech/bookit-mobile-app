import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/core/utils/time_utils.dart';

void main() {
  group('Time Utils UTC Format Tests', () {
    test('timeOfDayToUtcFormat converts TimeOfDay to UTC format correctly', () {
      // Test morning time
      final morningTime = TimeOfDay(hour: 9, minute: 30);
      expect(timeOfDayToUtcFormat(morningTime), equals('09:30:00'));
      
      // Test afternoon time
      final afternoonTime = TimeOfDay(hour: 14, minute: 15);
      expect(timeOfDayToUtcFormat(afternoonTime), equals('14:15:00'));
      
      // Test midnight
      final midnightTime = TimeOfDay(hour: 0, minute: 0);
      expect(timeOfDayToUtcFormat(midnightTime), equals('00:00:00'));
      
      // Test late evening
      final eveningTime = TimeOfDay(hour: 23, minute: 45);
      expect(timeOfDayToUtcFormat(eveningTime), equals('23:45:00'));
    });

    test('parseUtcTimeFormat converts UTC format to TimeOfDay correctly', () {
      // Test morning time
      final morningResult = parseUtcTimeFormat('09:30:00');
      expect(morningResult.hour, equals(9));
      expect(morningResult.minute, equals(30));
      
      // Test afternoon time
      final afternoonResult = parseUtcTimeFormat('14:15:00');
      expect(afternoonResult.hour, equals(14));
      expect(afternoonResult.minute, equals(15));
      
      // Test midnight
      final midnightResult = parseUtcTimeFormat('00:00:00');
      expect(midnightResult.hour, equals(0));
      expect(midnightResult.minute, equals(0));
      
      // Test late evening
      final eveningResult = parseUtcTimeFormat('23:45:00');
      expect(eveningResult.hour, equals(23));
      expect(eveningResult.minute, equals(45));
    });

    test('parseUtcTimeFormat handles invalid format', () {
      expect(() => parseUtcTimeFormat('invalid'), throwsException);
      expect(() => parseUtcTimeFormat('25:00:00'), throwsException);
      expect(() => parseUtcTimeFormat('12:60:00'), throwsException);
    });

    test('formatTimeOfDayForDisplay formats time correctly', () {
      // Test morning time
      final morningTime = TimeOfDay(hour: 9, minute: 30);
      expect(formatTimeOfDayForDisplay(morningTime), equals('9:30 AM'));
      
      // Test afternoon time
      final afternoonTime = TimeOfDay(hour: 14, minute: 15);
      expect(formatTimeOfDayForDisplay(afternoonTime), equals('2:15 PM'));
      
      // Test midnight
      final midnightTime = TimeOfDay(hour: 0, minute: 0);
      expect(formatTimeOfDayForDisplay(midnightTime), equals('12 AM'));
      
      // Test noon
      final noonTime = TimeOfDay(hour: 12, minute: 0);
      expect(formatTimeOfDayForDisplay(noonTime), equals('12 PM'));
      
      // Test hour with no minutes
      final hourTime = TimeOfDay(hour: 15, minute: 0);
      expect(formatTimeOfDayForDisplay(hourTime), equals('3 PM'));
    });

    test('round trip conversion maintains data integrity', () {
      final originalTime = TimeOfDay(hour: 14, minute: 30);
      final utcFormat = timeOfDayToUtcFormat(originalTime);
      final convertedBack = parseUtcTimeFormat(utcFormat);
      
      expect(convertedBack.hour, equals(originalTime.hour));
      expect(convertedBack.minute, equals(originalTime.minute));
    });
  });
}
