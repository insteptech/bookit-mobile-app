import 'package:flutter/material.dart';

/// App design constants for consistent spacing, sizing, and layout
/// throughout the BookIt mobile application.
class AppConstants {
  // ═══════════════════════════════════════════════════════════════════════════════════
  // SCAFFOLD & LAYOUT CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Default top spacing from SafeArea in scaffolds
  static const double scaffoldTopSpacing = 2;
  
  /// Reduced top spacing for scaffolds with back button
  static const double scaffoldTopSpacingWithBackButton = 2;
  
  /// Alternative top spacing used in some scaffolds
  static const double scaffoldTopSpacingAlt = 2;
  
  /// Spacing after back button before title
  static const double backButtonToTitleSpacing = 0;
  
  /// Alternative spacing after back button (onboarding style)
  static const double backButtonToTitleSpacingAlt = 0;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // PADDING & MARGINS
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Default horizontal padding for most screens
  static const double defaultHorizontalPadding = 20.0;
  
  /// Alternative horizontal padding used in auth and onboarding
  static const double authHorizontalPadding = 20.0;
  
  /// Default vertical padding for scaffold content
  static const double defaultVerticalPadding = 0;
  
  /// Default scaffold content padding
  // static const EdgeInsets defaultScaffoldPadding = EdgeInsets.symmetric(
  //   horizontal: defaultHorizontalPadding,
  //   vertical: defaultVerticalPadding,
  // );
   static const EdgeInsets defaultScaffoldPadding = EdgeInsets.fromLTRB(
    defaultHorizontalPadding, defaultVerticalPadding, defaultHorizontalPadding, 0
  );

  /// Auth flow scaffold padding
  static const EdgeInsets authScaffoldPadding = EdgeInsets.symmetric(
    horizontal: authHorizontalPadding,
  );
  
  /// Onboarding scaffold padding
  static const EdgeInsets onboardingScaffoldPadding = EdgeInsets.symmetric(
    horizontal: authHorizontalPadding,
  );

  // ═══════════════════════════════════════════════════════════════════════════════════
  // VERTICAL SPACING BETWEEN ELEMENTS
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Spacing between title and subtitle in headers
  static const double titleToSubtitleSpacing = 8.0;
  
  /// Large spacing between header and main content
  static const double headerToContentSpacing = 48.0;
  
  /// Medium spacing between header and content (alternative)
  static const double headerToContentSpacingMedium = 32.0;
  
  /// Spacing between content sections
  static const double sectionSpacing = 24.0;
  
  /// Small spacing between content elements
  static const double contentSpacing = 16.0;
  
  /// Extra small spacing between related elements
  static const double smallContentSpacing = 8.0;
  
  /// Tiny spacing for very close elements
  static const double tinySpacing = 3.0;
  
  /// Large spacing for significant content separation
  static const double largeContentSpacing = 40.0;
  
  /// Spacing before bottom buttons
  static const double bottomButtonSpacing = 24.0;
  
  /// Spacing after bottom buttons (bottom margin)
  static const double bottomButtonMargin = 16.0;
  
  /// Alternative bottom spacing used in onboarding
  static const double onboardingBottomSpacing = 12.0;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // FORM & INPUT FIELD SPACING
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Spacing between input field label and the field itself
  static const double labelToFieldSpacing = 8.0;
  
  /// Spacing between consecutive input fields
  static const double fieldToFieldSpacing = 16.0;
  
  /// Spacing between form sections
  static const double formSectionSpacing = 24.0;
  
  /// Input field internal padding (horizontal)
  static const double fieldHorizontalPadding = 16.0;
  
  /// Input field internal padding (vertical)
  static const double fieldVerticalPadding = 10.0;
  
  /// Input field content padding
  static const EdgeInsets fieldContentPadding = EdgeInsets.symmetric(
    horizontal: fieldHorizontalPadding,
    vertical: fieldVerticalPadding,
  );

  // ═══════════════════════════════════════════════════════════════════════════════════
  // LIST & ITEM SPACING
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Vertical gap between list items
  static const double listItemSpacing = 12.0;
  
  /// Vertical gap between menu items
  static const double menuItemSpacing = 16.0;
  
  /// Section spacing in lists
  static const double listSectionSpacing = 32.0;
  
  /// Spacing between list sections with headers
  static const double listHeaderSpacing = 16.0;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // BUTTON SPACING & SIZING
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Primary button internal vertical padding
  static const double buttonVerticalPadding = 12.0;
  
  /// Primary button internal horizontal padding
  static const double buttonHorizontalPadding = 16.0;
  
  /// Button content padding
  static const EdgeInsets buttonContentPadding = EdgeInsets.symmetric(
    horizontal: buttonHorizontalPadding,
    vertical: buttonVerticalPadding,
  );
  
  /// Spacing between buttons in button groups
  static const double buttonGroupSpacing = 16.0;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // ICON & UI ELEMENT SIZING
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Standard back button icon size
  static const double backButtonIconSize = 32.0;
  
  /// Standard menu icon size
  static const double menuIconSize = 24.0;
  
  /// Small icon size
  static const double smallIconSize = 16.0;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // NAVIGATION & BOTTOM BAR
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Bottom navigation bar top padding
  static const double bottomNavTopPadding = 5.0;
  
  /// Bottom navigation selected label font size
  static const double bottomNavSelectedFontSize = 14.0;
  
  /// Bottom navigation unselected label font size
  static const double bottomNavUnselectedFontSize = 14.0;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // CARD & CONTAINER SPACING
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Standard card internal padding
  static const double cardPadding = 16.0;
  
  /// Large card internal padding
  static const double cardPaddingLarge = 32.0;
  
  /// Small card internal padding
  static const double cardPaddingSmall = 8.0;
  
  /// Card margin from screen edges
  static const double cardMargin = 16.0;
  
  /// Spacing between cards
  static const double cardSpacing = 12.0;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // SPECIALIZED COMPONENT SPACING
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Progress stepper margin
  static const double progressStepperMargin = 4.0;
  
  /// OTP input horizontal padding
  static const double otpInputHorizontalPadding = 2.0;
  
  /// Map selector content padding
  static const EdgeInsets mapSelectorPadding = EdgeInsets.fromLTRB(25, 12, 20, 10);
  
  /// Switch component margin
  static const double switchMargin = 2.0;
  
  /// Calendar day horizontal padding
  static const double calendarDayPadding = 10.0;
  
  /// Calendar day vertical padding
  static const double calendarDayVerticalPadding = 6.0;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // ONBOARDING SPECIFIC CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Spacing between progress stepper and back button
  static const double progressToBackButtonSpacing = 26.0;
  
  /// Spacing when no back button is shown in onboarding
  static const double onboardingNoBackButtonSpacing = 63.0;

  // ═══════════════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════════════
  
  /// Returns a SizedBox with standard small vertical spacing
  static Widget get smallVerticalSpacing => const SizedBox(height: smallContentSpacing);
  
  /// Returns a SizedBox with standard content vertical spacing
  static Widget get verticalSpacing => const SizedBox(height: contentSpacing);
  
  /// Returns a SizedBox with standard section vertical spacing
  static Widget get sectionVerticalSpacing => const SizedBox(height: sectionSpacing);
  
  /// Returns a SizedBox with large vertical spacing
  static Widget get largeVerticalSpacing => const SizedBox(height: largeContentSpacing);
  
  /// Returns a SizedBox with header to content spacing
  static Widget get headerVerticalSpacing => const SizedBox(height: headerToContentSpacing);
  
  /// Returns a SizedBox with title to subtitle spacing
  static Widget get titleVerticalSpacing => const SizedBox(height: titleToSubtitleSpacing);
  
  /// Returns a SizedBox with field spacing
  static Widget get fieldVerticalSpacing => const SizedBox(height: fieldToFieldSpacing);
  
  /// Returns a SizedBox with custom height
  static Widget verticalSpace(double height) => SizedBox(height: height);
  
  /// Returns a SizedBox with custom width
  static Widget horizontalSpace(double width) => SizedBox(width: width);
}
