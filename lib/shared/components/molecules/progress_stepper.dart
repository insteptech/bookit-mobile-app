import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep;

  const ProgressStepper({super.key, required this.currentStep});


  final List<String> steps = const [
    "About You",
    "Locations",
    "Your offerings",
    "Select services",
    "Services details"
  ];

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
    return Row(
      children: 
        List.generate(steps.length, (index){
          bool isActive = index <= currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppConstants.progressStepperMargin),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? theme.colorScheme.primary : AppColors.socialIcon,
                borderRadius: BorderRadius.circular(4)
              ),
            )
          );
        })
    );
  }
}