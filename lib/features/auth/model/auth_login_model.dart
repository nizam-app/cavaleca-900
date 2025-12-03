class InternalLoginResponse {
  final String token;
  final InternalUser user;

  InternalLoginResponse({required this.token, required this.user});

  factory InternalLoginResponse.fromJson(Map<String, dynamic> json) {
    return InternalLoginResponse(
      token: json['token'],
      user: InternalUser.fromJson(json['user']),
    );
  }
}

class InternalUser {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isBlocked;
  final String createdAt;

  InternalUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isBlocked,
    required this.createdAt,
  });

  factory InternalUser.fromJson(Map<String, dynamic> json) {
    return InternalUser(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      isBlocked: json['isBlocked'],
      createdAt: json['createdAt'],
    );
  }
}
