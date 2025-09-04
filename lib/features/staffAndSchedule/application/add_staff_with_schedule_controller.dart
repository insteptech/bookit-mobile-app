import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/models/staff_profile_request_model.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';

class AddStaffWithScheduleController {
  final AddStaffController staffController;
  final StaffScheduleController scheduleController;
  final ActiveBusinessService _activeBusinessService = ActiveBusinessService();

  bool isLoading = false;
  Function(String message)? onSuccess;
  Function(String error)? onError;
  Function()? onStateChanged;

  AddStaffWithScheduleController({
    required this.staffController,
    required this.scheduleController,
  });

  void setCallbacks({
    Function(String message)? onSuccess,
    Function(String error)? onError,
    Function()? onStateChanged,
  }) {
    this.onSuccess = onSuccess;
    this.onError = onError;
    this.onStateChanged = onStateChanged;
  }

  bool get canSubmit => staffController.canSubmit && scheduleController.isValid();

  Future<void> submit() async {
    // if (!canSubmit) return;
    isLoading = true;
    onStateChanged?.call();
    try {
      final staffProfile = staffController.staffProfile;
      if (staffProfile == null) {
        onError?.call('Staff profile is missing');
        isLoading = false;
        onStateChanged?.call();
        return;
      }
      final schedule = scheduleController.getSchedulePayload();
      final payload = await _buildPayload(staffProfile, schedule);
      // Debug logging - remove in production
      // print('Submitting staff with schedule: $payload');
      
      await APIRepository.addStaffWithScheduleImage(payload);
      await Future.delayed(const Duration(seconds: 1)); // Simulate network
      onSuccess?.call('Staff and schedule saved successfully');
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      isLoading = false;
      onStateChanged?.call();
    }
  }

  Future<Map<String, dynamic>> _buildPayload(StaffProfile staff, Map<String, dynamic> schedule) async {
    final businessId = await _activeBusinessService.getActiveBusiness();
    
    // Transform schedule data to match backend expectations
    final daysSchedule = (schedule['days_schedule'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final services = (schedule['services'] as List?)?.cast<String>() ?? [];
    
    // Group schedules by location
    Map<String, List<Map<String, String>>> locationSchedules = {};
    
    // If we're editing existing staff and have no schedule data, we need to fetch and preserve existing data
    if (daysSchedule.isEmpty && staff.id != null) {
      try {
        final response = await APIRepository.getStaffDetailsAndScheduleById(staff.id!);
        if (response.statusCode == 200 && response.data['status'] == true) {
          final staffList = response.data['data']['staff'] as List<dynamic>?;
          if (staffList != null && staffList.isNotEmpty) {
            final existingStaffData = staffList[0];
            final existingSchedules = existingStaffData['schedules'] as List<dynamic>? ?? [];
            
            // Build location schedules from existing data
            for (var existingSchedule in existingSchedules) {
              final locationId = existingSchedule['location_id']?.toString();
              if (locationId != null && locationId.isNotEmpty) {
                locationSchedules[locationId] ??= [];
                locationSchedules[locationId]!.add({
                  'day': existingSchedule['day']?.toString().toLowerCase() ?? '',
                  'from': _convertAmPmToUtcFormat(existingSchedule['from']?.toString() ?? ''),
                  'to': _convertAmPmToUtcFormat(existingSchedule['to']?.toString() ?? ''),
                });
              }
            }
          }
        }
      } catch (e) {
        // Error fetching existing schedule data: Continue with empty schedule
      }
    } else {
      // Process new/updated schedule data
      
      // Check if we need to get location information from existing staff data
      Map<String, String> dayToLocationMap = {};
      if (staff.id != null) {
        try {
          final response = await APIRepository.getStaffDetailsAndScheduleById(staff.id!);
          if (response.statusCode == 200 && response.data['status'] == true) {
            final staffList = response.data['data']['staff'] as List<dynamic>?;
            if (staffList != null && staffList.isNotEmpty) {
              final existingStaffData = staffList[0];
              final existingSchedules = existingStaffData['schedules'] as List<dynamic>? ?? [];
              
              // Create a map of day -> location_id from existing schedules
              for (var existingSchedule in existingSchedules) {
                final day = existingSchedule['day']?.toString().toLowerCase();
                final locationId = existingSchedule['location_id']?.toString();
                if (day != null && locationId != null) {
                  dayToLocationMap[day] = locationId;
                }
              }
            }
          }
        } catch (e) {
          // Error getting location mapping: Continue without mapping
        }
      }
      
      for (var daySchedule in daysSchedule) {
        // Handle location data which might be nested in the daySchedule map
        String locationId = '';
        final day = daySchedule['day']?.toString().toLowerCase() ?? '';
        
        // Try to get location from the schedule entry first
        if (daySchedule['location'] is Map) {
          locationId = (daySchedule['location'] as Map)['id']?.toString() ?? '';
        } else if (daySchedule['location'] is String) {
          final locationString = daySchedule['location'] as String;
          // Parse the string to extract the ID using regex
          final idMatch = RegExp(r'id:\s*([^,}]+)').firstMatch(locationString);
          locationId = idMatch?.group(1)?.trim() ?? '';
        } else if (daySchedule['location_id'] != null) {
          locationId = daySchedule['location_id']?.toString() ?? '';
        }
        
        // If no location found in schedule entry, use the mapping from existing data
        if (locationId.isEmpty && dayToLocationMap.containsKey(day)) {
          locationId = dayToLocationMap[day]!;
        }
        
        if (locationId.isNotEmpty) {
          // Get the raw time strings and ensure they are in UTC format
          String fromTime = daySchedule['from']?.toString() ?? '';
          String toTime = daySchedule['to']?.toString() ?? '';
          
          locationSchedules[locationId] ??= [];
          locationSchedules[locationId]!.add({
            'day': day,
            'from': fromTime, // Keep as UTC - already converted by ScheduleSelector
            'to': toTime,     // Keep as UTC - already converted by ScheduleSelector
          });
        }
      }
    }
    
    // Build locations array for schedules
    List<Map<String, dynamic>> locations = [];
    for (var entry in locationSchedules.entries) {
      locations.add({
        'id': entry.key,
        'services': services,
        'days_schedule': entry.value,
      });
      }
    
    // Extract location IDs as strings from the locationSchedules keys
    List<String> locationIds = locationSchedules.keys.toList();

    // Build the final payload
    Map<String, dynamic> payload = {
      'name': staff.name,
      'email': staff.email,
      'phone_number': staff.phoneNumber,
      'gender': staff.gender,
      'category_id': staff.categoryIds,
      'location_id': locationIds,
      'for_class': staff.forClass ?? false,
      'schedules': {
        'locations': locations,
      },
    };
    
    // Add business_id if available
    if (businessId != null) {
      payload['business_id'] = businessId;
    }
    
    // Add id if it's an update (staff has existing id)
    if (staff.id != null) {
      payload['id'] = staff.id;
    }
    
    // Add profile image if exists
    if (staff.profileImage != null) {
      payload['profile_image'] = staff.profileImage;
    }
    
    return payload;
  }
  
  String _convertAmPmToUtcFormat(String timeStr) {
    if (timeStr.isEmpty) return '';
    
    // If the time is already in 24-hour UTC format, return it as is
    if (!timeStr.toUpperCase().contains('AM') && !timeStr.toUpperCase().contains('PM')) {
      // Ensure it has the :00 seconds part for UTC format
      if (timeStr.split(':').length == 2) {
        return '$timeStr:00';
      }
      return timeStr;
    }
    
    try {
      // Parse AM/PM format and convert to 24-hour UTC format
      final timeUpper = timeStr.toUpperCase().trim();
      final isAM = timeUpper.contains('AM');
      final isPM = timeUpper.contains('PM');
      
      if (!isAM && !isPM) return timeStr;
      
      // Remove AM/PM and extra spaces
      String timePart = timeUpper.replaceAll(RegExp(r'\s*(AM|PM)\s*'), '').trim();
      
      final parts = timePart.split(':');
      if (parts.length < 2) return timeStr;
      
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      
      // Convert to 24-hour format
      if (isPM && hour != 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }
      
      return '${hour.toString().padLeft(2, '0')}:$minute:00';
    } catch (e) {
      return timeStr; // Return original if conversion fails
    }
  }
}
