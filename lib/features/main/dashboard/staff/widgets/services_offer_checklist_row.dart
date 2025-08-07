import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/application/staff_schedule_controller.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/multi_select_item.dart';
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

            return CheckboxListItem(
              title: name,
              isSelected: isSelected,
              onChanged: (checked) {
                setState(() {
                  widget.controller.toggleService(widget.index, id);
                });
              },
            );
          }),

        if (widget.services.length > 4)
         SizedBox(height: 8,),
          SecondaryButton(onPressed: () {
              setState(() {
                showAll = !showAll;
              });
            }, text: showAll ? AppTranslationsDelegate.of(context).text("see_less") : AppTranslationsDelegate.of(context).text("see_all"))
      ],
    );
  }
}
