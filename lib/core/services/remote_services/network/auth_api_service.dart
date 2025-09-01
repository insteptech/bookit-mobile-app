import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:bookit_mobile_app/core/models/user_model.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/services/cache_service.dart';
import 'package:bookit_mobile_app/core/providers/business_categories_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/endpoint.dart';
import 'package:dio/dio.dart';
import '../../token_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/dio_client.dart';


// AuthService handles user authentication, including signup, login, OTP verification, and token management.
class AuthService {
  // static final Dio _dio = Dio(
  //   BaseOptions(
  //     baseUrl: AppConfig.apiBaseUrl,
  //     headers: {'Content-Type': 'application/json'},
  //   ),
  // );
  final Dio _dio = DioClient.instance;

  final TokenService _tokenService = TokenService();

  //...........................signup............................
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    String? OTP,
  }) async {
    try {
      await _dio.post(
        businessSignupEndpoint,
        data: {'full_name': name, 'email': email, 'password': password},
      );
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Signup failed.');
    }
  }

  //...........................verify OTP............................
  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        verifyOtpEndpoint,
        data: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['data']?['token'];
        final refreshToken = data['data']?['refresh_token'];

        if (token != null) {
          await _tokenService.saveToken(token);
          if (refreshToken != null) {
            await _tokenService.saveRefreshToken(refreshToken);
          }
          return data;
        } else {
          return {};
        }
      } else {
        throw Exception(response.data['message'] ?? 'OTP verification failed.');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'OTP verification failed.',
      );
    }
  }

  //.............................resend OTP.................................
  Future<void> resendOtp(String email) async {
    try {
      final response = await _dio.post(
        resendOtpEndpoint,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final refreshToken = response.data['refresh_token'];
        if (token != null) {
          await _tokenService.saveToken(token);
          if (refreshToken != null) {
            await _tokenService.saveRefreshToken(refreshToken);
          }
        }
      } else {
        throw Exception(response.data['message'] ?? 'Resend OTP failed.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Resend OTP failed.');
    }
  }

  //...............................login.................................
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Login failed.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed.');
    }
  }

  /// Logout
  Future<void> logout() async {
    // Clear token
    await _tokenService.clearToken();
    
    // Clear all cache data
    final cacheService = CacheService();
    await cacheService.clearAllCache();
    
    // Clear business categories provider
    BusinessCategoriesProvider.instance.clear();
  }

  //...........................initiate password reset............................
  Future<void> initiatePasswordReset({required String email}) async {
    try {
      final response = await _dio.post(
        initiatePasswordResetEndpoint,
        data: {'email': email},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Failed to initiate password reset.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to initiate password reset.');
    }
  }

  //...........................verify reset OTP............................
  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        verifyResetOtpEndpoint,
        data: {'email': email, 'otp': otp},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'OTP verification failed.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'OTP verification failed.');
    }
  }

  //...........................reset password............................
  Future<void> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        resetPasswordEndpoint,
        data: {
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Password reset failed.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Password reset failed.');
    }
  }
}


// UserService handles user-related operations such as fetching user details and business details.
class UserService {
  // final _dio = Dio(
  //   BaseOptions(
  //     baseUrl: AppConfig.apiBaseUrl,
  //     headers: {'Content-Type': 'application/json'},
  //   ),
  // );
  final Dio _dio = DioClient.instance;

  //............................fetch business details............................
  Future<BusinessModel> fetchBusinessDetails({
    required String businessId,
  }) async {
    print("🌐 UserService: Fetching business details from API for ID: $businessId");
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token found');
    
    try {
      final response = await _dio.get(
        businessDetailsEndpoint(businessId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        
        // Cache the business data
        print("💾 UserService: Saving business data to cache");
        final cacheService = CacheService();
        await cacheService.cacheBusinessData(businessId, data);
        print("✅ UserService: Business data cached successfully");
        
        return BusinessModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch business details');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch business details',
      );
    }
  }

  //............................fetch user details............................

//change made here

// Future<UserModel> fetchUserDetails() async {
//   try {
//     final response = await _dio.get(profileEndpoint);

//     if (response.statusCode == 200) {
//       final user = UserModel.fromJson(response.data);
//       await AuthStorageService().saveUserDetails(user);
//       return user;
//     } else {
//       throw Exception(
//         response.data['message'] ?? 'Failed to fetch user details',
//       );
//     }
//   } on DioException catch (e) {
//     throw Exception(
//       e.response?.data['message'] ?? 'Failed to fetch user details',
//     );
//   }
// }

Future<UserModel> fetchUserDetails() async {
    print("🌐 UserService: Fetching user details from API");
    final token = await TokenService().getToken();
    if (token == null) throw Exception('User not logged in');

    try {
      final response = await _dio.get(
        profileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        
        // Save to both AuthStorageService and CacheService
        await AuthStorageService().saveUserDetails(user);
        
        // Cache user data
        print("💾 UserService: Saving user data to cache");
        final cacheService = CacheService();
        await cacheService.cacheUserData(response.data);
        print("✅ UserService: User data cached successfully");
        
        return user;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch user details',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch user details',
      );
    }
  }
}
