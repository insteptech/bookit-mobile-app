import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/auth/scaffolds/auth_flow_scaffold.dart';
import 'package:bookit_mobile_app/shared/components/organisms/otp_form.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  String error = "";

  Future<void> handleVerifyOtp() async {
    if (otpController.text.isEmpty || otpController.text.length != 6) {
      setState(() {
        error = "Please enter a valid 6-digit OTP";
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      await APIRepository.verifyResetOtp(
        email: widget.email,
        otp: otpController.text,
      );
      
      if (!mounted) return;
      context.push('/newpassword?email=${widget.email}');
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

    return AuthFlowScaffold(
      title: localizations.text("forgot_pass_app_bar_title"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${localizations.text("forgot_pass_description2")} ${widget.email}.",
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (error.isNotEmpty)
            Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          const SizedBox(height: 48),
          Expanded(
            child: OtpForm(
              otpController: otpController,
              email: widget.email,
              nextButton: handleVerifyOtp,
              isSubmitting: isLoading,
              nextButtonText: isLoading ? "Verifying..." : "Next",
            ),
          ),
        ],
      ),
    );
  }
}
