import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/create_new_password_controller.dart';

void main() {
  group('CreateNewPasswordController', () {
    late ProviderContainer container;
    late CreateNewPasswordController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(createNewPasswordControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should have initial state', () {
      final state = container.read(createNewPasswordControllerProvider);
      
      expect(state.email, '');
      expect(state.password, '');
      expect(state.confirmPassword, '');
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.isPasswordValid, false);
      expect(state.isButtonDisabled, true);
    });

    test('should update email correctly', () {
      controller.updateEmail('test@example.com');
      final state = container.read(createNewPasswordControllerProvider);
      
      expect(state.email, 'test@example.com');
    });

    test('should update password correctly', () {
      controller.updatePassword('password123');
      final state = container.read(createNewPasswordControllerProvider);
      
      expect(state.password, 'password123');
    });

    test('should update confirm password correctly', () {
      controller.updateConfirmPassword('password123');
      final state = container.read(createNewPasswordControllerProvider);
      
      expect(state.confirmPassword, 'password123');
    });

    test('should update password validity correctly', () {
      controller.updatePasswordValid(true);
      final state = container.read(createNewPasswordControllerProvider);
      
      expect(state.isPasswordValid, true);
    });

    test('should set loading state correctly', () {
      controller.setLoading(true);
      final state = container.read(createNewPasswordControllerProvider);
      
      expect(state.isLoading, true);
    });

    test('should set error correctly', () {
      const errorMessage = 'Passwords do not match';
      controller.setError(errorMessage);
      final state = container.read(createNewPasswordControllerProvider);
      
      expect(state.error, errorMessage);
      expect(state.isLoading, false);
    });

    test('should handle error states correctly', () {
      // Test setting an error
      const errorMessage = 'Passwords do not match';
      controller.setError(errorMessage);
      var state = container.read(createNewPasswordControllerProvider);
      
      expect(state.error, errorMessage);
      expect(state.isLoading, false);
      
      // Test that updating password maintains error state
      controller.updatePassword('newpassword');
      state = container.read(createNewPasswordControllerProvider);
      expect(state.error, errorMessage); // Error persists until explicitly handled
    });

    test('should validate form correctly', () {
      // Initially form should be invalid
      var state = container.read(createNewPasswordControllerProvider);
      expect(state.isFormValid, false);
      expect(state.isButtonDisabled, true);
      
      // Set password but not confirm password
      controller.updatePassword('password123');
      controller.updatePasswordValid(true);
      state = container.read(createNewPasswordControllerProvider);
      expect(state.isFormValid, false);
      
      // Set matching passwords
      controller.updateConfirmPassword('password123');
      state = container.read(createNewPasswordControllerProvider);
      expect(state.isFormValid, true);
      expect(state.isButtonDisabled, false);
      
      // Set non-matching passwords
      controller.updateConfirmPassword('different');
      state = container.read(createNewPasswordControllerProvider);
      expect(state.isFormValid, false);
      expect(state.isButtonDisabled, true);
    });

    test('should update button state when password changes', () {
      // Set up valid password
      controller.updatePassword('password123');
      controller.updatePasswordValid(true);
      controller.updateConfirmPassword('password123');
      
      var state = container.read(createNewPasswordControllerProvider);
      expect(state.isButtonDisabled, false);
      
      // Change password to make form invalid
      controller.updatePassword('short');
      controller.updatePasswordValid(false);
      
      state = container.read(createNewPasswordControllerProvider);
      expect(state.isButtonDisabled, true);
    });
  });
}
