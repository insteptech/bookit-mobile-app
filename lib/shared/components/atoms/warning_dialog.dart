import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WarningDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? actionButtonColor;
  final Color? actionTextColor;

  const WarningDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actionText,
    required this.onConfirm,
    this.onCancel,
    this.actionButtonColor,
    this.actionTextColor,
  });

  /// Factory constructor for cancel class dialog
  factory WarningDialog.cancelClass({
    required String className,
    required DateTime classDate,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return WarningDialog(
      title: 'Cancel $className',
      message: 'Please note that this will cancel only this single class on ${DateFormat('EEEE, MMMM d').format(classDate)}. Your clients will be automatically notified via email about the cancellation.',
      actionText: 'Proceed to cancellation',
      onConfirm: onConfirm,
      onCancel: onCancel,
      actionButtonColor: Colors.transparent,
      actionTextColor: const Color(0xFF790077),
    );
  }

  /// Factory constructor for generic confirmation dialog
  factory WarningDialog.confirmation({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String actionText = 'Confirm',
    Color? actionButtonColor,
    Color? actionTextColor,
  }) {
    return WarningDialog(
      title: title,
      message: message,
      actionText: actionText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      actionButtonColor: actionButtonColor,
      actionTextColor: actionTextColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main dialog container
          Container(
            width: 325,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26212529), // rgba(33, 37, 41, 0.15)
                  offset: Offset(0, 0),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(32, 56, 32, 56),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and body text
                Column(
                  children: [
                    // Title
                    SizedBox(
                      width: 256,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          height: 1.2,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Body text
                    SizedBox(
                      width: 256,
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.25,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: actionButtonColor ?? Colors.transparent,
                      side: BorderSide(
                        color: actionTextColor ?? AppColors.error,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      actionText,
                      style: TextStyle(
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.25,
                        color: actionTextColor ?? AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Close button positioned absolutely outside the main container
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(false);
                if (onCancel != null) {
                  onCancel!();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 18,
                height: 18,
                child: Icon(
                  Icons.close,
                  size: 10,
                  color: Color(0xFF202733),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}