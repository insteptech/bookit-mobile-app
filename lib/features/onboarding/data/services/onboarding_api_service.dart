import 'package:bookit_mobile_app/app/config.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:dio/dio.dart';
import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/dio_client.dart';
import 'package:bookit_mobile_app/features/onboarding/data/models/models.dart';

/// OnboardingApiService handles pure HTTP communication for onboarding APIs.
/// It receives pre-built payloads and handles only network concerns.
class OnboardingApiService {
  final Dio _dio = DioClient.withBaseUrl('${AppConfig.apiBaseUrl}/business/onboarding');
  final String categoryUrl = '${AppConfig.apiBaseUrl}/categories';

  /// Submits onboarding step data with pre-built payload.
  /// Returns the business data from the API response.
  Future<BusinessModel> submitOnboardingStep({
    required Map<String, dynamic> payload,
  }) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    try {
      final response = await _dio.post(
        '',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      // Parse response using data models
      final businessApiResponse = BusinessApiResponse.fromJson(response.data['data']);
      return OnboardingDataMappers.mapBusinessResponse(businessApiResponse);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to submit onboarding data');
    }
  }

  /// Submits onboarding step data without expecting business model response.
  Future<void> submitOnboardingStepVoid({
    required Map<String, dynamic> payload,
  }) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No auth token found');

    try {
      await _dio.post(
        '',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to submit onboarding data');
    }
  }

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

  /// Fetches categories with optional level filtering.
  Future<List<CategoryModel>> getCategories({String? categoryLevel}) async {
    final query = categoryLevel != null ? '?level=$categoryLevel' : '';
    try {
      final response = await Dio().get(
        '$categoryUrl$query',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      
      // Parse response using data models
      final categoriesResponse = CategoriesListApiResponse.fromJson(response.data['data']);
      return OnboardingDataMappers.mapCategoriesListResponse(categoriesResponse);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load categories');
    }
  }
}
