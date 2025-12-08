// lib/features/freelancer/models/freelancer_profile_model.dart

import 'dart:convert';

FreelancerProfileResponse freelancerProfileResponseFromJson(String source) {
  final Map<String, dynamic> map = jsonDecode(source);
  return FreelancerProfileResponse.fromJson(map);
}

class FreelancerProfileResponse {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final bool isBlocked;
  final String? homeAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TechnicianProfile? technicianProfile;

  FreelancerProfileResponse({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isBlocked,
    required this.homeAddress,
    required this.createdAt,
    required this.updatedAt,
    required this.technicianProfile,
  });

  factory FreelancerProfileResponse.fromJson(Map<String, dynamic> json) {
    return FreelancerProfileResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      isBlocked: json['isBlocked'] as bool? ?? false,
      homeAddress: json['homeAddress'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      technicianProfile: json['technicianProfile'] != null
          ? TechnicianProfile.fromJson(
              json['technicianProfile'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class TechnicianProfile {
  final int id;
  final String type;
  final double commissionRate;
  final double bonusRate;
  final double baseSalary;
  final String status;
  final String? specialization;
  final String? academicTitle;
  final String? photoUrl;
  final String? idCardUrl;
  final String? residencePermitUrl;
  final DateTime? residencePermitFrom;
  final DateTime? residencePermitTo;
  final List<Certification> certifications;
  final String? department;
  final DateTime? joinDate;
  final String? position;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountHolder;
  final String? mobileBankingType;
  final String? mobileBankingNumber;
  final List<String> skills;
  final ResponseTime? responseTime;
  final Bonus? bonus;
  final PriorityStatus? priorityStatus;

  TechnicianProfile({
    required this.id,
    required this.type,
    required this.commissionRate,
    required this.bonusRate,
    required this.baseSalary,
    required this.status,
    required this.specialization,
    required this.academicTitle,
    required this.photoUrl,
    required this.idCardUrl,
    required this.residencePermitUrl,
    required this.residencePermitFrom,
    required this.residencePermitTo,
    required this.certifications,
    required this.department,
    required this.joinDate,
    required this.position,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountHolder,
    required this.mobileBankingType,
    required this.mobileBankingNumber,
    required this.skills,
    required this.responseTime,
    required this.bonus,
    required this.priorityStatus,
  });

  factory TechnicianProfile.fromJson(Map<String, dynamic> json) {
    return TechnicianProfile(
      id: json['id'] as int,
      type: json['type'] as String,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0,
      bonusRate: (json['bonusRate'] as num?)?.toDouble() ?? 0,
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
      specialization: json['specialization'] as String?,
      academicTitle: json['academicTitle'] as String?,
      photoUrl: json['photoUrl'] as String?,
      idCardUrl: json['idCardUrl'] as String?,
      residencePermitUrl: json['residencePermitUrl'] as String?,
      residencePermitFrom: json['residencePermitFrom'] != null
          ? DateTime.parse(json['residencePermitFrom'] as String)
          : null,
      residencePermitTo: json['residencePermitTo'] != null
          ? DateTime.parse(json['residencePermitTo'] as String)
          : null,
      certifications: (json['certifications'] as List<dynamic>? ?? [])
          .map((e) => Certification.fromJson(e as Map<String, dynamic>))
          .toList(),
      department: json['department'] as String?,
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'] as String)
          : null,
      position: json['position'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankAccountHolder: json['bankAccountHolder'] as String?,
      mobileBankingType: json['mobileBankingType'] as String?,
      mobileBankingNumber: json['mobileBankingNumber'] as String?,
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      responseTime: json['responseTime'] != null
          ? ResponseTime.fromJson(json['responseTime'] as Map<String, dynamic>)
          : null,
      bonus: json['bonus'] != null
          ? Bonus.fromJson(json['bonus'] as Map<String, dynamic>)
          : null,
      priorityStatus: json['priorityStatus'] != null
          ? PriorityStatus.fromJson(
              json['priorityStatus'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class Certification {
  final String name;
  final String url;
  final DateTime? verifiedAt;

  Certification({
    required this.name,
    required this.url,
    required this.verifiedAt,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      name: json['name'] as String,
      url: json['url'] as String,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
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
      minutes: json['minutes'] as int? ?? 0,
      formatted: json['formatted'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class Bonus {
  final num thisWeek;
  final double rate;
  final num ratePercentage;
  final String type;

  Bonus({
    required this.thisWeek,
    required this.rate,
    required this.ratePercentage,
    required this.type,
  });

  factory Bonus.fromJson(Map<String, dynamic> json) {
    return Bonus(
      thisWeek: json['thisWeek'] as num? ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      ratePercentage: json['ratePercentage'] as num? ?? 0,
      type: json['type'] as String? ?? '',
    );
  }
}

class PriorityStatus {
  final PriorityCounts counts;
  final PriorityPercentages percentages;
  final String mostCommon;

  PriorityStatus({
    required this.counts,
    required this.percentages,
    required this.mostCommon,
  });

  factory PriorityStatus.fromJson(Map<String, dynamic> json) {
    return PriorityStatus(
      counts: PriorityCounts.fromJson(json['counts'] as Map<String, dynamic>),
      percentages: PriorityPercentages.fromJson(
        json['percentages'] as Map<String, dynamic>,
      ),
      mostCommon: json['mostCommon'] as String? ?? '',
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
      low: json['low'] as int? ?? 0,
      medium: json['medium'] as int? ?? 0,
      high: json['high'] as int? ?? 0,
    );
  }
}

class PriorityPercentages {
  final num low;
  final num medium;
  final num high;

  PriorityPercentages({
    required this.low,
    required this.medium,
    required this.high,
  });

  factory PriorityPercentages.fromJson(Map<String, dynamic> json) {
    return PriorityPercentages(
      low: json['low'] as num? ?? 0,
      medium: json['medium'] as num? ?? 0,
      high: json['high'] as num? ?? 0,
    );
  }
}
