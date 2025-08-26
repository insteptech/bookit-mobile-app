import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/custom_switch.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'class_schedule_selector.dart';

class LocationScheduleAccordion extends StatefulWidget {
  final String locationId;
  final String locationTitle;
  final List<Map<String, dynamic>> schedules;
  final List<Map<String, dynamic>> staffMembers;
  final int classDurationMinutes;
  final bool spotsLimitEnabled;
  final TextEditingController spotsController;
  final bool classAvailable;
  final Function(List<Map<String, dynamic>>) onScheduleUpdate;
  final Function(bool) onSpotsLimitToggle;
  final Function(bool) onClassAvailabilityToggle;
  final Function(bool, double?, int?, double?) onLocationPricingUpdate;

  const LocationScheduleAccordion({
    super.key,
    required this.locationId,
    required this.locationTitle,
    required this.schedules,
    required this.staffMembers,
    required this.classDurationMinutes,
    required this.spotsLimitEnabled,
    required this.spotsController,
    required this.classAvailable,
    required this.onScheduleUpdate,
    required this.onSpotsLimitToggle,
    required this.onClassAvailabilityToggle,
    required this.onLocationPricingUpdate,
  });

  @override
  State<LocationScheduleAccordion> createState() => _LocationScheduleAccordionState();
}

class _LocationScheduleAccordionState extends State<LocationScheduleAccordion> {
  bool _isExpanded = false;
  bool _locationPricingEnabled = false;

  final TextEditingController _priceOverrideController = TextEditingController();
  final TextEditingController _packagePersonController = TextEditingController();
  final TextEditingController _packageAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-expand if there are existing schedules
    _isExpanded = widget.schedules.isNotEmpty;
    
    // Add listeners to controllers to notify pricing changes
    _priceOverrideController.addListener(_notifyPricingUpdate);
    _packagePersonController.addListener(_notifyPricingUpdate);
    _packageAmountController.addListener(_notifyPricingUpdate);
  }

  @override
  void dispose() {
    _priceOverrideController.dispose();
    _packagePersonController.dispose();
    _packageAmountController.dispose();
    super.dispose();
  }

  void _notifyPricingUpdate() {
    final price = _priceOverrideController.text.isNotEmpty 
        ? double.tryParse(_priceOverrideController.text) 
        : null;
    final packagePerson = _packagePersonController.text.isNotEmpty 
        ? int.tryParse(_packagePersonController.text) 
        : null;
    final packageAmount = _packageAmountController.text.isNotEmpty 
        ? double.tryParse(_packageAmountController.text) 
        : null;
    
    widget.onLocationPricingUpdate(_locationPricingEnabled, price, packagePerson, packageAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Accordion header
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1EFFF), // Always light lavender for header
            border: Border.all(color: const Color(0xFFBFB3FF)), // Lavender border only on header
            borderRadius: BorderRadius.circular(8),
          ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: _isExpanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    )
                  : BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.contentSpacing,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Location pin icon
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),

                    const SizedBox(width: AppConstants.smallContentSpacing),

                    // Location title
                    Expanded(
                      child: Text(
                        widget.locationTitle,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    // Expand/collapse icon
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Warning message for incomplete schedule details (show when class available but incomplete)
          if (widget.classAvailable && !_hasCompleteSchedule()) ...[
            // const SizedBox(height: 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(color: AppColors.error),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'please complete the schedule',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
          ],

          // Accordion content
          if (_isExpanded) ...[
            const Divider(
              height: 1,
              color: Color(0xFFBFB3FF),
            ),

            Container(
              decoration: const BoxDecoration(
                color: Colors.white, // White background for content
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.contentSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class availability section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Class availability',
                          style: AppTypography.headingSm,
                        ),
                        CustomSwitch(
                          value: widget.classAvailable,
                          onChanged: (value) {
                            widget.onClassAvailabilityToggle(value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.sectionSpacing),

                    // Location specific pricing section (disabled when class availability is off)
                    Opacity(
                      opacity: widget.classAvailable ? 1.0 : 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location specific pricing',
                            style: AppTypography.headingSm,
                          ),

                          const SizedBox(height: AppConstants.smallContentSpacing),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Override price for this location?',
                                style: AppTypography.bodyMedium,
                              ),
                              CustomSwitch(
                                value: widget.classAvailable && _locationPricingEnabled,
                                onChanged: widget.classAvailable ? (value) {
                                  setState(() {
                                    _locationPricingEnabled = value;
                                  });
                                  _notifyPricingUpdate();
                                } : null,
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (widget.classAvailable && _locationPricingEnabled) ...[
                      const SizedBox(height: AppConstants.contentSpacing),

                      // Cost override section
                      Text(
                        'Cost override',
                        style: AppTypography.headingSm,
                      ),

                      const SizedBox(height: AppConstants.contentSpacing),

                      // Price per session
                      Text(
                        'Price per session',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallContentSpacing),

                      Row(
                        children: [
                          Text(
                            'EGP',
                            style: AppTypography.bodyMedium,
                          ),
                          const SizedBox(width: AppConstants.smallContentSpacing),
                          SizedBox(
                            width: 88,
                            child: NumericInputBox(
                              controller: _priceOverrideController,
                              hintText: '400',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.contentSpacing),

                      // Package
                      Text(
                        'Package',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallContentSpacing),

                      Row(
                        children: [
                          SizedBox(
                            width: 88,
                            child: NumericInputBox(
                              controller: _packagePersonController,
                              hintText: '10x',
                            ),
                          ),
                          const SizedBox(width: AppConstants.smallContentSpacing),
                          SizedBox(
                            width: 88,
                            child: NumericInputBox(
                              controller: _packageAmountController,
                              hintText: '3200',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.sectionSpacing),
                    ],

                    // Schedule selector (disabled when class availability is off)
                    Opacity(
                      opacity: widget.classAvailable ? 1.0 : 0.5,
                      child: IgnorePointer(
                        ignoring: !widget.classAvailable,
                        child: ClassScheduleSelector(
                          key: ValueKey('${widget.locationId}_${widget.classAvailable}'),
                          staffMembers: widget.staffMembers,
                          classDurationMinutes: widget.classDurationMinutes,
                          initialSchedules: _convertSchedulesToSelectorFormat(widget.schedules),
                          onScheduleUpdate: (schedules) {
                            if (widget.classAvailable) {
                              final convertedSchedules = _convertSchedulesFromSelectorFormat(schedules);
                              widget.onScheduleUpdate(convertedSchedules);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
  }

  bool _hasCompleteSchedule() {
    // Check if there are any schedules and if they have all required fields
    return widget.schedules.isNotEmpty && 
           widget.schedules.every((schedule) => 
             schedule['day'] != null && 
             schedule['day'].toString().isNotEmpty &&
             schedule['start_time'] != null && 
             schedule['start_time'].toString().isNotEmpty &&
             schedule['end_time'] != null &&
             schedule['end_time'].toString().isNotEmpty &&
             schedule['instructor_ids'] != null &&
             (schedule['instructor_ids'] as List).isNotEmpty
           );
  }

  List<Map<String, String>> _convertSchedulesToSelectorFormat(List<Map<String, dynamic>> schedules) {
    return schedules.map((schedule) {
      final instructorIds = schedule['instructor_ids'] as List<dynamic>? ?? [];
      final staffId = instructorIds.isNotEmpty ? instructorIds.first.toString() : '';
      
      return {
        'id': schedule['id']?.toString() ?? '',
        'day': schedule['day']?.toString() ?? '',
        'from': schedule['start_time']?.toString() ?? '',
        'to': schedule['end_time']?.toString() ?? '',
        'staffId': staffId,
        'instructors': (schedule['instructor_names'] as List<dynamic>?)?.join(',') ?? '',
        'instructor_ids': (schedule['instructor_ids'] as List<dynamic>?)?.join(',') ?? '',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _convertSchedulesFromSelectorFormat(List<Map<String, dynamic>> schedules) {
    return schedules.map((schedule) {
      // The selector can use different field names, handle both formats
      final startTime = schedule['startTime'] ?? schedule['from'];
      final endTime = schedule['endTime'] ?? schedule['to'];
      final staffId = schedule['staffId'] ?? schedule['instructor_id'];
      
      // Handle instructor IDs - can be single staffId or comma-separated instructor_ids
      List<String> instructorIds = [];
      if (staffId != null && staffId.toString().isNotEmpty) {
        instructorIds = [staffId.toString()];
      } else if (schedule['instructor_ids'] != null) {
        instructorIds = schedule['instructor_ids'].toString().split(',').where((id) => id.isNotEmpty).toList();
      }
      
      // Handle instructor names - try to get from staff members if we have staffId
      List<String> instructorNames = [];
      if (staffId != null && widget.staffMembers.isNotEmpty) {
        final staffMember = widget.staffMembers.firstWhere(
          (member) => member['id']?.toString() == staffId.toString(),
          orElse: () => {},
        );
        if (staffMember.isNotEmpty && staffMember['name'] != null) {
          instructorNames = [staffMember['name'].toString()];
        }
      } else if (schedule['instructors'] != null) {
        instructorNames = schedule['instructors'].toString().split(',').where((name) => name.isNotEmpty).toList();
      }

      return {
        'id': schedule['id'],
        'day': schedule['day'],
        'start_time': startTime,
        'end_time': endTime,
        'instructor_ids': instructorIds,
        'instructor_names': instructorNames,
        if (widget.spotsLimitEnabled && widget.spotsController.text.isNotEmpty)
          'spots_available': int.tryParse(widget.spotsController.text),
      };
    }).toList();
  }
}