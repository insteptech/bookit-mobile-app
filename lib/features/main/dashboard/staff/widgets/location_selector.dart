import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/shared/components/molecules/checkbox_list_item.dart';
import 'package:flutter/material.dart';

class LocationSelector extends StatefulWidget {
  final VoidCallback? onSelectionChanged;
  
  const LocationSelector({super.key, this.onSelectionChanged});

  @override
  State<LocationSelector> createState() => LocationSelectorState();
}

class LocationSelectorState extends State<LocationSelector> {
  List<Map<String, String>> locations = [];
  Set<String> selectedLocationIds = {};

  /// Public getter for selected location IDs
  Set<String> get selectedLocations => selectedLocationIds;

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      // final Response response = await APIRepository.getUserDataForStaffRegistration();
      final response = await APIRepository.getBusinessLocations();
      final data = response;
        final List<dynamic> locationData = data['rows'];
        setState(() {
          locations = locationData
              .map((loc) => {
                    'id': loc['id'].toString(),
                    'title': loc['title'].toString(),
                  })
              .toList();
        });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Choose location", style: AppTypography.headingSm),
        const SizedBox(height: 8),

        if (locations.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          ...locations.map(
            (location) => CheckboxListItem(
              title: location['title'] ?? '',
              isSelected: selectedLocationIds.contains(location['id']),
              onChanged: (checked) {
                setState(() {
                  if (checked) {
                    selectedLocationIds.add(location['id']!);
                  } else {
                    selectedLocationIds.remove(location['id']);
                  }
                });
                widget.onSelectionChanged?.call();
              },
            ),
          ),
      ],
    );
  }
}