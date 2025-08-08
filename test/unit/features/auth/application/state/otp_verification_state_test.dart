import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/auth/application/state/otp_verification_state.dart';

void main() {
  group('OtpVerificationState', () {
    test('should create initial state with default values', () {
      final state = OtpVerificationState();
      
      expect(state.email, '');
      expect(state.otp, '');
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.isButtonDisabled, true);
    });

    test('should update email correctly', () {
      final state = OtpVerificationState();
      final updatedState = state.copyWith(email: 'test@example.com');
      
      expect(updatedState.email, 'test@example.com');
    });

    test('should update otp correctly', () {
      final state = OtpVerificationState();
      final updatedState = state.copyWith(otp: '123456');
      
      expect(updatedState.otp, '123456');
    });

    test('should set loading state', () {
      final state = OtpVerificationState();
      final loadingState = state.copyWith(isLoading: true);
      
      expect(loadingState.isLoading, true);
    });

    test('should set error state', () {
      final state = OtpVerificationState();
      const errorMessage = 'Invalid OTP';
      final errorState = state.copyWith(error: errorMessage);
      
      expect(errorState.error, errorMessage);
    });

    test('should clear error', () {
      final state = OtpVerificationState(error: 'Some error');
      final clearedState = state.clearError();
      
      expect(clearedState.error, null);
    });

    test('should update button disabled state', () {
      final state = OtpVerificationState();
      final updatedState = state.copyWith(isButtonDisabled: false);
      
      expect(updatedState.isButtonDisabled, false);
    });

    test('should validate OTP correctly', () {
      final state = OtpVerificationState();
      
      // Invalid OTP (too short)
      final shortOtpState = state.copyWith(otp: '123');
      expect(shortOtpState.isOtpValid, false);
      
      // Invalid OTP (too long)
      final longOtpState = state.copyWith(otp: '1234567');
      expect(longOtpState.isOtpValid, false);
      
      // Valid OTP
      final validOtpState = state.copyWith(otp: '123456');
      expect(validOtpState.isOtpValid, true);
    });

    test('copyWith should work correctly with multiple values', () {
      final state = OtpVerificationState();
      final updatedState = state.copyWith(
        email: 'test@example.com',
        otp: '123456',
        isLoading: true,
      );
      
      expect(updatedState.email, 'test@example.com');
      expect(updatedState.otp, '123456');
      expect(updatedState.isLoading, true);
    });

    test('copyWith should preserve unchanged values', () {
      final state = OtpVerificationState(
        email: 'existing@example.com',
        otp: '123456',
        isLoading: false,
      );
      
      final updatedState = state.copyWith(isLoading: true);
      
      expect(updatedState.email, 'existing@example.com');
      expect(updatedState.otp, '123456');
      expect(updatedState.isLoading, true);
    });
  });
}
