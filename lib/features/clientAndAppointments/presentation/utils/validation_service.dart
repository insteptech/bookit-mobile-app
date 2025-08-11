class ValidationService {
  /// Validates email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  /// Validates phone number (10-15 digits)
  static bool isValidPhone(String phone) {
    // Remove all non-digit characters for validation
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  /// Validates name (minimum 2 characters)
  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  /// Validates that a string is not empty after trimming
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  /// Validates client form data and returns error message if any
  static String? validateClientForm({
    required String name,
    required String email,
    required String phone,
  }) {
    if (!isNotEmpty(name)) {
      return "Name is required";
    }
    if (!isValidName(name)) {
      return "Name must be at least 2 characters";
    }
    if (!isNotEmpty(email)) {
      return "Email is required";
    }
    if (!isValidEmail(email)) {
      return "Please enter a valid email address";
    }
    if (!isNotEmpty(phone)) {
      return "Phone number is required";
    }
    if (!isValidPhone(phone)) {
      return "Please enter a valid phone number (10-15 digits)";
    }
    return null;
  }
}
