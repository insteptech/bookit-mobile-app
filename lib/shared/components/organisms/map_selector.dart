import 'dart:convert';
import 'package:bookit_mobile_app/app/api_keys.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;

class MapSelector extends StatefulWidget {
  final void Function(Map<String, dynamic>) onLocationSelected;
  final VoidCallback? onBackPressed; // Add callback for back button
  final double? initialLat;
  final double? initialLng;

  const MapSelector({
    super.key,
    required this.onLocationSelected,
    this.onBackPressed,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapSelector> createState() => _MapSelectorState();
}

class _MapSelectorState extends State<MapSelector> {
  MapboxMap? mapboxMap;
  Position centerPosition = Position(30, 31); // Chandigarh
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
    
    // Request location permission on init
    _requestLocationPermissionOnInit();
  }

  Future<void> _requestLocationPermissionOnInit() async {
    try {
      var permission = await Permission.location.status;
      if (permission.isDenied || permission.isRestricted) {
        permission = await Permission.location.request();
      }

      if (permission.isPermanentlyDenied) {
        // Show dialog or snackbar to inform user to enable from settings
        _showLocationPermissionDialog();
        return;
      }

      if (permission.isGranted) {
        // Automatically move to current location when permission is granted
        await _getCurrentLocationAndMove();
      }
    } catch (e) {
      // Handle any errors silently
    }
  }

  Future<void> _getCurrentLocationAndMove() async {
    try {
      final current = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      centerPosition = Position(current.longitude, current.latitude);
      
      // Update the camera to show current location
      camera = CameraOptions(
        center: Point(coordinates: centerPosition),
        zoom: 15,
      );
      
      // If map is already created, fly to the location
      if (mapboxMap != null) {
        await mapboxMap?.flyTo(
          CameraOptions(center: Point(coordinates: centerPosition), zoom: 15),
          MapAnimationOptions(duration: 1000),
        );
      }
      
      setState(() {});
    } catch (e) {
      // Handle any errors silently
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to show your current location on the map. Please enable location permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _onMapCreated(MapboxMap map) {
    mapboxMap = map;
    
    // If we already have a user's location and camera is set to current location,
    // move to it when map is ready
    if (centerPosition.lat != 30 || centerPosition.lng != 31) {
      // This means we've updated the position from default Chandigarh coordinates
      mapboxMap?.flyTo(
        CameraOptions(center: Point(coordinates: centerPosition), zoom: 15),
        MapAnimationOptions(duration: 1000),
      );
    }
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
      if (!permission.isGranted) {
        // If permission is not granted, request it
        permission = await Permission.location.request();
      }

      if (permission.isPermanentlyDenied) {
        _showLocationPermissionDialog();
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
      // print('Error getting current location: $e');
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
    setState(() {
      searchResults = []; // clear suggestions after moving
    });
  }

  void _handleBackButton() {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // hide keyboard
        if (searchResults.isNotEmpty) {
          setState(() {
            searchResults = []; // hide suggestions
          });
        }
      },
      behavior: HitTestBehavior.opaque, // Detect taps on empty space
      child: Stack(
          children: [
            if (camera != null)
              MapWidget(
                cameraOptions: camera!,
                onMapCreated: _onMapCreated,
                onCameraChangeListener: _onCameraChange,
              ),

            Center(
              child: Icon(Icons.location_pin,
                  size: 50, color: theme.colorScheme.primary),
            ),

            Positioned(
              top: 50,
              left: 34,
              right: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 54,
                        padding: const EdgeInsets.only(left: 48, right: 20),
                        alignment: Alignment.centerLeft,
                        child: TextField(
  controller: searchController,
  style: AppTypography.bodyMedium,
  decoration: InputDecoration(
    hintText: 'Search here',
    hintStyle: AppTypography.bodyMedium,
    fillColor: theme.scaffoldBackgroundColor,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30), // Circular shape
      borderSide: BorderSide(color: theme.scaffoldBackgroundColor), // Border color
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: theme.scaffoldBackgroundColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: theme.scaffoldBackgroundColor), // Focused border color
    ),
  ),
  onChanged: _searchPlaces,
),

                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _handleBackButton, // Use the new handler
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 12,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (_, index) {
                          final result = searchResults[index];
                          return ListTile(
                            title: Text(result['name']),
                            onTap: () {
                              searchController.text = result['name'];
                              _moveToSearchResult(result['lat'], result['lng']);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            Positioned(
              bottom: 80,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                onPressed: _moveToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ),

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
    )
    );
  }
}