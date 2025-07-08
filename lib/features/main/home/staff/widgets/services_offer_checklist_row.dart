import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/main/home/staff/application/staff_schedule_controller.dart';
import 'package:flutter/material.dart';

class ServicesOfferChecklistRow extends StatefulWidget {
  final int index;
  final List<Map<String, String>> services;
  final StaffScheduleController controller;

  const ServicesOfferChecklistRow({
    super.key,
    required this.index,
    required this.services,
    required this.controller,
  });

  @override
  State<ServicesOfferChecklistRow> createState() => _ServicesOfferChecklistRowState();
}

class _ServicesOfferChecklistRowState extends State<ServicesOfferChecklistRow> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    final visibleServices = showAll ? widget.services : widget.services.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          "Services they offer",
          style: AppTypography.headingSm,
        ),
        if (widget.services.isEmpty)
          const Center(child: Text(""))
        else
          ...visibleServices.map((service) {
            final id = service['id']!;
            final name = service['name']!;
            final isSelected = widget.controller.entries[widget.index].selectedServices.contains(id);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    onChanged: (checked) {
                      setState(() {
                        widget.controller.toggleService(widget.index, id);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(name, style: AppTypography.bodyMedium),
                  ),
                ],
              ),
            );
          }),

        if (widget.services.length > 4)
          TextButton(
            onPressed: () {
              setState(() {
                showAll = !showAll;
              });
            },
            child: Text(showAll ? 'See Less' : 'See All'),
          ),
      ],
    );
  }
}
