import 'package:flutter/material.dart';
import '../../../app/theme/app_typography.dart';

class AppBarTitle extends StatelessWidget {
  final String title;

  const AppBarTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        Center(
          child: Text(
            title,
            style: AppTypography.appBarHeading,
          ),
        ),
      ],
    );
  }
}
