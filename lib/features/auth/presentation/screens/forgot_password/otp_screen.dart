import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/auth/presentation/scaffolds/auth_flow_scaffold.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/otp_verification_controller.dart';
import 'package:bookit_mobile_app/shared/components/organisms/otp_form.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the email in the state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpVerificationControllerProvider.notifier).updateEmail(widget.email);
    });
    
    otpController.addListener(() {
      ref.read(otpVerificationControllerProvider.notifier).updateOtp(otpController.text);
    });
  }

  Future<void> handleVerifyOtp() async {
    final controller = ref.read(otpVerificationControllerProvider.notifier);
    
    if (otpController.text.isEmpty || otpController.text.length != 6) {
      controller.setError("Please enter a valid 6-digit OTP");
      return;
    }

    controller.setLoading(true);
    controller.clearError();

    try {
      await APIRepository.verifyResetOtp(
        email: widget.email,
        otp: otpController.text,
      );
      
      if (!mounted) return;
      context.push('/newpassword?email=${widget.email}');
    } catch (e) {
      controller.setError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    final otpState = ref.watch(otpVerificationControllerProvider);

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
          if (otpState.error?.isNotEmpty == true)
            Text(
              otpState.error!,
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
              isSubmitting: otpState.isLoading,
              nextButtonText: otpState.isLoading ? "Verifying..." : "Next",
            ),
          ),
        ],
      ),
    );
  }
}
