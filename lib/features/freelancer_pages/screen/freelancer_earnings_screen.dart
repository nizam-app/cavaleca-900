import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

/// ------------------------------------------------------
///  COLORS
/// ------------------------------------------------------
const kEarningsBg = Color(0xFFF4F4F4);
const kEarningsHeaderStart = Color(0xFFFFB111);
const kEarningsHeaderEnd = Color(0xFFE69F0F);
const kEarningsTextMain = Color(0xFF111827);
const kEarningsTextMuted = Color(0xFF6B7280);
const kEarningsCard = Colors.white;
const kEarningsGreen = Color(0xFF16A34A);
const kEarningsGreenDark = Color(0xFF15803D);
const kEarningsYellow = Color(0xFFFFB111);

/// ------------------------------------------------------
///  MODELS
/// ------------------------------------------------------
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
}

/// ------------------------------------------------------
///  RIVERPOD PROVIDER  (এখানে পরে API কল বসিয়ে দেবে)
/// ------------------------------------------------------

final freelancerEarningsProvider =
Provider<FreelancerEarningsData>((ref) {
  const commissionRate = 15.0;

  // const না, normal list রাখো
  final weekJobPayments = <double>[150, 120, 200, 95, 180, 110, 85];

  final availableBalance = weekJobPayments.fold<double>(
    0,
        (sum, p) => sum + (p * commissionRate) / 100,
  );

  final todayEarnings =
      (150 * commissionRate) / 100 + (120 * commissionRate) / 100;

  final monthlyEarnings = availableBalance * 3.5; // approx

  return FreelancerEarningsData(
    commissionRate: commissionRate,
    totalEarningsAllTime: 24680,
    monthChangePercent: 12.5,
    todayEarnings: todayEarnings,
    thisWeekEarnings: availableBalance,
    thisMonthEarnings: monthlyEarnings,
    availableBalance: availableBalance,
    thisWeekJobs: weekJobPayments.length,
    monthJobsCompleted: 28,
    monthJobsAmount: 6450,
    monthCommission: 320,
    recentTransactions: const [
      FreelancerTransaction(
        id: 1,
        job: 'HVAC Maintenance',
        customer: 'Michael Johnson',
        date: 'Today, 2:00 PM',
        amount: '\$95',
      ),
      FreelancerTransaction(
        id: 2,
        job: 'Plumbing Repair',
        customer: 'Robert Brown',
        date: 'Nov 3, 2025',
        amount: '\$75',
      ),
      FreelancerTransaction(
        id: 3,
        job: 'HVAC Installation',
        customer: 'Emily Davis',
        date: 'Nov 2, 2025',
        amount: '\$200',
      ),
      FreelancerTransaction(
        id: 4,
        job: 'Electrical Repair',
        customer: 'James Wilson',
        date: 'Nov 1, 2025',
        amount: '\$55',
      ),
    ],
  );
});


/// ------------------------------------------------------
///  MAIN SCREEN
/// ------------------------------------------------------
class FreelancerEarningsScreen extends ConsumerWidget {
  const FreelancerEarningsScreen({super.key});

  static const String routeName = 'freelancer-earnings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(freelancerEarningsProvider);

    return Scaffold(
      backgroundColor: kEarningsBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _HeaderSection(data: data),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  children: [
                    _StatsRow(data: data),
                    SizedBox(height: 16.h),
                    _AvailableBalanceCard(data: data),
                    SizedBox(height: 16.h),
                    _CommissionRateCard(data: data),
                    SizedBox(height: 16.h),
                    _MonthBreakdownCard(data: data),
                    SizedBox(height: 16.h),
                    _RecentTransactions(data: data),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  HEADER + TOTAL EARNINGS
/// ------------------------------------------------------
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.data});

  final FreelancerEarningsData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kEarningsHeaderStart, kEarningsHeaderEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          /// top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'earnings_label'.tr(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: kEarningsTextMain,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'track_commission'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: kEarningsTextMain.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  foregroundColor: kEarningsTextMain,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                      content: Text('Export coming soon…'),
                    ),
                  );
                },
                icon: Icon(
                  Icons.download_rounded,
                  size: 16.sp,
                ),
                label: Text(
                  'export'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// total earnings card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
              child: Column(
                children: [
                  Text(
                    'total_earnings_all_time'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: kEarningsTextMain.withOpacity(0.85),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '\$${data.totalEarningsAllTime.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: kEarningsTextMain,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '+${data.monthChangePercent.toStringAsFixed(1)}% from last month',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: kEarningsGreenDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
///  STATS (Today / This Week / Month)
/// ------------------------------------------------------
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});

  final FreelancerEarningsData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.attach_money_rounded,
            iconBg: const Color(0xFFE8FFF3),
            iconColor: kEarningsGreen,
            label: 'today'.tr(),
            value: '\$${data.todayEarnings.toStringAsFixed(2)}',
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            iconBg: const Color(0xFFE5F0FF),
            iconColor: const Color(0xFF2563EB),
            label: 'This Week (${data.commissionRate.toStringAsFixed(0)}%)',
            value: '\$${data.thisWeekEarnings.toStringAsFixed(2)}',
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_month_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF7C3AED),
            label: 'this_month'.tr(),
            value: '\$${data.thisMonthEarnings.toStringAsFixed(0)}',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: kEarningsCard,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.sp, color: iconColor),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: kEarningsTextMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: kEarningsTextMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  AVAILABLE BALANCE (Green Card + Dialog)
/// ------------------------------------------------------
class _AvailableBalanceCard extends StatelessWidget {
  const _AvailableBalanceCard({required this.data});

  final FreelancerEarningsData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'available_balance'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'This week\'s earnings',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),

            Text(
              '\$${data.availableBalance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${data.thisWeekJobs} jobs × ${data.commissionRate.toStringAsFixed(0)}% commission',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 14.h),

            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kEarningsGreenDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                onPressed: data.availableBalance == 0
                    ? null
                    : () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => EarlyPayoutDialog(
                      availableBalance: data.availableBalance,
                      jobsCount: data.thisWeekJobs,
                      commissionRate: data.commissionRate,
                    ),
                  ) ??
                      false;

                  if (confirmed && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Payout request submitted successfully! You will receive your payment within 24 hours.',
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.attach_money_rounded,
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'request_payout'.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                'regular_payout'.tr(),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  COMMISSION RATE (Orange Card)
/// ------------------------------------------------------
class _CommissionRateCard extends StatelessWidget {
  const _CommissionRateCard({required this.data});

  final FreelancerEarningsData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kEarningsHeaderStart, kEarningsHeaderEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.percent_rounded,
                    size: 20.sp,
                    color: kEarningsTextMain,
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'current_commission'.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: kEarningsTextMain,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'earnings_per_job'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kEarningsTextMain.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.commissionRate.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w700,
                    color: kEarningsTextMain,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: kEarningsTextMain,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'five_percent_rate'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: kEarningsTextMain.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  MONTH BREAKDOWN CARD
/// ------------------------------------------------------
class _MonthBreakdownCard extends StatelessWidget {
  const _MonthBreakdownCard({required this.data});

  final FreelancerEarningsData data;

  @override
  Widget build(BuildContext context) {
    final total = data.monthJobsAmount + data.monthCommission;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kEarningsCard,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'this_month_breakdown'.tr(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: kEarningsTextMain,
              ),
            ),
            SizedBox(height: 12.h),
            _BreakdownRow(
              icon: '💼',
              title: 'jobs_completed_amount'.tr(),
              subtitle: '${data.monthJobsCompleted} jobs',
              amount: '\$${data.monthJobsAmount.toStringAsFixed(0)}',
            ),
            SizedBox(height: 10.h),
            _BreakdownRow(
              icon: '💰',
              title: 'commission_earnings_rate'.tr(),
              subtitle: 'Earnings rate',
              amount: '\$${data.monthCommission.toStringAsFixed(0)}',
            ),
            SizedBox(height: 10.h),
            Divider(color: const Color(0xFFE5E7EB)),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: kEarningsTextMain,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: kEarningsGreenDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String icon;
  final String title;
  final String subtitle;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(icon, style: TextStyle(fontSize: 16.sp)),
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: kEarningsTextMain,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: kEarningsTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: kEarningsTextMain,
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------
///  RECENT TRANSACTIONS
/// ------------------------------------------------------
class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({required this.data});

  final FreelancerEarningsData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'recent_transactions'.tr(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: kEarningsTextMain,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: view-all route
              },
              child: Text(
                'view_all'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: kEarningsYellow,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Column(
          children: data.recentTransactions
              .map(
                (tx) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: kEarningsCard,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.job,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: kEarningsTextMain,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                tx.customer,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: kEarningsTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          tx.amount,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: kEarningsGreenDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      tx.date,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kEarningsTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------
///  EARLY PAYOUT DIALOG
/// ------------------------------------------------------
class EarlyPayoutDialog extends StatefulWidget {
  const EarlyPayoutDialog({
    super.key,
    required this.availableBalance,
    required this.jobsCount,
    required this.commissionRate,
  });

  final double availableBalance;
  final int jobsCount;
  final double commissionRate;

  @override
  State<EarlyPayoutDialog> createState() => _EarlyPayoutDialogState();
}

class _EarlyPayoutDialogState extends State<EarlyPayoutDialog> {
  bool _isProcessing = false;

  Future<void> _handleConfirm() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2)); // TODO: API call
    if (!mounted) return;
    setState(() => _isProcessing = false);
    Navigator.of(context).pop(true); // success
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// header
              SizedBox(
                height: 32.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center title
                    Center(
                      child: Text(
                        'request_payout'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: kEarningsTextMain,
                        ),
                      ),
                    ),

                    // Close icon on the right
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        icon: Icon(Icons.close_rounded, size: 20.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'early_payout_description'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: kEarningsTextMuted,
                ),
              ),
              SizedBox(height: 16.h),

              /// amount card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFDF3),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: const Color(0xFFBBF7D0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'amount_available'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kEarningsTextMuted,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '\$${widget.availableBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: kEarningsGreenDark,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'jobs_completed'.tr(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kEarningsTextMuted,
                            ),
                          ),
                          Text(
                            '${widget.jobsCount}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kEarningsGreenDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'commission_rate'.tr(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kEarningsTextMuted,
                            ),
                          ),
                          Text(
                            '${widget.commissionRate.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kEarningsGreenDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// info box
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE0EDFF),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18.sp,
                        color: const Color(0xFF2563EB),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoText('payment_processing_time'.tr()),
                            _infoText(
                                'sent_to_bank'.tr()),
                            _infoText(
                                'regular_payout_next_week'.tr()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// payment method
              Text(
                'payment_method'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: kEarningsTextMuted,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFFDF3),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.attach_money_rounded,
                          color: kEarningsGreen,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'bank_account'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: kEarningsTextMain,
                            ),
                          ),
                          Text(
                            '****1234',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kEarningsTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              /// buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kEarningsGreenDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: _isProcessing
                      ? Text(
                    'Processing...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'confirm_payout_request'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                  _isProcessing ? null : () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    'cancel'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: kEarningsTextMain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText(String text) => Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h),
    child: Text(
      '• $text',
      style: TextStyle(
        fontSize: 11.sp,
        color: const Color(0xFF1F2937),
      ),
    ),
  );
}
