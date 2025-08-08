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
    
    // Reset form completely when returning to signup screen
    // Use addPostFrameCallback to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear all text controllers
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      
      // Reset the form state
      ref.read(signupControllerProvider.notifier).resetForm();
    });
    
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
    controller.setEmailExists(false);
    
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
      final errorMessage = e.toString().replaceAll('Exception:', '').trim();
      
      // Check if the error indicates that email already exists
      if (errorMessage.toLowerCase().contains('email') && 
          (errorMessage.toLowerCase().contains('exist') || 
           errorMessage.toLowerCase().contains('already') ||
           errorMessage.toLowerCase().contains('registered'))) {
        controller.setEmailExists(true);
        controller.setError('An account with this email already exists. Try logging in or resetting your password.');
      } else {
        controller.setError(errorMessage);
      }
    } finally {
      controller.setLoading(false);
    }
  }

  void handleResetPassword() {
    // Navigate to reset password screen
    context.go('/forgetpassword');
  }

  void handleLogin() {
    // Navigate to login screen
    context.go('/login');
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
                  if (signupState.emailExists) ...[
                    // Show Reset Password and Login buttons when email exists
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 24),
                      child: PrimaryButton(
                        isDisabled: false,
                        text: localizations.text("reset_password"),
                        onPressed: handleResetPassword,
                        isHollow: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: PrimaryButton(
                        isDisabled: false,
                        text: localizations.text("login_button"),
                        onPressed: handleLogin,
                      ),
                    ),
                  ] else ...[
                    // Show normal signup button when email doesn't exist
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 24),
                      child: PrimaryButton(
                        isDisabled: signupState.isButtonDisabled || signupState.isLoading,
                        text: localizations.text("complete_sign_up"),
                        onPressed: signupState.isLoading ? null : handleSendOtp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
