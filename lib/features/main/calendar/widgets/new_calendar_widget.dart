import 'dart:ui';
import 'package:flutter/material.dart';
// Assuming AppTypography is a custom class for text styles.
// If not available, replace with standard TextStyle.
// import 'package:bookit_mobile_app/app/theme/app_typography.dart';

// --- MOCK AppTypography for standalone running ---
class AppTypography {
  static const TextStyle bodyLarge = TextStyle(fontSize: 16);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14);
  static const TextStyle bodySmall = TextStyle(fontSize: 12);
  static const TextStyle bodyExtraSmall = TextStyle(fontSize: 10);
}
// --- END MOCK ---

// Enum to control which view to display
enum AppointmentViewType { list, calendar }

class AppointmentView extends StatefulWidget {
  final List<Map<String, dynamic>> appointments;
  final int? maxServices;
  final AppointmentViewType viewType;

  const AppointmentView({
    super.key,
    required this.appointments,
    this.maxServices,
    this.viewType = AppointmentViewType.list, // Default to list view
  });

  @override
  State<AppointmentView> createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  String _filter = 'upcoming'; // 'upcoming', 'past', 'cancelled'

  @override
  Widget build(BuildContext context) {
    // Process appointments and flatten them into a single list
    final now = DateTime.now();
    final processedAppointments = widget.appointments.expand((staff) {
      final appointments = (staff['appointments'] as List<Map<String, dynamic>>?) ?? [];
      return appointments.map((appt) {
        final startTime = DateTime.parse(appt['start_time']).toLocal();
        final endTime = startTime.add(Duration(minutes: appt['duration_minutes'] as int));

        String filterCategory;
        String displayStatus = '';
        Color statusColor = Theme.of(context).primaryColor;

        if (appt['status'] == 'cancelled') {
          filterCategory = 'cancelled';
        } else if (endTime.isBefore(now)) {
          filterCategory = 'past';
        } else {
          filterCategory = 'upcoming';
          if (startTime.isBefore(now) && endTime.isAfter(now)) {
            displayStatus = 'Started';
            statusColor = Colors.green;
          } else {
            displayStatus = 'Booked';
          }
        }

        return {
          ...appt,
          'staff_name': staff['staff_name'],
          'start_time_local': startTime,
          'end_time_local': endTime,
          'filter_category': filterCategory,
          'display_status': displayStatus,
          'status_color': statusColor,
          'price': appt['price'] ?? 'EGP 0000', // Add a dummy price
        };
      });
    }).toList();

    // Apply the current filter
    List<Map<String, dynamic>> filteredAppointments = processedAppointments
        .where((appt) => appt['filter_category'] == _filter)
        .toList();

    // Sort appointments: upcoming are ascending, past/cancelled are descending
    if (_filter == 'upcoming') {
      filteredAppointments.sort((a, b) =>
          (a['start_time_local'] as DateTime).compareTo(b['start_time_local'] as DateTime));
    } else {
      filteredAppointments.sort((a, b) =>
          (b['start_time_local'] as DateTime).compareTo(a['start_time_local'] as DateTime));
    }

    // Apply max services limit if provided
    if (widget.maxServices != null) {
      filteredAppointments = filteredAppointments.take(widget.maxServices!).toList();
    }
    
    // Return the calendar view if specified
    if (widget.viewType == AppointmentViewType.calendar) {
      // The original MyCalenderWidget required a different data structure.
      // We pass the raw appointments for it to process internally.
      return MyCalenderWidget(appointments: widget.appointments);
    }
    
    // Build the List View
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterTabs(
          currentFilter: _filter,
          onFilterChanged: (newFilter) {
            setState(() {
              _filter = newFilter;
            });
          },
        ),
        const SizedBox(height: 16),
        if (filteredAppointments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48.0),
            child: Center(child: Text('No appointments in this category.')),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) {
              final appointment = filteredAppointments[index];
              return AppointmentCard(
                appointment: appointment,
                filterType: _filter,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const _FilterTabs({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab(context, 'Upcoming', 'upcoming'),
        const SizedBox(width: 32),
        _buildTab(context, 'Past', 'past'),
        const SizedBox(width: 32),
        _buildTab(context, 'Cancelled', 'cancelled'),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String title, String filterName) {
    final bool isSelected = currentFilter == filterName;
    final color = isSelected ? Theme.of(context).primaryColor : const Color(0xFF212529);

    return GestureDetector(
      onTap: () => onFilterChanged(filterName),
      child: Container(
        color: Colors.transparent, // For better hit testing
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          title,
          style: AppTypography.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final String filterType;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.filterType,
  });

  String _formatDate(DateTime date) {
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startTime = appointment['start_time_local'] as DateTime;
    final endTime = appointment['end_time_local'] as DateTime;
    final duration = appointment['duration_minutes'] as int;
    final borderColor = filterType == 'upcoming' ? theme.primaryColor : const Color(0xFFDEE2E6);

    String headerText;
    if (filterType == 'upcoming') {
      headerText = '${TimeOfDay.fromDateTime(startTime).format(context)} - ${TimeOfDay.fromDateTime(endTime).format(context)}';
    } else {
      headerText = _formatDate(startTime);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerText,
                        style: AppTypography.bodyMedium.copyWith(
                          color: filterType == 'upcoming' ? theme.primaryColor : const Color(0xFF212529),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment['service_name']} (${duration} mins)',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (filterType == 'upcoming')
                  _buildStatusBadge(context)
                else if (filterType == 'past')
                  _buildPriceTag(context),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: filterType == 'upcoming' ? theme.primaryColor : Colors.black,
                      size: 9,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment['client_name'],
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Text(
                    appointment['staff_name'],
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          if (filterType == 'upcoming') ...[
            Divider(color: borderColor, height: 1, thickness: 1),
            IntrinsicHeight(
              child: Row(
                children: [
                  _buildContactButton(context, "Email", borderColor),
                  VerticalDivider(color: borderColor, width: 1, thickness: 1),
                  _buildContactButton(context, "Call", borderColor),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final displayStatus = appointment['display_status'] as String;
    if (displayStatus.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: appointment['status_color'],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text(
        displayStatus,
        style: AppTypography.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriceTag(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: const Color(0xFFADB5BD)),
      ),
      child: Text(
        appointment['price'],
        style: AppTypography.bodySmall.copyWith(
          color: const Color(0xFF212529),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContactButton(BuildContext context, String label, Color borderColor) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // Add Email/Call logic here
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

// The calendar widget remains unchanged as requested.
class MyCalenderWidget extends StatefulWidget {
  final List<Map<String, dynamic>> appointments;
  const MyCalenderWidget({super.key, required this.appointments});

  @override
  State<MyCalenderWidget> createState() => _MyCalenderWidgetState();
}

class _MyCalenderWidgetState extends State<MyCalenderWidget> {
  List<Map<String, dynamic>> staff = [];

  // --- Layout Constants ---
  static const double minuteHeight = 1.6;
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
      final viewportHeight = MediaQuery.of(context).size.height * 0.5;
      final initialScrollOffset = (currentTimeOffset - viewportHeight).clamp(0.0, totalHeight);
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
      mainAxisSize: MainAxisSize.min, // Prevent unbounded height
      children: [
        _buildStickyHeader(),
        SizedBox(
          height: totalHeight, // Constrain height for calendar
          child: _buildScrollableBody(),
        ),
      ],
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
                bottom: BorderSide(color: theme.scaffoldBackgroundColor, width: 1),
                right: BorderSide(color: theme.scaffoldBackgroundColor, width: 1),
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
                  children: staff.map((staffMember) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(1, 0, 2, 2),
                      child: Container(
                        width: staffColumnWidth,
                        height: headerHeight,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE9ECEF),
                        ),
                        child: Center(
                          child: Text(
                            staffMember['staff_name'],
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
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
    final now = DateTime.now();
    final currentTimeOffset = (now.hour * 60 + now.minute) * minuteHeight;

    return SingleChildScrollView(
      controller: _verticalScrollController,
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      child: Stack(
        children: [
          Positioned(
            top: currentTimeOffset - 1,
            left: 0,
            right: 0,
            child: _buildCurrentTimeIndicator(),
          ),
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
                      children: staff.map((s) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _buildStaffColumn(s),
                        );
                      }).toList(),
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
              padding: const EdgeInsets.only(right: 8.0),
              alignment: Alignment.topRight,
              child: Text(
                _formatTime(hour, minute),
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStaffColumn(Map<String, dynamic> staffMember) {
    final appointments = (staffMember['appointments'] as List<Map<String, dynamic>>?) ?? [];
    return SizedBox(
      width: staffColumnWidth,
      height: totalHeight,
      child: Stack(
        children: [
          ...List.generate(48, (index) {
            return Positioned(
              top: index * 30 * minuteHeight,
              left: 0,
              right: 0,
              child: Container(height: 0.2, color: const Color(0xFFCED4DA)),
            );
          }),
          ...appointments.map((appointment) => _buildAppointment(appointment)),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeIndicator() {
    final theme = Theme.of(context);
    return Row(
      children: [
        const SizedBox(width: timeColumnWidth),
        Expanded(child: Container(height: 1, color: theme.colorScheme.primary)),
      ],
    );
  }

  Widget _buildAppointment(Map<String, dynamic> appointment) {
    final theme = Theme.of(context);
    final utcTime = DateTime.parse(appointment['start_time']);
    final localTime = utcTime.toLocal();
    double topOffset = _getTopOffset(appointment['start_time']);
    double height = (appointment['duration_minutes'] as int) * minuteHeight;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final appointmentStartMinutes = _getMinutesFromTime(appointment['start_time']);
    final appointmentEndMinutes = appointmentStartMinutes + (appointment['duration_minutes'] as int);
    final isCurrentAppointment =
        currentMinutes >= appointmentStartMinutes && currentMinutes < appointmentEndMinutes;

    const Color backgroundColor = Color(0xFFDEEAFF);
    final Color textColor = theme.colorScheme.onSurface;

    final formattedTime = TimeOfDay(hour: localTime.hour, minute: localTime.minute).format(context);

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isCurrentAppointment ? const Color(0xFF9CBFFF) : backgroundColor,
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

  double _getTopOffset(String startTime) {
    final utcTime = DateTime.parse(startTime);
    final localTime = utcTime.toLocal();
    int hour = localTime.hour;
    int minute = localTime.minute;
    return (hour * 60 + minute) * minuteHeight;
  }

  int _getMinutesFromTime(String startTime) {
    final utcTime = DateTime.parse(startTime);
    final localTime = utcTime.toLocal();
    int hour = localTime.hour;
    int minute = localTime.minute;
    return hour * 60 + minute;
  }

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