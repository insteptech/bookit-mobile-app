import 'dart:convert';

class DataComparisonUtils {
  static bool hasDataChanged(dynamic cachedData, dynamic freshData) {
    if (cachedData == null && freshData == null) return false;
    if (cachedData == null || freshData == null) return true;
    
    final cachedJson = jsonEncode(cachedData);
    final freshJson = jsonEncode(freshData);
    
    return cachedJson != freshJson;
  }

  static bool isListSame<T>(List<T>? list1, List<T>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    
    return jsonEncode(list1) == jsonEncode(list2);
  }

  static bool isCacheStale(DateTime timestamp, {Duration maxAge = const Duration(minutes: 5)}) {
    return DateTime.now().difference(timestamp) > maxAge;
  }
}

class CachedData<T> {
  final T data;
  final DateTime timestamp;

  CachedData({
    required this.data,
    required this.timestamp,
  });

  factory CachedData.create(T data) {
    return CachedData(
      data: data,
      timestamp: DateTime.now(),
    );
  }

  bool get isStale => DataComparisonUtils.isCacheStale(timestamp);
  
  bool hasChanged(T newData) {
    return DataComparisonUtils.hasDataChanged(data, newData);
  }

  CachedData<T> copyWith({T? data}) {
    return CachedData.create(data ?? this.data);
  }
}