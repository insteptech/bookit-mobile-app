class OtpVerificationState {
  final String email;
  final String otp;
  final bool isLoading;
  final String? error;
  final bool isButtonDisabled;

  OtpVerificationState({
    this.email = '',
    this.otp = '',
    this.isLoading = false,
    this.error,
    this.isButtonDisabled = true,
  });

  OtpVerificationState copyWith({
    String? email,
    String? otp,
    bool? isLoading,
    String? error,
    bool? isButtonDisabled,
    bool clearError = false,
  }) {
    return OtpVerificationState(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isButtonDisabled: isButtonDisabled ?? this.isButtonDisabled,
    );
  }

  OtpVerificationState clearError() {
    return copyWith(clearError: true);
  }

  bool get isOtpValid => otp.length == 6;
}
