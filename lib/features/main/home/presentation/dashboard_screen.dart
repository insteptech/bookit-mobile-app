import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 34,
                    vertical: 70,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification Icon Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Icon(Icons.notifications_outlined, size: 28),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Welcome back text
                      Text("Welcome back", style: AppTypography.headingLg),
                      const SizedBox(height: 16),

                      // Studio Button 
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.surface),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("Studio X Zamalek"),
                      ),

                      const SizedBox(height: 32),

                      // Today's appointments
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today’s appointments",
                            style: AppTypography.headingMd.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          context.push("/add_staff");
                        },
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Click to add staff and their availability.",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Today's class schedule
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today’s class schedule",
                            style: AppTypography.headingMd.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          // context.push("/staff_list");
                        },
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Click to add staff and class schedules.",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Logout Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 34),
              child: PrimaryButton(
                onPressed: () async {
                  await TokenService().clearToken();
                  context.go("/login");
                },
                isDisabled: false,
                text: "Logout",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
