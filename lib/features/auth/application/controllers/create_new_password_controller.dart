import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/create_new_password_state.dart';

class CreateNewPasswordController extends StateNotifier<CreateNewPasswordState> {
  CreateNewPasswordController() : super(CreateNewPasswordState());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
    _updateButtonState();
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
    _updateButtonState();
  }

  void updatePasswordValid(bool isValid) {
    state = state.copyWith(isPasswordValid: isValid);
    _updateButtonState();
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void clearError() {
    state = state.clearError();
  }

  void _updateButtonState() {
    final isDisabled = !state.isFormValid;
    state = state.copyWith(isButtonDisabled: isDisabled);
  }
}

final createNewPasswordControllerProvider = StateNotifierProvider<CreateNewPasswordController, CreateNewPasswordState>(
  (ref) => CreateNewPasswordController(),
);
