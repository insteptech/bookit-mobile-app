import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddClassScheduleScreen extends StatefulWidget {
  const AddClassScheduleScreen({super.key});

  @override
  State<AddClassScheduleScreen> createState() => _AddClassScheduleScreenState();
}
class _AddClassScheduleScreenState extends State<AddClassScheduleScreen> {

List<Map<String, String>> category = [];

  List<Map<String, dynamic>> classes = [
    {"id": "1", "name": "Yoga"},
    {"id": "2", "name": "Pilates"},
    {"id": "3", "name": "Zumba"},
    {"id": "4", "name": "Spinning"},
    {"id": "5", "name": "HIIT"},
  ];


  String selectedLocation = "1"; // Default to first location
  List<Map<String, String>> locations = [
    {"id": "1", "title": "Main Gym"},
    {"id": "2", "title": "Yoga Studio"},
    {"id": "3", "title": "Dance Hall"},
  ];
  bool locationSpecificPricing = false;

  List<Map<String, dynamic>> userList = [
    {"id": "1", "name": "John Doe"},
    {"id": "2", "name": "Jane Smith"},
    {"id": "3", "name": "Alice Johnson"},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 34,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 70),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 32),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          AppTranslationsDelegate.of(context).text("class_schedule"),
                          style: AppTypography.headingLg,
                        ),

                        SizedBox(height: 8,),

                        Text(AppTranslationsDelegate.of(context).text("class_schedule_description"), style: AppTypography.bodyMedium,),
                        
                        const SizedBox(height: 40),

//classes
                        ...classes.map((className) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              className['name'] ?? '',
                              style: AppTypography.bodyMedium,
                            ),
                          );
                        }).toList(),


//select location


                       ...locations.map((location){
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              location['title'] ?? '',
                              style: AppTypography.bodyMedium,
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 24),
//location specific pricing

                        Text(AppTranslationsDelegate.of(context).text("location_specific_pricing"), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),),
                        Text(AppTranslationsDelegate.of(context).text("override_price_for_location"), style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    children: [
                      PrimaryButton(
                        text: AppTranslationsDelegate.of(context).text("continue_to_schedule"),
                        onPressed: () {

                        },
                        isDisabled: false,
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('home_screen'),
                          child: Text(
                            AppTranslationsDelegate.of(context).text("save_and_exit"),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}