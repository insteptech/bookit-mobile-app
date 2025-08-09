/// Represents service duration and pricing information
class ServiceDuration {
  final int durationMinutes;
  final int price;
  final int? packageAmount;
  final int? packagePerson;

  ServiceDuration({
    required this.durationMinutes,
    required this.price,
    this.packageAmount,
    this.packagePerson,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'duration_minutes': durationMinutes,
      'price': price,
    };
    if (packageAmount != null) map['package_amount'] = packageAmount!;
    if (packagePerson != null) map['package_person'] = packagePerson!;
    return map;
  }
}

/// Represents service form data
class ServiceData {
  final String serviceId;
  final String name;
  final String description;
  final List<ServiceDuration> durations;
  final int? spotsAvailable;

  ServiceData({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.durations,
    this.spotsAvailable,
  });

  Map<String, dynamic> toJson(String businessId) {
    return {
      'business_id': businessId,
      'service_id': serviceId,
      'name': name,
      'description': description,
      'durations': durations.map((d) => d.toJson()).toList(),
      'spots_available': spotsAvailable,
    };
  }
}

/// Factory for creating service data from form inputs
class ServiceDataFactory {
  static ServiceData? fromFormData({
    required String serviceId,
    required String name,
    required String description,
    required List<Map<String, dynamic>> durationAndCosts,
    bool spotsAvailable = false,
    String? spotsText,
  }) {
    // Validation
    if (name.trim().isEmpty) return null;

    // Parse durations
    final durations = durationAndCosts
        .where((item) {
          return item['duration'].toString().isNotEmpty &&
              item['cost'].toString().isNotEmpty;
        })
        .map((item) {
          return ServiceDuration(
            durationMinutes: int.tryParse(item['duration'] ?? '0') ?? 0,
            price: int.tryParse(item['cost'] ?? '0') ?? 0,
            packageAmount: (item['packageAmount'] ?? '').isNotEmpty 
                ? int.tryParse(item['packageAmount']) 
                : null,
            packagePerson: (item['packagePerson'] ?? '').isNotEmpty 
                ? int.tryParse(item['packagePerson']) 
                : null,
          );
        })
        .toList();

    if (durations.isEmpty) return null;

    return ServiceData(
      serviceId: serviceId,
      name: name.trim(),
      description: description.trim(),
      durations: durations,
      spotsAvailable: spotsAvailable ? (int.tryParse(spotsText ?? '')) : null,
    );
  }
}
