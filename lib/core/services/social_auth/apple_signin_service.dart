import 'dart:io';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'social_auth_service.dart';

class AppleSignInService implements SocialAuthService {
  @override
  String get providerName => 'Apple';

  @override
  Future<SocialUser?> signIn() async {
    try {
      // Check if Apple Sign In is available (iOS 13+ and macOS)
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw Exception('Apple Sign In is only available on iOS and macOS');
      }

      if (!await SignInWithApple.isAvailable()) {
        throw Exception('Apple Sign In is not available on this device');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final fullName = credential.givenName != null || credential.familyName != null
          ? '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim()
          : 'Apple User';

      return SocialUser(
        id: credential.userIdentifier ?? '',
        name: fullName,
        email: credential.email ?? '',
        avatarUrl: null, // Apple doesn't provide avatar URLs
        accessToken: credential.identityToken,
        provider: SocialProvider.apple,
      );
    } catch (error) {
      throw Exception('Apple sign-in failed: $error');
    }
  }

  @override
  Future<void> signOut() async {
    // Apple doesn't provide a sign-out method
    // The app should handle this by clearing local session data
  }

  @override
  Future<bool> isSignedIn() async {
    // Apple doesn't provide a way to check sign-in status
    // The app should track this locally
    return false;
  }
}