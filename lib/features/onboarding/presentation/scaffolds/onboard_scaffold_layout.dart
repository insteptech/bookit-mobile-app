import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
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
  final bool backButtonDisabled;

  const OnboardScaffoldLayout({
    super.key,
    required this.heading,
    required this.subheading,
    required this.body,
    required this.onNext,
    required this.nextButtonText,
    required this.nextButtonDisabled,
    required this.currentStep,
    required this.backButtonDisabled
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.onboardingScaffoldPadding,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppConstants.scaffoldTopSpacingWithBackButton),
                      ProgressStepper(currentStep: currentStep),
                      if(!backButtonDisabled)
                      SizedBox(height: AppConstants.progressToBackButtonSpacing,),
                      if(!backButtonDisabled)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: (){
                              context.pop();
                            },
                            child: 
                            Icon(Icons.arrow_back, size: AppConstants.backButtonIconSize,)
                          )
                        ],
                      ),
                      if(backButtonDisabled)
                      SizedBox(height: AppConstants.onboardingNoBackButtonSpacing,),
                      SizedBox(height: AppConstants.backButtonToTitleSpacing),
                      Text(heading, style: AppTypography.headingLg),
                      SizedBox(height: AppConstants.titleToSubtitleSpacing),
                      Text(subheading, style: AppTypography.bodyMedium),
                      SizedBox(height: AppConstants.headerToContentSpacing),
                      body,
                      SizedBox(height: AppConstants.sectionSpacing),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppConstants.onboardingBottomSpacing),
                child: PrimaryButton(
                onPressed: onNext,
                isDisabled: nextButtonDisabled,
                text: nextButtonText,
              )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
