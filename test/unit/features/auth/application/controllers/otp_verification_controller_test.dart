import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/otp_verification_controller.dart';

void main() {
  group('OtpVerificationController', () {
    late ProviderContainer container;
    late OtpVerificationController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(otpVerificationControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should have initial state', () {
      final state = container.read(otpVerificationControllerProvider);
      
      expect(state.email, '');
      expect(state.otp, '');
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.isButtonDisabled, true);
    });

    test('should update email correctly', () {
      controller.updateEmail('test@example.com');
      final state = container.read(otpVerificationControllerProvider);
      
      expect(state.email, 'test@example.com');
    });

    test('should update otp correctly', () {
      controller.updateOtp('123456');
      final state = container.read(otpVerificationControllerProvider);
      
      expect(state.otp, '123456');
    });

    test('should set loading state correctly', () {
      controller.setLoading(true);
      final state = container.read(otpVerificationControllerProvider);
      
      expect(state.isLoading, true);
    });

    test('should set error correctly', () {
      const errorMessage = 'Invalid OTP';
      controller.setError(errorMessage);
      final state = container.read(otpVerificationControllerProvider);
      
      expect(state.error, errorMessage);
      expect(state.isLoading, false);
    });

    test('should handle error states correctly', () {
      // Test setting an error
      const errorMessage = 'Invalid OTP';
      controller.setError(errorMessage);
      var state = container.read(otpVerificationControllerProvider);
      
      expect(state.error, errorMessage);
      expect(state.isLoading, false);
      
      // Test that updating OTP maintains error state  
      controller.updateOtp('123456');
      state = container.read(otpVerificationControllerProvider);
      expect(state.error, errorMessage); // Error persists until explicitly handled
    });

    test('should update button state based on OTP validity', () {
      // Initially button should be disabled
      var state = container.read(otpVerificationControllerProvider);
      expect(state.isButtonDisabled, true);
      
      // Enter invalid OTP (too short)
      controller.updateOtp('123');
      state = container.read(otpVerificationControllerProvider);
      expect(state.isButtonDisabled, true);
      
      // Enter valid OTP
      controller.updateOtp('123456');
      state = container.read(otpVerificationControllerProvider);
      expect(state.isButtonDisabled, false);
    });
  });
}
