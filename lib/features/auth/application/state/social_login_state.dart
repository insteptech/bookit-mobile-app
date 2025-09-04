import 'package:bookit_mobile_app/core/services/social_auth/social_auth_service.dart';

class SocialLoginState {
  final bool isLoading;
  final SocialProvider? currentProvider;

  SocialLoginState({
    this.isLoading = false,
    this.currentProvider,
  });

  SocialLoginState copyWith({
    bool? isLoading,
    SocialProvider? currentProvider,
  }) {
    return SocialLoginState(
      isLoading: isLoading ?? this.isLoading,
      currentProvider: currentProvider ?? this.currentProvider,
    );
  }
}