class CustomerUser {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;

  CustomerUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
  });

  factory CustomerUser.fromJson(Map<String, dynamic> json) {
    return CustomerUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }
}

/// -------------- SEND OTP RESPONSE MODEL --------------

class CustomerOtpSendResponse {
  final String message;
  final String code;
  final String expiresAt;
  final String tempToken;
  final String tempTokenExpiry;
  final String smsStatus;
  final String token;
  final Map<String, dynamic>? user;

  CustomerOtpSendResponse({
    required this.message,
    required this.code,
    required this.expiresAt,
    required this.tempToken,
    required this.tempTokenExpiry,
    required this.smsStatus,
    required this.token,
    required this.user,
  });

  factory CustomerOtpSendResponse.fromJson(Map<String, dynamic> json) {
    return CustomerOtpSendResponse(
      message: json['message'] as String? ?? '',
      code: json['code'] as String? ?? '',
      expiresAt: json['expiresAt'] as String? ?? '',
      tempToken: json['tempToken'] as String? ?? '',
      tempTokenExpiry: json['tempTokenExpiry'] as String? ?? '',
      smsStatus: json['smsStatus'] as String? ?? '',
      token: json['token'] as String? ?? '',
      user: json['user'] as Map<String, dynamic>?,
    );
  }
}

/// -------------- VERIFY OTP RESPONSE MODEL --------------

class CustomerOtpVerifyResponse {
  final String message;
  final bool verified;
  final String phone;
  final String tempToken;
  final String tempTokenExpiry;
  final String token;
  final CustomerUser user;

  CustomerOtpVerifyResponse({
    required this.message,
    required this.verified,
    required this.phone,
    required this.tempToken,
    required this.tempTokenExpiry,
    required this.token,
    required this.user,
  });

  factory CustomerOtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return CustomerOtpVerifyResponse(
      message: json['message'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      phone: json['phone'] as String? ?? '',
      tempToken: json['tempToken'] as String? ?? '',
      tempTokenExpiry: json['tempTokenExpiry'] as String? ?? '',
      token: json['token'] as String? ?? '',
      user: CustomerUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// ---------------- API HELPER ----------------
