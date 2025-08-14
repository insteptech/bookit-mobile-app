import 'dart:async';

import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A two-step delete action that matches Figma specs:
/// 1) Idle: 18x18 trash outline icon (#790077)
/// 2) Confirm: pill button height 24, padding 4x8, radius 100, text "Delete"
///    Campton 12 semi-bold, white text, background #EA52E7
class DeleteAction extends StatefulWidget {
  final VoidCallback onConfirm;
  final Duration confirmTimeout;
  final String iconAssetPath;

  /// Creates a delete action that toggles from icon to a confirm pill.
  ///
  /// [iconAssetPath] should point to the SVG matching the Figma icon.
  const DeleteAction({
    super.key,
    required this.onConfirm,
    this.confirmTimeout = const Duration(seconds: 3),
    this.iconAssetPath = 'assets/icons/actions/trash_medium.svg',
  });

  @override
  State<DeleteAction> createState() => _DeleteActionState();
}

class _DeleteActionState extends State<DeleteAction> {
  bool _isConfirming = false;
  Timer? _revertTimer;

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }

  void _startConfirmTimer() {
    _revertTimer?.cancel();
    _revertTimer = Timer(widget.confirmTimeout, () {
      if (mounted) {
        setState(() => _isConfirming = false);
      }
    });
  }

  void _handleTap() {
    if (_isConfirming) {
      widget.onConfirm();
      setState(() => _isConfirming = false);
      _revertTimer?.cancel();
    } else {
      setState(() => _isConfirming = true);
      _startConfirmTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConfirming) {
      // Idle icon state: exact 18x18
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: SizedBox(
          width: 18,
          height: 18,
          child: SvgPicture.asset(
            widget.iconAssetPath,
            width: 18,
            height: 18,
            color: AppColors.primary,
          ),
        ),
      );
    }

    // Confirm pill state: height 24, padding 4x8, radius 100
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Delete',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.white,
            height: 1.3333333333, // line height ~16px per Figma
          ),
        ),
      ),
    );
  }
}


