import 'package:bookit_mobile_app/app/config.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:dio/dio.dart';
import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/dio_client.dart';


// OnboardingApiService handles all API calls related to business onboarding, including submitting business info, locations, categories, and services.
class OnboardingApiService {

  // final Dio _dio = Dio(BaseOptions(
  //   baseUrl: '${AppConfig.apiBaseUrl}/business/onboarding',
  //   headers: {'Content-Type': 'application/json'},
  // ));

  // final Dio _dio = DioClient.instance;

  final Dio _dio = DioClient.withBaseUrl('${AppConfig.apiBaseUrl}/business/onboarding');


  final String categoryUrl = '${AppConfig.apiBaseUrl}/categories';



  //......................Business Info Screen................................
  /// Submits business information during the onboarding process.
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

    try {
      final response = await _dio.post(
        '',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data['data'];
      return BusinessModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to submit business data');
    }
  }

  //.......................Get Business Details................................
  /// Fetches business details by ID.
  Future<BusinessModel> getBusinessDetails({String? businessId}) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    try {
      final response = await _dio.get(
        '/$businessId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data['data'];
      return BusinessModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch business data');
    }
  }

  //.........................Submit Location Info................................
  /// Submits location information for the business.
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
    try {
      await _dio.post(
        '',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to submit location data');
    }
  }

  //.............................Get Categories.................................
  Future<List<CategoryModel>> getCategories({String? categoryLevel}) async {
    final query = categoryLevel != null ? '?level=$categoryLevel' : '';
    try {
      final response = await Dio().get(
        '$categoryUrl$query',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final categoriesJson = response.data['data']['categories'] as List;
      return categoriesJson.map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load categories');
    }
  }


  //..............................Submit Categories.................................
  Future<void> updateCategory({
    String? id,
    required String businessId,
    required String categoryId,
  }) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    final payload = {
      "step": "categories",
      "data": {
        "id": id,
        "business_id": businessId,
        "category_id": categoryId,
      },
    };

    try {
      await _dio.post(
        '',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update category',
      );
    }
  }

  //..............................Create Services.................................
  Future<void> createServices({
    required List<Map<String, dynamic>> services,
  }) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');
    final payload = {
      "step": "services",
      "data": {"services": services},
    };
    try {
      await _dio.post(
        '',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to submit services',
      );
    }
  }

  //................................Update Service..................................
  /// Updates service details during the onboarding process.
  /// [allDetails] should contain a list of maps with service details.
  Future<void> updateService({
    required List<Map<String, dynamic>> allDetails,
  }) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    final payload = {
      "step": "service_details",
      "data": {"details": allDetails},
    };

    try {
      await _dio.post(
        '',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update service details',
      );
    }
  }
}