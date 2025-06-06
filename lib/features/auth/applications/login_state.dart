class LoginState {
  final String email;
  final String password;
  final bool rememberMe;

  LoginState({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}
