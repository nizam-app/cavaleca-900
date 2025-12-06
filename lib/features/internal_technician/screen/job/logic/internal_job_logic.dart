import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/internal_technician/screen/job/model/internal_job_model.dart';

// TODO: এখানে তোমার আসল base URL বসাও

class TechnicianJobsApi {
  static Future<String> _getToken() async {
    final token = await AuthLocalStorage.getToken();
    if (token == null) {
      throw Exception('No auth token found');
    }
    return token;
  }

  /// GET /api/technician/InternalJobs?status=incoming|active|done
  static Future<List<InternalJob>> fetchJobs(String listStatus) async {
    final token = await _getToken();

    final url = Uri.parse(AuthAPIController.internalJobsStatus(listStatus));

    final res = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load InternalJobs ($listStatus) [${res.statusCode}]',
      );
    }

    final Map<String, dynamic> data = jsonDecode(res.body);
    final List<dynamic> InternalJobsJson = data['jobs'] ?? [];

    return InternalJobsJson.map((e) => InternalJob.fromJson(e)).toList();
  }

  /// PATCH /api/wos/{woId}/respond   { "action": "ACCEPT" | "DECLINE" }
  static Future<InternalJob> respondToWorkOrder({
    required int woId,
    required String action,
  }) async {
    final token = await _getToken();

    final url = Uri.parse(AuthAPIController.wosRespond(woId));

    final res = await http.patch(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'action': action}),
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to $action work order ($woId) [${res.statusCode}]',
      );
    }

    final body = jsonDecode(res.body);
    // কখনো সরাসরি InternalJob, কখনো "wo" এর ভিতরে
    final Map<String, dynamic> InternalJobJson =
        (body['wo'] ?? body) as Map<String, dynamic>;
    return InternalJob.fromJson(InternalJobJson);
  }

  /// PATCH /api/wos/{woId}/start   { "lat": ..., "lng": ... }
  static Future<InternalJob> startWorkOrder({
    required int woId,
    required double lat,
    required double lng,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(AuthAPIController.wosStart(woId));

    final res = await http.patch(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'lat': lat, 'lng': lng}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to start work order ($woId)');
    }

    final body = jsonDecode(res.body);
    final Map<String, dynamic> InternalJobJson =
        (body['wo'] ?? body) as Map<String, dynamic>;
    return InternalJob.fromJson(InternalJobJson);
  }

  /// PATCH /api/wos/{woId}/complete
  /// এখনের জন্য simple JSON body, পরে চাইলে multipart + photos add করবে
  static Future<InternalJob> completeWorkOrder({
    required int woId,
    required String completionNotes,
    required String materialsUsedJson, // উদাহরণ: '[{"item":"Filter","qty":1}]'
  }) async {
    final token = await _getToken();
    final url = Uri.parse(AuthAPIController.wosComplete(woId));

    final res = await http.patch(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'completionNotes': completionNotes,
        'materialsUsed': materialsUsedJson,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to complete work order ($woId)');
    }

    final body = jsonDecode(res.body);
    final Map<String, dynamic> InternalJobJson =
        (body['wo'] ?? body) as Map<String, dynamic>;
    return InternalJob.fromJson(InternalJobJson);
  }

  /// GET /api/wos/{woId}/time-remaining
  static Future<TimeRemaining> getTimeRemaining(int woId) async {
    final token = await _getToken();
    final url = Uri.parse(AuthAPIController.time_remaining(woId));

    final res = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to get time remaining');
    }

    final Map<String, dynamic> data = jsonDecode(res.body);
    return TimeRemaining.fromJson(data);
  }
}

class TimeRemaining {
  final bool hasDeadline;
  final String message;

  TimeRemaining({required this.hasDeadline, required this.message});

  factory TimeRemaining.fromJson(Map<String, dynamic> json) {
    return TimeRemaining(
      hasDeadline: json['hasDeadline'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
