import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/internal_technician/screen/profile/model/internal_profile_modle.dart';

class InternalProfileRepository {
  Future<InternalProfile> fetchProfile() async {
    final token = await AuthLocalStorage.getToken();

    if (token == null) {
      throw Exception('No auth token found');
    }

    final url = Uri.parse(AuthAPIController.profile); // GET /api/auth/profile

    final res = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load profile (${res.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(res.body);

    return InternalProfile.fromJson(data);
  }
}

/// Riverpod repository provider
final internalProfileRepositoryProvider = Provider<InternalProfileRepository>((
  ref,
) {
  return InternalProfileRepository();
});

/// Riverpod FutureProvider for UI
final internalProfileProvider = FutureProvider<InternalProfile>((ref) async {
  final repo = ref.read(internalProfileRepositoryProvider);
  return repo.fetchProfile();
});
