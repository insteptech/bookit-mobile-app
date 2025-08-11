import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.businessServiceId,
    required super.name,
    required super.description,
    required super.isClass,
    required super.durations,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      businessServiceId: json['business_service_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isClass: json['is_class'] ?? false,
      durations: (json['durations'] as List? ?? [])
          .map((d) => ServiceDurationModel.fromJson(d))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_service_id': businessServiceId,
      'name': name,
      'description': description,
      'is_class': isClass,
      'durations': durations.map((d) => (d as ServiceDurationModel).toJson()).toList(),
    };
  }

  Service toEntity() => this;
}

class ServiceDurationModel extends ServiceDuration {
  const ServiceDurationModel({
    required super.id,
    required super.durationMinutes,
    required super.price,
  });

  factory ServiceDurationModel.fromJson(Map<String, dynamic> json) {
    return ServiceDurationModel(
      id: json['id']?.toString() ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration_minutes': durationMinutes,
      'price': price,
    };
  }

  ServiceDuration toEntity() => this;
}
