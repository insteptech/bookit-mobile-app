import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class StaffMemberRow extends StatefulWidget {
  final String staffName;
  final String staffId;
  final String staffImageUrl;
  final VoidCallback? onClick;

  const StaffMemberRow({
    super.key,
    required this.staffName,
    required this.staffId,
    required this.staffImageUrl,
    this.onClick,
  });

  @override
  State<StaffMemberRow> createState() => _StaffMemberRowState();
}

class _StaffMemberRowState extends State<StaffMemberRow> {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          if (widget.onClick != null) {
            widget.onClick!();
          }
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child:
                  widget.staffImageUrl.isNotEmpty
                      ? Image.network(
                        widget.staffImageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultIcon(),
                      )
                      : _defaultIcon(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(widget.staffName, style: AppTypography.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultIcon() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade200,
      child: const Icon(Icons.person, size: 30, color: Colors.grey),
    );
  }
}
