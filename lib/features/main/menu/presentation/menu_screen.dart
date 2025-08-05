import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/core/services/navigation_service.dart';
import 'package:bookit_mobile_app/features/main/menu/widgets/menu_item.dart';
import 'package:bookit_mobile_app/features/main/menu/widgets/menu_section.dart';
import 'package:bookit_mobile_app/features/main/menu/controllers/menu_controller.dart' as menu_ctrl;
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final menu_ctrl.MenuController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = menu_ctrl.MenuController();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.fromLTRB(
                  35,80,35,10
                ),
                children: [
                  const SizedBox(height: 24),
                  Text(
                    AppTranslationsDelegate.of(context).text("menu_title"),
                    style: AppTypography.headingLg,
                  ),
                  const SizedBox(height: 48),
                  
                  // STAFF Section
                  MenuSection(
                    title: "STAFF",
                    children: [
                      MenuItem(
                        icon: Icons.person_outline,
                        title: AppTranslationsDelegate.of(context).text("profiles"),
                        onTap: _menuController.navigateToProfiles,
                      ),
                    ],
                  ),

                  // SETTINGS Section
                  MenuSection(
                    title: "SETTINGS",
                    children: [
                      MenuItem(
                        icon: Icons.business_outlined,
                        title: AppTranslationsDelegate.of(context).text("business_information"),
                        onTap: _menuController.navigateToBusinessInformation,
                      ),
                      MenuItem(
                        icon: Icons.web_outlined,
                        title: AppTranslationsDelegate.of(context).text("client_web_app"),
                        onTap: _menuController.navigateToClientWebApp,
                      ),
                      MenuItem(
                        icon: Icons.payment_outlined,
                        title: AppTranslationsDelegate.of(context).text("billing_payment"),
                        onTap: _menuController.navigateToBillingPayment,
                      ),
                      MenuItem(
                        icon: Icons.lock_outline,
                        title: AppTranslationsDelegate.of(context).text("password_security"),
                        onTap: _menuController.navigateToPasswordSecurity,
                      ),
                      MenuItem(
                        icon: Icons.language_outlined,
                        title: AppTranslationsDelegate.of(context).text("app_language"),
                        onTap: _menuController.navigateToAppLanguage,
                      ),
                      MenuItem(
                        icon: Icons.star_outline,
                        title: AppTranslationsDelegate.of(context).text("membership_status"),
                        onTap: _menuController.navigateToMembershipStatus,
                      ),
                      MenuItem(
                        icon: Icons.notifications_outlined,
                        title: AppTranslationsDelegate.of(context).text("notifications"),
                        onTap: _menuController.navigateToNotifications,
                      ),
                      MenuItem(
                        icon: Icons.visibility_outlined,
                        title: AppTranslationsDelegate.of(context).text("account_visibility"),
                        onTap: _menuController.navigateToAccountVisibility,
                      ),
                      MenuItem(
                        icon: Icons.description_outlined,
                        title: AppTranslationsDelegate.of(context).text("terms_conditions"),
                        onTap: _menuController.navigateToTermsConditions,
                      ),
                    ],
                  ),

                  // Log out button
                   Row(
                        children: [
                          SizedBox(
                            height: 36,
                            child: OutlinedButton(
                              onPressed: () async {
                                await TokenService().clearToken();
                                await ActiveBusinessService().clearActiveBusiness();
                                NavigationService.go("/login");
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                AppTranslationsDelegate.of(context).text("log_out"),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
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
