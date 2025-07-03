import 'dart:convert';
import 'package:bookit_mobile_app/app/config.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';

class OnboardingApiService {
  final String baseUrl = '${AppConfig.apiBaseUrl}/business/onboarding';

  //About you screen
  Future<BusinessModel> submitBusinessInfo({
    required String name,
    required String email,
    required String phone,
    String? website,
    String? businessId,
  }) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    final payload = {
      "step": "about_you",
      "data": {
        "business_id": businessId,
        "name": name,
        "email": email,
        "phone": phone,
        "website": website,
        "active_step": "locations",
      },
    };

    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final businessData = json['data'];

      return BusinessModel.fromJson(businessData);
    } else {
      final errorJson = jsonDecode(response.body);
      final errorMessage =
          errorJson['message'] ?? 'Failed to submit business data';
      throw Exception(errorMessage);
    }
  }

  //get business info
  Future<BusinessModel> getBusinessDetails({String? businessId}) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    final response = await http.get(
      Uri.parse('$baseUrl/$businessId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final businessData = json['data'];
      return BusinessModel.fromJson(businessData);
    } else {
      final errorJson = jsonDecode(response.body);
      final errorMessage =
          errorJson['message'] ?? 'Failed to submit business data';
      throw Exception(errorMessage);
    }
  }

  //location screen
  Future<void> submitLocationInfo({
    required String businessId,
    required List<Map<String, dynamic>> locations,
  }) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    final payload = {
      "step": "locations",
      "data": {"business_id": businessId, "locations": locations},
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorJson = jsonDecode(response.body);
      final errorMessage =
          errorJson['message'] ?? 'Failed to submit location data';
      throw Exception(errorMessage);
    }
  }

  //offerings screen
  //get categories
  Future<List<CategoryModel>> getCategories({String? categoryLevel}) async {
    final String postfixUrl =
        (categoryLevel == null) ? "" : "?level=$categoryLevel";

    final response = await http.get(
      Uri.parse("${AppConfig.apiBaseUrl}/categories$postfixUrl"),
      headers: {'Content-Type': 'application/json'},
    );

    print("${AppConfig.apiBaseUrl}$postfixUrl");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final categoriesJson = jsonResponse['data']['categories'] as List;

      return categoriesJson
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  //update categories
  Future<void> updateCategory({
    String? id,
    required String businessId,
    required String categoryId,
  }) async {
    final Uri url = Uri.parse("${baseUrl}");

    final payload = {
      "step": "categories",
      "data": {"id":id,"business_id": businessId, "category_id": categoryId},
    };

    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("Category updated successfully");
      } else {
        print("Failed to update category: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in updateCategory(): $e");
    }
  }

  //update services
  Future<void> createServices({
    required List<Map<String, dynamic>> services,
  }) async {
    final Uri url = Uri.parse("${baseUrl}");
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    final payload = {
      "step": "services",
      "data": {"services": services},
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );


      if (response.statusCode == 200) {
        print("Services submitted successfully");
      } else {
        print("Failed to submit services: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in createServices(): $e");
    }
  }

  //update services
  Future<void> updateService({
    required List<Map<String, dynamic>> allDetails,
  }) async {
    final Uri url = Uri.parse("${baseUrl}");
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    final payload = {
      "step": "service_details",
      "data": {"details": allDetails},
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print("Data sent successfully");
    } else {
      print("Error: ${response.body}");
    }
  }
}
