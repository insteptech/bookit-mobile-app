import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';

/// A global navigation service that allows navigation from anywhere in the app,
/// including from services and interceptors outside the widget tree.
/// 
/// This service provides a consistent interface for navigation throughout the app
/// and can be used both in UI components and service classes.
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static GoRouter? _router;

  /// Initialize the navigation service with the GoRouter instance
  static void initialize(GoRouter router) {
    _router = router;
  }

  /// Get the current BuildContext if available
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to login screen and clear navigation stack
  static void navigateToLogin() {
    go(AppRoutes.login);
  }

  /// Navigate to a specific route (replaces current route)
  static void go(String location, {Object? extra}) {
    _validateRoute(location);
    if (_router != null) {
      _router!.go(location, extra: extra);
    } else {
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.go(location, extra: extra);
      } else {
        debugPrint('Warning: Unable to navigate to $location - no router or context available');
      }
    }
  }

  /// Push a new route onto the stack
  static void push(String location, {Object? extra}) {
    _validateRoute(location);
    if (_router != null) {
      _router!.push(location, extra: extra);
    } else {
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.push(location, extra: extra);
      } else {
        debugPrint('Warning: Unable to push to $location - no router or context available');
      }
    }
  }

  /// Replace the current route
  static void replace(String location, {Object? extra}) {
    _validateRoute(location);
    if (_router != null) {
      _router!.replace(location, extra: extra);
    } else {
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.replace(location, extra: extra);
      } else {
        debugPrint('Warning: Unable to replace with $location - no router or context available');
      }
    }
  }

  /// Go back to previous route
  static void pop([Object? result]) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.pop(result);
    } else {
      debugPrint('Warning: Unable to go back - no context available');
    }
  }

  /// Check if we can go back
  static bool canPop() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      return context.canPop();
    }
    return false;
  }

  /// Get current route location
  static String? get currentLocation {
    final context = navigatorKey.currentContext;
    if (context != null) {
      return GoRouterState.of(context).uri.toString();
    }
    return null;
  }

  /// Validate route before navigation
  static void _validateRoute(String route) {
    if (!AppRoutes.isValidRoute(route)) {
      debugPrint('Warning: Attempting to navigate to unregistered route: $route');
    }
  }

  // Commonly used navigation methods with type safety
  
  /// Navigate to home screen
  static void goToHome() => go(AppRoutes.homeScreen);
  
  /// Navigate to login
  static void goToLogin() => go(AppRoutes.login);
  
  /// Navigate to app language screen
  static void pushAppLanguage() => push(AppRoutes.appLanguage);
  
  /// Navigate to staff list
  static void pushStaffList() => push(AppRoutes.staffList);
  
  /// Navigate to book appointment
  static void pushBookAppointment() => push(AppRoutes.bookNewAppointment);
  
  /// Navigate to add staff screen
  static void pushAddStaff({bool isClass = false}) => push(AppRoutesExtension.addStaffWithType(isClass: isClass));

  /// Navigate to service categories selection
  static void pushServiceCategories() => push(AppRoutes.addServiceCategories);
  
  /// Navigate to add service with category
  static void pushAddServiceWithCategory({required String categoryId, required String categoryName}) => 
    push(AppRoutesExtension.addServiceWithCategory(categoryId: categoryId, categoryName: categoryName));

  // Legacy methods for backwards compatibility
  @Deprecated('Use go() instead')
  static void navigateTo(String route, {Object? extra}) => go(route, extra: extra);
  
  @Deprecated('Use push() instead')
  static void pushTo(String route, {Object? extra}) => push(route, extra: extra);
  
  @Deprecated('Use pop() instead')
  static void goBack() => pop();
  
  @Deprecated('Use canPop() instead')
  static bool canGoBack() => canPop();
}
