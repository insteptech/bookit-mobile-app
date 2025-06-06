import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/features/auth/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_data.dart';
import '../atoms/input_field.dart';
import '../molecules/remember_me_row.dart';

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppTranslationsDelegate.of(context);
    final rememberMe = ref.watch(rememberMeProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InputField(
            hintText: localizations.text('email'),
            controller: TextEditingController(),
          ),
          const SizedBox(height: 16),
          InputField(
            hintText: localizations.text('password'),
            controller: TextEditingController(),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          RememberMeRow(
            rememberMe: rememberMe,
            onChanged: (value) {
              ref.read(rememberMeProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon('assets/icons/apple.svg'),
              const SizedBox(width: 16),
              _socialIcon('assets/icons/google.svg'),
              const SizedBox(width: 16),
              _socialIcon('assets/icons/facebook.svg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: lightTheme.focusColor, width: 1),
      ),
      child: SvgPicture.asset(assetPath, height: 20, width: 20),
    );
  }
}
