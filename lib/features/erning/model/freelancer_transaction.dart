import 'package:workpleis/features/erning/model/erninig_model.dart';
import 'package:intl/intl.dart';

class Withdrawal {
  final int id;
  final String type;
  final String description;
  final String sourceType;
  final int sourceId;
  final DateTime date;
  final double amount;
  final String status;

  const Withdrawal({
    required this.id,
    required this.type,
    required this.description,
    required this.sourceType,
    required this.sourceId,
    required this.date,
    required this.amount,
    required this.status,
  });

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final withdrawalDate = DateTime(date.year, date.month, date.day);
    
    if (withdrawalDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (withdrawalDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  String get formattedAmount => '-\$${amount.toStringAsFixed(2)}';

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: (json['id'] ?? 0).toInt(),
      type: (json['type'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      sourceType: (json['sourceType'] ?? '') as String,
      sourceId: (json['sourceId'] ?? 0).toInt(),
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      amount: (json['amount'] ?? 0).toDouble(),
      status: (json['status'] ?? '') as String,
    );
  }
}

class FreelancerTransaction {
  final int id;
  final String jobName;
  final String customerName;
  final DateTime date;
  final double jobPayment;
  final double bonus;
  final String status;
  final String woNumber;

  const FreelancerTransaction({
    required this.id,
    required this.jobName,
    required this.customerName,
    required this.date,
    required this.jobPayment,
    required this.bonus,
    required this.status,
    required this.woNumber,
  });

  // Helper getters for backward compatibility with UI
  String get job => jobName;
  String get customer => customerName;
  String get amount => '\$${bonus.toStringAsFixed(2)}';
  
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  factory FreelancerTransaction.fromJson(Map<String, dynamic> json) {
    return FreelancerTransaction(
      id: (json['id'] ?? 0).toInt(),
      jobName: (json['jobName'] ?? '') as String,
      customerName: (json['customerName'] ?? '') as String,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      jobPayment: (json['jobPayment'] ?? 0).toDouble(),
      bonus: (json['bonus'] ?? 0).toDouble(),
      status: (json['status'] ?? '') as String,
      woNumber: (json['woNumber'] ?? '') as String,
    );
  }
}

class FreelancerEarningsData {
  final double commissionRate;
  final double totalEarningsAllTime;
  final double monthChangePercent;

  final double todayEarnings;
  final double thisWeekEarnings;
  final double thisMonthEarnings;

  final double availableBalance;
  final int thisWeekJobs;

  final int monthJobsCompleted;
  final double monthJobsAmount;
  final double monthCommission;

  final List<Withdrawal> recentWithdrawals;

  const FreelancerEarningsData({
    required this.commissionRate,
    required this.totalEarningsAllTime,
    required this.monthChangePercent,
    required this.todayEarnings,
    required this.thisWeekEarnings,
    required this.thisMonthEarnings,
    required this.availableBalance,
    required this.thisWeekJobs,
    required this.monthJobsCompleted,
    required this.monthJobsAmount,
    required this.monthCommission,
    required this.recentWithdrawals,
  });

  /// ✅ NEW: build from API JSON model
  factory FreelancerEarningsData.fromSummary(
    TechnicianEarningsSummary summary,
  ) {
    final bonusRate = summary.bonusRate;
    final breakdown = summary.breakdown;
    final avail = summary.availableBonus;
    final total = summary.totalBonuses;
    final monthlySalary = summary.monthlySalary;

    // breakdown.thisMonth is the total job payment amount for the month
    // monthlySalary.thisMonthBonus is the commission/bonus amount for the month
    // Use breakdown.thisMonth as job amount and monthlySalary.thisMonthBonus as commission
    final monthJobsAmount = breakdown.thisMonth; // Total job payment amount
    final monthCommission = monthlySalary.thisMonthBonus > 0
        ? monthlySalary.thisMonthBonus // Use commission from API
        : (breakdown.thisMonth * bonusRate.rate); // Fallback: calculate from job amount

    return FreelancerEarningsData(
      commissionRate: bonusRate.ratePercentage, // ex: 15
      totalEarningsAllTime: total.amount, // totalBonuses.amount
      monthChangePercent: total.increaseRate, // totalBonuses.increaseRate
      todayEarnings: breakdown.today, // breakdown.today
      thisWeekEarnings: breakdown.thisWeek, // breakdown.thisWeek
      thisMonthEarnings: breakdown.thisMonth, // breakdown.thisMonth
      availableBalance: avail.amount, // availableBonus.amount
      thisWeekJobs: avail.jobsCount, // availableBonus.jobsCount
      monthJobsCompleted: avail.jobsCount, // আপাতত same
      monthJobsAmount: monthJobsAmount, // Total job payment amount
      monthCommission: monthCommission, // Commission/bonus amount
      recentWithdrawals: summary.recentWithdrawals
          .map((w) => Withdrawal.fromJson(w))
          .toList(),
    );
  }
}
