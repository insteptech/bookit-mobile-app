import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/password_validation_widget.dart';
import 'package:bookit_mobile_app/shared/components/organisms/auth_flow_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordValid = false;
  bool isButtonDisabled = true;

  void _updateButtonState() {
    setState(() {
      isButtonDisabled = !(isPasswordValid);
    });
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    return AuthFlowScaffold(
      title: "Forgot password",
      child: Column(
        children: [
          Row(
            children: [
              Text(
            localizations.text("forgot_pass_description3"),
            style: AppTypography.bodyMedium,
          ),
            ],
          ),
          SizedBox(height: 48,),
          PasswordValidationWidget(passwordController: passwordController, confirmPasswordController: confirmPasswordController, onValidationChanged: (isValid){
            setState(() {
              isPasswordValid = isValid;
            });
            _updateButtonState();
          }),
          const Spacer(),
          PrimaryButton(onPressed: (){
            context.push('/signin');
          }, isDisabled: isButtonDisabled, text: localizations.text("forgot_pass_next_button"))
        ],
      ), 
    );
  }
}