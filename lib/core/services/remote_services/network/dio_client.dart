import 'package:dio/dio.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'auth_interceptor.dart';
import 'package:bookit_mobile_app/app/config.dart';

class DioClient {
  static Dio? _defaultDio;
  static Dio? _refreshDio; // Separate Dio instance for refresh calls

  /// Returns the default Dio instance with baseUrl = AppConfig.apiBaseUrl
  static Dio get instance {
    _defaultDio ??= _createDio(AppConfig.apiBaseUrl);
    return _defaultDio!;
  }

  /// Returns a Dio instance for refresh token calls (without auth interceptor)
  static Dio get refreshInstance {
    _refreshDio ??= Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      headers: {'Content-Type': 'application/json'},
    ));
    return _refreshDio!;
  }

  /// Returns a new Dio instance with a custom baseUrl, interceptor attached
  static Dio withBaseUrl(String baseUrl) {
    return _createDio(baseUrl);
  }

  /// Internal method to create Dio with interceptor
  static Dio _createDio(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(AuthInterceptor(
      dio: refreshInstance, // Use refresh instance to avoid circular dependency
      tokenService: TokenService(),
    ));

    return dio;
  }
}
