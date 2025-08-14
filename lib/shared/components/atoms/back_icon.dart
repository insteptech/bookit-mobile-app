import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackIcon extends StatelessWidget {
  final double? size;
  final Color? color;
  final VoidCallback? onPressed;

  const BackIcon({
    super.key,
    this.size,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onPressed,
        child: SvgPicture.asset(
          'assets/icons/actions/back.svg',
          width: size ?? 32,
          height: size ?? 32,
          color: color,
        ),
      ),
    );
  }
}
