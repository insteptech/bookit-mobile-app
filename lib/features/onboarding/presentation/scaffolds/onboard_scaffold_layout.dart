import 'package:bookit_mobile_app/shared/components/organisms/sticky_header_scaffold.dart';
import 'package:bookit_mobile_app/shared/components/molecules/progress_stepper.dart';
import 'package:flutter/material.dart';
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
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? contentPadding;

  const OnboardScaffoldLayout({
    super.key,
    required this.heading,
    required this.subheading,
    required this.body,
    required this.onNext,
    required this.nextButtonText,
    required this.nextButtonDisabled,
    required this.currentStep,
    required this.backButtonDisabled,
    this.contentPadding,
    this.physics
  });

  @override
  Widget build(BuildContext context) {
    return StickyHeaderScaffold(
      title: heading,
      subtitle: subheading,
      showBackButton: !backButtonDisabled,
      onBackPressed: backButtonDisabled ? null : () => context.pop(),
      progressBar: ProgressStepper(currentStep: currentStep),
      content: body,
      contentPadding: contentPadding,
      buttonText: nextButtonText,
      onButtonPressed: onNext,
      isButtonDisabled: nextButtonDisabled,
      physics: physics
    );
  }
}
