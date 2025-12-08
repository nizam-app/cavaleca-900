import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/erning/data/erning_data.dart';
import 'package:workpleis/features/erning/model/erninig_model.dart';

class Earningsscreen extends ConsumerWidget {
  const Earningsscreen({super.key});

  static const String routeName = '/internalEarningsScreen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(internalEarningsProvider);

    return asyncSummary.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Failed to load earnings:\n$err',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (summary) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 30.h),
            child: Column(
              children: [
                _header(summary),
                SizedBox(height: 16.h),
                _statsRow(summary),
                SizedBox(height: 16.h),
                _availableBonusCard(summary),
                SizedBox(height: 16.h),
                _bonusRateCard(summary),
                SizedBox(height: 16.h),
                monthlySalaryCard(summary),
                SizedBox(height: 22.h),
                _recentBonusesHeader(),
                if (summary.monthlySalary.isFreelancer == false &&
                    summary.availableBonus.jobsCount == 0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'No recent bonuses yet',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                // যদি backend পরে recentBonuses পাঠায়, এখানে list map করে দেখাবে
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // HEADER  – use totalBonuses
  // ------------------------------------------------------------------
  Widget _header(TechnicianEarningsSummary summary) {
    final total = summary.totalBonuses;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 26.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1625),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26.r),
          bottomRight: Radius.circular(26.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Earnings",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white.withOpacity(0.15),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.file_download_outlined,
                      color: Colors.white70,
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Export",
                      style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            "Track your bonus earnings",
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
          SizedBox(height: 18.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2432),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Total Bonuses (All Time)",
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  "\$${total.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  total.increaseText.isNotEmpty
                      ? total.increaseText
                      : "${total.increaseRate.toStringAsFixed(1)}% from last month",
                  style: TextStyle(
                    color: const Color(0xFF05DF72),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // TODAY / WEEK / MONTH  – use breakdown
  // ------------------------------------------------------------------
  Widget _statsRow(TechnicianEarningsSummary summary) {
    final br = summary.breakdown;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statBox(
          title: "Today",
          value: "\$${br.today.toStringAsFixed(2)}",
          icon: Icons.attach_money,
          bgColor: const Color(0xFFE8FEEA),
          iconColor: const Color(0xFF4CAF50),
        ),
        _statBox(
          title: "This Week (${br.thisWeekPercentage.toStringAsFixed(0)}%)",
          value: "\$${br.thisWeek.toStringAsFixed(2)}",
          icon: Icons.trending_up,
          bgColor: const Color(0xFFEAF3FF),
          iconColor: const Color(0xFF2979FF),
        ),
        _statBox(
          title: "This Month",
          value: "\$${br.thisMonth.toStringAsFixed(2)}",
          icon: Icons.calendar_month,
          bgColor: const Color(0xFFF5E8FF),
          iconColor: const Color(0xFF9C27B0),
        ),
      ],
    );
  }

  Widget _statBox({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      width: 110.w,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // AVAILABLE BONUS card – use availableBonus
  // ------------------------------------------------------------------
  Widget _availableBonusCard(TechnicianEarningsSummary summary) {
    final ab = summary.availableBonus;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A77FF),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Available Bonus",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "This week’s earnings",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            "\$${ab.amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "${ab.jobsText} × ${ab.bonusText}",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          SizedBox(height: 20.h),
          _earlyPayoutButton(),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              ab.payoutInfo,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _earlyPayoutButton() {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.attach_money, color: const Color(0xFF0A77FF), size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            "Request Early Payout",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A77FF),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // BONUS RATE card – use bonusRate
  // ------------------------------------------------------------------
  Widget _bonusRateCard(TechnicianEarningsSummary summary) {
    final br = summary.bonusRate;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF131A26),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current ${br.type} Rate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "For internal employees",
                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                br.ratePercentage.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 48.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                " %",
                style: TextStyle(
                  fontSize: 30.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                "per job",
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: Colors.white70, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    br.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // MONTHLY SALARY card – use monthlySalary
  // ------------------------------------------------------------------
  Widget monthlySalaryCard(TechnicianEarningsSummary summary) {
    final ms = summary.monthlySalary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0CCE6B), Color(0xFF00B95A)],
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Monthly Salary",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "\$${ms.total.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 32.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Base Salary",
                      style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                    ),
                    const Spacer(),
                    Text(
                      "\$${ms.baseSalary.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 13.sp, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Text(
                      "This Month Bonus",
                      style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                    ),
                    const Spacer(),
                    Text(
                      "+\$${ms.thisMonthBonus.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 13.sp, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // RECENT BONUSES HEADER (same)
  // ------------------------------------------------------------------
  Widget _recentBonusesHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          Text(
            "Recent Bonuses",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            "View All",
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF364153),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
