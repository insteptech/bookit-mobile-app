import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/password_validation_widget.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/signup_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      ref.read(signupControllerProvider.notifier).updateName(nameController.text);
    });
    emailController.addListener(() {
      ref.read(signupControllerProvider.notifier).updateEmail(emailController.text);
    });
    passwordController.addListener(() {
      ref.read(signupControllerProvider.notifier).updatePassword(passwordController.text);
    });
    confirmPasswordController.addListener(() {
      ref.read(signupControllerProvider.notifier).updateConfirmPassword(confirmPasswordController.text);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleSendOtp() async {
    final controller = ref.read(signupControllerProvider.notifier);
    controller.setLoading(true);
    controller.clearError();
    
    try {
      final authService = AuthService();

      await authService.signup(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      context.go('/signup_otp', extra: {'email': emailController.text});
    } catch (e) {
      controller.setError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    final theme = Theme.of(context);
    final signupState = ref.watch(signupControllerProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  InputField(
                    hintText: localizations.text("full_name"),
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    hintText: localizations.text("email"),
                    controller: emailController,
                  ),
                  if (signupState.error?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        signupState.error!,
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  PasswordValidationWidget(
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    onValidationChanged: (isValid) {
                      ref.read(signupControllerProvider.notifier).updatePasswordValid(isValid);
                    },
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 24),
                    child: PrimaryButton(
                      isDisabled: signupState.isButtonDisabled,
                      text: localizations.text("complete_sign_up"),
                      onPressed: handleSendOtp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
