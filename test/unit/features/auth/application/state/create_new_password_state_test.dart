import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/auth/application/state/create_new_password_state.dart';

void main() {
  group('CreateNewPasswordState', () {
    test('should create initial state with default values', () {
      final state = CreateNewPasswordState();
      
      expect(state.email, '');
      expect(state.password, '');
      expect(state.confirmPassword, '');
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.isPasswordValid, false);
      expect(state.isButtonDisabled, true);
    });

    test('should update email correctly', () {
      final state = CreateNewPasswordState();
      final updatedState = state.copyWith(email: 'test@example.com');
      
      expect(updatedState.email, 'test@example.com');
    });

    test('should update password correctly', () {
      final state = CreateNewPasswordState();
      final updatedState = state.copyWith(password: 'newPassword123');
      
      expect(updatedState.password, 'newPassword123');
    });

    test('should update confirm password correctly', () {
      final state = CreateNewPasswordState();
      final updatedState = state.copyWith(confirmPassword: 'newPassword123');
      
      expect(updatedState.confirmPassword, 'newPassword123');
    });

    test('should set loading state', () {
      final state = CreateNewPasswordState();
      final loadingState = state.copyWith(isLoading: true);
      
      expect(loadingState.isLoading, true);
    });

    test('should set error state', () {
      final state = CreateNewPasswordState();
      const errorMessage = 'Password reset failed';
      final errorState = state.copyWith(error: errorMessage);
      
      expect(errorState.error, errorMessage);
    });

    test('should clear error', () {
      final state = CreateNewPasswordState(error: 'Some error');
      final clearedState = state.clearError();
      
      expect(clearedState.error, null);
    });

    test('should update password validation correctly', () {
      final state = CreateNewPasswordState();
      final updatedState = state.copyWith(isPasswordValid: true);
      
      expect(updatedState.isPasswordValid, true);
    });

    test('should update button disabled state correctly', () {
      final state = CreateNewPasswordState();
      final updatedState = state.copyWith(isButtonDisabled: false);
      
      expect(updatedState.isButtonDisabled, false);
    });

    test('should validate form correctly', () {
      final state = CreateNewPasswordState();
      
      // Invalid form (empty fields)
      expect(state.isFormValid, false);
      
      // Invalid form (passwords don\'t match)
      final mismatchedPasswordsState = state.copyWith(
        password: 'password123',
        confirmPassword: 'different123',
        isPasswordValid: true,
      );
      expect(mismatchedPasswordsState.isFormValid, false);
      
      // Valid form
      final validState = state.copyWith(
        password: 'password123',
        confirmPassword: 'password123',
        isPasswordValid: true,
      );
      expect(validState.isFormValid, true);
    });

    test('copyWith should work correctly with multiple values', () {
      final state = CreateNewPasswordState();
      final updatedState = state.copyWith(
        email: 'test@example.com',
        password: 'newPassword123',
        confirmPassword: 'newPassword123',
        isLoading: true,
      );
      
      expect(updatedState.email, 'test@example.com');
      expect(updatedState.password, 'newPassword123');
      expect(updatedState.confirmPassword, 'newPassword123');
      expect(updatedState.isLoading, true);
    });

    test('copyWith should preserve unchanged values', () {
      final state = CreateNewPasswordState(
        email: 'existing@example.com',
        password: 'existingPassword',
        isLoading: false,
      );
      
      final updatedState = state.copyWith(isLoading: true);
      
      expect(updatedState.email, 'existing@example.com');
      expect(updatedState.password, 'existingPassword');
      expect(updatedState.isLoading, true);
    });
  });
}
