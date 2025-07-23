import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  List<Map<String, dynamic>> staffSchedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() {
      isLoading = true;
    });

    try {
      final activeLocation = ref.read(activeLocationProvider);
      if (activeLocation.isNotEmpty) {
        // This would be the actual API call to fetch schedules
        // For now, we'll use mock data
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          staffSchedules = [
            {
              'id': '1',
              'staffName': 'Sarah Johnson',
              'role': 'Massage Therapist',
              'status': 'Available',
              'todaySchedule': '9:00 AM - 5:00 PM',
              'appointmentsToday': 4,
              'profileImage': null,
            },
            {
              'id': '2',
              'staffName': 'Michael Chen',
              'role': 'Fitness Instructor',
              'status': 'Busy',
              'todaySchedule': '6:00 AM - 2:00 PM',
              'appointmentsToday': 6,
              'profileImage': null,
            },
            {
              'id': '3',
              'staffName': 'Emma Wilson',
              'role': 'Wellness Coach',
              'status': 'Off',
              'todaySchedule': 'Day Off',
              'appointmentsToday': 0,
              'profileImage': null,
            },
          ];
        });
      }
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    } finally {
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
                  const SizedBox(height: 70),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppTranslationsDelegate.of(context).text("schedule"),
                    style: AppTypography.headingLg,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage staff schedules and availability',
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Location Selector (if multiple locations)
                  if (locations.length > 1) ...[
                    Text(
                      'Location',
                      style: AppTypography.headingSm,
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: locations.map((location) {
                          final isSelected = activeLocation == location['id'];
                          return GestureDetector(
                            onTap: () {
                              ref.read(activeLocationProvider.notifier).state = location['id']!;
                              _fetchSchedules();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected 
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected 
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                location['title']!,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isSelected 
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                  fontWeight: isSelected 
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          'Add Staff',
                          Icons.person_add_outlined,
                          () => context.push('/add_staff'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          'View All',
                          Icons.people_outlined,
                          () => context.push('/staff_list'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Staff Schedules
                  Text(
                    'Today\'s Schedule',
                    style: AppTypography.headingSm,
                  ),
                  const SizedBox(height: 16),

                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (staffSchedules.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...staffSchedules.map((schedule) => _buildScheduleCard(
                      context,
                      schedule,
                    )),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    Map<String, dynamic> schedule,
  ) {
    final theme = Theme.of(context);
    
    Color statusColor;
    Color statusBackgroundColor;
    
    switch (schedule['status']) {
      case 'Available':
        statusColor = Colors.green;
        statusBackgroundColor = Colors.green.withOpacity(0.1);
        break;
      case 'Busy':
        statusColor = Colors.orange;
        statusBackgroundColor = Colors.orange.withOpacity(0.1);
        break;
      case 'Off':
        statusColor = Colors.grey;
        statusBackgroundColor = Colors.grey.withOpacity(0.1);
        break;
      default:
        statusColor = theme.colorScheme.onSurface;
        statusBackgroundColor = theme.colorScheme.onSurface.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: schedule['profileImage'] != null
                  ? ClipOval(
                      child: Image.network(
                        schedule['profileImage'],
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule['staffName'],
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      schedule['role'],
                      style: AppTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  schedule['status'],
                  style: AppTypography.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                schedule['todaySchedule'],
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              Text(
                '${schedule['appointmentsToday']} appointments',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No schedules found',
            style: AppTypography.headingSm.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add staff members to start managing schedules',
            style: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
