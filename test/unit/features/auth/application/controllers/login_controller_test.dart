import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/auth/provider.dart';

void main() {
  group('LoginController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should have initial state', () {
      final state = container.read(loginProvider);
      
      expect(state.email, '');
      expect(state.password, '');
      expect(state.isLoading, false);
    });

    test('should update email correctly', () {
      final controller = container.read(loginProvider.notifier);
      controller.updateEmail('test@example.com');
      final state = container.read(loginProvider);
      
      expect(state.email, 'test@example.com');
    });

    test('should update password correctly', () {
      final controller = container.read(loginProvider.notifier);
      controller.updatePassword('password123');
      final state = container.read(loginProvider);
      
      expect(state.password, 'password123');
    });

    test('should validate form with email and password', () {
      final controller = container.read(loginProvider.notifier);
      
      // Enter valid email and password
      controller.updateEmail('test@example.com');
      controller.updatePassword('password123');
      final state = container.read(loginProvider);
      
      expect(state.email, 'test@example.com');
      expect(state.password, 'password123');
      expect(state.email.isNotEmpty && state.password.isNotEmpty, true);
    });

    test('should update loading state correctly', () {
      final state = container.read(loginProvider);
      
      // Test that state can be copied with loading true
      final loadingState = state.copyWith(isLoading: true);
      expect(loadingState.isLoading, true);
      
      // Test that state can be copied with loading false
      final notLoadingState = state.copyWith(isLoading: false);
      expect(notLoadingState.isLoading, false);
    });
  });
}
