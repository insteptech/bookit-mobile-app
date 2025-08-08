import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/password_validation_widget.dart';
import 'package:bookit_mobile_app/features/auth/presentation/scaffolds/auth_flow_scaffold.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/create_new_password_controller.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateNewPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const CreateNewPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends ConsumerState<CreateNewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the email in the state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createNewPasswordControllerProvider.notifier).updateEmail(widget.email);
    });
    
    passwordController.addListener(() {
      ref.read(createNewPasswordControllerProvider.notifier).updatePassword(passwordController.text);
    });
    confirmPasswordController.addListener(() {
      ref.read(createNewPasswordControllerProvider.notifier).updateConfirmPassword(confirmPasswordController.text);
    });
  }

  Future<void> handleResetPassword() async {
    final controller = ref.read(createNewPasswordControllerProvider.notifier);
    final state = ref.read(createNewPasswordControllerProvider);
    
    if (!state.isFormValid) {
      controller.setError("Please ensure passwords match and meet requirements");
      return;
    }

    controller.setLoading(true);
    controller.clearError();

    try {
      await APIRepository.resetPassword(
        email: widget.email,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      
      if (!mounted) return;
      context.push('/signin');
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
    final createPasswordState = ref.watch(createNewPasswordControllerProvider);
    
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
          if (createPasswordState.error?.isNotEmpty == true)
            Text(
              createPasswordState.error!,
              style: AppTypography.bodySmall.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          const SizedBox(height: 48),
          PasswordValidationWidget(
            passwordController: passwordController, 
            confirmPasswordController: confirmPasswordController, 
            onValidationChanged: (isValid) {
              ref.read(createNewPasswordControllerProvider.notifier).updatePasswordValid(isValid);
            }
          ),
          const Spacer(),
          PrimaryButton(
            onPressed: createPasswordState.isLoading ? null : handleResetPassword,
            isDisabled: createPasswordState.isButtonDisabled || createPasswordState.isLoading,
            text: createPasswordState.isLoading 
                ? "Resetting..." 
                : localizations.text("forgot_pass_next_button"),
          )
        ],
      ), 
    );
  }
}