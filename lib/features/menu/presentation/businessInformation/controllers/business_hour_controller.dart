import 'package:flutter/material.dart';

/// Represents a single day's business hours
class BusinessDay {
  final String dayName;
  final String dayCode;
  bool isOpen;
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  BusinessDay({
    required this.dayName,
    required this.dayCode,
    this.isOpen = false,
    this.openTime,
    this.closeTime,
  });

  /// Creates a copy of this BusinessDay with updated values
  BusinessDay copyWith({
    bool? isOpen,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
  }) {
    return BusinessDay(
      dayName: dayName,
      dayCode: dayCode,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  /// Converts to backend-compatible format (UTC HH:mm:ss)
  Map<String, dynamic> toJson() {
    return {
      'day': dayCode.toLowerCase(),
      'is_open': isOpen,
      'open_time': openTime != null ? _timeToUtcString(openTime!) : null,
      'close_time': closeTime != null ? _timeToUtcString(closeTime!) : null,
    };
  }

  /// Converts TimeOfDay to UTC string format (HH:mm:ss)
  String _timeToUtcString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// Creates BusinessDay from backend JSON
  factory BusinessDay.fromJson(Map<String, dynamic> json, String dayName, String dayCode) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        return null;
      }
    }

    return BusinessDay(
      dayName: dayName,
      dayCode: dayCode,
      isOpen: json['is_open'] ?? false,
      openTime: parseTime(json['open_time']),
      closeTime: parseTime(json['close_time']),
    );
  }
}

/// Controller for managing business opening hours
/// 
/// Handles:
/// - Daily hours configuration
/// - Open/closed status for each day
/// - Time validation
/// - Backend payload generation
class BusinessHoursController extends ChangeNotifier {
  late List<BusinessDay> _businessDays;
  bool _isLoading = false;
  String? _errorMessage;

  BusinessHoursController() {
    _initializeDefaultHours();
  }

  // Getters
  List<BusinessDay> get businessDays => _businessDays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize with default business days
  void _initializeDefaultHours() {
    _businessDays = [
      BusinessDay(dayName: 'Monday', dayCode: 'MON'),
      BusinessDay(dayName: 'Tuesday', dayCode: 'TUE'),
      BusinessDay(dayName: 'Wednesday', dayCode: 'WED'),
      BusinessDay(dayName: 'Thursday', dayCode: 'THU'),
      BusinessDay(dayName: 'Friday', dayCode: 'FRI'),
      BusinessDay(dayName: 'Saturday', dayCode: 'SAT'),
      BusinessDay(dayName: 'Sunday', dayCode: 'SUN'),
    ];
  }

  /// Toggle a day's open/closed status
  void toggleDayStatus(int dayIndex, bool isOpen) {
    if (dayIndex >= 0 && dayIndex < _businessDays.length) {
      _businessDays[dayIndex] = _businessDays[dayIndex].copyWith(isOpen: isOpen);
      
      // Clear times if closing the day
      if (!isOpen) {
        _businessDays[dayIndex] = _businessDays[dayIndex].copyWith(
          openTime: null,
          closeTime: null,
        );
      }
      
      _clearError();
      notifyListeners();
    }
  }

  /// Update opening time for a specific day
  void updateOpenTime(int dayIndex, TimeOfDay time) {
    if (dayIndex >= 0 && dayIndex < _businessDays.length) {
      _businessDays[dayIndex] = _businessDays[dayIndex].copyWith(
        openTime: time,
        isOpen: true, // Automatically mark as open when setting time
      );
      
      // Validate that close time is after open time
      final day = _businessDays[dayIndex];
      if (day.closeTime != null && !_isValidTimeRange(time, day.closeTime!)) {
        _businessDays[dayIndex] = _businessDays[dayIndex].copyWith(closeTime: null);
      }
      
      _clearError();
      notifyListeners();
    }
  }

  /// Update closing time for a specific day
  void updateCloseTime(int dayIndex, TimeOfDay time) {
    if (dayIndex >= 0 && dayIndex < _businessDays.length) {
      final day = _businessDays[dayIndex];
      
      // Validate that close time is after open time
      if (day.openTime != null && !_isValidTimeRange(day.openTime!, time)) {
        _setError('Closing time must be after opening time');
        return;
      }
      
      _businessDays[dayIndex] = _businessDays[dayIndex].copyWith(
        closeTime: time,
        isOpen: true, // Automatically mark as open when setting time
      );
      
      _clearError();
      notifyListeners();
    }
  }

  /// Check if time range is valid (close time after open time)
  bool _isValidTimeRange(TimeOfDay openTime, TimeOfDay closeTime) {
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;
    return closeMinutes > openMinutes;
  }

  /// Set all days to the same hours
  void setUniformHours(TimeOfDay openTime, TimeOfDay closeTime) {
    if (!_isValidTimeRange(openTime, closeTime)) {
      _setError('Invalid time range');
      return;
    }

    for (int i = 0; i < _businessDays.length; i++) {
      _businessDays[i] = _businessDays[i].copyWith(
        isOpen: true,
        openTime: openTime,
        closeTime: closeTime,
      );
    }
    
    _clearError();
    notifyListeners();
  }

  /// Set weekday hours (Monday to Friday)
  void setWeekdayHours(TimeOfDay openTime, TimeOfDay closeTime) {
    if (!_isValidTimeRange(openTime, closeTime)) {
      _setError('Invalid time range');
      return;
    }

    for (int i = 0; i < 5; i++) { // Monday to Friday
      _businessDays[i] = _businessDays[i].copyWith(
        isOpen: true,
        openTime: openTime,
        closeTime: closeTime,
      );
    }
    
    _clearError();
    notifyListeners();
  }

  /// Close all days
  void closeAllDays() {
    for (int i = 0; i < _businessDays.length; i++) {
      _businessDays[i] = _businessDays[i].copyWith(
        isOpen: false,
        openTime: null,
        closeTime: null,
      );
    }
    
    _clearError();
    notifyListeners();
  }

  /// Load business hours from backend data
  void loadFromData(Map<String, dynamic> data) {
    _setLoading(true);
    
    try {
      if (data['business_hours'] != null) {
        final List<dynamic> hoursData = data['business_hours'];
        
        for (var hourData in hoursData) {
          final dayCode = hourData['day']?.toString().toUpperCase();
          final dayIndex = _businessDays.indexWhere((d) => d.dayCode == dayCode);
          
          if (dayIndex != -1) {
            _businessDays[dayIndex] = BusinessDay.fromJson(
              hourData,
              _businessDays[dayIndex].dayName,
              _businessDays[dayIndex].dayCode,
            );
          }
        }
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to load business hours: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate payload for backend submission
  Map<String, dynamic> buildPayload() {
    final openDays = _businessDays.where((day) => day.isOpen).toList();
    
    return {
      'business_hours': openDays.map((day) => day.toJson()).toList(),
      'updated_by': 'lsvishawjeet', // Current user
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Validate current configuration
  bool validate() {
    _clearError();
    
    // Check if at least one day is open
    if (!_businessDays.any((day) => day.isOpen)) {
      _setError('At least one day must be open');
      return false;
    }
    
    // Check that open days have both open and close times
    for (var day in _businessDays) {
      if (day.isOpen) {
        if (day.openTime == null || day.closeTime == null) {
          _setError('${day.dayName} is marked as open but missing hours');
          return false;
        }
      }
    }
    
    return true;
  }

  /// Get formatted hours string for a day
  String getFormattedHours(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= _businessDays.length) return '';
    
    final day = _businessDays[dayIndex];
    if (!day.isOpen) return 'Closed';
    
    if (day.openTime == null || day.closeTime == null) return 'Set hours';
    
    return '${_formatTime(day.openTime!)} - ${_formatTime(day.closeTime!)}';
  }

  /// Format TimeOfDay to readable string
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Helper methods for error handling
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Reset to default state
  void reset() {
    _initializeDefaultHours();
    _clearError();
    notifyListeners();
  }
}