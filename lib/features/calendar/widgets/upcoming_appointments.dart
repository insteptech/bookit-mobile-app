import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/no_upcoming_appointments_box.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppointmentStatus { upcoming, past, cancelled }

class AppointmentsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> staffAppointments;
  final int? maxAppointments; // Optional parameter to limit appointments shown
  final bool? isLoading;
  final bool showBottomOptions;
  
  const AppointmentsWidget({
    super.key, 
    required this.staffAppointments,
    this.maxAppointments,
    this.isLoading,
    required this.showBottomOptions
  });

  @override
  State<AppointmentsWidget> createState() => _AppointmentsWidgetState();
}

class _AppointmentsWidgetState extends State<AppointmentsWidget> {
  AppointmentStatus selectedStatus = AppointmentStatus.upcoming;

  // Flatten appointments from all staff members
  List<Map<String, dynamic>> get flattenedAppointments {
    List<Map<String, dynamic>> allAppointments = [];
    
    for (var staff in widget.staffAppointments) {
      final staffName = staff['staff_name'] ?? 'Unknown Staff';
      final appointments = staff['appointments'] as List<dynamic>? ?? [];
      
      for (var appointment in appointments) {
        final flatAppointment = Map<String, dynamic>.from(appointment);
        flatAppointment['staff_name'] = staffName;
        allAppointments.add(flatAppointment);
      }
    }
    
    return allAppointments;
  }

  List<Map<String, dynamic>> get filteredAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<Map<String, dynamic>> filtered = flattenedAppointments.where((appointment) {
      final startTimeStr = appointment['start_time'] ?? '';
      final status = appointment['status']?.toString().toLowerCase() ?? '';
      
      try {
        // Parse UTC time and convert to local time
        final utcStartTime = DateTime.parse(startTimeStr);
        final localStartTime = utcStartTime.toLocal();
        final appointmentDate = DateTime(localStartTime.year, localStartTime.month, localStartTime.day);
        
        switch (selectedStatus) {
          case AppointmentStatus.upcoming:
            return (appointmentDate.isAfter(today) || appointmentDate.isAtSameMomentAs(today)) && 
                   status != 'cancelled';
          case AppointmentStatus.past:
            return appointmentDate.isBefore(today) && status != 'cancelled';
          case AppointmentStatus.cancelled:
            return status == 'cancelled';
        }
      } catch (e) {
        // If date parsing fails, treat as upcoming
        return selectedStatus == AppointmentStatus.upcoming && status != 'cancelled';
      }
    }).toList();

    // Sort appointments by start time (convert to local time for sorting)
    filtered.sort((a, b) {
      try {
        final aUtcTime = DateTime.parse(a['start_time'] ?? '');
        final bUtcTime = DateTime.parse(b['start_time'] ?? '');
        final aLocalTime = aUtcTime.toLocal();
        final bLocalTime = bUtcTime.toLocal();
        return aLocalTime.compareTo(bLocalTime);
      } catch (e) {
        return 0;
      }
    });

    // Apply max appointments limit if specified
    if (widget.maxAppointments != null && widget.maxAppointments! > 0) {
      return filtered.take(widget.maxAppointments!).toList();
    }
    
    return filtered;
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final primaryColor = theme.colorScheme.primary;

  final hasAppointments = filteredAppointments.isNotEmpty;

  if (widget.isLoading == true) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: CircularProgressIndicator(color: primaryColor),
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Tab bar for filtering
      Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            _buildTabButton("Upcoming", AppointmentStatus.upcoming, primaryColor),
            const SizedBox(width: 24),
            _buildTabButton("Past", AppointmentStatus.past, primaryColor),
            const SizedBox(width: 24),
            _buildTabButton("Cancelled", AppointmentStatus.cancelled, primaryColor),
          ],
        ),
      ),

      // Appointments list or empty state
      if (!hasAppointments)
        _buildEmptyState(theme, primaryColor)
      else ...[
        ...filteredAppointments.map((appointment) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppointmentCard(appointment: appointment),
          ),
        ),
        if(widget.showBottomOptions == true)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                context.push("/view_all_appointments");
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslationsDelegate.of(context).text("view_all"),
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push("/book_new_appointment");
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Book new appointment",
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    ],
  );
}

  Widget _buildTabButton(String title, AppointmentStatus status, Color primaryColor) {
    final isSelected = selectedStatus == status;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = status;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected ? primaryColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: title.length * 8.0, // Approximate width based on text
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, Color primaryColor) {
    String message;
    switch (selectedStatus) {
      case AppointmentStatus.upcoming:
        message = "You don't have any upcoming appointments. Click below to schedule new appointments.";
        break;
      case AppointmentStatus.past:
        message = "You don't have any past appointments.";
        break;
      case AppointmentStatus.cancelled:
        message = "You don't have any cancelled appointments.";
        break;
    }

    return Column(
        children: [
        if(selectedStatus != AppointmentStatus.upcoming)
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (selectedStatus == AppointmentStatus.upcoming)
            NoUpcomingAppointmentsBox()
        ],
      );
  }
}

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  
  const AppointmentCard({super.key, required this.appointment});

  String _formatTimeSlot(String startTimeStr, int durationMinutes) {
    try {
      // Parse UTC time and convert to local time
      final utcStartTime = DateTime.parse(startTimeStr);
      final localStartTime = utcStartTime.toLocal();
      final localEndTime = localStartTime.add(Duration(minutes: durationMinutes));
      
      final timeFormat = DateFormat('h:mm a');
      return '${timeFormat.format(localStartTime)} - ${timeFormat.format(localEndTime)}';
    } catch (e) {
      return 'Invalid time';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Email launch failed silently
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Phone launch failed silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    // Extract appointment data
    final startTimeStr = appointment['start_time'] ?? '';
    final durationMinutes = appointment['duration_minutes'] ?? 0;
    final serviceName = appointment['service_name'] ?? 'Unknown Service';
    final clientName = appointment['client_name'] ?? 'Unknown Client';
    final staffName = appointment['staff_name'] ?? 'Unknown Staff';
    final status = appointment['status']?.toString().toLowerCase() ?? '';
    final clientEmail = appointment['client_email'] ?? '';
    final clientPhone = appointment['client_phone'] ?? '';
    
    final timeSlot = _formatTimeSlot(startTimeStr, durationMinutes);
    final treatmentInfo = '$serviceName ($durationMinutes min)';

    // Determine status chip properties
    Color statusColor;
    String statusText;
    
    // Determine if appointment is past based on current time (convert UTC to local)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool isPast = false;
    
    try {
      // Parse UTC time and convert to local time
      final utcStartTime = DateTime.parse(startTimeStr);
      final localStartTime = utcStartTime.toLocal();
      final appointmentDate = DateTime(localStartTime.year, localStartTime.month, localStartTime.day);
      isPast = appointmentDate.isBefore(today);
    } catch (e) {
      // If parsing fails, assume not past
    }
    
    if (status == 'cancelled') {
      statusColor = Colors.red;
      statusText = "Cancelled";
    } else if (isPast) {
      statusColor = Colors.green;
      statusText = "Started";
    } else {
      statusColor = primaryColor;
      statusText = "Booked";
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: primaryColor, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section: date, time, treatment info and status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  // if (date.isNotEmpty)
                  //   Padding(
                  //     padding: const EdgeInsets.only(bottom: 4),
                  //     child: Text(
                  //       date,
                  //       style: AppTypography.bodySmall.copyWith(
                  //         color: Colors.grey[600],
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //   ),
                  
                  // Time and status row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left part: Time and treatment info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeSlot,
                              style: AppTypography.bodyMedium.copyWith(
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              treatmentInfo,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Right part: Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          statusText,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Middle section: Client and Practitioner Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.circle, 
                        color: primaryColor, 
                        size: 8,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        clientName,
                        style: AppTypography.bodySmall
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                 Text(
                      staffName,
                      style: AppTypography.bodySmall
                    ),
                ],
              ),
            ),
            
            // Bottom section: Action buttons (only for upcoming appointments)
            if (status != 'cancelled' && !isPast) ...[
              Divider(
                color: primaryColor, 
                height: 1, 
                thickness: 1,
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    // Email Button
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: clientEmail.isNotEmpty ? () {
                            _launchEmail(clientEmail);
                          } : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Center(
                              child: Text(
                                AppTranslationsDelegate.of(context).text("email"),
                                style: AppTypography.bodyMedium
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Vertical divider
                    Container(
                      width: 1,
                      color: primaryColor,
                    ),
                    
                    // Call Button
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: clientPhone.isNotEmpty ? () {
                            _launchPhone(clientPhone);
                          } : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Center(
                              child: Text(
                                AppTranslationsDelegate.of(context).text("call"),
                                style: AppTypography.bodyMedium
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
