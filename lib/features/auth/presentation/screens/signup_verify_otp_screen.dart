import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/otp_verification_controller.dart';
import 'package:bookit_mobile_app/shared/components/organisms/otp_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupVerifyOtpScreen extends ConsumerStatefulWidget {
  final String email;
  const SignupVerifyOtpScreen({super.key, required this.email});

  @override
  ConsumerState<SignupVerifyOtpScreen> createState() => _SignupVerifyOtpScreenState();
}

class _SignupVerifyOtpScreenState extends ConsumerState<SignupVerifyOtpScreen> {
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

  Future<void> handleSignup() async {
    final controller = ref.read(otpVerificationControllerProvider.notifier);
    controller.setLoading(true);
    controller.clearError();

    try {
      final authService = AuthService();

      await authService.verifyOTP(
        email: widget.email,
        otp: otpController.text,
      );

      final userDetails = await UserService().fetchUserDetails();

      if (userDetails.businessIds.isNotEmpty) {
        final String businessId = userDetails.businessIds[0];
        final businessDetails = await UserService().fetchBusinessDetails(
          businessId: businessId,
        );
        if (businessDetails.isOnboardingComplete) {
          if(mounted) context.go('/home_screen');
        } else {
          if(mounted) context.go('/onboarding_welcome');
        }
      } else {
        if(mounted) context.go('/onboarding_welcome');
      }

      if (!mounted) return;

      context.go('/onboarding_welcome');
    } catch (e) {
      controller.setError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppTranslationsDelegate.of(context);
    final otpState = ref.watch(otpVerificationControllerProvider);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                localizations.text("sign_up"),
                style: AppTypography.headingLg,
              ),
              const SizedBox(height: 8),
              Text("To verify your email we’ve sent a 6-digit code to ${widget.email}", style: AppTypography.bodyMedium,),
              const SizedBox(height: 3),
              if (otpState.error?.isNotEmpty == true)
                Text(
                  otpState.error!,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              SizedBox(height: 48),
              Expanded(
                child: OtpForm(
                  otpController: otpController,
                  email: widget.email,
                  nextButton: () async {
                    await handleSignup();
                  },
                  isSubmitting: otpState.isLoading,
                  nextButtonText: "Complete sign up",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}