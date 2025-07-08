import 'package:dio/dio.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenService tokenService;

  AuthInterceptor({
    required this.dio,
    required this.tokenService,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != '/auth/refresh-token') {
      final refreshToken = await tokenService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await dio.post(
            '/auth/refresh-token',
            data: {'refresh_token': refreshToken},
          );
          if (response.statusCode == 200) {
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token']; 

            await tokenService.saveToken(newAccessToken);
            await tokenService.saveRefreshToken(newRefreshToken);

            final retryRequest = err.requestOptions;
            retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(retryRequest);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await tokenService.clearToken();
        }
      }
    }

    handler.next(err);
  }
}
