import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/auth/application/state/login_state.dart';

void main() {
  group('LoginState', () {
    test('should create initial state with default values', () {
      final state = LoginState();
      
      expect(state.email, '');
      expect(state.password, '');
      expect(state.isLoading, false);
    });

    test('should update email correctly', () {
      final state = LoginState();
      final updatedState = state.copyWith(email: 'test@example.com');
      
      expect(updatedState.email, 'test@example.com');
      expect(updatedState.password, '');
      expect(updatedState.isLoading, false);
    });

    test('should update password correctly', () {
      final state = LoginState();
      final updatedState = state.copyWith(password: 'password123');
      
      expect(updatedState.password, 'password123');
      expect(updatedState.email, '');
      expect(updatedState.isLoading, false);
    });

    test('should set loading state', () {
      final state = LoginState();
      final loadingState = state.copyWith(isLoading: true);
      
      expect(loadingState.isLoading, true);
    });

    test('copyWith should work correctly with multiple values', () {
      final state = LoginState();
      final updatedState = state.copyWith(
        email: 'test@example.com',
        password: 'password123',
        isLoading: true,
      );
      
      expect(updatedState.email, 'test@example.com');
      expect(updatedState.password, 'password123');
      expect(updatedState.isLoading, true);
    });

    test('copyWith should preserve unchanged values', () {
      final state = LoginState(
        email: 'existing@example.com',
        password: 'existingPassword',
        isLoading: false,
      );
      
      final updatedState = state.copyWith(isLoading: true);
      
      expect(updatedState.email, 'existing@example.com');
      expect(updatedState.password, 'existingPassword');
      expect(updatedState.isLoading, true);
    });

    test('should handle null values in copyWith', () {
      final state = LoginState(email: 'test@example.com');
      final updatedState = state.copyWith(email: null);
      
      // Should preserve the existing email since null was passed
      expect(updatedState.email, 'test@example.com');
    });
  });
}
