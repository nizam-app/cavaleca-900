import 'package:workpleis/features/erning/model/erninig_model.dart';

class FreelancerTransaction {
  final int id;
  final String job;
  final String customer;
  final String date;
  final String amount;

  const FreelancerTransaction({
    required this.id,
    required this.job,
    required this.customer,
    required this.date,
    required this.amount,
  });
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

  final List<FreelancerTransaction> recentTransactions;

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
    required this.recentTransactions,
  });

  /// ✅ NEW: build from API JSON model
  factory FreelancerEarningsData.fromSummary(
    TechnicianEarningsSummary summary,
  ) {
    final bonusRate = summary.bonusRate;
    final breakdown = summary.breakdown;
    final avail = summary.availableBonus;
    final total = summary.totalBonuses;

    // simple example – চাইলে formula পরে change করতে পারো
    final monthCommission = breakdown.thisMonth * bonusRate.rate;

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
      monthJobsAmount: breakdown.thisMonth, // full month amount
      monthCommission: monthCommission, // derived
      recentTransactions: const [], // backend এখন খালি দিচ্ছে
    );
  }
}
