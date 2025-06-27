import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/molecules/otp_input_row.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpForm extends StatefulWidget {
  final TextEditingController otpController;
  final String email;

  const OtpForm({
    super.key,
    required this.otpController,
    required this.email,
  });

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {

  bool isButtonDisabled = true;
  
  @override
  void initState(){
    super.initState();
    widget.otpController.addListener(
      (){
        setState(() {
            isButtonDisabled = widget.otpController.text.length < 6;
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        OtpInputRow(otpController: widget.otpController),
        const SizedBox(height: 48),
        Text(
          localizations.text("forgot_pass_didnt_get_code_text"),
          style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            //control data
          },
          child: Text(
            localizations.text("forgot_pass_resend_code_link"),
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        PrimaryButton(
          onPressed: () {
            // OTP verification logic placeholder
            print(widget.otpController.text);
            context.push('/newpassword');
          },
          isDisabled: isButtonDisabled,
          text: localizations.text("forgot_pass_next_button"),
        ),
      ],
    );
  }
}
