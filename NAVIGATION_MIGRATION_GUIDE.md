# Navigation Service Migration Guide

## Overview
This guide helps migrate from direct GoRouter usage (`context.go()`, `context.push()`, etc.) to the centralized NavigationService.

## Benefits of Migration
1. **Consistency** - Single navigation pattern across the app
2. **Global Access** - Navigate from services, interceptors, utilities
3. **Centralized Control** - Add logging, analytics, navigation guards
4. **Better Testing** - Mock navigation service for unit tests
5. **Future Extensibility** - Easy to add features like navigation history, breadcrumbs

## Migration Pattern

### Before (Direct GoRouter)
```dart
import 'package:go_router/go_router.dart';

// In widget methods
context.go('/login');
context.push('/settings');
context.pop();
```

### After (NavigationService)
```dart
import 'package:your_app/core/services/navigation_service.dart';

// From anywhere in the app
NavigationService.go('/login');
NavigationService.push('/settings');
NavigationService.pop();
```

## Available Methods

| GoRouter Method | NavigationService Equivalent | Description |
|-----------------|------------------------------|-------------|
| `context.go()` | `NavigationService.go()` | Navigate to route (replace current) |
| `context.push()` | `NavigationService.push()` | Push new route onto stack |
| `context.pop()` | `NavigationService.pop()` | Go back to previous route |
| `context.replace()` | `NavigationService.replace()` | Replace current route |
| `context.canPop()` | `NavigationService.canPop()` | Check if can go back |

## Migration Steps

### Step 1: Update Import Statements
```dart
// Remove
import 'package:go_router/go_router.dart';

// Add
import 'package:your_app/core/services/navigation_service.dart';
```

### Step 2: Replace Navigation Calls
```dart
// Before
context.go('/home');
context.push('/settings');
context.pop();

// After
NavigationService.go('/home');
NavigationService.push('/settings');
NavigationService.pop();
```

### Step 3: Remove BuildContext Dependencies
Since NavigationService doesn't need BuildContext, you can remove mounted checks:

```dart
// Before
if (mounted) {
  context.go('/login');
}

// After
NavigationService.go('/login');
```

## Files Requiring Updates

### Authentication & Onboarding
- `lib/features/splash/presentation/splash_sceen.dart`
- `lib/features/auth/applications/login_controller.dart`
- `lib/features/auth/presentation/login_screen.dart`
- `lib/features/auth/presentation/signup_screen.dart`
- `lib/features/onboarding/presentation/*.dart`

### Main App Navigation
- `lib/features/main/dashboard/presentation/dashboard_screen.dart`
- `lib/features/main/calendar/presentation/*.dart`
- `lib/features/main/menu/presentation/menu_screen.dart`

### Shared Components
- `lib/shared/components/organisms/login_form.dart`
- `lib/shared/components/organisms/signup_form.dart`
- `lib/shared/components/organisms/onboard_scaffold_layout.dart`

## Special Cases

### 1. Navigation with Extra Data
```dart
// Before
context.go('/signup_otp', extra: {'email': email});

// After
NavigationService.go('/signup_otp', extra: {'email': email});
```

### 2. Query Parameters
```dart
// Before
context.push('/otpscreen?email=$email');

// After
NavigationService.push('/otpscreen?email=$email');
```

### 3. Conditional Navigation
```dart
// Before
if (mounted) {
  context.go('/login');
}

// After (no mounted check needed)
NavigationService.go('/login');
```

## Testing Considerations

### Mock Navigation Service for Tests
```dart
class MockNavigationService extends NavigationService {
  List<String> navigationHistory = [];
  
  @override
  static void go(String location, {Object? extra}) {
    navigationHistory.add('go: $location');
  }
  
  @override
  static void push(String location, {Object? extra}) {
    navigationHistory.add('push: $location');
  }
}
```

## Implementation Status

### ✅ Completed
- NavigationService implementation
- Auth interceptor integration
- Enhanced app initialization

### 🔄 In Progress
- Splash screen migration (partially done)

### ⏳ Pending
- Login controller migration
- Onboarding flow migration
- Main app navigation migration
- Shared components migration

## Next Steps

1. **Decide Migration Scope**: Full migration vs selective areas
2. **Update High-Priority Files**: Start with auth and onboarding
3. **Test Navigation Flow**: Ensure all routes work correctly
4. **Add Navigation Logging**: Implement centralized navigation tracking
5. **Update Tests**: Mock navigation service in unit tests

## Notes
- The old methods are marked as `@deprecated` for backwards compatibility
- Migration can be done gradually, file by file
- Both patterns can coexist during transition period
- NavigationService provides fallbacks to context-based navigation
