class InternalLoginResponse {
  final String token;
  final InternalUser user;

  InternalLoginResponse({required this.token, required this.user});

  factory InternalLoginResponse.fromJson(Map<String, dynamic> json) {
    return InternalLoginResponse(
      token: json['token']?.toString() ?? '',
      user: InternalUser.fromJson((json['user'] ?? {}) as Map<String, dynamic>),
    );
  }
}

class InternalUser {
  final int id;
  final String name;
  final String phone;
  final String role;

  InternalUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory InternalUser.fromJson(Map<String, dynamic> json) {
    return InternalUser(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}
