enum SocialProvider { google, apple, facebook }

class SocialUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? accessToken;
  final SocialProvider provider;

  SocialUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.accessToken,
    required this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'access_token': accessToken,
      'provider': provider.name,
    };
  }
}

abstract class SocialAuthService {
  Future<SocialUser?> signIn();
  Future<void> signOut();
  Future<bool> isSignedIn();
  String get providerName;
}