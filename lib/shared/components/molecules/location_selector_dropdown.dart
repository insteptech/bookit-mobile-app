import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';

class LocationSelectorDropdown extends ConsumerStatefulWidget {
  const LocationSelectorDropdown({super.key});

  @override
  ConsumerState<LocationSelectorDropdown> createState() => _LocationSelectorDropdownState();
}

class _LocationSelectorDropdownState extends ConsumerState<LocationSelectorDropdown> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(locationsProvider);
    final activeLocation = ref.watch(activeLocationProvider);
    
    if (locations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final activeLocationData = locations.firstWhere(
      (location) => location['id'] == activeLocation,
      orElse: () => locations.first,
    );
    
    final otherLocations = locations.where(
      (location) => location['id'] != activeLocation,
    ).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected location pill
        GestureDetector(
          onTap: () {
            if (otherLocations.isNotEmpty) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activeLocationData['title'] ?? 'Unknown Location',
                  style: const TextStyle(
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                if (otherLocations.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.black,
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Dropdown
        if (_isExpanded && otherLocations.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: 324,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCED4DA), width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(33, 37, 41, 0.08),
                  blurRadius: 1,
                  offset: Offset(0, 0),
                ),
                BoxShadow(
                  color: Color.fromRGBO(33, 37, 41, 0.06),
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < otherLocations.length; i++) ...[
                  GestureDetector(
                    onTap: () async {
                      final locationId = otherLocations[i]['id'];
                      
                      // Update active location
                      ref.read(activeLocationProvider.notifier).state = locationId;
                      
                      // Fetch appointments for the new location
                      await ref.read(appointmentsControllerProvider.notifier)
                          .fetchAppointments(locationId);
                      
                      // Fetch business categories if not already loaded
                      final businessController = ref.read(businessControllerProvider.notifier);
                      if (!ref.read(businessLoadedProvider)) {
                        await businessController.fetchBusinessCategories();
                      }
                      
                      // Close dropdown
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    child: SizedBox(
                      height: 20,
                      child: Text(
                        otherLocations[i]['title'] ?? 'Unknown Location',
                        style: const TextStyle(
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.25,
                          color: Color(0xFF202733),
                        ),
                      ),
                    ),
                  ),
                  if (i < otherLocations.length - 1) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 0.5,
                      color: const Color(0xFFE9ECEF),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}