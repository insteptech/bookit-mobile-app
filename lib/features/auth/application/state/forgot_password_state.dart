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
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  ForgotPasswordState clearError() {
    return copyWith(clearError: true);
  }

  bool get isEmailValid => email.isNotEmpty && email.contains('@');
}
