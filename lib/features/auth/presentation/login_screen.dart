import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/features/auth/widgets/login_form.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1.0, 0.0), // Center-left positioning
            radius: 1.5,
            colors: [
              Color(0xFF790077), // #790077 - Dark purple at center-left
              Color(0xFFBB27B8), // #BB27B8 - Medium purple 
              Color.fromARGB(255, 249, 139, 249), // #FFF3FF - Light pink at edges
            ],
            stops: [0.3, 0.8, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text(
                localizations.text('good_day'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  color: AppColors.surfaceLight,
                  fontFamily: 'SaintRegusSemiBoldCondensed',
                  fontSize: 56,
                ),
              ),
              const Spacer(flex: 4),
              const LoginForm(),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(child: Divider(color: AppColors.surfaceLight)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "or",
                            style: TextStyle(
                                color: AppColors.surfaceLight,
                                fontFamily: 'Campton',
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.surfaceLight)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: (){
                        context.push('/signup');
                      },
              
                      child: Text(
                        localizations.text('sign_up_link'),
                        style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w500)
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
