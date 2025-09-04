import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'social_auth_service.dart';

class FacebookSignInService implements SocialAuthService {
  @override
  String get providerName => 'Facebook';

  @override
  Future<SocialUser?> signIn() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final userData = await FacebookAuth.instance.getUserData();

        return SocialUser(
          id: userData['id'] ?? '',
          name: userData['name'] ?? 'Facebook User',
          email: userData['email'] ?? '',
          avatarUrl: userData['picture']?['data']?['url'],
          accessToken: accessToken.tokenString,
          provider: SocialProvider.facebook,
        );
      } else if (result.status == LoginStatus.cancelled) {
        return null; // User cancelled
      } else {
        throw Exception('Facebook login failed: ${result.message}');
      }
    } catch (error) {
      throw Exception('Facebook sign-in failed: $error');
    }
  }

  @override
  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
  }

  @override
  Future<bool> isSignedIn() async {
    final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    return accessToken != null;
  }
}