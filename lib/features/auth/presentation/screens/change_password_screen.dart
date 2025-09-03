import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/shared/components/organisms/sticky_header_scaffold.dart';
import 'package:bookit_mobile_app/shared/components/atoms/password_input_field.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/change_password_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _oldPasswordController.addListener(_onPasswordChange);
    _newPasswordController.addListener(_checkFormValidity);
    _confirmPasswordController.addListener(_checkFormValidity);
    
    // Reset form state and clear fields when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(changePasswordControllerProvider.notifier).resetForm();
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  void _onPasswordChange() {
    // Clear error when user starts typing in old password field
    if (mounted) {
      ref.read(changePasswordControllerProvider.notifier).clearError();
    }
    _checkFormValidity();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    setState(() {});
  }

  bool _hasMinLength(String password) => password.length >= 8;
  bool _hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));
  bool _hasSpecialChar(String password) => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool _hasNumber(String password) => password.contains(RegExp(r'[0-9]'));
  bool _passwordsMatch() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    return newPassword.isNotEmpty && 
           confirmPassword.isNotEmpty && 
           newPassword == confirmPassword;
  }

  bool _isFormValid() {
    final newPassword = _newPasswordController.text;
    final isPasswordValid = _hasMinLength(newPassword) &&
                           _hasUppercase(newPassword) &&
                           _hasSpecialChar(newPassword) &&
                           _hasNumber(newPassword) &&
                           _passwordsMatch();
    
    return _oldPasswordController.text.isNotEmpty && isPasswordValid;
  }

  Future<void> _handleChangePassword() async {
    // Only proceed if form is valid
    if (!_isFormValid()) return;
    
    final controller = ref.read(changePasswordControllerProvider.notifier);
    
    try {
      final success = await controller.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        if (mounted) context.pop();
      }
    } catch (e) {
      // Error handling is done in the controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changePasswordState = ref.watch(changePasswordControllerProvider);
    final isFormValid = _isFormValid();
    final isLoading = changePasswordState.when(
      data: (state) => state.isLoading,
      loading: () => true,
      error: (_, __) => false,
    );
    
    return StickyHeaderScaffold(
      title: 'Password & security',
      showBackButton: true,
      onBackPressed: () => context.pop(),
      buttonText: isLoading ? 'Changing password...' : 'Save',
      isButtonDisabled: !isFormValid || isLoading,
      onButtonPressed: _handleChangePassword,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Old Password Field
          PasswordInputField(
            hintText: 'Old password',
            controller: _oldPasswordController,
          ),
          
          const SizedBox(height: AppConstants.fieldToFieldSpacing),
          
          // Error Display for old password
          changePasswordState.when(
            data: (state) {
              if (state.error != null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.smallContentSpacing),
                  child: Text(
                    state.error!,
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (error, _) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.smallContentSpacing),
              child: Text(
                error.toString(),
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
          
          // New Password Field
          PasswordInputField(
            hintText: 'New password',
            controller: _newPasswordController,
          ),
          
          const SizedBox(height: AppConstants.fieldToFieldSpacing),
          
          // Confirm New Password Field
          PasswordInputField(
            hintText: 'Confirm new password',
            controller: _confirmPasswordController,
          ),
          
          const SizedBox(height: AppConstants.fieldToFieldSpacing),
          
          // Password Requirements
          Text(
            'Password must contain:',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.appLightGrayFont,
            ),
          ),
          const SizedBox(height: 5),
          _buildRequirementItem('8 characters', _hasMinLength(_newPasswordController.text)),
          _buildRequirementItem('1 uppercase letter (A,B,C...)', _hasUppercase(_newPasswordController.text)),
          _buildRequirementItem('1 special character', _hasSpecialChar(_newPasswordController.text)),
          _buildRequirementItem('1 alphanumeric character', _hasNumber(_newPasswordController.text)),
          _buildRequirementItem('Password match', _passwordsMatch()),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? AppColors.primary : AppColors.error,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              requirement,
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