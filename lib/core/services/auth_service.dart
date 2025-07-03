import 'dart:convert';
import 'package:bookit_mobile_app/app/config.dart';
import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:bookit_mobile_app/core/models/user_model.dart';
import 'package:bookit_mobile_app/core/services/onboarding_service.dart';
import 'package:http/http.dart' as http;

import 'token_service.dart';

class AuthService {
  final _baseUrl = '${AppConfig.apiBaseUrl}/auth';

  final TokenService _tokenService = TokenService();

  ///  Signup
  Future<String?> signup({
    required name,
    required String email,
    required String password,
    String? OTP,
  }) async {
    final url = Uri.parse('$_baseUrl/business-register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("user signup up data saved");
    } else {
      final message = jsonDecode(response.body)['message'] ?? 'Signup failed.';
      // print("Error: $message");
      throw Exception(message);
    }
  }

  //verify OTP
  Future<Map<String, dynamic>> verifyOTP({required email, required otp}) async {
    final url = Uri.parse('$_baseUrl/verify-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']?['token']; // Extract from nested "data"

      if (token != null) {
        await _tokenService.saveToken(token);

        return data;
      } else {
        return {};
      }
    } else {
      final message = jsonDecode(response.body)['message'] ?? 'Signup failed.';
      print("Error: $message");
      throw Exception(message);
    }
  }

  //resend otp
  Future<void> resendOtp(String email) async {
    final url = Uri.parse('$_baseUrl/resend-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await _tokenService.saveToken(token); // store token locally
      }
    } else {
      final message = jsonDecode(response.body)['message'] ?? 'Login failed.';
      throw Exception(message);
    }
  }

  ///  Login: Stores token and returns success
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      final message = jsonDecode(response.body)['message'] ?? 'Login failed.';
      throw Exception(message);
    }
  }

  /// Logout: Clears local token
  Future<void> logout() async {
    await _tokenService.clearToken();
    // Optionally: Clear onboarding step too
    // await OnboardingService().clearStep();
  }
}

// Todo: replace the routes with fethcing the user details including the business. or do something else
class UserService {
  final _baseUrl = '${AppConfig.apiBaseUrl}';

  Future<BusinessModel> fetchBusinessDetails({
    required String businessId,
  }) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token found');
    print(token);

    final url = Uri.parse('$_baseUrl/business/onboarding/$businessId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'];
      return BusinessModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch business details');
    }
  }

  //fetch user details
  Future<UserModel> fetchUserDetails() async {
    final token = await TokenService().getToken();

    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$_baseUrl/auth/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print(response.body);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final userData = json;
      return UserModel.fromJson(userData);
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to fetch user details';
      throw Exception(message);
    }
  }
}
