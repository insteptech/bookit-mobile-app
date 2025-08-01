# AddStaffScreen Usage Examples

The `AddStaffScreen` has been updated to support flexible category filtering and button modes.

## Parameters

### `isClass` (bool?, optional)
- `null` - Shows all business categories (both class and non-class categories)
- `true` - Shows only class categories
- `false` - Shows only non-class categories

### `buttonMode` (StaffScreenButtonMode)
- `StaffScreenButtonMode.continueToSchedule` (default) - Shows "Continue to Schedule" + "Save & Exit" buttons
- `StaffScreenButtonMode.saveOnly` - Shows only "Save" button

## Navigation Examples

### Show all categories with continue to schedule buttons (default behavior)
```dart
context.push("/add_staff");
```

### Show only class categories with continue to schedule buttons
```dart
context.push("/add_staff?isClass=true");
```

### Show only non-class categories with continue to schedule buttons
```dart
context.push("/add_staff?isClass=false");
```

### Show all categories with save-only button
```dart
context.push("/add_staff?buttonMode=saveOnly");
```

### Show class categories with save-only button
```dart
context.push("/add_staff?isClass=true&buttonMode=saveOnly");
```

## Widget Usage Examples

### Default usage (all categories, continue to schedule)
```dart
AddStaffScreen()
```

### Class categories only with save-only button
```dart
AddStaffScreen(
  isClass: true,
  buttonMode: StaffScreenButtonMode.saveOnly,
)
```

### All categories with save-only button
```dart
AddStaffScreen(
  buttonMode: StaffScreenButtonMode.saveOnly,
)
```

## Category Filtering Logic

- When `isClass` is `null`: All categories are shown
- When `isClass` is `true`: Only categories where `category['isClass'] == true` are shown
- When `isClass` is `false`: Only categories where `category['isClass'] == false` are shown

## Button Behavior

### StaffScreenButtonMode.continueToSchedule
- Primary button: "Continue to Schedule" (or "Adding Staff..." when loading)
- Secondary button: "Save & Exit" (text button)
- Navigation: Goes to schedule screen or staff list based on isClass value

### StaffScreenButtonMode.saveOnly  
- Primary button: "Save" (or "Adding Staff..." when loading)
- Navigation: Just goes back to previous screen

## Implementation Notes

- The `CategorySelector` widget has been updated to handle optional `isClass` parameter
- The `AddMemberForm` widget passes through the optional `isClass` parameter
- Router has been updated to parse query parameters and create appropriate `AddStaffScreen` instances
