import 'package:google_sign_in/google_sign_in.dart';
import 'social_auth_service.dart';

class GoogleSignInService implements SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  String get providerName => 'Google';

  @override
  Future<SocialUser?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;

      return SocialUser(
        id: account.id,
        name: account.displayName ?? '',
        email: account.email,
        avatarUrl: account.photoUrl,
        accessToken: auth.accessToken,
        provider: SocialProvider.google,
      );
    } catch (error) {
      throw Exception('Google sign-in failed: $error');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}