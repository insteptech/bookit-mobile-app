import 'package:flutter/material.dart';
import '../../../app/theme/app_typography.dart';
import 'back_icon.dart';

class AppBarTitle extends StatelessWidget {
  final String title;

  const AppBarTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: Offset(0, 0),
              child: BackIcon(
                size: 30,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
        Center(child: Text(title, style: AppTypography.appBarHeading)),
      ],
    );
  }
}
