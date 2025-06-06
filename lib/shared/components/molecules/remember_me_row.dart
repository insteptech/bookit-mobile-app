import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class RememberMeRow extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool> onChanged;

  const RememberMeRow({
    super.key,
    required this.rememberMe,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(-12, 0),
              child: Checkbox(
                value: rememberMe,
                shape: const CircleBorder(),
                onChanged: (value) => onChanged(value ?? false),
              ),
            ),
            Transform.translate(
              offset: const Offset(-18, 0),
              child: Text(
                localizations.text('remember_me'),
                style: const TextStyle(
                  color: AppColors.onSurfaceLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Campton',
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          localizations.text('forgot_password'),
          style: const TextStyle(
            decoration: TextDecoration.underline,
            color: AppColors.onSurfaceLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Campton',
          ),
        ),
      ],
    );
  }
}
