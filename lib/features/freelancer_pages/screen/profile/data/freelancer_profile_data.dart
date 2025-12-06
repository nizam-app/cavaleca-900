// lib/features/freelancer/data/freelancer_profile_repo.dart

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/freelancer_pages/screen/profile/screen/freelancer_profile_screen.dart';

class FreelancerProfileRepository {
  final http.Client _client;

  FreelancerProfileRepository({http.Client? client})
    : _client = client ?? http.Client();

  /// /api/auth/profile theke freelancer profile ene
  /// FreelancerProfileData e map kore return korbe
  Future<FreelancerProfileData> fetchProfileData() async {
    // ====== 1) token ana ======
    final String? token = await AuthLocalStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    // ====== 2) API call ======
    final response = await _client.get(
      Uri.parse(AuthAPIController.profile), // <-- /api/auth/profile
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load profile (${response.statusCode})');
    }

    final Map<String, dynamic> root =
        jsonDecode(response.body) as Map<String, dynamic>;

    // ====== 3) JSON theke field gula ber kora ======
    final Map<String, dynamic>? tech =
        root['technicianProfile'] as Map<String, dynamic>?;

    final String fullName = root['name'] as String? ?? 'Freelancer';
    final String initials = _getInitials(fullName);

    // title – position na thakle fallback
    final String title =
        tech?['position'] as String? ?? 'Freelancer Technician';

    // memberSince – age joinDate theke, na pele createdAt year
    String memberSince = '—';
    DateTime? dt;
    final String? joinDateStr = tech?['joinDate'] as String?;
    if (joinDateStr != null) {
      dt = DateTime.tryParse(joinDateStr);
    }
    final String? createdAtStr = root['createdAt'] as String?;
    dt ??= createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
    if (dt != null) {
      memberSince = dt.year.toString();
    }

    // skills
    List<String> skills = [];
    final skillsJson = tech?['skills'];
    if (skillsJson is List) {
      skills = skillsJson.map((e) => e.toString()).toList();
    }

    // certifications count
    int verifiedCerts = 0;
    final certsJson = tech?['certifications'];
    if (certsJson is List) {
      verifiedCerts = certsJson.length;
    }

    // bank linked?
    final bool bankLinked =
        tech?['bankName'] != null && tech?['bankAccountNumber'] != null;

    // ====== 4) UI model build ======
    return FreelancerProfileData(
      initials: initials,
      fullName: fullName,
      title: title,
      memberSince: memberSince,
      skills: skills.isEmpty ? ['General'] : skills,
      verifiedCerts: verifiedCerts,
      bankLinked: bankLinked,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'F';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
