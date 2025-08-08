import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/auth/application/state/forgot_password_state.dart';

void main() {
  group('ForgotPasswordState', () {
    test('should create initial state with default values', () {
      final state = ForgotPasswordState();
      
      expect(state.email, '');
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('should update email correctly', () {
      final state = ForgotPasswordState();
      final updatedState = state.copyWith(email: 'test@example.com');
      
      expect(updatedState.email, 'test@example.com');
    });

    test('should set loading state', () {
      final state = ForgotPasswordState();
      final loadingState = state.copyWith(isLoading: true);
      
      expect(loadingState.isLoading, true);
    });

    test('should set error state', () {
      final state = ForgotPasswordState();
      const errorMessage = 'Email not found';
      final errorState = state.copyWith(error: errorMessage);
      
      expect(errorState.error, errorMessage);
    });

    test('should clear error', () {
      final state = ForgotPasswordState(error: 'Some error');
      final clearedState = state.clearError();
      
      expect(clearedState.error, null);
    });

    test('should validate email correctly', () {
      final state = ForgotPasswordState();
      
      // Invalid email (empty)
      expect(state.isEmailValid, false);
      
      // Invalid email (no @)
      final invalidEmailState = state.copyWith(email: 'invalid');
      expect(invalidEmailState.isEmailValid, false);
      
      // Valid email
      final validEmailState = state.copyWith(email: 'test@example.com');
      expect(validEmailState.isEmailValid, true);
    });

    test('copyWith should work correctly with multiple values', () {
      final state = ForgotPasswordState();
      final updatedState = state.copyWith(
        email: 'test@example.com',
        isLoading: true,
        error: 'Some error',
      );
      
      expect(updatedState.email, 'test@example.com');
      expect(updatedState.isLoading, true);
      expect(updatedState.error, 'Some error');
    });

    test('copyWith should preserve unchanged values', () {
      final state = ForgotPasswordState(
        email: 'existing@example.com',
        isLoading: false,
      );
      
      final updatedState = state.copyWith(isLoading: true);
      
      expect(updatedState.email, 'existing@example.com');
      expect(updatedState.isLoading, true);
    });
  });
}
