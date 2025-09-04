import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/auth/provider.dart';
import 'package:bookit_mobile_app/core/services/social_auth/social_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_data.dart';
import '../../../../shared/components/atoms/input_field.dart';
import '../../../../shared/components/atoms/password_input_field.dart';
import '../../../../shared/components/molecules/remember_me_row.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(loginProvider);
    _passwordController = TextEditingController(text: state.password);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    final state = ref.watch(loginProvider);
    final controller = ref.read(loginProvider.notifier);
    final rememberMe = ref.watch(rememberMeProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InputField(
            hintText: localizations.text('email'),
            onChanged: controller.updateEmail,
            initialValue: state.email,
          ),
          const SizedBox(height: 16),
          PasswordInputField(
            hintText: localizations.text('password'),
            controller: _passwordController,
            onChanged: controller.updatePassword,
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RememberMeRow(
                  rememberMe: rememberMe,
                  onChanged: (value) {
                    ref.read(rememberMeProvider.notifier).state = value;
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.push('/forgetpassword');
                },
                child: Text(
                  "Forgot Password?",
                  style: AppTypography.bodySmall.copyWith(
                    decoration: TextDecoration.underline,
                    color: AppColors.onSurfaceLight,      
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), // Only horizontal padding
    ),
    onPressed: state.isLoading ? null : () async {
      try {
        await controller.submit(context, ref);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    },
    child: state.isLoading
    ? const SizedBox(
        width: 20, // or your preferred size
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : Text(localizations.text("login_button"), style: AppTypography.button),
  ),
),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon('assets/icons/apple.svg', SocialProvider.apple, ref),
              const SizedBox(width: 16),
              _socialIcon('assets/icons/google.svg', SocialProvider.google, ref),
              const SizedBox(width: 16),
              _socialIcon('assets/icons/facebook.svg', SocialProvider.facebook, ref),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(String assetPath, SocialProvider provider, WidgetRef ref) {
    final socialState = ref.watch(socialLoginProvider);
    final socialController = ref.read(socialLoginProvider.notifier);
    final isLoading = socialState.isLoading && socialState.currentProvider == provider;
    
    return GestureDetector(
      onTap: isLoading ? null : () async {
        try {
          await socialController.signInWithProvider(context, ref, provider);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: lightTheme.focusColor, width: 1),
        ),
        child: isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : SvgPicture.asset(assetPath, height: 20, width: 20),
      ),
    );
  }
}
