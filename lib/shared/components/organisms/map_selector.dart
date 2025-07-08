import 'dart:convert';
import 'package:bookit_mobile_app/app/api_keys.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;

class MapSelector extends StatefulWidget {
  final void Function(Map<String, dynamic>) onLocationSelected;
  final double? initialLat;
  final double? initialLng;

  const MapSelector({
    super.key,
    required this.onLocationSelected,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapSelector> createState() => _MapSelectorState();
}

class _MapSelectorState extends State<MapSelector> {
  MapboxMap? mapboxMap;
  Position centerPosition = Position(76.8604, 30.6606); // Chandigarh
  CameraOptions? camera;

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      centerPosition = Position(widget.initialLng!, widget.initialLat!);
    }
    camera = CameraOptions(
      center: Point(coordinates: centerPosition),
      zoom: 14,
    );
  }

  void _onMapCreated(MapboxMap map) {
    mapboxMap = map;
  }

  void _onCameraChange(CameraChangedEventData data) async {
    if (mapboxMap != null) {
      final cameraState = await mapboxMap!.getCameraState();
      setState(() {
        centerPosition = Position(
          cameraState.center.coordinates.lng,
          cameraState.center.coordinates.lat,
        );
      });
    }
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      var permission = await Permission.location.status;
      if (permission.isDenied || permission.isRestricted) {
        permission = await Permission.location.request();
      }

      if (permission.isPermanentlyDenied) {
        openAppSettings();
        return;
      }

      if (!permission.isGranted) return;

      final current = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      centerPosition = Position(current.longitude, current.latitude);
      await mapboxMap?.flyTo(
        CameraOptions(center: Point(coordinates: centerPosition), zoom: 15),
        MapAnimationOptions(duration: 1000),
      );
      setState(() {});
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<Map<String, dynamic>> _reverseGeocode(Position coords) async {
    try {
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${coords.lng},${coords.lat}.json?access_token=$mapboxToken';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode != 200) throw Exception('Geocode failed');

      final data = jsonDecode(res.body);
      String city = '', state = '', country = '';

      for (var feat in data['features']) {
        if (feat['place_type'] == null) continue;
        final type = feat['place_type'][0];
        if (type == 'place' && city.isEmpty) city = feat['text'] ?? '';
        if (type == 'region' && state.isEmpty) state = feat['text'] ?? '';
        if (type == 'country' && country.isEmpty) country = feat['text'] ?? '';
      }

      return {
        'lat': coords.lat,
        'lng': coords.lng,
        'city': city,
        'state': state,
        'country': country,
      };
    } catch (e) {
      print('Error in reverse geocoding: $e');
      return {
        'lat': coords.lat,
        'lng': coords.lng,
        'city': '',
        'state': '',
        'country': '',
      };
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$mapboxToken&autocomplete=true&limit=5';

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return;

    final data = jsonDecode(res.body);
    final features = data['features'] ?? [];

    setState(() {
      searchResults = features.map<Map<String, dynamic>>((f) {
        return {
          "name": f["place_name"],
          "lat": f["center"][1],
          "lng": f["center"][0],
        };
      }).toList();
    });
  }

  Future<void> _moveToSearchResult(double lat, double lng) async {
    centerPosition = Position(lng, lat);
    await mapboxMap?.flyTo(
      CameraOptions(center: Point(coordinates: centerPosition), zoom: 14),
      MapAnimationOptions(duration: 1000),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (camera != null)
              MapWidget(
                cameraOptions: camera!,
                onMapCreated: _onMapCreated,
                onCameraChangeListener: _onCameraChange,
              ),

            // 📍 Pin
            Center(
              child: Icon(Icons.location_pin,
                  size: 50, color: theme.colorScheme.primary),
            ),

            // 🔍 Search Box + Suggestions
            Positioned(
              top: 50,
              left: 34,
              right: 34,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                      onChanged: _searchPlaces,
                    ),
                  ),
                  if (searchResults.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (_, index) {
                          final result = searchResults[index];
                          return ListTile(
                            title: Text(result['name']),
                            onTap: () {
                              searchController.text = result['name'];
                              searchResults = [];
                              _moveToSearchResult(result['lat'], result['lng']);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // 🎯 Current location FAB
            Positioned(
              bottom: 80,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                onPressed: _moveToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ),

            // ✅ Confirm Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.fromLTRB(25, 12, 20, 10),
                child: PrimaryButton(
                  text: "Next: Fill Address",
                  isDisabled: false,
                  onPressed: () async {
                    final data = await _reverseGeocode(centerPosition);
                    widget.onLocationSelected(data);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}