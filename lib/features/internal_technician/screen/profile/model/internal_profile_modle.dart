class InternalProfile {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isBlocked;
  final String? homeAddress;
  final String? locationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TechnicianProfile? technicianProfile;

  InternalProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isBlocked,
    required this.homeAddress,
    this.locationStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.technicianProfile,
  });

  factory InternalProfile.fromJson(Map<String, dynamic> json) {
    return InternalProfile(
      id: json['id'] as int,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isBlocked: json['isBlocked'] ?? false,
      homeAddress: json['homeAddress'],
      locationStatus: json['locationStatus'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      technicianProfile: json['technicianProfile'] != null
          ? TechnicianProfile.fromJson(json['technicianProfile'])
          : null,
    );
  }
}

class TechnicianProfile {
  final int id;
  final String type;
  final double commissionRate;
  final double bonusRate;
  final num baseSalary;
  final String status;
  final String? specialization;
  final String? department;
  final DateTime? joinDate;
  final String? position;
  final List<String> skills;
  final List<TechCertification> certifications;

  // some extra nested fields (optional)
  final ResponseTime? responseTime;
  final BonusInfo? bonus;
  final PriorityStatus? priorityStatus;

  TechnicianProfile({
    required this.id,
    required this.type,
    required this.commissionRate,
    required this.bonusRate,
    required this.baseSalary,
    required this.status,
    this.specialization,
    this.department,
    this.joinDate,
    this.position,
    required this.skills,
    required this.certifications,
    this.responseTime,
    this.bonus,
    this.priorityStatus,
  });

  factory TechnicianProfile.fromJson(Map<String, dynamic> json) {
    return TechnicianProfile(
      id: json['id'] as int,
      type: json['type'] ?? '',
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0,
      bonusRate: (json['bonusRate'] as num?)?.toDouble() ?? 0,
      baseSalary: json['baseSalary'] ?? 0,
      status: json['status'] ?? '',
      specialization: json['specialization'],
      department: json['department'],
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : null,
      position: json['position'],
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      certifications: (json['certifications'] as List<dynamic>? ?? [])
          .map((e) => TechCertification.fromJson(e))
          .toList(),
      responseTime: json['responseTime'] != null
          ? ResponseTime.fromJson(json['responseTime'])
          : null,
      bonus: json['bonus'] != null ? BonusInfo.fromJson(json['bonus']) : null,
      priorityStatus: json['priorityStatus'] != null
          ? PriorityStatus.fromJson(json['priorityStatus'])
          : null,
    );
  }
}

class TechCertification {
  final String name;
  final String url;
  final DateTime? verifiedAt;

  TechCertification({required this.name, required this.url, this.verifiedAt});

  factory TechCertification.fromJson(Map<String, dynamic> json) {
    return TechCertification(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
    );
  }
}

class ResponseTime {
  final int minutes;
  final String formatted;
  final String status;

  ResponseTime({
    required this.minutes,
    required this.formatted,
    required this.status,
  });

  factory ResponseTime.fromJson(Map<String, dynamic> json) {
    return ResponseTime(
      minutes: json['minutes'] ?? 0,
      formatted: json['formatted'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class BonusInfo {
  final num thisWeek;
  final double rate;
  final num ratePercentage;
  final String type;

  BonusInfo({
    required this.thisWeek,
    required this.rate,
    required this.ratePercentage,
    required this.type,
  });

  factory BonusInfo.fromJson(Map<String, dynamic> json) {
    return BonusInfo(
      thisWeek: json['thisWeek'] ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      ratePercentage: json['ratePercentage'] ?? 0,
      type: json['type'] ?? '',
    );
  }
}

class PriorityStatus {
  final PriorityCounts? counts;
  final PriorityPercentages? percentages;
  final String? mostCommon;

  PriorityStatus({this.counts, this.percentages, this.mostCommon});

  factory PriorityStatus.fromJson(Map<String, dynamic> json) {
    return PriorityStatus(
      counts: json['counts'] != null
          ? PriorityCounts.fromJson(json['counts'])
          : null,
      percentages: json['percentages'] != null
          ? PriorityPercentages.fromJson(json['percentages'])
          : null,
      mostCommon: json['mostCommon'],
    );
  }
}

class PriorityCounts {
  final int low;
  final int medium;
  final int high;

  PriorityCounts({required this.low, required this.medium, required this.high});

  factory PriorityCounts.fromJson(Map<String, dynamic> json) {
    return PriorityCounts(
      low: json['low'] ?? 0,
      medium: json['medium'] ?? 0,
      high: json['high'] ?? 0,
    );
  }
}

class PriorityPercentages {
  final int low;
  final int medium;
  final int high;

  PriorityPercentages({
    required this.low,
    required this.medium,
    required this.high,
  });

  factory PriorityPercentages.fromJson(Map<String, dynamic> json) {
    return PriorityPercentages(
      low: json['low'] ?? 0,
      medium: json['medium'] ?? 0,
      high: json['high'] ?? 0,
    );
  }
}
