class ForgotPasswordState {
  final String email;
  final bool isLoading;
  final String? error;

  ForgotPasswordState({
    this.email = '',
    this.isLoading = false,
    this.error,
  });

  ForgotPasswordState copyWith({
    String? email,
    bool? isLoading,
    String? error,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  ForgotPasswordState clearError() {
    return copyWith(error: null);
  }

  bool get isEmailValid => email.isNotEmpty && email.contains('@');
}
