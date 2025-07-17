import 'dart:async';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/shared/components/molecules/otp_input_row.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:flutter/material.dart';

class OtpForm extends StatefulWidget {
  final TextEditingController otpController;
  final String email;
  final Function nextButton;
  final bool isSubmitting;
  final String nextButtonText;

  const OtpForm({
    super.key,
    required this.otpController,
    required this.email,
    required this.nextButton,
    required this.isSubmitting,
    required this.nextButtonText
  });

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  bool isButtonDisabled = true;
  bool isResendEnabled = false;
  String error = "";
  Timer? _timer;
  int _timerSeconds = 600; // 10 minutes = 600 seconds
  bool isResendLoading = false;

  @override
  void initState() {
    super.initState();
    widget.otpController.addListener(() {
      setState(() {
        isButtonDisabled = widget.otpController.text.length < 6;
      });
    });
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 600; // Reset to 10 minutes
      isResendEnabled = false;
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        setState(() {
          isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  Future<void> resendOtp() async {
    if (!isResendEnabled || isResendLoading) return;
    
    setState(() {
      isResendLoading = true;
      error = "";
    });

    try {
      await AuthService().resendOtp(widget.email);
      setState(() {
        error = "OTP sent successfully";
      });
      _startTimer(); // Restart the timer
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      setState(() {
        isResendLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
          onTap: isResendEnabled && !isResendLoading ? resendOtp : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: isResendLoading
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Text(
                    isResendEnabled
                        ? localizations.text("forgot_pass_resend_code_link")
                        : "Resend in ${_formatTime(_timerSeconds)}",
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (error.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.bodySmall.copyWith(
              color: error.contains("successfully")
                  ? Colors.green
                  : theme.colorScheme.error,
            ),
          ),
        ],
        const Spacer(),
        PrimaryButton(
          onPressed: () {
            widget.nextButton();
          },
          isDisabled: isButtonDisabled || widget.isSubmitting,
          text: widget.nextButtonText
          // text: localizations.text("forgot_pass_next_button"),
        ),
      ],
    );
  }
}