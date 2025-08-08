import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/otp_verification_state.dart';

class OtpVerificationController extends StateNotifier<OtpVerificationState> {
  OtpVerificationController() : super(OtpVerificationState());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateOtp(String otp) {
    state = state.copyWith(otp: otp);
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
    final isDisabled = !state.isOtpValid;
    state = state.copyWith(isButtonDisabled: isDisabled);
  }
}

final otpVerificationControllerProvider = StateNotifierProvider<OtpVerificationController, OtpVerificationState>(
  (ref) => OtpVerificationController(),
);
