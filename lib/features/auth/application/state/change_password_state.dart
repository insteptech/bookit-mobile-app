class ChangePasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final String? message;

  const ChangePasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.message,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    String? message,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }
}