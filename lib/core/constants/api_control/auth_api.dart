import 'global_api.dart';

class AuthAPIController {
  static String _base_api = "$api/api";
  static String technician_login = "${_base_api}/auth/login";
  static String sendOTP = "${_base_api}/otp/send";
  static String numberVerify = "${_base_api}/otp/verify";
  static String logout = "${_base_api}/auth/logout";
  static String profile = "${_base_api}/auth/profile";
}
