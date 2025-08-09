class SignupState {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final String? error;
  final bool isPasswordValid;
  final bool isButtonDisabled;
  final bool emailExists;

  SignupState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.error,
    this.isPasswordValid = false,
    this.isButtonDisabled = true,
    this.emailExists = false,
  });

  SignupState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    String? error,
    bool? isPasswordValid,
    bool? isButtonDisabled,
    bool? emailExists,
    bool clearError = false,
  }) {
    return SignupState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isButtonDisabled: isButtonDisabled ?? this.isButtonDisabled,
      emailExists: emailExists ?? this.emailExists,
    );
  }

  SignupState clearError() {
    return copyWith(clearError: true);
  }

  bool get isFormValid =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      isPasswordValid;
}
