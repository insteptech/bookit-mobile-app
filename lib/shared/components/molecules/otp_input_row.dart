import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/otp_input_box.dart';
import 'package:flutter/material.dart';

class OtpInputRow extends StatefulWidget {
  final TextEditingController otpController;

  const OtpInputRow({super.key, required this.otpController});

  @override
  State<OtpInputRow> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputRow> {
  final int otpLength = 6;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(otpLength, (_) => TextEditingController());
    focusNodes = List.generate(otpLength, (_) => FocusNode());

    // Add listeners to update the parent controller
    for (var controller in controllers) {
      controller.addListener(_updateParentOtp);
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateParentOtp() {
    final otp = controllers.map((c) => c.text).join();
    widget.otpController.text = otp;
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    _updateParentOtp(); // Manually trigger update when backspacing or changing
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(otpLength, (index) {
            return OtpInputBox(
              controller: controllers[index],
              focusNode: focusNodes[index],
              onChanged: (value) => _onChanged(value, index),
            );
          }),
        ),
      ],
    );
  }
}
