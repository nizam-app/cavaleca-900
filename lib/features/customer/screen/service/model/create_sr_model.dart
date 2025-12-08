import 'dart:convert';

/// -------- Category / Service / Subservice --------

class FsmCategory {
  final int id;
  final String name;
  final String? description;
  final List<FsmService> services;

  FsmCategory({
    required this.id,
    required this.name,
    this.description,
    required this.services,
  });

  factory FsmCategory.fromJson(Map<String, dynamic> json) {
    return FsmCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => FsmService.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FsmService {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final List<FsmSubservice> subservices;

  FsmService({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.subservices,
  });

  factory FsmService.fromJson(Map<String, dynamic> json) {
    return FsmService(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      subservices: (json['subservices'] as List<dynamic>? ?? [])
          .map((e) => FsmSubservice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FsmSubservice {
  final int id;
  final int serviceId;
  final String name;
  final String? description;
  final num? baseRate;

  FsmSubservice({
    required this.id,
    required this.serviceId,
    required this.name,
    this.description,
    this.baseRate,
  });

  factory FsmSubservice.fromJson(Map<String, dynamic> json) {
    return FsmSubservice(
      id: json['id'] as int,
      serviceId: json['serviceId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      baseRate: json['baseRate'] as num?,
    );
  }
}

/// -------- Service Request Payload --------

class ServiceRequestPayload {
  final String name;
  final String phone;
  final String address;
  final int categoryId;
  final int serviceId;
  final int? subserviceId;
  final String? description;
  final String paymentType; // "CASH" / "MOBILE_MONEY"
  final String? priority; // e.g. "MEDIUM"
  final double? latitude;
  final double? longitude;

  ServiceRequestPayload({
    required this.name,
    required this.phone,
    required this.address,
    required this.categoryId,
    required this.serviceId,
    this.subserviceId,
    this.description,
    required this.paymentType,
    this.priority,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
      "address": address,
      "categoryId": categoryId,
      "serviceId": serviceId,
      if (subserviceId != null) "subserviceId": subserviceId,
      if (description != null && description!.trim().isNotEmpty)
        "description": description,
      "paymentType": paymentType,
      if (priority != null) "priority": priority,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}
