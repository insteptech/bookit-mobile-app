import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/auth/application/state/change_password_state.dart';
import 'package:bookit_mobile_app/features/auth/data/services/auth_api_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final changePasswordControllerProvider = StateNotifierProvider<ChangePasswordController, AsyncValue<ChangePasswordState>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ChangePasswordController(authService);
});

class ChangePasswordController extends StateNotifier<AsyncValue<ChangePasswordState>> {
  final AuthService _authService;

  ChangePasswordController(this._authService) : super(const AsyncValue.data(ChangePasswordState()));

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Set loading state
    state = AsyncValue.data(
      ChangePasswordState(
        isLoading: true,
      ),
    );

    try {
      // Validate passwords match
      if (newPassword != confirmPassword) {
        state = AsyncValue.data(
          ChangePasswordState(
            error: 'Passwords do not match',
          ),
        );
        return false;
      }

      // Validate password strength
      if (!_isPasswordValid(newPassword)) {
        state = AsyncValue.data(
          ChangePasswordState(
            error: 'Password does not meet requirements',
          ),
        );
        return false;
      }

      // Call API to change password
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      state = AsyncValue.data(
        ChangePasswordState(
          isSuccess: true,
          message: 'Password changed successfully',
        ),
      );

      return true;
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Handle specific error messages
      if (errorMessage.toLowerCase().contains('incorrect') || 
          errorMessage.toLowerCase().contains('wrong') ||
          errorMessage.toLowerCase().contains('invalid')) {
        errorMessage = 'Incorrect old password';
      }
      
      state = AsyncValue.data(
        ChangePasswordState(
          error: errorMessage,
        ),
      );
      return false;
    }
  }

  bool _isPasswordValid(String password) {
    // Check minimum length
    if (password.length < 8) return false;
    
    // Check for uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Check for special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    
    // Check for alphanumeric (both letters and numbers)
    if (!password.contains(RegExp(r'[a-zA-Z]')) || !password.contains(RegExp(r'[0-9]'))) return false;
    
    return true;
  }

  void clearError() {
    state.whenData((currentState) {
      if (currentState.error != null) {
        state = AsyncValue.data(
          ChangePasswordState(
            isSuccess: currentState.isSuccess,
            message: currentState.message,
          ),
        );
      }
    });
  }

  void resetForm() {
    state = const AsyncValue.data(ChangePasswordState());
  }
}