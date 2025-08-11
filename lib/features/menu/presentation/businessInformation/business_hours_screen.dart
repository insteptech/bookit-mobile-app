import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/schedule_selector.dart';
import 'package:bookit_mobile_app/features/menu/presentation/businessInformation/controllers/business_hour_controller.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/staff_schedule_controller.dart';
import 'package:flutter/material.dart';

class BusinessHoursScreen extends StatefulWidget {
  const BusinessHoursScreen({super.key});

  @override
  State<BusinessHoursScreen> createState() => _BusinessHoursScreenState();
}

class _BusinessHoursScreenState extends State<BusinessHoursScreen> {
  late BusinessHoursController businessController;
  late StaffScheduleController scheduleController;

  @override
  void initState() {
    super.initState();
    businessController = BusinessHoursController();
    scheduleController = StaffScheduleController();
    
    // Initialize the schedule controller with one entry for business hours
    scheduleController.addNewEntry();
    
    // Sync business hours to schedule controller format
    _syncBusinessHoursToScheduleController();
    
    // Listen to business controller changes
    businessController.addListener(_onBusinessHoursChanged);
  }

  @override
  void dispose() {
    businessController.removeListener(_onBusinessHoursChanged);
    businessController.dispose();
    super.dispose();
  }

  void _onBusinessHoursChanged() {
    _syncBusinessHoursToScheduleController();
  }

  /// Convert business hours format to schedule controller format
  void _syncBusinessHoursToScheduleController() {
    final List<Map<String, String>> daySchedules = [];
    
    for (var day in businessController.businessDays) {
      if (day.isOpen && day.openTime != null && day.closeTime != null) {
        daySchedules.add({
          "day": day.dayName.toLowerCase(),
          "from": _timeToUtcString(day.openTime!),
          "to": _timeToUtcString(day.closeTime!),
        });
      }
    }
    
    scheduleController.updateDaySchedule(0, daySchedules);
  }

  /// Convert TimeOfDay to UTC string format (HH:mm:ss)
  String _timeToUtcString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// Convert UTC string to TimeOfDay
  TimeOfDay _parseUtcString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Save business hours
  Future<void> _saveBusinessHours() async {
    // Sync any changes from ScheduleSelector back to BusinessHoursController
    _syncScheduleControllerToBusinessHours();
    
    if (!businessController.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(businessController.errorMessage ?? 'Please check your business hours'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final payload = businessController.buildPayload();
      print('Saving business hours: $payload');
      
      // TODO: Replace with actual API call
      // await APIRepository.saveBusinessHours(payload);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business hours saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving business hours: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Sync changes from ScheduleSelector back to BusinessHoursController
  void _syncScheduleControllerToBusinessHours() {
    if (scheduleController.entries.isNotEmpty) {
      final daySchedules = scheduleController.entries[0].daySchedules;
      
      // First, reset all days to closed
      for (int i = 0; i < businessController.businessDays.length; i++) {
        businessController.toggleDayStatus(i, false);
      }
      
      // Then set the days that have schedules
      for (var schedule in daySchedules) {
        final dayName = schedule['day'];
        final from = schedule['from'];
        final to = schedule['to'];
        
        if (dayName != null && from != null && to != null) {
          final dayIndex = businessController.businessDays.indexWhere(
            (d) => d.dayName.toLowerCase() == dayName.toLowerCase()
          );
          
          if (dayIndex != -1) {
            try {
              final openTime = _parseUtcString(from);
              final closeTime = _parseUtcString(to);
              
              businessController.toggleDayStatus(dayIndex, true);
              businessController.updateOpenTime(dayIndex, openTime);
              businessController.updateCloseTime(dayIndex, closeTime);
            } catch (e) {
              print('Error parsing time for $dayName: $from - $to, Error: $e');
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: businessController,
      builder: (context, child) {
        return MenuScreenScaffold(
          title: "Business hours",
          subtitle: "Input your business hours to enable a seamless booking experience for your clients.", 
          content: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Opening hours", 
                    style: AppTypography.headingSm,
                  ),
                  if (businessController.errorMessage != null)
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                ],
              ),
              
              // Show error message if any
              if (businessController.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    businessController.errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Use your existing ScheduleSelector component
              ScheduleSelector(
                index: 0,
                controller: scheduleController,
              ),
              
              const SizedBox(height: 24),
              
            ],
          ),
          isButtonDisabled: false,
          buttonText: "Save Business Hours",
          onButtonPressed: ()async{
            await _saveBusinessHours();
          },
        );
      },
    );
  }
}