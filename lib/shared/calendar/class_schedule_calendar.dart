import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/controllers/classes_controller.dart';
import 'package:bookit_mobile_app/core/utils/time_utils.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/no_classes_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ClassScheduleCalendar extends ConsumerStatefulWidget {
  final bool? showCalendarHeader;
  final String? locationId;
  final int? numberOfClasses;
  
  const ClassScheduleCalendar({
    super.key, 
    this.showCalendarHeader, 
    this.locationId, 
    this.numberOfClasses
  });

  @override
  ConsumerState<ClassScheduleCalendar> createState() => _ClassScheduleCalendarState();
}

class _ClassScheduleCalendarState extends ConsumerState<ClassScheduleCalendar> {
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    // Fetch classes for the initial selected date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchClassesForDate(selectedDate);
    });
  }

  void _fetchClassesForDate(DateTime date) {
    ref.read(classesControllerProvider.notifier).fetchClassesForDate(widget.locationId, date);
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    _fetchClassesForDate(date);
  }

  List<dynamic> _getSelectedDayClasses() {
    final allClasses = ref.watch(classesForDateProvider({
      'locationId': widget.locationId,
      'date': selectedDate,
    }));
    
    // If numberOfClasses is provided, limit the results, otherwise show all
    if (widget.numberOfClasses != null && allClasses.isNotEmpty) {
      return allClasses.take(widget.numberOfClasses!).toList();
    }
    
    return allClasses;
  }

  String _formatTime(String timeString) {
    try {
      // Convert UTC time to local time first
      final localTime = parseUtcTimeFormatToLocal(timeString);
      
      // Create a DateTime object for formatting
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        localTime.hour,
        localTime.minute,
      );
      
      return DateFormat('h:mma').format(dateTime).toLowerCase();
    } catch (e) {
      return timeString;
    }
  }

  int _calculateDuration(String startTime, String endTime) {
    try {
      // Convert UTC times to local times first
      final localStartTime = parseUtcTimeFormatToLocal(startTime);
      final localEndTime = parseUtcTimeFormatToLocal(endTime);
      
      // Create DateTime objects for calculation
      final now = DateTime.now();
      final start = DateTime(
        now.year,
        now.month,
        now.day,
        localStartTime.hour,
        localStartTime.minute,
      );
      final end = DateTime(
        now.year,
        now.month,
        now.day,
        localEndTime.hour,
        localEndTime.minute,
      );
      
      return end.difference(start).inMinutes;
    } catch (e) {
      return 60; // Default duration
    }
  }

  Widget _buildWeekCalendar({bool isRefreshing = false}) {
    if (widget.showCalendarHeader != true) return const SizedBox.shrink();
    
    List<Widget> dayWidgets = [];
    DateTime startOfWeek = currentDate.subtract(Duration(days: currentDate.weekday % 7));
    
    for (int i = 0; i < 7; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      bool isToday = day.day == currentDate.day && 
                    day.month == currentDate.month && 
                    day.year == currentDate.year;
      bool isSelected = day.day == selectedDate.day && 
                       day.month == selectedDate.month && 
                       day.year == selectedDate.year;
      
      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () => _onDaySelected(day),
            child: Column(
              children: [
                Text(
                  DateFormat('E').format(day).substring(0, 1).toUpperCase(),
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                if (isToday && !isSelected)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getHeaderText(),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (isRefreshing) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(children: dayWidgets),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getHeaderText() {
    bool isToday = selectedDate.day == currentDate.day && 
                  selectedDate.month == currentDate.month && 
                  selectedDate.year == currentDate.year;
    
    if (isToday) {
      return 'Today';
    } else {
      return DateFormat('EEEE, MMMM d').format(selectedDate);
    }
  }

  Widget _buildClassCard(dynamic classData) {
    final schedule = classData['schedule'];
    final serviceName = classData['service_name'] ?? '';
    final serviceId = schedule['class_id'] ?? '';
    final location = schedule['Location']?['title'] ?? 'Location';
    final instructor = schedule['instructors']?.isNotEmpty == true 
      ? schedule['instructors'][0]['instructor']['name'] 
      : 'Instructor';
    
    final startTime = _formatTime(schedule['start_time']);
    final duration = _calculateDuration(schedule['start_time'], schedule['end_time']);
    
    // Mock status logic - you can implement based on your business logic
    String? status;
    Color? statusColor;
    if (schedule['package_person'] != null && schedule['package_person'] <= 10) {
      status = 'Full';
      statusColor = AppColors.primary;
    }
    // Add more status logic as needed

    return GestureDetector(
      onTap: () {
        if(serviceId == null || serviceName.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Service details are not available.'))
            );
          }
          return;
        }
        context.push(
          '/add_edit_class_and_schedule',
          extra: {
            'classId': serviceId, 
            'className': serviceName, 
            'isEditing': true
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGrayBoxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and Duration Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryFontColor,
                  ),
                ),
                Text(
                  '${duration}min',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryFontColor,
                  ),
                ),
              ],
            ),
            SizedBox(width: 24),
            
            // Class Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName.length > 20 
                      ? '${serviceName.substring(0, 17)}...' 
                      : serviceName,
                    style: AppTypography.appBarHeading.copyWith(
                      color: AppColors.secondaryFontColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    location,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondaryFontColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    instructor,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Status Badge
            if (status != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton() {
  return GestureDetector(
    onTap: () {
      context.push("/all_classes_screen");
    },
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Vertically center
      mainAxisAlignment: MainAxisAlignment.start,    // Align to left
      children: [
        Text(
          'View all',
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.arrow_forward,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(classesLoadingProvider);
    final isRefreshing = ref.watch(classesRefreshingProvider);
    final selectedDayClasses = _getSelectedDayClasses();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeekCalendar(isRefreshing: isRefreshing),
        
        if (isLoading && selectedDayClasses.isEmpty)
         Container(
        height: 160,
        color: AppColors.lightGrayBoxColor,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: const Center(
            child: CircularProgressIndicator(),
          )
      )
          
        else if (selectedDayClasses.isEmpty) 
          NoClassesBox(message: _getHeaderText().toLowerCase())
        else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedDayClasses.length,
            itemBuilder: (context, index) {
              return _buildClassCard(selectedDayClasses[index]);
            },
          ),
          if (widget.numberOfClasses != null) _buildViewAllButton(),
        ],
      ],
    );
  }
}