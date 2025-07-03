import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
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
  bool isButtonDisabled = false;
  String error = "";

  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleSignup() async {
    setState(() {
      isLoading = true;
    });
    isButtonDisabled = true;

    try {
      final authService = AuthService();

      final data = await authService.verifyOTP(
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
          context.go('/home_screen');
        } else {
          context.go('/onboarding_welcome');
        }
      } else {
        context.go('/onboarding_welcome');
      }

      if (!mounted) return;

      context.go('/onboarding_welcome');
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      isButtonDisabled = false;
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
              // AppBarTitle(title: "title"),
              const SizedBox(height: 64),
              Text("Verify your OTP", style: AppTypography.bodyLg),
              const SizedBox(height: 3),
              Text("We’ve sent your 6-digit code to ${widget.email}"),
              const SizedBox(height: 3),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
