import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/auth/scaffolds/auth_flow_scaffold.dart';
import 'package:bookit_mobile_app/shared/components/organisms/otp_form.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);

    return AuthFlowScaffold(
      title: localizations.text("forgot_pass_app_bar_title"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${localizations.text("forgot_pass_description2")} ${widget.email}.",
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 48),
          Expanded(
            child: OtpForm(
              otpController: otpController,
              email: widget.email,
              nextButton: (){},
              isSubmitting: false,
              nextButtonText: "Next",
            ),
          ),
        ],
      ),
    );
  }
}
