import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/features/auth/presentation/scaffolds/auth_flow_scaffold.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/forgot_password_controller.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      ref.read(forgotPasswordControllerProvider.notifier).updateEmail(emailController.text);
    });
  }

  Future<void> handleForgotPassword() async {
    final controller = ref.read(forgotPasswordControllerProvider.notifier);
    
    if (emailController.text.isEmpty) {
      controller.setError("Please enter your email address");
      return;
    }

    controller.setLoading(true);
    controller.clearError();

    try {
      await APIRepository.initiatePasswordReset(email: emailController.text);
      if (!mounted) return;
      
      final email = emailController.text;
      context.push('/otpscreen?email=$email');
    } catch (e) {
      controller.setError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      controller.setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppTranslationsDelegate.of(context);
    final forgotPasswordState = ref.watch(forgotPasswordControllerProvider);

    return AuthFlowScaffold(
      title: localizations.text("forgot_pass_app_bar_title"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.text("forgot_pass_description1"),
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 48),
          InputField(hintText: localizations.text("email"), controller: emailController),
          const SizedBox(height: 8),
          if (forgotPasswordState.error?.isNotEmpty == true)
            Text(
              forgotPasswordState.error!,
              style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.error),
            ),
          const Spacer(),
          PrimaryButton(
            onPressed: forgotPasswordState.isLoading ? null : handleForgotPassword,
            isDisabled: emailController.text.isEmpty || forgotPasswordState.isLoading,
            text: forgotPasswordState.isLoading 
                ? "Sending..." 
                : localizations.text("forgot_pass_next_button"),
          ),
        ],
      ),
    );
  }
}
