import 'package:bookit_mobile_app/app/api_keys.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/organisms/map_selector.dart';
import 'package:flutter/material.dart';

class OnboardingLocationInfoForm extends StatelessWidget {
  final void Function(Map<String, dynamic>) onLocationUpdated;
  final TextEditingController locationController;
  final TextEditingController addressController;
  final TextEditingController floorController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController countryController;
  final TextEditingController instructionController;
  final double? lat;
  final double? lng;
  final bool showDeleteButton;
  final Function onClick;
  final int? addressNumber;

  const OnboardingLocationInfoForm({
    super.key,
    required this.locationController,
    required this.addressController,
    required this.cityController,
    required this.floorController,
    required this.instructionController,
    required this.countryController,
    required this.stateController,
    required this.onClick,
    required this.showDeleteButton,
    required this.onLocationUpdated,
    this.lat,
    this.lng,
    this.addressNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use provided lat/lng or default to egypt
    final double latitude = lat ?? 30;
    final double longitude = lng ?? 31;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              addressNumber != null && addressNumber! > 0 
                ? "${AppTranslationsDelegate.of(context).text("address")} $addressNumber"
                : AppTranslationsDelegate.of(context).text("address"), 
              style: AppTypography.bodyMedium
            ),
            if (showDeleteButton)
              GestureDetector(
                onTap: () {
                  onClick();
                },
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => MapSelector(
                      initialLat: lat,
                      initialLng: lng,
                      onLocationSelected: (locationData) {
                        onLocationUpdated(
                          locationData,
                        ); // ✅ use your callback directly
                        Navigator.pop(context); // ✅ close the map screen
                      },
                    ),
              ),
            );
          },
          //----------- For mapbox sdk ----------------
          // child: SizedBox(
          //   height: 200,
          //   width: double.infinity,
          //   child: Stack(
          //     children: [
          //       MapWidget(cameraOptions: camera),
          //       Center(
          //         child: Icon(
          //           Icons.location_pin,
          //           color: theme.colorScheme.primary,
          //           size: 34,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          //------------ For mapbox image --------------
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/'
                    '$longitude,$latitude,18,0/1280x720'
                    '?access_token=$mapboxToken',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 240,
                  ),
                ),
                Icon(
                  Icons.location_pin,
                  color: theme.colorScheme.primary,
                  size: 34,
                ),
              ],
            ),
          ),
          
        ),

        SizedBox(height: 16),
        Text(AppTranslationsDelegate.of(context).text("location_name"), style: AppTypography.bodyMedium),
        InputField(hintText: AppTranslationsDelegate.of(context).text("location_name"), controller: locationController),

        SizedBox(height: 8),
        Text(AppTranslationsDelegate.of(context).text("address"), style: AppTypography.bodyMedium),
        InputField(hintText: AppTranslationsDelegate.of(context).text("street"), controller: addressController),

        SizedBox(height: 8),
        Text(AppTranslationsDelegate.of(context).text("floor_apt"), style: AppTypography.bodyMedium),
        InputField(hintText: AppTranslationsDelegate.of(context).text("floor_apt_number"), controller: floorController),

        SizedBox(height: 8),
        Text(AppTranslationsDelegate.of(context).text("city"), style: AppTypography.bodyMedium),
        InputField(hintText: AppTranslationsDelegate.of(context).text("city"), controller: cityController),

        SizedBox(height: 8),
        Text(AppTranslationsDelegate.of(context).text("state"), style: AppTypography.bodyMedium),
        InputField(hintText: "State", controller: stateController),

        SizedBox(height: 8),
        Text(AppTranslationsDelegate.of(context).text("country"), style: AppTypography.bodyMedium),
        InputField(hintText: "Country", controller: countryController),

        SizedBox(height: 8),
        Text(AppTranslationsDelegate.of(context).text("additional_instructions"), style: AppTypography.bodyMedium),
        InputField(
          hintText: "Directions and instructions",
          controller: instructionController,
        ),
      ],
    );
  }
}