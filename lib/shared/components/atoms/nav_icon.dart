import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavIcon extends StatelessWidget {
  final String asset;
  final Color color;
  final double size;

  const NavIcon({
    super.key,
    required this.asset,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: SvgPicture.asset(
        asset,
        color: color,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}

