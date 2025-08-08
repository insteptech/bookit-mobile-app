import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/forgot_password_controller.dart';

void main() {
  group('ForgotPasswordController', () {
    late ProviderContainer container;
    late ForgotPasswordController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(forgotPasswordControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should have initial state', () {
      final state = container.read(forgotPasswordControllerProvider);
      
      expect(state.email, '');
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.isEmailValid, false);
    });

    test('should update email correctly', () {
      controller.updateEmail('test@example.com');
      final state = container.read(forgotPasswordControllerProvider);
      
      expect(state.email, 'test@example.com');
    });

    test('should set loading state correctly', () {
      controller.setLoading(true);
      final state = container.read(forgotPasswordControllerProvider);
      
      expect(state.isLoading, true);
    });

    test('should set error correctly', () {
      const errorMessage = 'Email not found';
      controller.setError(errorMessage);
      final state = container.read(forgotPasswordControllerProvider);
      
      expect(state.error, errorMessage);
      expect(state.isLoading, false);
    });

    test('should handle error states correctly', () {
      // Test setting an error
      const errorMessage = 'Email not found';
      controller.setError(errorMessage);
      var state = container.read(forgotPasswordControllerProvider);
      
      expect(state.error, errorMessage);
      expect(state.isLoading, false);
      
      // Test that updating email maintains error state
      controller.updateEmail('newemail@example.com');
      state = container.read(forgotPasswordControllerProvider);
      expect(state.error, errorMessage); // Error persists until explicitly handled
    });

    test('should update button state based on email validity', () {
      // Initially email should be invalid
      var state = container.read(forgotPasswordControllerProvider);
      expect(state.isEmailValid, false);
      
      // Enter invalid email
      controller.updateEmail('invalid-email');
      state = container.read(forgotPasswordControllerProvider);
      expect(state.isEmailValid, false);
      
      // Enter valid email
      controller.updateEmail('test@example.com');
      state = container.read(forgotPasswordControllerProvider);
      expect(state.isEmailValid, true);
      
      // Clear email
      controller.updateEmail('');
      state = container.read(forgotPasswordControllerProvider);
      expect(state.isEmailValid, false);
    });
  });
}
