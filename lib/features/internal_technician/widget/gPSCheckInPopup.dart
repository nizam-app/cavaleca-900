import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// ---------------- COLORS ----------------
const kDialogBg = Color(0xFFF4F4F4);
const kCardBg = Colors.white;
const kTextMain = Color(0xFF222222);
const kTextMuted = Color(0xFF9E9E9E);
const kPrimaryBlue = Color(0xFF2563EB);
const kBorderLight = Color(0xFFE5E5E5);
const kPrimaryRed = Color(0xFFE60000);

class Gpscheckinpopup extends StatelessWidget {
  const Gpscheckinpopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340.w,
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(28.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ----------- TITLE -----------
            Text(
              "GPS Check-In Required",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: kTextMain,
              ),
            ),
            SizedBox(height: 6.h),

            Text(
              "Verify your location at the job site to start working",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: kTextMuted,
              ),
            ),

            SizedBox(height: 28.h),

            // ----------- LOTTIE / ICON -----------
            Container(
              height: 100.w,
              width: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade50,
              ),
              child: Center(
                child: Icon(
                  Icons.navigation_rounded,    // <-- replace with Lottie later
                  size: 48.sp,
                  color: Colors.blue.shade400,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              "Click below to verify your location",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: kTextMain,
              ),
            ),

            SizedBox(height: 24.h),

            // ----------- LOCATION CARD -----------
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18.sp, color: Colors.red),
                      SizedBox(width: 6.w),
                      Text(
                        "Job Location",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Rue 15, Ksar, Nouakchott",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: kTextMain,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ----------- VERIFY BUTTON -----------
            GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                height: 50.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kPrimaryBlue,
                  borderRadius: BorderRadius.circular(26.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.navigation_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Verify Location",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
