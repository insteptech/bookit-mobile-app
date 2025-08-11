import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';

class AppointmentSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> partialPayload;

  const AppointmentSummaryWidget({
    super.key,
    required this.partialPayload,
  });

  String _buildAppointmentSummary(BuildContext context) {
    try {
      final duration = partialPayload['duration_minutes'];
      final serviceName = partialPayload['service_name'];
      final practitionerName = partialPayload['practitioner_name'];
      final startTime = DateTime.parse(partialPayload['date']).toLocal();
      final formattedTime = DateFormat('h:mm a').format(startTime);
      final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(startTime);

      return "$duration min - $serviceName at [$formattedTime] on [$formattedDate] with $practitionerName";
    } catch (e) {
      return AppTranslationsDelegate.of(context).text("could_not_load_appointment_details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _buildAppointmentSummary(context),
      style: AppTypography.headingSm,
    );
  }
}
