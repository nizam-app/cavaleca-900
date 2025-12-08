class CustomerProfile {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final bool isBlocked;
  final String? homeAddress;
  final double? latitude;
  final double? longitude;
  final int totalBookings;
  final int totalSpent;
  final Map<String, String>? businessHours;

  const CustomerProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.isBlocked,
    this.homeAddress,
    this.latitude,
    this.longitude,
    required this.totalBookings,
    required this.totalSpent,
    this.businessHours,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    final bhRaw = json['businessHours'] as Map<String, dynamic>?;

    return CustomerProfile(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      email: json['email'] as String?,
      role: (json['role'] ?? '') as String,
      isBlocked: (json['isBlocked'] ?? false) as bool,
      homeAddress: json['homeAddress'] as String?,
      latitude: json['latitude'] == null
          ? null
          : (json['latitude'] as num).toDouble(),
      longitude: json['longitude'] == null
          ? null
          : (json['longitude'] as num).toDouble(),
      totalBookings: (json['totalBookings'] ?? 0) as int,
      totalSpent: (json['totalSpent'] ?? 0) as int,
      businessHours: bhRaw == null
          ? null
          : bhRaw.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );
  }
}
