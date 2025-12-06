import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Earningsscreen extends StatelessWidget {
  const Earningsscreen({super.key});

  static const String routeName = '/internalEarningsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 30.h),
        child: Column(
          children: [
            _header(),
            SizedBox(height: 16.h),
            _statsRow(),
            SizedBox(height: 16.h),
            _availableBonusCard(),
            SizedBox(height: 16.h),
            _bonusRateCard(),
            SizedBox(height: 16.h),
            monthlySalaryCard(),
            SizedBox(height: 22.h),
            _recentBonusesHeader(),
            _recentBonusItem(
              job: "HVAC System Maintenance",
              name: "Ahmed Mohammed",
              time: "Today, 2:00 PM",
              amount: "\$180",
              bonus: "+\$25",
              dateColor: Colors.green,
            ),
            _recentBonusItem(
              job: "Plumbing Emergency",
              name: "Omar Abdullah",
              time: "Nov 2, 2025",
              amount: "\$200",
              bonus: "+\$30",
              dateColor: Colors.green,
            ),
            _recentBonusItem(
              job: "HVAC Installation",
              name: "Amadou Diallo",
              time: "Nov 2, 2025",
              amount: "\$350",
              bonus: "+\$75",
              dateColor: Colors.green,
            ),
            _recentBonusItem(
              job: "Electrical Panel Upgrade",
              name: "Sidi Mohamed",
              time: "Nov 1, 2025",
              amount: "\$280",
              bonus: "+\$140",
              dateColor: Colors.green,
            ),

          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // HEADER
  // -------------------------------------------------------
  Widget _header() {
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
                    Icon(Icons.file_download_outlined,
                        color: Colors.white70, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      "Export",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.sp,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),

          SizedBox(height: 6.h),

          Text(
            "Track your bonus earnings",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 18.h),

          // TOTAL BONUSES CARD
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "\$4,820",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "+8.5% from last month",
                  style: TextStyle(
                    color: Color(0xFF05DF72),
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

  // -------------------------------------------------------
  // TODAY / WEEK / MONTH ROW
  // -------------------------------------------------------
  Widget _statsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statBox(
          title: "Today",
          value: "\$16.50",
          icon: Icons.attach_money,
          bgColor: const Color(0xFFE8FEEA),
          // light green
          iconColor: const Color(0xFF4CAF50), // green
        ),
        _statBox(
          title: "This Week (5%)",
          value: "\$37.25",
          icon: Icons.trending_up,
          bgColor: const Color(0xFFEAF3FF),
          // light blue
          iconColor: const Color(0xFF2979FF), // blue
        ),
        _statBox(
          title: "This Month",
          value: "\$142",
          icon: Icons.calendar_month,
          bgColor: const Color(0xFFF5E8FF),
          // light purple
          iconColor: const Color(0xFF9C27B0), // purple
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
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black54,
            ),
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

  // -------------------------------------------------------
  // AVAILABLE BONUS (Blue Card)
  // -------------------------------------------------------
  Widget _availableBonusCard() {
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Icon with Background ----
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

              // ---- Texts ----
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

          // ---- Amount ----
          Text(
            "\$37.25",
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            "5 jobs × 5% bonus",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.85),
            ),
          ),

          SizedBox(height: 20.h),

          // ---- Early Payout Button ----
          _earlyPayoutButton(),

          SizedBox(height: 12.h),

          // ---- Regular Payout Info ----
          Center(
            child: Text(
              "Regular payout: Every Monday",
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
          Icon(
            Icons.attach_money,
            color: const Color(0xFF0A77FF),
            size: 20.sp,
          ),
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

  Widget _bonusRateCard() {
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
          // ---- Header icon + title ----
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
                  Icons.workspace_premium_outlined, // ribbon-like icon
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Bonus Rate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "For internal employees",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              )
            ],
          ),

          SizedBox(height: 20.h),

          // ---- 5% Per Job ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "5",
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
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              )
            ],
          ),

          SizedBox(height: 20.h),

          // ---- Info Box ----
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
                    "Earn 5% bonus on every verified job completion. Bonuses are paid every Monday, with early payout available during the week for urgent needs.",
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


  // -------------------------------------------------------
  // MONTHLY SALARY (Green Card)
  // -------------------------------------------------------
  Widget monthlySalaryCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0CCE6B),
            Color(0xFF00B95A),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Title
          Text(
            "Monthly Salary",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),

          /// Amount + Icon Box
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "\$2,400",
                style: TextStyle(
                  fontSize: 32.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),

              /// Icon Background
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.rectangle,
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

          /// Inner small container like your design
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
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "\$2,400",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Text(
                      "This Month Bonus",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "+\$142",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
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


  // -------------------------------------------------------
  // RECENT BONUSES HEADER
  // -------------------------------------------------------
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

  // -------------------------------------------------------
  // RECENT BONUS ITEM
  // -------------------------------------------------------
  Widget _recentBonusItem({
    required String job,
    required String name,
    required String time,
    required String amount,
    required String bonus,
    required Color dateColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- TOP ROW ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Left text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),

              /// Right amount & bonus
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    bonus,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 5.h),

          /// ---------- DIVIDER ----------
          Container(
            height: 1,
            color: Colors.black12,
            width: double.infinity,
          ),

           SizedBox(height: 5.h),

          /// ---------- BOTTOM ROW ----------
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black38,
                ),
              ),
              const Spacer(),

              /// Right green icon
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}