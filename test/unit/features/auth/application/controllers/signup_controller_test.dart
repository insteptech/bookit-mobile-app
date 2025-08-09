import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/signup_controller.dart';

void main() {
  group('SignupController', () {
    late ProviderContainer container;
    late SignupController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(signupControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should have initial state', () {
      final state = container.read(signupControllerProvider);
      
      expect(state.name, '');
      expect(state.email, '');
      expect(state.password, '');
      expect(state.confirmPassword, '');
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.isPasswordValid, false);
      expect(state.isButtonDisabled, true);
      expect(state.emailExists, false);
    });

    test('should update name correctly', () {
      controller.updateName('John Doe');
      final state = container.read(signupControllerProvider);
      
      expect(state.name, 'John Doe');
    });

    test('should update email correctly', () {
      controller.updateEmail('test@example.com');
      final state = container.read(signupControllerProvider);
      
      expect(state.email, 'test@example.com');
    });

    test('should update password correctly', () {
      controller.updatePassword('password123');
      final state = container.read(signupControllerProvider);
      
      expect(state.password, 'password123');
    });

    test('should update confirm password correctly', () {
      controller.updateConfirmPassword('password123');
      final state = container.read(signupControllerProvider);
      
      expect(state.confirmPassword, 'password123');
    });

    test('should update password validity correctly', () {
      controller.updatePasswordValid(true);
      final state = container.read(signupControllerProvider);
      
      expect(state.isPasswordValid, true);
    });

    test('should set loading state correctly', () {
      controller.setLoading(true);
      final state = container.read(signupControllerProvider);
      
      expect(state.isLoading, true);
    });

    test('should set error correctly', () {
      const errorMessage = 'Something went wrong';
      controller.setError(errorMessage);
      final state = container.read(signupControllerProvider);
      
      expect(state.error, errorMessage);
      expect(state.isLoading, false);
    });

    test('should handle error states correctly', () {
      // Test setting an error
      const errorMessage = 'Email already exists';
      controller.setError(errorMessage);
      var state = container.read(signupControllerProvider);
      
      expect(state.error, errorMessage);
      expect(state.isLoading, false);
      
      // Test that updating fields maintains error state
      controller.updateName('New Name');
      state = container.read(signupControllerProvider);
      expect(state.error, errorMessage); // Error persists until explicitly handled
    });

    test('should update button state based on form validity', () {
      // Initially button should be disabled
      var state = container.read(signupControllerProvider);
      expect(state.isButtonDisabled, true);
      
      // Fill all required fields
      controller.updateName('John Doe');
      controller.updateEmail('test@example.com');
      controller.updatePassword('password123');
      controller.updateConfirmPassword('password123');
      controller.updatePasswordValid(true);
      
      state = container.read(signupControllerProvider);
      expect(state.isButtonDisabled, false);
    });

    test('should set email exists flag correctly', () {
      controller.setEmailExists(true);
      final state = container.read(signupControllerProvider);
      
      expect(state.emailExists, true);
    });

    test('should clear error correctly', () {
      // Set an error first
      controller.setError('Some error');
      var state = container.read(signupControllerProvider);
      expect(state.error, 'Some error');
      
      // Clear the error
      controller.clearError();
      state = container.read(signupControllerProvider);
      expect(state.error, null);
    });

    test('should reset email exists state correctly', () {
      // Set email exists and error first
      controller.setEmailExists(true);
      controller.setError('Email already exists');
      var state = container.read(signupControllerProvider);
      expect(state.emailExists, true);
      expect(state.error, 'Email already exists');
      
      // Reset email exists state
      controller.resetEmailExistsState();
      state = container.read(signupControllerProvider);
      expect(state.emailExists, false);
      expect(state.error, null);
    });

    test('should reset entire form correctly', () {
      // Set up a form with data
      controller.updateName('John Doe');
      controller.updateEmail('test@example.com');
      controller.updatePassword('password123');
      controller.updateConfirmPassword('password123');
      controller.updatePasswordValid(true);
      controller.setLoading(true);
      controller.setError('Some error');
      controller.setEmailExists(true);
      
      var state = container.read(signupControllerProvider);
      
      // Reset the form
      controller.resetForm();
      state = container.read(signupControllerProvider);
      
      // Verify everything is reset to initial state
      expect(state.name, '');
      expect(state.email, '');
      expect(state.password, '');
      expect(state.confirmPassword, '');
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.isPasswordValid, false);
      expect(state.emailExists, false);
      expect(state.isButtonDisabled, true);
    });
  });
}
