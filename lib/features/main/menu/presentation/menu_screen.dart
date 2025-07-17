import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  Text("Menu", style: AppTypography.headingLg),
                  const SizedBox(height: 8),
                  const SizedBox(height: 48),

                  SizedBox(height: 48),
                  Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 36,
                            child: OutlinedButton(
                              onPressed: () async {
                                await TokenService().clearToken();
                                await ActiveBusinessService().clearActiveBusiness();
                                context.go("/login");
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                // padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                              ),
                              child: Text(
                                "Log out",
                                style: AppTypography.bodyMedium.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
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
