import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/core/services/social_auth/social_auth_service.dart';
import 'package:bookit_mobile_app/core/services/social_auth/google_signin_service.dart';
import 'package:bookit_mobile_app/core/services/social_auth/apple_signin_service.dart';
import 'package:bookit_mobile_app/core/services/social_auth/facebook_signin_service.dart';
import 'package:bookit_mobile_app/features/auth/data/services/auth_api_service.dart' as auth_data;
import '../state/social_login_state.dart';

class SocialLoginController extends StateNotifier<SocialLoginState> {
  SocialLoginController() : super(SocialLoginState());

  final TokenService _tokenService = TokenService();
  final Map<SocialProvider, SocialAuthService> _socialServices = {
    SocialProvider.google: GoogleSignInService(),
    SocialProvider.apple: AppleSignInService(),
    SocialProvider.facebook: FacebookSignInService(),
  };

  Future<void> signInWithProvider(
    BuildContext context, 
    WidgetRef ref, 
    SocialProvider provider
  ) async {
    final service = _socialServices[provider];
    if (service == null) {
      throw Exception('Social provider not supported: ${provider.name}');
    }

    try {
      state = state.copyWith(isLoading: true, currentProvider: provider);
      
      final socialUser = await service.signIn();
      if (socialUser == null) {
        // User cancelled the sign-in
        state = state.copyWith(isLoading: false, currentProvider: null);
        return;
      }

      // Send social user data to backend
      final authService = auth_data.AuthService();
      final data = await authService.socialLogin(socialUser);
      
      if (data != null) {
        final user = data['user'];
        final isVerified = user?['isVerified'] ?? false;

        if (isVerified) {
          final token = data['token'];
          final refreshToken = data['refresh_token'];
          if (token != null) {
            await _tokenService.saveToken(token);
            await _tokenService.saveRefreshToken(refreshToken);
          }
          
          final userData = await auth_data.UserService().fetchUserDetails();
          
          if (userData.businessIds.isNotEmpty) {
            final String businessId = userData.businessIds[0];
            await ActiveBusinessService().saveActiveBusiness(businessId);
            final businessDetails = await auth_data.UserService().fetchBusinessDetails(
              businessId: businessId,
            );
            
            if (businessDetails.isOnboardingComplete && context.mounted) {
              context.go('/home_screen');
            } else if (context.mounted) {
              context.go('/onboarding_welcome');
            }
          } else if (context.mounted) {
            context.go('/onboarding_welcome');
          }
        } else if (context.mounted) {
          // Handle unverified user case for social login
          context.go('/signup_otp', extra: {'email': socialUser.email});
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, currentProvider: null);
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false, currentProvider: null);
    }
  }

  Future<void> signOut(SocialProvider provider) async {
    final service = _socialServices[provider];
    if (service != null) {
      await service.signOut();
    }
  }
}