import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/forgot_password_state.dart';

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordController() : super(ForgotPasswordState());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
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
}

final forgotPasswordControllerProvider = StateNotifierProvider<ForgotPasswordController, ForgotPasswordState>(
  (ref) => ForgotPasswordController(),
);
