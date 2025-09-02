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
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  
  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
  
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  void _toggleDropdown() {
    if (_isExpanded) {
      _removeOverlay();
      setState(() {
        _isExpanded = false;
      });
    } else {
      _showOverlay();
      setState(() {
        _isExpanded = true;
      });
    }
  }
  
  void _showOverlay() {
    final renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _DropdownOverlay(
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        screenSize: screenSize,
        locations: ref.read(locationsProvider).where(
          (location) => location['id'] != ref.read(activeLocationProvider),
        ).toList(),
        onLocationSelected: (locationId) async {
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
          _toggleDropdown();
        },
        onClose: _toggleDropdown,
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }
  
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
    
    return GestureDetector(
      key: _buttonKey,
      onTap: () {
        if (otherLocations.isNotEmpty) {
          _toggleDropdown();
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
    );
  }
}

class _DropdownOverlay extends StatelessWidget {
  final Offset buttonPosition;
  final Size buttonSize;
  final Size screenSize;
  final List<Map<String, dynamic>> locations;
  final Function(String) onLocationSelected;
  final VoidCallback onClose;

  const _DropdownOverlay({
    required this.buttonPosition,
    required this.buttonSize,
    required this.screenSize,
    required this.locations,
    required this.onLocationSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate dropdown dimensions
    final dropdownHeight = (locations.length * 36.0) + 32.0; // 36 per item + padding
    final dropdownWidth = 200.0; // Responsive width
    
    // Calculate optimal position
    double left = buttonPosition.dx;
    double top = buttonPosition.dy + buttonSize.height + 8;
    
    // Check if dropdown fits to the right
    if (left + dropdownWidth > screenSize.width) {
      // Position to the left of the button
      left = buttonPosition.dx + buttonSize.width - dropdownWidth;
    }
    
    // Check if dropdown fits below
    if (top + dropdownHeight > screenSize.height) {
      // Position above the button
      top = buttonPosition.dy - dropdownHeight - 8;
    }
    
    // Ensure dropdown stays within screen bounds
    left = left.clamp(16.0, screenSize.width - dropdownWidth - 16.0);
    top = top.clamp(16.0, screenSize.height - dropdownHeight - 16.0);

    return Stack(
      children: [
        // Invisible barrier to close dropdown when tapping outside
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),
        
        // Dropdown content
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dropdownWidth,
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < locations.length; i++) ...[
                    GestureDetector(
                      onTap: () => onLocationSelected(locations[i]['id']),
                      child: Container(
                        width: double.infinity,
                        height: 20,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          locations[i]['title'] ?? 'Unknown Location',
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
                    if (i < locations.length - 1) ...[
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
          ),
        ),
      ],
    );
  }
}