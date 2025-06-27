import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/auth/provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/password_input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/remember_me_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SigninScreen extends ConsumerWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final localizations = AppTranslationsDelegate.of(context);

    final rememberMe = ref.watch(rememberMeProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24,),
              Text("Sign in", style: AppTypography.headingLg,),
              SizedBox(height: 64,),
              InputField(hintText: localizations.text("email"), controller: emailController),
              SizedBox(height: 16,),
              PasswordInputField(hintText: localizations.text("password"), controller: passwordController),
              SizedBox(height: 8,),
              RememberMeRow(rememberMe: rememberMe, onChanged: (value){
                ref.read(rememberMeProvider.notifier).state = value;
              }),
              const Spacer(),
              PrimaryButton(onPressed: (){}, isDisabled: false, text: localizations.text("forgot_pass_done_button"))
            ],
          )
        )
      )
    );
  }
}