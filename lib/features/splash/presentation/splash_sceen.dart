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
    print("🔒 Logging out - clearing tokens and cache");
    await TokenService().clearToken();
    final cacheService = CacheService();
    await cacheService.clearAllCache();
    print("🗑️ All cache cleared on logout");
    NavigationService.go("/login");
  }

  Future<void> _checkAndRedirect() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');

    if (!mounted) return;

    if (token == null) {
      print("🔐 No token found - redirecting to login");
      NavigationService.go('/login');
      return;
    }

    try {
      final cacheService = CacheService();
      
      // Try to get user data from cache first
      print("🔍 Checking user data cache...");
      UserModel? cachedUser;
      if (await cacheService.isUserDataCacheValid()) {
        print("✅ User cache is valid - reading from cache");
        final userData = await cacheService.getCachedUserData();
        if (userData != null) {
          cachedUser = UserModel.fromJson(userData);
          print("📱 User data loaded from cache: ${cachedUser.email}");
        }
      } else {
        print("❌ User cache is invalid or expired");
      }

      // If we have cached user data, proceed with business data check
      if (cachedUser != null && cachedUser.businessIds.isNotEmpty) {
        final businessId = cachedUser.businessIds[0];
        
        // Check if business data is cached
        print("🔍 Checking business data cache for ID: $businessId");
        if (await cacheService.isBusinessDataCacheValid(businessId)) {
          print("✅ Business cache is valid - reading from cache");
          final cachedBusinessData = await cacheService.getCachedBusinessData(businessId);
          if (cachedBusinessData != null) {
            final businessModel = BusinessModel.fromJson(cachedBusinessData);
            print("🏢 Business data loaded from cache: ${businessModel.name}");
            
            // Your strategy: If onboarding is complete, trust cache and navigate
            if (businessModel.isOnboardingComplete) {
              print("🎯 Onboarding complete - using cached data to navigate to dashboard");
              ref.read(businessProvider.notifier).state = businessModel;
              await ActiveBusinessService().saveActiveBusiness(businessId);
              NavigationService.go("/home_screen");
              
              // Background refresh for next time
              print("🔄 Starting background refresh for next launch");
              _refreshDataInBackground();
              return;
            } else {
              print("⚠️ Onboarding not complete - fetching fresh business data");
              await _fetchFreshDataAndNavigate(businessId);
              return;
            }
          }
        } else {
          print("❌ Business cache is invalid or expired");
        }
      } else {
        print("❌ No cached user data or no business IDs");
      }

      // Fallback: No cache or invalid cache - fetch fresh data
      print("🌐 No valid cache available - fetching fresh data from API");
      await _fetchFreshDataAndNavigate();
      
    } catch (e) {
      print("❌ Cache check error: ${e.toString()} - redirecting to login");
      NavigationService.go('/login');
    }
  }

  Future<void> _fetchFreshDataAndNavigate([String? knownBusinessId]) async {
    try {
      final userService = UserService();
      final cacheService = CacheService();
      
      UserModel user;
      if (knownBusinessId != null) {
        print("🔄 Business ID known ($knownBusinessId) - checking if user cache can be reused");
        // We already know the business ID, get user from cache or fetch
        if (await cacheService.isUserDataCacheValid()) {
          print("✅ Reusing valid user cache");
          final userData = await cacheService.getCachedUserData();
          user = UserModel.fromJson(userData!);
        } else {
          print("🌐 User cache invalid - fetching fresh user data from API");
          user = await userService.fetchUserDetails();
          print("💾 User data fetched and cached automatically");
        }
      } else {
        print("🌐 Fetching fresh user data from API");
        user = await userService.fetchUserDetails();
        print("💾 User data fetched and cached automatically");
      }

      if (user.businessIds.isNotEmpty) {
        final businessId = knownBusinessId ?? user.businessIds[0];
        print("🌐 Fetching fresh business data from API for ID: $businessId");
        final businessData = await userService.fetchBusinessDetails(businessId: businessId);
        print("💾 Business data fetched and cached automatically");
        
        ref.read(businessProvider.notifier).state = businessData;

        if (businessData.isOnboardingComplete) {
          print("🎯 Fresh data shows onboarding complete - navigating to dashboard");
          await ActiveBusinessService().saveActiveBusiness(businessId);
          NavigationService.go("/home_screen");
        } else {
          print("⚠️ Fresh data shows onboarding incomplete - navigating to onboarding");
          NavigationService.go('/onboarding_welcome');
        }
      } else {
        print("⚠️ User has no business IDs - navigating to onboarding");
        NavigationService.go('/onboarding_welcome');
      }
    } catch (e) {
      print("❌ API fetch error: ${e.toString()} - redirecting to login");
      NavigationService.go('/login');
    }
  }

  Future<void> _refreshDataInBackground() async {
    try {
      print("🔄 Background refresh: Updating cache for next app launch");
      final userService = UserService();
      
      print("🌐 Background refresh: Fetching fresh user data");
      final user = await userService.fetchUserDetails();
      print("💾 Background refresh: User data cached");
      
      if (user.businessIds.isNotEmpty) {
        print("🌐 Background refresh: Fetching fresh business data");
        await userService.fetchBusinessDetails(businessId: user.businessIds[0]);
        print("💾 Background refresh: Business data cached");
        print("✅ Background refresh completed successfully");
      }
    } catch (e) {
      print("❌ Background refresh failed: ${e.toString()}");
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
