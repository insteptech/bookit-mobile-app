import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/utils/validators.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/models/staff_profile_request_model.dart';

class AddStaffController {
  List<int> memberForms = [0];
  Map<int, StaffProfile> staffProfiles = {};
  bool isLoading = false;
  
  // Callbacks for UI updates
  Function()? onStateChanged;
  Function(String message)? onSuccess;
  Function(String error)? onError;

  void setCallbacks({
    Function()? onStateChanged,
    Function(String message)? onSuccess,
    Function(String error)? onError,
  }) {
    this.onStateChanged = onStateChanged;
    this.onSuccess = onSuccess;
    this.onError = onError;
  }

  void addMemberForm() {
    memberForms.add(DateTime.now().millisecondsSinceEpoch);
    _notifyStateChanged();
  }

  void removeMemberForm(int id) {
    if (memberForms.length <= 1) return;

    memberForms.remove(id);
    staffProfiles.remove(id);
    _notifyStateChanged();
  }

  void updateStaffProfile(int id, StaffProfile profile) {
    staffProfiles[id] = profile;
    _notifyStateChanged();
  }

  /// Validates if all required fields are filled for all staff members
  bool get canSubmit {
    // Check if we have profiles for all forms
    if (staffProfiles.length != memberForms.length) {
      // print('Cannot submit: profiles (${staffProfiles.length}) != forms (${memberForms.length})');
      return false;
    }
    
    // Check if all profiles have required fields filled
    final allComplete = staffProfiles.values.every((profile) => _isProfileComplete(profile));
    
    if (!allComplete) {
      // print('Cannot submit: Not all profiles are complete');
      // print('Validation summary: ${getValidationSummary()}');
    }
    
    return allComplete;
  }

  /// Gets a summary of validation status for debugging
  String getValidationSummary() {
    final buffer = StringBuffer();
    for (int formId in memberForms) {
      if (staffProfiles.containsKey(formId)) {
        final profile = staffProfiles[formId]!;
        final missing = getMissingFields(formId);
        buffer.writeln('Form $formId (${profile.name.isEmpty ? "Unnamed" : profile.name}): ${missing.isEmpty ? "Complete" : "Missing: ${missing.join(", ")}"}');
      } else {
        buffer.writeln('Form $formId: No profile data');
      }
    }
    return buffer.toString();
  }

  /// Checks if a single staff profile has all required fields filled
  bool _isProfileComplete(StaffProfile profile) {
    final isComplete = profile.name.trim().isNotEmpty &&
           profile.email.trim().isNotEmpty &&
           isEmailInCorrectFormat(profile.email) &&
           isMobileNumberInCorrectFormat(profile.phoneNumber) &&
           profile.gender.trim().isNotEmpty &&
           profile.categoryIds.isNotEmpty &&
           profile.locationIds.isNotEmpty;
    
    // Debug logging
    if (!isComplete) {
      // print('Profile incomplete for ${profile.name}: '
      //       'name: ${profile.name.trim().isNotEmpty}, '
      //       'email: ${profile.email.trim().isNotEmpty}, '
      //       'phone: ${profile.phoneNumber.trim().isNotEmpty}, '
      //       'gender: ${profile.gender.trim().isNotEmpty}, '
      //       'categories: ${profile.categoryIds.isNotEmpty}, '
      //       'locations: ${profile.locationIds.isNotEmpty}');
    }
    
    return isComplete;
  }

  /// Gets validation status for each staff member form
  Map<int, bool> getValidationStatus() {
    Map<int, bool> validationStatus = {};
    for (int formId in memberForms) {
      if (staffProfiles.containsKey(formId)) {
        validationStatus[formId] = _isProfileComplete(staffProfiles[formId]!);
      } else {
        validationStatus[formId] = false;
      }
    }
    return validationStatus;
  }

  /// Gets missing fields for a specific staff member
  List<String> getMissingFields(int formId) {
    if (!staffProfiles.containsKey(formId)) {
      return ['All fields are required'];
    }

    final profile = staffProfiles[formId]!;
    List<String> missing = [];

    if (profile.name.trim().isEmpty) missing.add('Name');
    if (profile.email.trim().isEmpty) missing.add('Email');
    if (profile.phoneNumber.trim().isEmpty) missing.add('Phone Number');
    if (profile.gender.trim().isEmpty) missing.add('Gender');
    if (profile.categoryIds.isEmpty) missing.add('Categories');
    if (profile.locationIds.isEmpty) missing.add('Locations');

    return missing;
  }

  Future<void> submitStaffProfiles() async {
    await _submitStaffProfiles(false);
  }

  Future<void> saveAndExit() async {
    await _submitStaffProfiles(true);
  }

  Future<void> _submitStaffProfiles(bool isSaveAndExit) async {
    if (!canSubmit) return;

    isLoading = true;
    _notifyStateChanged();

    try {
      final response = await APIRepository.addMultipleStaff(
        staffProfiles: staffProfiles.values.toList(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isSaveAndExit) {
          onSuccess?.call('Staff members saved successfully');
        } else {
          onSuccess?.call('Staff members added successfully');
        }
      } else {
        throw Exception('Failed to add staff members');
      }
    } catch (e) {
      print("Error occurred while adding staff members: $e");
      onError?.call('Error: $e');
    } finally {
      isLoading = false;
      _notifyStateChanged();
    }
  }

  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  /// Reset the controller to initial state
  void reset() {
    memberForms = [0];
    staffProfiles.clear();
    isLoading = false;
    _notifyStateChanged();
  }

  /// Dispose method to clean up resources
  void dispose() {
    onStateChanged = null;
    onSuccess = null;
    onError = null;
  }
}
