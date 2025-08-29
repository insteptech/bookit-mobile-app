import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/core/services/navigation_service.dart';
import 'package:bookit_mobile_app/core/services/cache_service.dart';
import 'package:bookit_mobile_app/core/models/user_model.dart';
import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/shared_pref_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRedirect();
  }

  void logout()async{
    await TokenService().clearToken();
    final cacheService = CacheService();
    await cacheService.clearAllCache();
    NavigationService.go("/login");
  }

  Future<void> _checkAndRedirect() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');

    if (!mounted) return;

    if (token == null) {
      NavigationService.go('/login');
      return;
    }

    try {
      final cacheService = CacheService();
      
      // Try to get user data from cache first
      UserModel? cachedUser;
      if (await cacheService.isUserDataCacheValid()) {
        final userData = await cacheService.getCachedUserData();
        if (userData != null) {
          cachedUser = UserModel.fromJson(userData);
        }
      }

      // If we have cached user data, proceed with business data check
      if (cachedUser != null && cachedUser.businessIds.isNotEmpty) {
        final businessId = cachedUser.businessIds[0];
        
        // Check if business data is cached
        if (await cacheService.isBusinessDataCacheValid(businessId)) {
          final cachedBusinessData = await cacheService.getCachedBusinessData(businessId);
          if (cachedBusinessData != null) {
            final businessModel = BusinessModel.fromJson(cachedBusinessData);
            
            // Your strategy: If onboarding is complete, trust cache and navigate
            if (businessModel.isOnboardingComplete) {
              ref.read(businessProvider.notifier).state = businessModel;
              await ActiveBusinessService().saveActiveBusiness(businessId);
              NavigationService.go("/home_screen");
              
              // Background refresh for next time
              _refreshDataInBackground();
              return;
            } else {
              // If onboarding not complete, fetch fresh data
              await _fetchFreshDataAndNavigate(businessId);
              return;
            }
          }
        }
      }

      // Fallback: No cache or invalid cache - fetch fresh data
      await _fetchFreshDataAndNavigate();
      
    } catch (e) {
      NavigationService.go('/login');
    }
  }

  Future<void> _fetchFreshDataAndNavigate([String? knownBusinessId]) async {
    try {
      final userService = UserService();
      final cacheService = CacheService();
      
      UserModel user;
      if (knownBusinessId != null) {
        // We already know the business ID, get user from cache or fetch
        if (await cacheService.isUserDataCacheValid()) {
          final userData = await cacheService.getCachedUserData();
          user = UserModel.fromJson(userData!);
        } else {
          user = await userService.fetchUserDetails();
        }
      } else {
        // Fetch fresh user data
        user = await userService.fetchUserDetails();
      }

      if (user.businessIds.isNotEmpty) {
        final businessId = knownBusinessId ?? user.businessIds[0];
        final businessData = await userService.fetchBusinessDetails(businessId: businessId);
        
        ref.read(businessProvider.notifier).state = businessData;

        if (businessData.isOnboardingComplete) {
          await ActiveBusinessService().saveActiveBusiness(businessId);
          NavigationService.go("/home_screen");
        } else {
          NavigationService.go('/onboarding_welcome');
        }
      } else {
        NavigationService.go('/onboarding_welcome');
      }
    } catch (e) {
      NavigationService.go('/login');
    }
  }

  Future<void> _refreshDataInBackground() async {
    try {
      final userService = UserService();
      
      final user = await userService.fetchUserDetails();
      
      if (user.businessIds.isNotEmpty) {
        await userService.fetchBusinessDetails(businessId: user.businessIds[0]);
      }
    } catch (e) {
      // Silent background refresh failure
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1.0, 0.0), // Center-left positioning
            radius: 1.5,
            colors: [
              Color(0xFF790077), // #790077 - Dark purple at center-left
              Color(0xFFBB27B8), // #BB27B8 - Medium purple 
              Color.fromARGB(255, 249, 139, 249), // #FFF3FF - Light pink at edges
            ],
            stops: [0.3, 0.8, 1.0],
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            width: 174.56,
            height: 57.53,
          ),
        ),
      ),
    );
  }
}
