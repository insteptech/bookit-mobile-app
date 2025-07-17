import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  LocationsNotifier() : super([]);

  Future<void> fetchLocations() async {
    final data = await APIRepository.getBusinessLocations();
    state = data['rows'].cast<Map<String, dynamic>>();
  }
}

final locationsProvider = StateNotifierProvider<LocationsNotifier, List<Map<String, dynamic>>>(
  (ref) => LocationsNotifier(),
);

// Add this for global active location state
final activeLocationProvider = StateProvider<String>((ref) => "");