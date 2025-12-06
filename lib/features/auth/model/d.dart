class SendOtpResponse {
  final String message;
  final String code; // test env এ কাজে লাগবে
  final String tempToken;
  final DateTime? expiresAt;

  SendOtpResponse({
    required this.message,
    required this.code,
    required this.tempToken,
    this.expiresAt,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      message: json['message'] ?? '',
      code: json['code']?.toString() ?? '',
      tempToken: json['tempToken'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }
}

class VerifyOtpResponse {
  final String message;
  final bool verified;
  final String phone;
  final String tempToken;

  VerifyOtpResponse({
    required this.message,
    required this.verified,
    required this.phone,
    required this.tempToken,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] ?? '',
      verified: json['verified'] ?? false,
      phone: json['phone']?.toString() ?? '',
      tempToken: json['tempToken'] ?? '',
    );
  }
}

class SetPasswordResponse {
  final String token;
  final Map<String, dynamic> user;
  final String message;

  SetPasswordResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  factory SetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return SetPasswordResponse(
      token: json['token'] ?? '',
      user: (json['user'] ?? {}) as Map<String, dynamic>,
      message: json['message'] ?? '',
    );
  }
}
