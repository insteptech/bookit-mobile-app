import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoUpcomingAppointmentsBox extends StatefulWidget {
  const NoUpcomingAppointmentsBox({super.key});

  @override
  State<NoUpcomingAppointmentsBox> createState() => _NoUpcomingAppointmentsBoxState();
}

class _NoUpcomingAppointmentsBoxState extends State<NoUpcomingAppointmentsBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 160,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: AppColors.lightGrayBoxColor, 
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "You don’t have any upcoming appointments. Click below to schedule new appointments.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: (){
            context.push("/book_new_appointment");
          },
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: theme.colorScheme.primary, size: 18),
            const SizedBox(width: 4),
            Text(
              "Book new appointment",
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        )
      ],
    );
  }
}
