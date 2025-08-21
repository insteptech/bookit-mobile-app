import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/utils/validators.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/models/staff_profile_request_model.dart';

class AddStaffController {
  StaffProfile? staffProfile;
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

  // void addMemberForm() {
  //   memberForms.add(DateTime.now().millisecondsSinceEpoch);
  //   _notifyStateChanged();
  // }

  // void removeMemberForm(int id) {
  //   if (memberForms.length <= 1) return;

  //   memberForms.remove(id); 
  //   staffProfiles.remove(id);
  //   _notifyStateChanged();
  // }

  void updateStaffProfile(StaffProfile profile) {
    staffProfile = profile;
    _notifyStateChanged();
  }

  /// Validates if all required fields are filled for the staff member
  bool get canSubmit {
    if (staffProfile == null) return false;
    return _isProfileComplete(staffProfile!);
  }

  /// Gets a summary of validation status for debugging
  String getValidationSummary() {
    if (staffProfile == null) return 'No profile data';
    final missing = getMissingFields();
    return missing.isEmpty
        ? 'Complete'
        : 'Missing: ${missing.join(", ")}' ;
  }

  /// Checks if a single staff profile has all required fields filled
  bool _isProfileComplete(StaffProfile profile) {
    final isComplete = profile.name.trim().isNotEmpty &&
           profile.email.trim().isNotEmpty &&
           isEmailInCorrectFormat(profile.email) &&
           isMobileNumberInCorrectFormat(profile.phoneNumber) &&
           profile.gender.trim().isNotEmpty &&
           profile.categoryIds.isNotEmpty;
    
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

  // No longer needed: getValidationStatus for multiple forms

  /// Gets missing fields for the staff member
  List<String> getMissingFields() {
    if (staffProfile == null) {
      return ['All fields are required'];
    }
    final profile = staffProfile!;
    List<String> missing = [];
    if (profile.name.trim().isEmpty) missing.add('Name');
    if (profile.email.trim().isEmpty) missing.add('Email');
    if (profile.phoneNumber.trim().isEmpty) missing.add('Phone Number');
    if (profile.gender.trim().isEmpty) missing.add('Gender');
    if (profile.categoryIds.isEmpty) missing.add('Categories');
    return missing;
  }

  Future<void> submitStaffProfile() async {
    if (!canSubmit) return;
    isLoading = true;
    _notifyStateChanged();
    try {
      final response = await APIRepository.addMultipleStaff(
        staffProfiles: [staffProfile!],
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess?.call('Staff member added successfully');
      } else {
        throw Exception('Failed to add staff member');
      }
    } catch (e) {
      print("Error occurred while adding staff member: $e");
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
    staffProfile = null;
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
