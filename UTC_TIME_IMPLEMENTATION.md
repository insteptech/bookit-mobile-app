# UTC Time Format Implementation for Staff Schedules

This document explains the implementation of UTC time format support for the staff scheduling system in the BookIt mobile app.

## Overview

The staff scheduling system now properly handles time in UTC format for backend communication while maintaining a user-friendly local time display in the UI.

## Backend Requirements

The backend expects time in 24-hour UTC format matching the pattern: `^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$`

Examples:
- `09:00:00` (9:00 AM UTC)
- `14:30:00` (2:30 PM UTC)
- `23:45:00` (11:45 PM UTC)

## Implementation Details

### 1. Time Utilities (`lib/core/utils/time_utils.dart`)

#### New Functions Added:

- **`timeOfDayToUtcFormat(TimeOfDay time)`**: Converts Flutter's TimeOfDay to UTC format string
- **`parseUtcTimeFormat(String utcTimeStr)`**: Parses UTC format string to TimeOfDay
- **`parseUtcTimeFormatToLocal(String utcTimeStr)`**: Converts UTC time to local TimeOfDay (with timezone)
- **`timeOfDayToUtcFormatWithTimezone(TimeOfDay localTime)`**: Converts local time to UTC with timezone consideration
- **`formatTimeOfDayForDisplay(TimeOfDay time)`**: Formats TimeOfDay for UI display (12-hour format)

#### Example Usage:

```dart
// Convert TimeOfDay to UTC format for backend
final time = TimeOfDay(hour: 14, minute: 30);
final utcFormat = timeOfDayToUtcFormat(time); // "14:30:00"

// Parse UTC format from backend
final timeFromBackend = parseUtcTimeFormat("09:00:00"); // TimeOfDay(hour: 9, minute: 0)

// Format for display
final displayTime = formatTimeOfDayForDisplay(time); // "2:30 PM"
```

### 2. Schedule Selector Widget (`lib/features/main/dashboard/staff/widgets/schedule_selector.dart`)

#### Changes Made:

- **Backend Communication**: Uses UTC format when sending data to controller
- **UI Display**: Continues to show local time format for user convenience  
- **Data Parsing**: Handles both UTC format (from backend) and legacy formats

#### Key Methods:

```dart
// Sends UTC format to controller
void _updateScheduleInController() {
  // ...existing code...
  daysSchedule.add({
    "day": fullDays[index].toLowerCase(),
    "from": timeOfDayToUtcFormat(range.start), // UTC format
    "to": timeOfDayToUtcFormat(range.end),     // UTC format
  });
  // ...existing code...
}

// Parses time from backend (UTC format)
TimeOfDay _parseTimeFromBackend(String timeStr) {
  try {
    return parseUtcTimeFormat(timeStr); // Try UTC format first
  } catch (e) {
    return _parseTimeString(timeStr);   // Fallback to legacy format
  }
}
```

### 3. Staff Schedule Controller (`lib/features/main/dashboard/staff/application/staff_schedule_controller.dart`)

#### Payload Structure:

The controller builds payload with UTC time format:

```json
{
  "locations": [
    {
      "id": "1",
      "is_available": true,
      "services": ["service1", "service2"],
      "days_schedule": [
        {
          "day": "monday",
          "from": "09:00:00",  // UTC format
          "to": "17:00:00"     // UTC format
        }
      ]
    }
  ]
}
```

### 4. Add Staff Schedule Screen (`lib/features/main/dashboard/staff/presentation/add_staff_schedule_screen.dart`)

#### Data Flow:

1. **Receiving Data**: Backend sends UTC time format
2. **UI Processing**: ScheduleSelector automatically handles conversion
3. **Sending Data**: Controller sends UTC format back to backend

## Testing

Comprehensive unit tests ensure proper functionality:

```bash
flutter test test/unit/time_utils_test.dart
```

### Test Coverage:

- ✅ TimeOfDay to UTC format conversion
- ✅ UTC format to TimeOfDay parsing
- ✅ Invalid format error handling
- ✅ Display format generation
- ✅ Round-trip conversion integrity

## Usage Examples

### Setting Up a Schedule Entry

```dart
// UI shows: "9:00 AM - 5:00 PM"
// Backend receives: {"from": "09:00:00", "to": "17:00:00"}

final entry = LocationScheduleEntry(locationId: "1");
entry.daySchedules = [
  {
    "day": "monday",
    "from": "09:00:00", // UTC format
    "to": "17:00:00"    // UTC format
  }
];
```

### Displaying Schedule Data

```dart
// Backend sends: {"from": "09:00:00", "to": "17:00:00"}
// UI displays: "9:00 AM - 5:00 PM"

final startTime = parseUtcTimeFormat("09:00:00");
final displayText = formatTimeOfDayForDisplay(startTime); // "9:00 AM"
```

## Migration Notes

### Backward Compatibility

The implementation maintains backward compatibility:

- Old format parsing is supported as fallback
- Existing schedules continue to work
- Gradual migration to UTC format

### Error Handling

- Invalid time formats throw descriptive exceptions
- Graceful fallback to legacy parsing
- Comprehensive validation for time ranges (0-23 hours, 0-59 minutes)

## Future Considerations

### Timezone Support

While the current implementation uses simple UTC format, it can be extended to support timezone-aware conversions:

```dart
// Future enhancement example
String timeOfDayToUtcFormatWithTimezone(TimeOfDay localTime, String timezone) {
  // Implementation would consider specific timezone
}
```

### Internationalization

The display format can be easily adapted for different locales:

```dart
// Future enhancement for locale-specific formatting
String formatTimeOfDayForLocale(TimeOfDay time, Locale locale) {
  // Implementation would use locale-specific time formatting
}
```

## Troubleshooting

### Common Issues

1. **Time Format Mismatch**: Ensure backend sends HH:mm:ss format
2. **Timezone Confusion**: Remember UTC format doesn't consider local timezone by default
3. **Display Issues**: Use `formatTimeOfDayForDisplay()` for user-facing time strings

### Debug Tips

```dart
// Log time conversions for debugging
print('Original: ${time.format(context)}');
print('UTC Format: ${timeOfDayToUtcFormat(time)}');
print('Parsed Back: ${parseUtcTimeFormat(timeOfDayToUtcFormat(time))}');
```

## Conclusion

This implementation provides a robust, tested solution for handling UTC time format in staff schedules while maintaining excellent user experience with local time display. The code is well-documented, thoroughly tested, and maintains backward compatibility.
