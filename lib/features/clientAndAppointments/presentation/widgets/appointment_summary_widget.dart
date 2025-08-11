import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import '../utils/date_formatter_service.dart';

class AppointmentSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> partialPayload;

  const AppointmentSummaryWidget({
    super.key,
    required this.partialPayload,
  });

  String _buildAppointmentSummary(BuildContext context) {
    final fallbackMessage = AppTranslationsDelegate.of(context).text("could_not_load_appointment_details");
    
    return DateFormatterService.formatAppointmentSummary(
      dateString: partialPayload['date'],
      duration: partialPayload['duration_minutes'],
      serviceName: partialPayload['service_name'],
      practitionerName: partialPayload['practitioner_name'],
      fallbackMessage: fallbackMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _buildAppointmentSummary(context),
      style: AppTypography.headingSm,
    );
  }
}
