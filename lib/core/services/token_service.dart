import 'package:bookit_mobile_app/core/services/shared_prefs_storage.dart';

import 'storage_interface.dart';

const _tokenKey = 'auth_token';
const _refreshToken = 'refresh_token';

class TokenService {
  final StorageInterface _storage = SharedPrefsStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(_refreshToken, refreshToken);
  }

  Future<String?> getToken() async {
    return await _storage.read(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(_refreshToken);
  }

  Future<void> clearToken() async {
    await _storage.delete(_tokenKey);
    await _storage.delete(_refreshToken);
  }
}
