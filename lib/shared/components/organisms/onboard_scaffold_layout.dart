import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/molecules/progress_stepper.dart';
import 'package:go_router/go_router.dart';

class OnboardScaffoldLayout extends StatelessWidget {
  final String heading;
  final String subheading;
  final Widget body;
  final VoidCallback onNext;
  final String nextButtonText;
  final bool nextButtonDisabled;
  final int currentStep;

  const OnboardScaffoldLayout({
    super.key,
    required this.heading,
    required this.subheading,
    required this.body,
    required this.onNext,
    required this.nextButtonText,
    required this.nextButtonDisabled,
    required this.currentStep,
  });


  @override
  Widget build(BuildContext context) {
  void logout()async{
    await TokenService().clearToken();
    print("Token cleared");
    context.go("/login");
  }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35,),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      ProgressStepper(currentStep: currentStep),
                      const SizedBox(height: 67),
                      Text(heading, style: AppTypography.headingLg),
                      const SizedBox(height: 8),
                      Text(subheading, style: AppTypography.bodyMedium),
                      const SizedBox(height: 48),
                      body,
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: PrimaryButton(
                onPressed: onNext,
                isDisabled: nextButtonDisabled,
                text: nextButtonText,
              )
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 1),
              //   child: PrimaryButton(
              //   onPressed: logout,
              //   isDisabled: false,
              //   text: "Logout",
              // )
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
