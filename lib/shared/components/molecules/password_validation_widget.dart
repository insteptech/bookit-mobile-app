import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/utils/validators.dart';
import 'package:bookit_mobile_app/shared/components/atoms/password_input_field.dart';

class PasswordValidationWidget extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final ValueChanged<bool> onValidationChanged;

  const PasswordValidationWidget({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onValidationChanged,
  });

  @override
  State<PasswordValidationWidget> createState() =>
      _PasswordValidationWidgetState();
}

class _PasswordValidationWidgetState extends State<PasswordValidationWidget> {
  bool isLengthValid = false;
  bool hasUppercase = false;
  bool hasSpecialChar = false;
  bool hasNumber = false;
  bool passwordMatch = false;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_validatePassword);
    widget.confirmPasswordController.addListener(_checkPasswordMatch);
  }

  void _validatePassword() {
    final password = widget.passwordController.text;
    setState(() {
      isLengthValid = isPasswordLengthSufficient(password);
      hasUppercase = containsUppercaseLetter(password);
      hasSpecialChar = containsSpecialCharacter(password);
      hasNumber = containsNumericCharacter(password);
    });
    _checkPasswordMatch();
    _notifyParent();
  }

  void _checkPasswordMatch() {
    setState(() {
      if (widget.passwordController.text.length >= 8) {
        passwordMatch = doPasswordsMatch(
          widget.passwordController.text,
          widget.confirmPasswordController.text,
        );
      }
    });
    _notifyParent();
  }

  void _notifyParent() {
    final isValid = isLengthValid &&
        hasUppercase &&
        hasSpecialChar &&
        hasNumber &&
        passwordMatch;
    widget.onValidationChanged(isValid);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_validatePassword);
    widget.confirmPasswordController.removeListener(_checkPasswordMatch);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PasswordInputField(
          hintText: localizations.text("password"),
          controller: widget.passwordController,
        ),
        const SizedBox(height: 16),
        PasswordInputField(
          hintText: localizations.text("confirm_password"),
          controller: widget.confirmPasswordController,
        ),
        const SizedBox(height: 16),
        Text(
          localizations.text("password_must_contain"),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.appLightGrayFont,
          ),
        ),
        const SizedBox(height: 5),
        _ruleItem(localizations.text("8_characters"), isLengthValid),
        _ruleItem(localizations.text("1_uppercase_letter"), hasUppercase),
        _ruleItem(localizations.text("1_special_character"), hasSpecialChar),
        _ruleItem(localizations.text("1_alphanumeric_character"), hasNumber),
        _ruleItem(localizations.text("password_match"), passwordMatch),
      ],
    );
  }

  Widget _ruleItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.appLightGrayFont,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
