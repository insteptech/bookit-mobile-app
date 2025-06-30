import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/password_validation_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}


class _SignupFormState extends ConsumerState<SignupForm>
 {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String error = "";
  bool isButtonDisabled = true;
  bool isPasswordValid = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_updateButtonState);
    emailController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonDisabled =
          !(isPasswordValid &&
              nameController.text.isNotEmpty &&
              isEmailInCorrectFormat(emailController.text));
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

  Future<void> handleSignup() async {
    setState(() {
      isLoading = true;
    });
    try {
      final authService = AuthService();

      await authService.signup(
        nameController.text,
        emailController.text,
        passwordController.text,
      );

      if (!mounted) return; 

      context.go('/onboarding_welcome');
  
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: 620,
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
          if (error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                error,
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
              setState(() {
                isPasswordValid = isValid;
              });
              _updateButtonState();
            },
          ),
          const Spacer(),
          PrimaryButton(
            isDisabled: isButtonDisabled,
            text: localizations.text("complete_sign_up"),
            onPressed: handleSignup,
          ),
        ],
      ),
    );
  }
}
