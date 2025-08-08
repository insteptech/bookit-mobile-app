import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/auth/presentation/widgets/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget{
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppTranslationsDelegate.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 35, right: 35),
          child: Column(
            children: [
              // Header section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.scaffoldTopSpacing),
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: const Offset(-10, 0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Text(
                    localizations.text("sign_up"),
                    style: AppTypography.headingLg,
                  ),
                  Row(
                    children: [
                      Text(localizations.text("already_have_an_account_?"), style: AppTypography.bodyMedium),
                      Text(" "),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(localizations.text("sign_in"), style: AppTypography.bodyMedium.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
                      )
                    ],
                  ),
                  const SizedBox(height: 48,),
                ],
              ),
              // Form section
              Expanded(
                child: SignupForm()
              )
            ],
          )
        )
      )
    );
  }
}