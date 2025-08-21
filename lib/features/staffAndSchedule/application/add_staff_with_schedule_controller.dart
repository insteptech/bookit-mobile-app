import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/models/staff_profile_request_model.dart';

class AddStaffWithScheduleController {
  final AddStaffController staffController;
  final StaffScheduleController scheduleController;

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
      final payload = _buildPayload(staffProfile, schedule);

      print('Submitting staff with schedule: $payload');
      // TODO: Replace with your API call
      // await APIRepository.submitStaffWithSchedule(payload);
      await Future.delayed(const Duration(seconds: 1)); // Simulate network
      onSuccess?.call('Staff and schedule saved successfully');
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      isLoading = false;
      onStateChanged?.call();
    }
  }

  Map<String, dynamic> _buildPayload(StaffProfile staff, Map<String, dynamic> schedule) {
    return {
      'staff': staff.toJson(),
      'schedule': schedule,
    };
  }
}
