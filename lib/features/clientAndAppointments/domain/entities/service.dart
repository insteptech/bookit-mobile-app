class Service {
  final String id;
  final String businessServiceId;
  final String name;
  final String description;
  final bool isClass;
  final List<ServiceDuration> durations;

  const Service({
    required this.id,
    required this.businessServiceId,
    required this.name,
    required this.description,
    required this.isClass,
    required this.durations,
  });

  Service copyWith({
    String? id,
    String? businessServiceId,
    String? name,
    String? description,
    bool? isClass,
    List<ServiceDuration>? durations,
  }) {
    return Service(
      id: id ?? this.id,
      businessServiceId: businessServiceId ?? this.businessServiceId,
      name: name ?? this.name,
      description: description ?? this.description,
      isClass: isClass ?? this.isClass,
      durations: durations ?? this.durations,
    );
  }
}

class ServiceDuration {
  final String id;
  final int durationMinutes;
  final double price;

  const ServiceDuration({
    required this.id,
    required this.durationMinutes,
    required this.price,
  });

  ServiceDuration copyWith({
    String? id,
    int? durationMinutes,
    double? price,
  }) {
    return ServiceDuration(
      id: id ?? this.id,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
    );
  }
}
