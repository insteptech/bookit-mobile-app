import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_state.dart';

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(LoginState());

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  Future<void> submit() async {
    // Handle login logic here
    print("Logging in with: ${state.email}, ${state.password}");
  }
}
