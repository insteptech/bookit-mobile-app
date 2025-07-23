import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:flutter/material.dart';

class SetupChecklistScreen extends StatefulWidget {
  const SetupChecklistScreen({super.key});

  @override
  State<SetupChecklistScreen> createState() => _SetupChecklistScreenState();
}

class _SetupChecklistScreenState extends State<SetupChecklistScreen> {
  
  final List<Map<String, dynamic>> checklistItems = [
    {
      'title': 'Business Information',
      'description': 'Add your business details and contact information',
      'isCompleted': true,
      'icon': Icons.business_outlined,
    },
    {
      'title': 'Locations',
      'description': 'Set up your business locations',
      'isCompleted': true,
      'icon': Icons.location_on_outlined,
    },
    {
      'title': 'Services & Offerings',
      'description': 'Add your services and pricing',
      'isCompleted': true,
      'icon': Icons.spa_outlined,
    },
    {
      'title': 'Staff Members',
      'description': 'Add your team members and their schedules',
      'isCompleted': false,
      'icon': Icons.people_outlined,
    },
    {
      'title': 'Payment Setup',
      'description': 'Configure payment methods and billing',
      'isCompleted': false,
      'icon': Icons.payment_outlined,
    },
    {
      'title': 'Client Web App',
      'description': 'Customize your online booking experience',
      'isCompleted': false,
      'icon': Icons.web_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedItems = checklistItems.where((item) => item['isCompleted']).length;
    final totalItems = checklistItems.length;
    final progressPercentage = (completedItems / totalItems * 100).round();

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
                    AppTranslationsDelegate.of(context).text("setup_checklist"),
                    style: AppTypography.headingLg,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete these steps to get your business ready for bookings',
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
