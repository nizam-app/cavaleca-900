class CustomerBookingModel {
  final int srId;
  final String srNumber;
  final String status; // "ACTIVE", "COMPLETED", "CANCELLED"
  final String readableStatus;
  final String internalStatus;
  final String description;
  final String priority;
  final String address;
  final String? preferredAppointmentDate;
  final String? preferredAppointmentTime;
  final String? scheduledAt;
  final Category? category;
  final Subservice? subservice;
  final Service? service;
  final AssignedTechnician? assignedTechnician;
  final TechnicianRating? technicianRating;
  final PaymentSummary? paymentSummary;
  final String createdAt;
  final String updatedAt;

  CustomerBookingModel({
    required this.srId,
    required this.srNumber,
    required this.status,
    required this.readableStatus,
    required this.internalStatus,
    required this.description,
    required this.priority,
    required this.address,
    this.preferredAppointmentDate,
    this.preferredAppointmentTime,
    this.scheduledAt,
    this.category,
    this.subservice,
    this.service,
    this.assignedTechnician,
    this.technicianRating,
    this.paymentSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerBookingModel.fromJson(Map<String, dynamic> json) {
    return CustomerBookingModel(
      srId: (json['srId'] as int?) ?? 0,
      srNumber: (json['srNumber'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      readableStatus: (json['readableStatus'] ?? '') as String,
      internalStatus: (json['internalStatus'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      priority: (json['priority'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      preferredAppointmentDate: json['preferredAppointmentDate'] as String?,
      preferredAppointmentTime: json['preferredAppointmentTime'] as String?,
      scheduledAt: json['scheduledAt'] as String?,
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      subservice: json['subservice'] == null
          ? null
          : Subservice.fromJson(json['subservice'] as Map<String, dynamic>),
      service: json['service'] == null
          ? null
          : Service.fromJson(json['service'] as Map<String, dynamic>),
      assignedTechnician: json['assignedTechnician'] == null
          ? null
          : AssignedTechnician.fromJson(
              json['assignedTechnician'] as Map<String, dynamic>),
      technicianRating: json['technicianRating'] == null
          ? null
          : TechnicianRating.fromJson(
              json['technicianRating'] as Map<String, dynamic>),
      paymentSummary: json['paymentSummary'] == null
          ? null
          : PaymentSummary.fromJson(
              json['paymentSummary'] as Map<String, dynamic>),
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
    );
  }

  static List<CustomerBookingModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CustomerBookingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class Category {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      isActive: (json['isActive'] ?? false) as bool,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
    );
  }
}

class Subservice {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final String createdAt;
  final String updatedAt;

  Subservice({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subservice.fromJson(Map<String, dynamic> json) {
    return Subservice(
      id: (json['id'] as int?) ?? 0,
      categoryId: (json['categoryId'] as int?) ?? 0,
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
    );
  }
}

class Service {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final String createdAt;
  final String updatedAt;

  Service({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: (json['id'] as int?) ?? 0,
      categoryId: (json['categoryId'] as int?) ?? 0,
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
    );
  }
}

class AssignedTechnician {
  final int id;
  final String name;
  final String phone;

  AssignedTechnician({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory AssignedTechnician.fromJson(Map<String, dynamic> json) {
    return AssignedTechnician(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
    );
  }
}

class TechnicianRating {
  final int rating;
  final String? comment;

  TechnicianRating({
    required this.rating,
    this.comment,
  });

  factory TechnicianRating.fromJson(Map<String, dynamic> json) {
    return TechnicianRating(
      rating: (json['rating'] as int?) ?? 0,
      comment: json['comment'] as String?,
    );
  }
}

class PaymentSummary {
  final double totalAmount;
  final String paymentStatus;
  final String? paymentMethod;

  PaymentSummary({
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentMethod,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      totalAmount: json['totalAmount'] == null
          ? 0.0
          : (json['totalAmount'] as num).toDouble(),
      paymentStatus: (json['paymentStatus'] ?? '') as String,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }
}

