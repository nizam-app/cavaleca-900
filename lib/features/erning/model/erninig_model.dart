import 'dart:convert';

/// Root object for /api/technician/earnings
class TechnicianEarningsSummary {
  final TotalBonuses totalBonuses;
  final EarningsBreakdown breakdown;
  final AvailableBonus availableBonus;
  final BonusRate bonusRate;
  final MonthlySalary monthlySalary;
  final List<Map<String, dynamic>> recentTransactions;
  final List<Map<String, dynamic>> recentBonuses;

  TechnicianEarningsSummary({
    required this.totalBonuses,
    required this.breakdown,
    required this.availableBonus,
    required this.bonusRate,
    required this.monthlySalary,
    required this.recentTransactions,
    required this.recentBonuses,
  });

  factory TechnicianEarningsSummary.fromJson(Map<String, dynamic> json) {
    return TechnicianEarningsSummary(
      totalBonuses: TotalBonuses.fromJson(json['totalBonuses'] ?? {}),
      breakdown: EarningsBreakdown.fromJson(json['breakdown'] ?? {}),
      availableBonus: AvailableBonus.fromJson(json['availableBonus'] ?? {}),
      bonusRate: BonusRate.fromJson(json['bonusRate'] ?? {}),
      monthlySalary: MonthlySalary.fromJson(json['monthlySalary'] ?? {}),
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      recentBonuses: (json['recentBonuses'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  static TechnicianEarningsSummary fromJsonString(String source) =>
      TechnicianEarningsSummary.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
}

class TotalBonuses {
  final double amount;
  final double increaseRate;
  final String increaseText;

  TotalBonuses({
    required this.amount,
    required this.increaseRate,
    required this.increaseText,
  });

  factory TotalBonuses.fromJson(Map<String, dynamic> json) {
    return TotalBonuses(
      amount: (json['amount'] ?? 0).toDouble(),
      increaseRate: (json['increaseRate'] ?? 0).toDouble(),
      increaseText: (json['increaseText'] ?? '') as String,
    );
  }
}

class EarningsBreakdown {
  final double today;
  final double thisWeek;
  final double thisWeekPercentage;
  final double thisMonth;

  EarningsBreakdown({
    required this.today,
    required this.thisWeek,
    required this.thisWeekPercentage,
    required this.thisMonth,
  });

  factory EarningsBreakdown.fromJson(Map<String, dynamic> json) {
    return EarningsBreakdown(
      today: (json['today'] ?? 0).toDouble(),
      thisWeek: (json['thisWeek'] ?? 0).toDouble(),
      thisWeekPercentage: (json['thisWeekPercentage'] ?? 0).toDouble(),
      thisMonth: (json['thisMonth'] ?? 0).toDouble(),
    );
  }
}

class AvailableBonus {
  final double amount;
  final int jobsCount;
  final String jobsText;
  final String bonusText;
  final String payoutInfo;

  AvailableBonus({
    required this.amount,
    required this.jobsCount,
    required this.jobsText,
    required this.bonusText,
    required this.payoutInfo,
  });

  factory AvailableBonus.fromJson(Map<String, dynamic> json) {
    return AvailableBonus(
      amount: (json['amount'] ?? 0).toDouble(),
      jobsCount: (json['jobsCount'] ?? 0).toInt(),
      jobsText: (json['jobsText'] ?? '') as String,
      bonusText: (json['bonusText'] ?? '') as String,
      payoutInfo: (json['payoutInfo'] ?? '') as String,
    );
  }
}

class BonusRate {
  final double rate; // example: 0.05
  final double ratePercentage; // example: 5
  final String type; // "Bonus" / "Commission"
  final String description;

  BonusRate({
    required this.rate,
    required this.ratePercentage,
    required this.type,
    required this.description,
  });

  factory BonusRate.fromJson(Map<String, dynamic> json) {
    return BonusRate(
      rate: (json['rate'] ?? 0).toDouble(),
      ratePercentage: (json['ratePercentage'] ?? 0).toDouble(),
      type: (json['type'] ?? '') as String,
      description: (json['description'] ?? '') as String,
    );
  }
}

class MonthlySalary {
  final double baseSalary;
  final double thisMonthBonus;
  final double total;
  final bool isFreelancer;

  MonthlySalary({
    required this.baseSalary,
    required this.thisMonthBonus,
    required this.total,
    required this.isFreelancer,
  });

  factory MonthlySalary.fromJson(Map<String, dynamic> json) {
    return MonthlySalary(
      baseSalary: (json['baseSalary'] ?? 0).toDouble(),
      thisMonthBonus: (json['thisMonthBonus'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      isFreelancer: (json['isFreelancer'] ?? false) as bool,
    );
  }
}
