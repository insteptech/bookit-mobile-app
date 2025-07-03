import 'package:bookit_mobile_app/core/models/user_model.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import 'login_state.dart';

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(LoginState());

  void updateEmail(String email) => state = state.copyWith(email: email);
  void updatePassword(String password) =>
      state = state.copyWith(password: password);

  final TokenService _tokenService = TokenService();

  Future<void> submit(BuildContext context, WidgetRef ref) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      throw Exception("Email and password cannot be empty");
    }

    try {
      state = state.copyWith(isLoading: true);
      final authService = AuthService();
      final data = await authService.login(state.email, state.password);
      // state = state.copyWith(isLoading: false);

      final user = data?['user'];
      final isVerified = user?['isVerified'] ?? false;

      if (isVerified) {
        final token = data?['token'];
        if (token != null) {
          await _tokenService.saveToken(token);
        }
        final UserModel userData = await UserService().fetchUserDetails();
        if (userData.businessIds.isNotEmpty) {
          final String businessId = userData.businessIds[0];
          final businessDetails = await UserService().fetchBusinessDetails(
            businessId: businessId,
          );
          if(businessDetails.isOnboardingComplete){
              context.go('/home_screen');
          }
          else{
            context.go('/onboarding_welcome');
          }
        }
        else{
          context.go('/onboarding_welcome');
        }
        
      } else {
        await AuthService().resendOtp(state.email);
        context.go('/signup_otp', extra: {'email': state.email});
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
