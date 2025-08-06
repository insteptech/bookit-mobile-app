import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';

class LocationSelectorWidget extends ConsumerWidget {
  const LocationSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locations = ref.watch(locationsProvider);
    final activeLocation = ref.watch(activeLocationProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...locations.map((location) {
            return GestureDetector(
              onTap: () async {
                // Update active location
                ref.read(activeLocationProvider.notifier).state = location['id'];
                
                // Fetch appointments for the new location
                await ref.read(appointmentsControllerProvider.notifier)
                    .fetchAppointments(location['id']);
                
                // Fetch business categories if not already loaded
                final businessController = ref.read(businessControllerProvider.notifier);
                if (!ref.read(businessLoadedProvider)) {
                  await businessController.fetchBusinessCategories();
                }
                
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: activeLocation == location['id']
                        ? theme.colorScheme.onSurface
                        : AppColors.appLightGrayFont,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(location["title"]),
              ),
            );
          }),
        ],
      ),
    );
  }
}
