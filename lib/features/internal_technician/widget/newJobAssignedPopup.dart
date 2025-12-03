import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/internal_technician/widget/gPSCheckInPopup.dart';

/// --------------------- COLORS ------------------------
const kDialogBg = Color(0xFFF4F4F4);
const kCardBg = Colors.white;
const kTextMain = Color(0xFF222222);
const kTextMuted = Color(0xFF9E9E9E);
const kTextSubtle = Color(0xFFB0B0B0);
const kPrimaryGreen = Color(0xFF00B357);
const kPrimaryRed = Color(0xFFE60000);
const kBorderLight = Color(0xFFE5E5E5);
const kPrimaryYellow = Color(0xFFFFD966);

class NewJobAssignedPopup extends StatefulWidget {
  const NewJobAssignedPopup({super.key});

  @override
  State<NewJobAssignedPopup> createState() => _NewJobAssignedPopupState();
}

class _NewJobAssignedPopupState extends State<NewJobAssignedPopup> {
  int secondsLeft = 20;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      if (secondsLeft == 0) return false;

      setState(() {
        secondsLeft--;
      });

      return secondsLeft > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340.w,
        decoration: BoxDecoration(
          color: kDialogBg,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                SizedBox(height: 16.h),
                _bellIcon(),
                SizedBox(height: 12.h),
                _titleText(),
                SizedBox(height: 4.h),
                _subtitleText(),
                SizedBox(height: 8.h),
                _timerText(),
                SizedBox(height: 16.h),
                _jobCard(),
                SizedBox(height: 20.h),
                _bottomButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // HEADER + CLOSE
  // ------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 30),
        Expanded(
          child: Text(
            "",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.close, size: 22.sp, color: Colors.grey.shade700),
        )
      ],
    );
  }

  // ------------------------------------------------------
  // BELL ICON
  // ------------------------------------------------------
  Widget _bellIcon() {
    return Container(
      height: 60.w,
      width: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.shade50,
      ),
      child: Icon(Icons.notifications_active_rounded,
          color: Colors.red.shade600, size: 32.sp),
    );
  }

  // ------------------------------------------------------
  // TITLE + SUBTITLE
  // ------------------------------------------------------
  Widget _titleText() {
    return Text(
      "New Job Assigned!",
      style: TextStyle(
        color: kTextMain,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _subtitleText() {
    return Text(
      "You have 20 seconds to respond",
      style: TextStyle(
        color: kTextMuted,
        fontSize: 12.sp,
      ),
    );
  }

  // ------------------------------------------------------
  // TIMER TEXT
  // ------------------------------------------------------
  Widget _timerText() {
    return Text(
      "00:${secondsLeft.toString().padLeft(2, '0')}",
      style: TextStyle(
        fontSize: 28.sp,
        color: kPrimaryRed,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ------------------------------------------------------
  // JOB CARD
  // ------------------------------------------------------
  Widget _jobCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE + PRIORITY CHIP
          Row(
            children: [
              Expanded(
                child: Text(
                  "Electrical Safety Check",
                  style: TextStyle(
                    color: kTextMain,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0C2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "MEDIUM",
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),
          Text(
            "Electrical",
            style: TextStyle(
              color: Colors.red,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 12.h),

          // ------------------- PERSON -------------------
          Row(
            children: [
              Icon(Icons.person_rounded, size: 16.sp, color: kTextMuted),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  "Fatima Hassan\n+222 45 23 45 67",
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.3,
                    color: kTextMain,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ------------------- LOCATION -------------------
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 16.sp, color: Colors.red),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  "Rue 15, Ksar, Nouakchott",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kTextMain,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ------------------- DATE/TIME -------------------
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 16.sp, color: Colors.blue),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  "Nov 5, 2025 at 4:30 PM",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: kTextMain,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // ------------------- DESCRIPTION -------------------
          Text(
            "Comprehensive electrical safety inspection.",
            style: TextStyle(
              fontSize: 12.sp,
              color: kTextMain,
            ),
          ),

          SizedBox(height: 16.h),

          // ------------------- PAYMENT CARD -------------------
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE7FAF0), Color(0xFFF4FFF9)],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _paymentRow("Job Payment", "\$150"),
                SizedBox(height: 6.h),
                _paymentRow("Your Bonus (5%)", "+\$7.50"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: kTextMain),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryGreen,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------
  // BUTTONS
  // ------------------------------------------------------
  Widget _bottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: kCardBg,
                border: Border.all(color: kBorderLight),
              ),
              alignment: Alignment.center,
              child: Text(
                "Decline",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Gpscheckinpopup(),
              );

            },
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: kPrimaryGreen,
              ),
              alignment: Alignment.center,
              child: Text(
                "Accept Job",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
