class LoginState {
  final String email;
  final String password;
  final bool isLoading;

  LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
