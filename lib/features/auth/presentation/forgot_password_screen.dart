import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/features/auth/scaffolds/auth_flow_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String error = "We couldn’t find this email in our database, input a valid email address to continue";

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      setState(() {});
    });
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
          Text(
            error,
            style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.error),
          ),
          const Spacer(),
          PrimaryButton(
            onPressed: () {
              final email = emailController.text;
              context.push('/otpscreen?email=$email');
            },
            isDisabled: emailController.text.isEmpty,
            text: localizations.text("forgot_pass_next_button"),
          ),
        ],
      ),
    );
  }
}
