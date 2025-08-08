import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:flutter/material.dart';

/// Example showing how to use AppConstants for consistent spacing
/// This can be used as a reference for developers
class AppConstantsExample extends StatelessWidget {
  const AppConstantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          // Use predefined scaffold padding
          padding: AppConstants.defaultScaffoldPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use scaffold top spacing
              SizedBox(height: AppConstants.scaffoldTopSpacing),
              
              const Text(
                'Example Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              
              // Use title to subtitle spacing
              AppConstants.titleVerticalSpacing,
              
              const Text('Subtitle text here'),
              
              // Use header to content spacing
              AppConstants.headerVerticalSpacing,
              
              // Form example with field spacing
              Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'First Field',
                      // Uses field content padding
                      contentPadding: AppConstants.fieldContentPadding,
                    ),
                  ),
                  
                  // Field to field spacing
                  AppConstants.fieldVerticalSpacing,
                  
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Second Field',
                      contentPadding: AppConstants.fieldContentPadding,
                    ),
                  ),
                ],
              ),
              
              // Section spacing
              AppConstants.sectionVerticalSpacing,
              
              // List with proper spacing
              ...List.generate(3, (index) => Container(
                margin: EdgeInsets.only(bottom: AppConstants.listItemSpacing),
                padding: EdgeInsets.all(AppConstants.cardPadding),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('List item ${index + 1}'),
              )),
              
              const Spacer(),
              
              // Bottom button with proper spacing
              SizedBox(height: AppConstants.bottomButtonSpacing),
              
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: AppConstants.buttonContentPadding,
                ),
                child: const Text('Action Button'),
              ),
              
              SizedBox(height: AppConstants.bottomButtonMargin),
            ],
          ),
        ),
      ),
    );
  }
}

/// Utility methods examples
class ConstantsUtilities {
  // Custom spacing examples
  static Widget customSpacing(double height) => AppConstants.verticalSpace(height);
  
  // Quick access to common spacings
  static Widget get smallGap => AppConstants.smallVerticalSpacing;
  static Widget get mediumGap => AppConstants.verticalSpacing;
  static Widget get largeGap => AppConstants.sectionVerticalSpacing;
}
