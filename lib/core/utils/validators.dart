/// Checks if the password has at least 8 characters.
bool isPasswordLengthSufficient(String password) => password.length >= 8;

/// Checks if the password contains at least one uppercase letter.
bool containsUppercaseLetter(String password) =>
    RegExp(r'[A-Z]').hasMatch(password);

/// Checks if the password contains at least one special character.
bool containsSpecialCharacter(String password) =>
    RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

/// Checks if the password contains at least one number.
bool containsNumericCharacter(String password) =>
    RegExp(r'\d').hasMatch(password);

/// Checks if both password fields match.
bool doPasswordsMatch(String password, String confirmPassword) =>
    password == confirmPassword;

/// Checks if email is in correct format
bool isEmailInCorrectFormat(String email) {
  final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  return emailRegex.hasMatch(email);
}

bool isMobileNumberInCorrectFormat(String mobile) {
  // Remove any whitespace
  mobile = mobile.trim();
  
  // Egyptian mobile number patterns:
  // Local format: 01[0125]xxxxxxxx (11 digits)
  // International format: +2001[0125]xxxxxxxx (14 digits with +20)
  final RegExp localFormat = RegExp(r'^01[0125]\d{8}$');
  final RegExp internationalFormat = RegExp(r'^\+201[0125]\d{8}$');
  // Debug logging - remove in production
  // print(localFormat.hasMatch(mobile) || internationalFormat.hasMatch(mobile));
  
  return localFormat.hasMatch(mobile) || internationalFormat.hasMatch(mobile);
}