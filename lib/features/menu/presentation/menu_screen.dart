import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/core/services/cache_service.dart';
import 'package:bookit_mobile_app/core/services/navigation_service.dart';
import 'package:bookit_mobile_app/core/providers/business_categories_provider.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_item.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_section.dart';
import 'package:bookit_mobile_app/features/menu/controllers/menu_controller.dart' as menu_ctrl;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  late final menu_ctrl.MenuController _menuController;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _menuController = menu_ctrl.MenuController();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appVersion = 'v1.0.0+3';
      });
    }
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
                padding: EdgeInsets.fromLTRB(
                  AppConstants.authHorizontalPadding,
                  AppConstants.scaffoldTopSpacing,
                  AppConstants.authHorizontalPadding,
                  10
                ),
                children: [
                  SizedBox(height: AppConstants.scaffoldTopSpacing),
                  Text(
                    AppTranslationsDelegate.of(context).text("menu_title"),
                    style: AppTypography.headingLg,
                  ),
                  SizedBox(height: AppConstants.headerToContentSpacing),
                  
                  // STAFF Section
                  MenuSection(
                    title: "Staff",
                    children: [
                      MenuItem(
                        iconAsset: 'assets/icons/menu/staff.svg',
                        title: AppTranslationsDelegate.of(context).text("profiles"),
                        onTap: _menuController.navigateToProfiles,
                      ),
                    ],
                  ),

                  // SETTINGS Section
                  MenuSection(
                    title: "Settings",
                    children: [
                      MenuItem(
                        iconAsset: 'assets/icons/menu/briefcase.svg',
                        title: AppTranslationsDelegate.of(context).text("business_information"),
                        onTap: _menuController.navigateToBusinessInformation,
                      ),
                      MenuItem(
                        iconAsset: 'assets/icons/menu/link.svg',
                        title: AppTranslationsDelegate.of(context).text("client_web_app"),
                        onTap: _menuController.navigateToClientWebApp,
                      ),
                      MenuItem(
                        iconAsset: 'assets/icons/menu/billing.svg',
                        title: AppTranslationsDelegate.of(context).text("billing_payment"),
                        onTap: _menuController.navigateToBillingPayment,
                      ),
                      MenuItem(
                        iconAsset: 'assets/icons/menu/lock.svg',
                        title: AppTranslationsDelegate.of(context).text("password_security"),
                        onTap: _menuController.navigateToPasswordSecurity,
                      ),
                      MenuItem(
                        iconAsset: 'assets/icons/menu/star.svg',
                        title: AppTranslationsDelegate.of(context).text("membership_status"),
                        onTap: _menuController.navigateToMembershipStatus,
                      ),
                      MenuItem(
                        iconAsset: 'assets/icons/menu/language.svg',
                        title: AppTranslationsDelegate.of(context).text("app_language"),
                        onTap: _menuController.navigateToAppLanguage,
                      ),
                      MenuItem(
                        iconAsset: 'assets/icons/menu/icons.svg',
                        title: AppTranslationsDelegate.of(context).text("notifications"),
                        onTap: _menuController.navigateToNotifications,
                      ),
                      MenuItem(
                        iconAsset: 'assets/icons/menu/eye.svg',
                        title: AppTranslationsDelegate.of(context).text("account_visibility"),
                        onTap: _menuController.navigateToAccountVisibility,
                      ),
                      MenuItem(
                        iconAsset: 'assets/icons/menu/edit.svg',
                        title: AppTranslationsDelegate.of(context).text("terms_conditions"),
                        onTap: _menuController.navigateToTermsConditions,
                      ),
                    ],
                  ),

                  // App Version (debug only)
                  if (_appVersion.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.contentSpacing),
                      child: Center(
                        child: Text(
                          _appVersion,
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),

                  // Log out button
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          print("🔒 Logging out - clearing all data");
                          
                          // Clear token and active business
                          await TokenService().clearToken();
                          await ActiveBusinessService().clearActiveBusiness();
                          
                          // Clear all cache data
                          final cacheService = CacheService();
                          await cacheService.clearAllCache();
                          print("🗑️ Cache cleared on logout");
                          
                          // Clear business categories provider
                          BusinessCategoriesProvider.instance.clear();
                          print("🗑️ Business categories provider cleared");
                          
                          // Clear Riverpod business provider
                          ref.read(businessProvider.notifier).state = null;
                          print("🗑️ Business provider cleared");
                          
                          NavigationService.go("/login");
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          side: BorderSide(
                            color: const Color(0xFF790077),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          AppTranslationsDelegate.of(context).text("log_out"),
                          style: AppTypography.button.copyWith(
                            color: const Color(0xFF790077),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppConstants.headerToContentSpacingMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
