import 'dart:convert';
import 'package:bookit_mobile_app/core/services/shared_prefs_storage.dart';

class CacheService {
  static const String _businessTypeKey = 'cached_business_type';
  static const String _staffDataKey = 'cached_staff_data';
  static const String _businessTypeCacheTimeKey = 'business_type_cache_time';
  static const String _staffCacheTimeKey = 'staff_cache_time';
  
  final SharedPrefsStorage _storage = SharedPrefsStorage();

  // Business Type Caching
  Future<void> cacheBusinessType(Map<String, dynamic> businessData) async {
    final jsonString = jsonEncode(businessData);
    await _storage.write(_businessTypeKey, jsonString);
    await _storage.write(_businessTypeCacheTimeKey, DateTime.now().millisecondsSinceEpoch.toString());
  }

  Future<Map<String, dynamic>?> getCachedBusinessType() async {
    final jsonString = await _storage.read(_businessTypeKey);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  Future<bool> isBusinessTypeCacheValid({Duration maxAge = const Duration(hours: 24)}) async {
    final cacheTimeString = await _storage.read(_businessTypeCacheTimeKey);
    if (cacheTimeString == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(int.parse(cacheTimeString));
    return DateTime.now().difference(cacheTime) < maxAge;
  }

  // Staff Data Caching
  Future<void> cacheStaffData(List<Map<String, dynamic>> staffData) async {
    final jsonString = jsonEncode(staffData);
    await _storage.write(_staffDataKey, jsonString);
    await _storage.write(_staffCacheTimeKey, DateTime.now().millisecondsSinceEpoch.toString());
  }

  Future<List<Map<String, dynamic>>?> getCachedStaffData() async {
    final jsonString = await _storage.read(_staffDataKey);
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<bool> isStaffCacheValid({Duration maxAge = const Duration(minutes: 30)}) async {
    final cacheTimeString = await _storage.read(_staffCacheTimeKey);
    if (cacheTimeString == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(int.parse(cacheTimeString));
    return DateTime.now().difference(cacheTime) < maxAge;
  }

  // Clear cache methods
  Future<void> clearBusinessTypeCache() async {
    await _storage.delete(_businessTypeKey);
    await _storage.delete(_businessTypeCacheTimeKey);
  }

  Future<void> clearStaffCache() async {
    await _storage.delete(_staffDataKey);
    await _storage.delete(_staffCacheTimeKey);
  }

  Future<void> clearAllCache() async {
    await clearBusinessTypeCache();
    await clearStaffCache();
  }
}