import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/calendar/widgets/upcoming_appointments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  Future<void> fetchAppointments(String locationId) async {
    final data = await APIRepository.getAppointments(locationId);
    setState(() {
      appointments = List<Map<String, dynamic>>.from(data['data']);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final notifier = ref.read(locationsProvider.notifier);
    if (ref.read(locationsProvider).isEmpty) {
      await notifier.fetchLocations();
    }
    final locations = ref.read(locationsProvider);
    if (locations.isNotEmpty) {
      final activeLocation = ref.read(activeLocationProvider);
      final locationId = activeLocation.isNotEmpty ? activeLocation : locations[0]['id'];
      ref.read(activeLocationProvider.notifier).state = locationId;
      setState(() {
        isLoading = true;
      });
      await fetchAppointments(locationId);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locations = ref.watch(locationsProvider);
    final activeLocation = ref.watch(activeLocationProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 24,
                ),
                children: [
                  const SizedBox(height: 98),
                  const SizedBox(height: 16),
                  Text(AppTranslationsDelegate.of(context).text("calendar_title"), style: AppTypography.headingLg),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ...locations.map((location) {
                          return GestureDetector(
                            onTap: () async {
                              ref.read(activeLocationProvider.notifier).state = location['id'];
                              await fetchAppointments(location['id']);
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
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslationsDelegate.of(context).text("appointments"),
                        style: AppTypography.headingMd.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppointmentsWidget(
                    staffAppointments: appointments,
                    maxAppointments: 3,
                    isLoading: isLoading,
                    showBottomOptions: true,
                  ),
                 
                  SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslationsDelegate.of(context).text("schedule"),
                        style: AppTypography.headingMd.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}