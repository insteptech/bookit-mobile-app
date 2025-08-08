import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/auth/provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/remember_me_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SigninScreen extends ConsumerWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppTranslationsDelegate.of(context);
    final state = ref.watch(loginProvider);
    final controller = ref.read(loginProvider.notifier);
    final rememberMe = ref.watch(rememberMeProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text("Sign in", style: AppTypography.headingLg),
              const SizedBox(height: 64),
              InputField(
                hintText: localizations.text("email"), 
                onChanged: controller.updateEmail,
                initialValue: state.email,
              ),
              const SizedBox(height: 16),
              InputField(
                hintText: localizations.text("password"), 
                onChanged: controller.updatePassword,
                initialValue: state.password,
                obscureText: true,
              ),
              const SizedBox(height: 8),
              RememberMeRow(
                rememberMe: rememberMe, 
                onChanged: (value) {
                  ref.read(rememberMeProvider.notifier).state = value;
                }
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  context.push('/forgetpassword');
                },
                child: Text(
                  "Forgot Password?",
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                onPressed: state.isLoading 
                  ? null 
                  : () async {
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
                isDisabled: state.email.isEmpty || state.password.isEmpty || state.isLoading,
                text: state.isLoading 
                  ? "Signing in..." 
                  : localizations.text("login_button")
              )
            ],
          )
        )
      )
    );
  }
}