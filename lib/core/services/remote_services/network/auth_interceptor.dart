import 'package:dio/dio.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/endpoint.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/services/navigation_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenService tokenService;
  bool _isRefreshing = false;

  AuthInterceptor({
    required this.dio,
    required this.tokenService,
  });

  // Helper method to handle logout and clear all auth data
  Future<void> _handleAuthFailure() async {
    print("Auth failure - clearing all tokens and user data");
    await tokenService.clearToken();
    await AuthStorageService().clearUserDetails();
    
    // Navigate to login screen
    print("Navigating to login screen due to auth failure");
    NavigationService.navigateToLogin();
  }

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
    // Only handle 401 errors and avoid refresh token endpoint
    print("Entered in onError");
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/refresh-token') &&
        !_isRefreshing) {
      print("ENtered in onError if condition");
      _isRefreshing = true;
      
      try {
        final refreshToken = await tokenService.getRefreshToken();
        print("REfresh token: $refreshToken");
        if (refreshToken != null) {
          final response = await dio.post(
            refreshTokenEndpoint,
            data: {'refresh_token': refreshToken},
          );
        print("REfresh response: ${response.data}");

          
          if (response.statusCode == 200) {
            final responseData = response.data['data'];
            if (responseData == null) {
              print("Error: No data field in refresh response");
              _isRefreshing = false;
              await _handleAuthFailure();
              handler.next(err);
              return;
            }
            
            final newAccessToken = responseData['access_token'];
            final newRefreshToken = responseData['refresh_token']; 

            if (newAccessToken == null) {
              print("Error: No access_token in refresh response");
              _isRefreshing = false;
              await _handleAuthFailure();
              handler.next(err);
              return;
            }

            print("New access token: $newAccessToken");
            print("New refresh token: $newRefreshToken");

            await tokenService.saveToken(newAccessToken);
            if (newRefreshToken != null) {
              await tokenService.saveRefreshToken(newRefreshToken);
            }

            // Retry the original request with new token
            final retryRequest = RequestOptions(
              path: err.requestOptions.path,
              method: err.requestOptions.method,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
              headers: {
                ...err.requestOptions.headers,
                'Authorization': 'Bearer $newAccessToken',
              },
              extra: err.requestOptions.extra,
              responseType: err.requestOptions.responseType,
            );

            _isRefreshing = false;
            
            try {
              print("Retrying request with new token to: ${retryRequest.path}");
              // Use a fresh dio instance without interceptors to avoid recursion
              final freshDio = Dio(BaseOptions(
                baseUrl: dio.options.baseUrl,
                headers: {'Content-Type': 'application/json'},
              ));
              final retryResponse = await freshDio.fetch(retryRequest);
              print("Retry successful!");
              return handler.resolve(retryResponse);
            } catch (retryError) {
              print("Retry failed: ${retryError.toString()}");
              _isRefreshing = false;
              handler.next(err);
            }
          } else {
            print("Refresh token failed with status: ${response.statusCode}");
            _isRefreshing = false;
            await _handleAuthFailure();
            handler.next(err);
          }
        } else {
          print("No refresh token available");
          _isRefreshing = false;
          await _handleAuthFailure();
          handler.next(err);
        }
      } catch (refreshError) {
        print("Refresh error: ${refreshError.toString()}");
        _isRefreshing = false;
        await _handleAuthFailure();
        handler.next(err);
      }
    } else {
      print("Non-401 error or already refreshing");
      handler.next(err);
    }
  }
}
