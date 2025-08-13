import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:flutter/material.dart';

class MenuSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const MenuSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: const Color(0xFF6C757D),
          ),
        ),
        SizedBox(height: AppConstants.contentSpacing),
        ...children,
        SizedBox(height: AppConstants.headerToContentSpacingMedium),
      ],
    );
  }
}
