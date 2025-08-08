import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/signup_state.dart';

class SignupController extends StateNotifier<SignupState> {
  SignupController() : super(SignupState());

  void updateName(String name) {
    state = state.copyWith(name: name);
    _updateButtonState();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
    _updateButtonState();
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

  void setEmailExists(bool exists) {
    state = state.copyWith(emailExists: exists);
  }

  void clearError() {
    state = state.clearError();
  }

  void resetEmailExistsState() {
    state = state.copyWith(emailExists: false, error: null);
  }

  void resetForm() {
    state = SignupState();
  }

  void _updateButtonState() {
    final isDisabled = !state.isFormValid;
    state = state.copyWith(isButtonDisabled: isDisabled);
  }
}

final signupControllerProvider = StateNotifierProvider<SignupController, SignupState>(
  (ref) => SignupController(),
);
