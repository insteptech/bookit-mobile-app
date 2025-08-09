import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/auth/application/state/signup_state.dart';

void main() {
  group('SignupState', () {
    test('should create initial state with default values', () {
      final state = SignupState();
      
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
      final state = SignupState();
      final updatedState = state.copyWith(name: 'John Doe');
      
      expect(updatedState.name, 'John Doe');
    });

    test('should update email correctly', () {
      final state = SignupState();
      final updatedState = state.copyWith(email: 'test@example.com');
      
      expect(updatedState.email, 'test@example.com');
    });

    test('should update password correctly', () {
      final state = SignupState();
      final updatedState = state.copyWith(password: 'password123');
      
      expect(updatedState.password, 'password123');
    });

    test('should update confirm password correctly', () {
      final state = SignupState();
      final updatedState = state.copyWith(confirmPassword: 'password123');
      
      expect(updatedState.confirmPassword, 'password123');
    });

    test('should set loading state', () {
      final state = SignupState();
      final loadingState = state.copyWith(isLoading: true);
      
      expect(loadingState.isLoading, true);
    });

    test('should set error state', () {
      final state = SignupState();
      const errorMessage = 'Invalid credentials';
      final errorState = state.copyWith(error: errorMessage);
      
      expect(errorState.error, errorMessage);
    });

    test('should clear error', () {
      final state = SignupState(error: 'Some error');
      final clearedState = state.clearError();
      
      expect(clearedState.error, null);
    });

    test('should update password validation correctly', () {
      final state = SignupState();
      final updatedState = state.copyWith(isPasswordValid: true);
      
      expect(updatedState.isPasswordValid, true);
    });

    test('should update button disabled state correctly', () {
      final state = SignupState();
      final updatedState = state.copyWith(isButtonDisabled: false);
      
      expect(updatedState.isButtonDisabled, false);
    });

    test('should update email exists state correctly', () {
      final state = SignupState();
      final updatedState = state.copyWith(emailExists: true);
      
      expect(updatedState.emailExists, true);
    });

    test('should check if form is valid', () {
      final state = SignupState();
      expect(state.isFormValid, false);
      
      final validState = state.copyWith(
        name: 'John Doe',
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123',
        isPasswordValid: true,
      );
      expect(validState.isFormValid, true);
    });

    test('copyWith should work correctly with multiple values', () {
      final state = SignupState();
      final updatedState = state.copyWith(
        name: 'John Doe',
        email: 'test@example.com',
        password: 'password123',
        isLoading: true,
        emailExists: true,
      );
      
      expect(updatedState.name, 'John Doe');
      expect(updatedState.email, 'test@example.com');
      expect(updatedState.password, 'password123');
      expect(updatedState.isLoading, true);
      expect(updatedState.emailExists, true);
    });

    test('copyWith should preserve unchanged values', () {
      final state = SignupState(
        name: 'Existing Name',
        email: 'existing@example.com',
        isLoading: false,
      );
      
      final updatedState = state.copyWith(isLoading: true);
      
      expect(updatedState.name, 'Existing Name');
      expect(updatedState.email, 'existing@example.com');
      expect(updatedState.isLoading, true);
    });
  });
}
