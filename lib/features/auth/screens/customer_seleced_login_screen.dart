import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/auth/logic/check_login_screen.dart';
import 'package:workpleis/features/auth/logic/screen_check_enum.dart';
import 'package:workpleis/features/auth/screens/customer_create_account_screen.dart';
import 'package:workpleis/features/auth/screens/phone_login_screen.dart';

import '../widgets/customer_portal_top_section.dart';

class CustomerLoginSceled extends ConsumerWidget {
  const CustomerLoginSceled({super.key});
  static const String routeName = '/customer-portal';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔝 top card – SAME AS BEFORE
              const RoleSelectionCard(),

              SizedBox(height: 24.h),

              // ---------- MIDDLE CARD (pixel-perfect) ----------
              Padding(
                // card একটু narrow করতে horizontal padding বাড়ালাম
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 22.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF333333),
                          letterSpacing: 0.2,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // Subtitle
                      Text(
                        'Book services quickly and easily',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.3,
                          color: const Color(0xFF80848C),
                        ),
                      ),

                      SizedBox(height: 22.h),

                      // 🟡 Continue as Guest
                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(screenCheckProvider.notifier).state =
                                ScreenName.guest;
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFF4A623),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Continue as Guest',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 18.h),

                      // --- OR divider ---
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE5E5E5),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFFB0B0B0),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE5E5E5),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18.h),

                      // 🔴 Login button (white + red border)
                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(screenCheckProvider.notifier).state =
                                ScreenName.login;
                            context.push(PhoneLoginScreen.routeName);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFCF2626),
                              width: 1.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Login to Your Account',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFCF2626),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // 🔴 Create New Account
                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(screenCheckProvider.notifier).state =
                                ScreenName.register;
                            context.push(CustomerCreateAccountScreen.routeName);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFCF2626),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Create New Account',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 18.h),

                      // Note
                      Text(
                        'Guest bookings are limited. Create an account to\ntrack your service history.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.3,
                          color: const Color(0xFFB0B0B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 80.h),

              // ---------- BOTTOM BACK BUTTON ----------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      foregroundColor: const Color(0xFF333333),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Back to Role Selection',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
}
