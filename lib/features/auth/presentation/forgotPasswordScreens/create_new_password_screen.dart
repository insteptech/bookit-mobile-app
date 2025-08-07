import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/password_validation_widget.dart';
import 'package:bookit_mobile_app/features/auth/scaffolds/auth_flow_scaffold.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  const CreateNewPasswordScreen({super.key, required this.email});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordValid = false;
  bool isButtonDisabled = true;
  bool isLoading = false;
  String error = "";

  void _updateButtonState() {
    setState(() {
      isButtonDisabled = !(isPasswordValid);
    });
  }

  Future<void> handleResetPassword() async {
    if (!isPasswordValid) {
      setState(() {
        error = "Please ensure passwords match and meet requirements";
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      await APIRepository.resetPassword(
        email: widget.email,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      
      if (!mounted) return;
      context.push('/signin');
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    final theme = Theme.of(context);
    
    return AuthFlowScaffold(
      title: "Forgot password",
      child: Column(
        children: [
          Row(
            children: [
              Text(
                localizations.text("forgot_pass_description3"),
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (error.isNotEmpty)
            Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          const SizedBox(height: 48),
          PasswordValidationWidget(
            passwordController: passwordController, 
            confirmPasswordController: confirmPasswordController, 
            onValidationChanged: (isValid) {
              setState(() {
                isPasswordValid = isValid;
              });
              _updateButtonState();
            }
          ),
          const Spacer(),
          PrimaryButton(
            onPressed: isLoading ? null : handleResetPassword,
            isDisabled: isButtonDisabled || isLoading,
            text: isLoading 
                ? "Resetting..." 
                : localizations.text("forgot_pass_next_button"),
          )
        ],
      ), 
    );
  }
}