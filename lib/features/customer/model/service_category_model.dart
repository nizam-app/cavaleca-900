import 'dart:convert';

class ServiceCategory {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final List<Subservice> subservices;

  ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.subservices,
  });
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      subservices: (json['subservices'] as List<dynamic>? ?? [])
          .map((e) => Subservice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<ServiceCategory> listFromJson(String rawJson) {
    final List<dynamic> data = json.decode(rawJson) as List<dynamic>;
    return data
        .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class Subservice {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final List<ServiceItem> services;

  Subservice({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.services,
  });

  factory Subservice.fromJson(Map<String, dynamic> json) {
    return Subservice(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceItem {
  final int id;
  final int categoryId;
  final int subserviceId;
  final String name;
  final String? description;
  final double baseRate;

  ServiceItem({
    required this.id,
    required this.categoryId,
    required this.subserviceId,
    required this.name,
    this.description,
    required this.baseRate,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      subserviceId: json['subserviceId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      // baseRate backend theke number (int/double) ashe – safely double e cast
      baseRate: (json['baseRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// ---------- Create SR body model ----------

class ServiceRequestPayload {
  final String name;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final int categoryId;
  final int subserviceId;
  final int serviceId;
  final String description;
  final String paymentType; // "CASH" / "MOBILE"
  final String priority; // "MEDIUM" etc.
  final String appointment; // optional string / date-time

  ServiceRequestPayload({
    required this.name,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    required this.subserviceId,
    required this.serviceId,
    required this.description,
    required this.paymentType,
    required this.priority,
    required this.appointment,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      // NOTE: API te "Phone" capital P, tai oitar sathe match korlam
      "Phone": phone,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "categoryId": categoryId,
      "subserviceId": subserviceId,
      "serviceId": serviceId,
      "description": description,
      "paymentType": paymentType,
      "priority": priority,
      "appointment": appointment,
    };
  }
}
