import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//dummy data (structure should look like this)
List<Map<String, dynamic>> staffAppointments3 =[];
List<Map<String, dynamic>> staffAppointments2 = [
  {
    "staff_id": "staff-1",
    "staff_name": "Aïcha Niazy",
    "appointments": [
    ],
  },
  {
    "staff_id": "staff-2",
    "staff_name": "Steven Cohen",
    "appointments": [
    ],
  },
  {
    "staff_id": "staff-3",
    "staff_name": "Fatima Bombo",
    "appointments": [
    ],
  },
  {
    "staff_id": "staff-4",
    "staff_name": "Dr. Rajesh Patel",
    "appointments": [
    ],
  },
  {
    "staff_id": "staff-5",
    "staff_name": "Maria Gonzalez",
    "appointments": [
    ],
  },
];

List<Map<String, dynamic>> staffAppointments = [
  {
    "staff_id": "staff-1",
    "staff_name": "Aïcha Niazy",
    "appointments": [
      {
        "start_time": "2025-07-08T10:00:00Z", // Past
        "duration_minutes": 30,
        "service_name": "Acupuncture",
        "client_name": "Fadia Fadi",
        "status": "cancelled",
      },
      {
        "start_time": "2025-07-11T05:30:00Z", // TODAY past
        "duration_minutes": 30,
        "service_name": "Reiki",
        "client_name": "Amina Kamil",
        "status": "completed",
      },
      {
        "start_time": "2025-07-11T09:30:00Z", // TODAY upcoming
        "duration_minutes": 60,
        "service_name": "Thai Massage",
        "client_name": "Bilal Yusuf",
        "status": "",
      },
      {
        "start_time": "2025-07-12T11:00:00Z",
        "duration_minutes": 45,
        "service_name": "Swedish Massage",
        "client_name": "Ahmed Hassan",
        "status": "",
      },
      {
        "start_time": "2025-07-15T12:30:00Z",
        "duration_minutes": 60,
        "service_name": "Deep Tissue Massage",
        "client_name": "Layla Karim",
        "status": "",
      },
    ],
  },
  {
    "staff_id": "staff-2",
    "staff_name": "Steven Cohen",
    "appointments": [
      {
        "start_time": "2025-07-09T08:10:00Z", // Past
        "duration_minutes": 20,
        "service_name": "Reflexology",
        "client_name": "Sally Amir",
        "status": "",
      },
      {
        "start_time": "2025-07-11T06:15:00Z", // TODAY just before now
        "duration_minutes": 30,
        "service_name": "Chiropractic",
        "client_name": "Maya Noor",
        "status": "completed",
      },
      {
        "start_time": "2025-07-11T11:45:00Z", // TODAY later
        "duration_minutes": 60,
        "service_name": "Deep Tissue Massage",
        "client_name": "Omar Farooq",
        "status": "",
      },
      {
        "start_time": "2025-07-13T13:30:00Z",
        "duration_minutes": 30,
        "service_name": "Acupuncture",
        "client_name": "Sarah Mostafa",
        "status": "",
      },
      {
        "start_time": "2025-07-14T14:15:00Z",
        "duration_minutes": 45,
        "service_name": "Hot Stone Massage",
        "client_name": "Hana Saleh",
        "status": "",
      },
    ],
  },
  {
    "staff_id": "staff-3",
    "staff_name": "Fatima Bombo",
    "appointments": [
      {
        "start_time": "2025-07-07T09:00:00Z", // Past
        "duration_minutes": 60,
        "service_name": "Aromatherapy",
        "client_name": "Zainab Ali",
        "status": "",
      },
      {
        "start_time": "2025-07-11T07:00:00Z", // TODAY upcoming
        "duration_minutes": 30,
        "service_name": "Facial Therapy",
        "client_name": "Noor Alhadi",
        "status": "",
      },
      {
        "start_time": "2025-07-16T10:30:00Z",
        "duration_minutes": 45,
        "service_name": "Swedish Massage",
        "client_name": "Khalid Mahmoud",
        "status": "",
      },
    ],
  },
  {
    "staff_id": "staff-4",
    "staff_name": "Dr. Rajesh Patel",
    "appointments": [
      {
        "start_time": "2025-07-06T10:00:00Z", // Past
        "duration_minutes": 30,
        "service_name": "Chiropractic Adjustment",
        "client_name": "Priya Sharma",
        "status": "",
      },
      {
        "start_time": "2025-07-11T04:00:00Z", // TODAY past
        "duration_minutes": 30,
        "service_name": "Orthopedic Checkup",
        "client_name": "Dev Raj",
        "status": "completed",
      },
      {
        "start_time": "2025-07-12T12:00:00Z",
        "duration_minutes": 60,
        "service_name": "Physical Therapy",
        "client_name": "Vikram Singh",
        "status": "",
      },
      {
        "start_time": "2025-07-18T15:00:00Z",
        "duration_minutes": 45,
        "service_name": "Acupuncture",
        "client_name": "Anita Desai",
        "status": "cancelled",
      },
    ],
  },
  {
    "staff_id": "staff-5",
    "staff_name": "Maria Gonzalez",
    "appointments": [
      {
        "start_time": "2025-07-05T08:30:00Z", // Past
        "duration_minutes": 60,
        "service_name": "Deep Tissue Massage",
        "client_name": "Carlos Rivera",
        "status": "",
      },
      {
        "start_time": "2025-07-11T08:30:00Z", // TODAY current
        "duration_minutes": 30,
        "service_name": "Reflexology",
        "client_name": "Eva Morales",
        "status": "",
      },
      {
        "start_time": "2025-07-20T14:00:00Z",
        "duration_minutes": 30,
        "service_name": "Reflexology",
        "client_name": "Sofia Lopez",
        "status": "",
      },
    ],
  },
];


class MyCalenderWidget extends StatefulWidget {
  final List<Map<String, dynamic>> appointments;
  final bool? isLoading;
  final double? viewportHeight;
  const MyCalenderWidget({super.key, required this.appointments, this.isLoading, this.viewportHeight});


  @override
  State<MyCalenderWidget> createState() => _MyCalenderWidgetState();
}

class _MyCalenderWidgetState extends State<MyCalenderWidget> {
  List<Map<String, dynamic>> staff = [];

  // --- Layout Constants ---
  static const double minuteHeight =
      1.6; // Increased slightly for better spacing
  static const double staffColumnWidth = 140.0;
  static const double timeColumnWidth = 48.0;
  static const double totalHeight = 24 * 60 * minuteHeight;
  static const double headerHeight = 28.0;
  static const double timeSlotHeight = 30 * minuteHeight;

  // --- Scroll Controllers ---
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _bodyHorizontalController = ScrollController();
  bool _isSyncing = false;

@override
  void initState() {
    super.initState();
    staff = widget.appointments;
    _headerHorizontalController.addListener(_syncBodyScroll);
    _bodyHorizontalController.addListener(_syncHeaderScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final currentTimeOffset = (now.hour * 60 + now.minute) * minuteHeight;
      // Use passed viewportHeight if available, else fallback to MediaQuery
      final viewportHeight = widget.viewportHeight ??
          MediaQuery.of(context).size.height * 0.5;
      final initialScrollOffset =
          (currentTimeOffset - viewportHeight / 2).clamp(0.0, totalHeight);
      _verticalScrollController.jumpTo(initialScrollOffset);
    });
  }

  void _syncBodyScroll() {
    if (_isSyncing) return;
    _isSyncing = true;
    _bodyHorizontalController.jumpTo(_headerHorizontalController.offset);
    _isSyncing = false;
  }

  void _syncHeaderScroll() {
    if (_isSyncing) return;
    _isSyncing = true;
    _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
    _isSyncing = false;
  }

  @override
  void didUpdateWidget(MyCalenderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appointments != oldWidget.appointments) {
      setState(() {
        staff = widget.appointments;
      });
    }
  }

  @override
  void dispose() {
    _headerHorizontalController.removeListener(_syncBodyScroll);
    _bodyHorizontalController.removeListener(_syncHeaderScroll);
    _verticalScrollController.dispose();
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildStickyHeader(), Expanded(child: _buildScrollableBody())],
    );
  }

  Widget _buildStickyHeader() {
    final theme = Theme.of(context);
    return Container(
      height: headerHeight,
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Container(
            width: timeColumnWidth,
            height: headerHeight,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.scaffoldBackgroundColor,
                  width: 1,
                ),
                right: BorderSide(
                  color: theme.scaffoldBackgroundColor,
                  width: 1,
                ),
              ),
            ),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: SingleChildScrollView(
                controller: _headerHorizontalController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children:
                      staff.map((staffMember) {
                        return Padding(
                          // padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          padding: EdgeInsets.fromLTRB(1, 0, 2, 2),
                          child: Container(
                            width: staffColumnWidth,
                            height: headerHeight,
                            decoration: BoxDecoration(
                              // border: Border(
                              //   bottom: BorderSide(color: theme.dividerColor, width: 1),
                              //   right: BorderSide(color: theme.dividerColor, width: 1),
                              // ),
                              color: Theme.of(context).brightness == Brightness.dark
    ? Theme.of(context).colorScheme.surface // or another dark-friendly color
    : const Color(0xFFE9ECEF),
                            ),
                            child: Center(
                              child: Text(
                                staffMember['staff_name'],
                                style: AppTypography.bodySmall.copyWith(
                                  color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildScrollableBody() {
  final now = DateTime.now(); // Current time in local time zone
  final currentTimeOffset = (now.hour * 60 + now.minute) * minuteHeight;

  return SingleChildScrollView(
    controller: _verticalScrollController,
    scrollDirection: Axis.vertical,
    physics: const ClampingScrollPhysics(),
    child: Stack(
      children: [
        Positioned(
          top: currentTimeOffset - 1, // Center the line
          left: 0,
          right: 0,
          child: _buildCurrentTimeIndicator(),
        ),
        // Main Content Grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeColumn(),
            Expanded(
              child: SingleChildScrollView(
                controller: _bodyHorizontalController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  height: totalHeight,
                  child: Row(
                    children:
                        staff
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: _buildStaffColumn(s),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildTimeColumn() {
    final theme = Theme.of(context);
    return SizedBox(
      width: timeColumnWidth,
      height: totalHeight,
      child: Stack(
        children: List.generate(49, (index) {
          int hour = index ~/ 2;
          int minute = (index % 2) * 30;
          return Positioned(
            top: index * timeSlotHeight,
            left: 0,
            right: 0,
            child: Container(
              height: timeSlotHeight,
              // decoration: BoxDecoration(
              //   border: Border(
              //     bottom: BorderSide(color: theme.dividerColor, width: 0.5),
              //     right: BorderSide(color: theme.dividerColor, width: 1),
              //   ),
              // ),
              padding: const EdgeInsets.only(right: 8.0),
              alignment: Alignment.topRight,
              child: Text(
                _formatTime(hour, minute),
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStaffColumn(Map<String, dynamic> staffMember) {
    final theme = Theme.of(context);
    return Container(
      width: staffColumnWidth,
      height: totalHeight,
      // decoration: BoxDecoration(
      //   border: Border(right: BorderSide(color: theme.dividerColor, width: 0)),
      // ),
      child: Stack(
        children: [
          // Background hour lines
          ...List.generate(48, (index) {
            return Positioned(
              top: index * 30 * minuteHeight,
              left: 0,
              right: 0,
              child: Container(height: 0.2, color: Theme.of(context).brightness == Brightness.dark
    ? Theme.of(context).dividerColor.withOpacity(0.3)
    : const Color(0xFFCED4DA)),
            );
          }),
          // Appointments
          ...List.generate(staffMember['appointments'].length, (index) {
            return _buildAppointment(staffMember['appointments'][index]);
          }),
        ],
      ),
    );
  }

  // --- NEW: Helper to build the current time indicator ---
  Widget _buildCurrentTimeIndicator() {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(width: timeColumnWidth ), // Align with grid
        // Container(
        //   width: 8,
        //   height: 8,
        //   decoration: BoxDecoration(
        //     color: theme.colorScheme.primary,
        //     shape: BoxShape.circle,
        //   ),
        // ),
        Expanded(child: Container(height: 1, color: theme.colorScheme.primary)),
      ],
    );
  }

  Widget _buildAppointment(Map<String, dynamic> appointment) {
  final theme = Theme.of(context);
  // Parse UTC time and convert to local time
  final utcTime = DateTime.parse(appointment['start_time']);
  final localTime = utcTime.toLocal();
  double topOffset = _getTopOffset(appointment['start_time']);
  double height = appointment['duration_minutes'] * minuteHeight;

  // Check if the appointment is currently active (using local time)
  final now = DateTime.now(); // Current time in local time zone
  final currentMinutes = now.hour * 60 + now.minute;
  final appointmentStartMinutes = _getMinutesFromTime(appointment['start_time']);
  final appointmentEndMinutes = appointmentStartMinutes + appointment['duration_minutes'];
  final isCurrentAppointment = currentMinutes >= appointmentStartMinutes && currentMinutes < appointmentEndMinutes;

  // Set background color based on whether the appointment is ongoing
  final Color backgroundColor = isCurrentAppointment
    ? (Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
        : const Color(0xFF9CBFFF))
    : (Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface.withOpacity(0.7)
        : const Color(0xFFDEEAFF));

  final Color textColor = theme.colorScheme.onSurface;

  // Format local time for display
  final formattedTime = TimeOfDay(
    hour: localTime.hour,
    minute: localTime.minute,
  ).format(context);

  return Positioned(
    top: topOffset,
    left: 0,
    right: 0,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 2),
          right: BorderSide(color: theme.colorScheme.primary, width: 0.5),
          top: BorderSide(color: theme.colorScheme.primary, width: 0.5),
          bottom: BorderSide(color: theme.colorScheme.primary, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$formattedTime | ${appointment['duration_minutes']}min ${appointment['service_name']}',
            style: AppTypography.bodyExtraSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '• ${appointment['client_name']}',
            style: AppTypography.bodyExtraSmall.copyWith(
              color: textColor.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}


  // --- Helper Methods ---

double _getTopOffset(String startTime) {
  // Parse UTC time
  final utcTime = DateTime.parse(startTime);
  // Convert to local time
  final localTime = utcTime.toLocal();
  int hour = localTime.hour;
  int minute = localTime.minute;
  return (hour * 60 + minute) * minuteHeight;
}

int _getMinutesFromTime(String startTime) {
  // Parse UTC time
  final utcTime = DateTime.parse(startTime);
  // Convert to local time
  final localTime = utcTime.toLocal();
  int hour = localTime.hour;
  int minute = localTime.minute;
  return hour * 60 + minute;
}

  // Updated to always include AM/PM for clarity
  String _formatTime(int hour, int minute) {
    final period = hour < 12 || hour == 24 ? 'AM' : 'PM';
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;

    if (minute == 0) {
      return '$displayHour $period';
    } else {
      return '$displayHour:${minute.toString().padLeft(2, '0')}';
    }
  }


}
