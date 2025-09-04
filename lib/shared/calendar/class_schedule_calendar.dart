import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/controllers/classes_controller.dart';
import 'package:bookit_mobile_app/core/utils/time_utils.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/no_classes_box.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/warning_dialog.dart';
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
    
    print('📅 Classes data from backend:');
    print('Location ID: ${widget.locationId}');
    print('Selected Date: $selectedDate');
    print('Total classes count: ${allClasses.length}');
    print('Classes data: $allClasses');
    
    // If numberOfClasses is provided, limit the results, otherwise show all
    if (widget.numberOfClasses != null && allClasses.isNotEmpty) {
      final limitedClasses = allClasses.take(widget.numberOfClasses!).toList();
      print('Limited to ${widget.numberOfClasses} classes: $limitedClasses');
      return limitedClasses;
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

  Future<void> _cancelClass(String classId, String className) async {
    try {
      // Show confirmation dialog
      final bool? shouldCancel = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (BuildContext context) {
          return WarningDialog.cancelClass(
            className: className,
            classDate: selectedDate,
            onConfirm: () {}, // Dialog handles the navigation
          );
        },
      );

      if (shouldCancel == true) {
        // Show loading state
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Cancelling class...'),
                ],
              ),
              backgroundColor: const Color(0xFFEA52E7),
            ),
          );
        }

        // Call the cancel API
        final response = await APIRepository.cancelClass(classId);
        
        print('🚫 Cancel class API response from backend:');
        print('Class ID: $classId');
        print('Response: $response');
        
        if (mounted) {
          // Hide loading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          
          if (response['success'] == true) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Class cancelled successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Refresh the classes list
            _fetchClassesForDate(selectedDate);
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to cancel class. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling class: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Widget _buildClassCard(dynamic classData) {
    print('🎯 Individual class data from backend:');
    print('Full class data: $classData');
    
    final schedule = classData['schedule'];
    final serviceName = classData['service_name'] ?? '';
    final serviceId = schedule['class_id'] ?? '';
    final location = schedule['Location']?['title'] ?? 'Location';
    final instructor = schedule['instructors']?.isNotEmpty == true 
      ? schedule['instructors'][0]['instructor']['name'] 
      : 'Instructor';
    
    print('Parsed data - Service Name: $serviceName, Service ID: $serviceId');
    print('Schedule details: $schedule');
    
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

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: _SwipeToRevealCard(
        key: Key('class_${serviceId}_${DateTime.now().millisecondsSinceEpoch}'),
        onCancel: () => _cancelClass(serviceId, serviceName),
        child: GestureDetector(
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
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA), // Light gray background from Figma
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time and Duration Column
                SizedBox(
                  width: 54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3A0039), // Dark color from Figma
                          fontFamily: 'Campton',
                        ),
                      ),
                      Text(
                        '${duration}min',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF790077), // Purple color from Figma
                          fontFamily: 'Campton',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                
                // Class Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName.length > 20 
                          ? '${serviceName.substring(0, 17)}...' 
                          : serviceName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3A0039), // Dark color from Figma
                          fontFamily: 'Campton',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        instructor,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6C757D), // Gray color from Figma
                          fontFamily: 'Campton',
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

class _SwipeToRevealCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onCancel;

  const _SwipeToRevealCard({
    Key? key,
    required this.child,
    required this.onCancel,
  }) : super(key: key);

  @override
  _SwipeToRevealCardState createState() => _SwipeToRevealCardState();
}

class _SwipeToRevealCardState extends State<_SwipeToRevealCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  
  double _dragOffset = 0.0;
  bool _isRevealed = false;
  static const double _revealThreshold = 80.0; // Minimum swipe distance to reveal

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.25, 0), // Slide left by 25% to reveal cancel button
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(-120.0, 0.0); // Limit drag distance
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_dragOffset < -_revealThreshold) {
      // Reveal cancel button
      _revealCancel();
    } else {
      // Snap back to original position
      _hideCancel();
    }
  }

  void _revealCancel() {
    setState(() {
      _isRevealed = true;
      _dragOffset = -80.0; // Set to revealed position
    });
    _controller.forward();
  }

  void _hideCancel() {
    setState(() {
      _isRevealed = false;
      _dragOffset = 0.0;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Cancel button background (always present but hidden)
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerRight,
              color: const Color(0xFFEA52E7), // Pink cancel button color
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: widget.onCancel,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Campton',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Main card content
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: GestureDetector(
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              onTap: () {
                if (_isRevealed) {
                  _hideCancel(); // Hide cancel if revealed and tapped
                }
              },
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}