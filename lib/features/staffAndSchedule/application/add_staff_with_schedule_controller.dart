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
      print('Submitting staff with schedule: $payload');
      
      await APIRepository.addStaffWithSchedule(payload);
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
    
    for (var daySchedule in daysSchedule) {
      // Handle location data which might be nested in the daySchedule map
      String locationId = '';
      
      if (daySchedule is Map<String, dynamic>) {
        // If location is a nested map, extract the ID
        if (daySchedule['location'] is Map) {
          locationId = (daySchedule['location'] as Map)['id']?.toString() ?? '';
        } else if (daySchedule['location'] is String) {
          final locationString = daySchedule['location'] as String;
          // Parse the string to extract the ID using regex
          final idMatch = RegExp(r'id:\s*([^,}]+)').firstMatch(locationString);
          locationId = idMatch?.group(1)?.trim() ?? '';
        }
      }
      
      if (locationId.isNotEmpty) {
        locationSchedules[locationId] ??= [];
        locationSchedules[locationId]!.add({
          'day': daySchedule['day']?.toString().toLowerCase() ?? '',
          'from': _convertToAmPmFormat(daySchedule['from']?.toString() ?? ''),
          'to': _convertToAmPmFormat(daySchedule['to']?.toString() ?? ''),
        });
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
    
    return payload;
  }
  
  String _convertToAmPmFormat(String time24) {
    if (time24.isEmpty) return '';
    
    try {
      final parts = time24.split(':');
      if (parts.length < 2) return time24;
      
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      
      if (hour == 0) {
        return '12:$minute AM';
      } else if (hour < 12) {
        return '$hour:$minute AM';
      } else if (hour == 12) {
        return '12:$minute PM';
      } else {
        return '${hour - 12}:$minute PM';
      }
    } catch (e) {
      return time24; // Return original if conversion fails
    }
  }
}
