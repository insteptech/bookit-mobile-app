class CreateNewPasswordState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final String? error;
  final bool isPasswordValid;
  final bool isButtonDisabled;

  CreateNewPasswordState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.error,
    this.isPasswordValid = false,
    this.isButtonDisabled = true,
  });

  CreateNewPasswordState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    String? error,
    bool? isPasswordValid,
    bool? isButtonDisabled,
  }) {
    return CreateNewPasswordState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isButtonDisabled: isButtonDisabled ?? this.isButtonDisabled,
    );
  }

  CreateNewPasswordState clearError() {
    return copyWith(error: null);
  }

  bool get isFormValid => 
      password.isNotEmpty && 
      confirmPassword.isNotEmpty && 
      isPasswordValid &&
      password == confirmPassword;
}
