import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/shared/components/organisms/otp_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupVerifyOtpScreen extends StatefulWidget {
  final String email;
  const SignupVerifyOtpScreen({super.key, required this.email});

  @override
  State<SignupVerifyOtpScreen> createState() => _SignupVerifyOtpScreenState();
}

class _SignupVerifyOtpScreenState extends State<SignupVerifyOtpScreen> {
  bool isLoading = false;
  String error = "";

  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleSignup() async {
    setState(() {
      isLoading = true;
      error = "";
    });

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
      setState(() {
        error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppTranslationsDelegate.of(context);
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
              if (error.isNotEmpty)
                Text(
                  error,
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
                  isSubmitting: isLoading,
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