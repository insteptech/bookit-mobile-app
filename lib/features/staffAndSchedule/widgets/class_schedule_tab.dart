import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import '../application/add_edit_class_schedule_controller.dart';
import 'location_schedule_accordion.dart';

class ClassScheduleTab extends StatelessWidget {
  const ClassScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddEditClassScheduleController>(
      builder: (context, controller, child) {
        if (controller.locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: AppConstants.contentSpacing),
                Text(
                  'No locations available',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Please add business locations first',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.allStaffMembers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: AppConstants.contentSpacing),
                Text(
                  'No coach available',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Please add coach to schedule the class',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location accordions
            Column(
              children: controller.locations.map((location) {
                final locationId = location['id'];
                final locationTitle = location['title'] ?? 'Unknown Location';
                final schedules = controller.schedulesByLocation[locationId] ?? [];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.contentSpacing),
                  child: LocationScheduleAccordion(
                    key: ValueKey(locationId),
                    locationId: locationId,
                    locationTitle: locationTitle,
                    schedules: schedules,
                    staffMembers: controller.getStaffForLocation(locationId),
                    classDurationMinutes: int.tryParse(controller.durationController.text) ?? 60,
                    spotsLimitEnabled: controller.spotsLimitEnabledByLocation[locationId] ?? false,
                    spotsController: controller.getLocationSpotsController(locationId),
                    classAvailable: controller.classAvailabilityByLocation[locationId] ?? false,
                    onScheduleUpdate: (updatedSchedules) {
                      controller.updateLocationSchedule(locationId, updatedSchedules);
                    },
                    onSpotsLimitToggle: (enabled) {
                      controller.setLocationSpotsLimitEnabled(locationId, enabled);
                    },
                    onClassAvailabilityToggle: (available) {
                      controller.setLocationClassAvailability(locationId, available);
                    },
                    onLocationPricingUpdate: (enabled, price, packagePerson, packageAmount) {
                      controller.updateLocationPricing(locationId, enabled, price, packagePerson, packageAmount);
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}