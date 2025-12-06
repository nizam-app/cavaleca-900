import 'global_api.dart';

class AuthAPIController {
  static String _base_api = "$api/api";
  static String technician_login = "${_base_api}/auth/login";
  static String sendOTP = "${_base_api}/otp/send";
  static String numberVerify = "${_base_api}/otp/verify";
  static String logout = "${_base_api}/auth/logout";
  static String profile = "${_base_api}/auth/profile";
  static String internalJobsStatus(listStatus) =>
      "${_base_api}/technician/jobs?status=$listStatus";
  static String wosRespond(woId) => "${_base_api}/wos/$woId/respond";
  static String wosStart(woId) => "${_base_api}/wos/$woId/start";
  static String wosComplete(woId) => "${_base_api}/wos/$woId/complete";
  static String time_remaining(woId) => "${_base_api}/wos/$woId/time-remaining";
}
