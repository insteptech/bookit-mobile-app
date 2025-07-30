import 'package:bookit_mobile_app/app/routes.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/navigation_service.dart';

/// Controller for managing menu-related state and business logic
class MenuController extends ChangeNotifier {
  /// Navigate to setup checklist
  void navigateToSetupChecklist() {
    NavigationService.push('/setup_checklist');
  }

  /// Navigate to appointments
  void navigateToAppointments() {
    NavigationService.push('/view_all_appointments');
  }

  /// Navigate to schedule
  void navigateToSchedule() {
    // TODO: Implement schedule screen and add route
    debugPrint('Navigate to Schedule - Screen not implemented yet');
  }

  /// Navigate to wellness offerings
  void navigateToWellness() {
    // TODO: Implement wellness screen and add route
    debugPrint('Navigate to Wellness - Screen not implemented yet');
  }

  /// Navigate to classes offerings
  void navigateToClasses() {
    // TODO: Implement classes screen and add route
    debugPrint('Navigate to Classes - Screen not implemented yet');
  }

  /// Navigate to beauty offerings
  void navigateToBeauty() {
    // TODO: Implement beauty screen and add route
    debugPrint('Navigate to Beauty - Screen not implemented yet');
  }

  /// Navigate to staff profiles
  void navigateToProfiles() {
    NavigationService.push('/all_staff_members');
  }

  /// Navigate to business information
  void navigateToBusinessInformation() {
    NavigationService.push('/menu_business_information');
  }

  /// Navigate to client web app
  void navigateToClientWebApp() {
    NavigationService.push('/menu_client_web_app');
  }

  /// Navigate to billing & payment
  void navigateToBillingPayment() {
    // TODO: Implement billing & payment screen and add route
    debugPrint('Navigate to Billing & Payment - Screen not implemented yet');
  }

  /// Navigate to password & security
  void navigateToPasswordSecurity() {
    // TODO: Implement password & security screen and add route
    debugPrint('Navigate to Password & Security - Screen not implemented yet');
  }

  /// Navigate to app language
  void navigateToAppLanguage() {
    NavigationService.push('/app_language');
  }

  /// Navigate to membership status
  void navigateToMembershipStatus() {
    // TODO: Implement membership status screen and add route
    debugPrint('Navigate to Membership Status - Screen not implemented yet');
  }

  /// Navigate to notifications
  void navigateToNotifications() {
    // TODO: Implement notifications screen and add route
    debugPrint('Navigate to Notifications - Screen not implemented yet');
  }

  /// Navigate to account visibility
  void navigateToAccountVisibility() {
    // TODO: Implement account visibility screen and add route
    debugPrint('Navigate to Account Visibility - Screen not implemented yet');
  }

  /// Navigate to terms & conditions
  void navigateToTermsConditions() {
    NavigationService.push('/terms_conditions');
  }
}
