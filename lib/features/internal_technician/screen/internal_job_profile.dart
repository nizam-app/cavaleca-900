import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/core/widget/signOutButton.dart';

import '../../auth/screens/role/screen/role_selection_screen.dart';

import 'package:easy_localization/easy_localization.dart';

/// ------------------ COLORS ------------------
const kBG = Color(0xFFF4F4F4);
const kCard = Colors.white;
const kTextMain = Color(0xFF1F1F1F);
const kTextMuted = Color(0xFF9E9E9E);
const kDarkHeader = Color(0xFF1E2432);
const kBorderLight = Color(0xFFEAEAEA);

class InternalJobProfile extends StatelessWidget {
  const InternalJobProfile({super.key});
  static const String routeName = '/internal-jobProfile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBG,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _headerSection(),
            SizedBox(height: 16.h),
            _profileCard(),
            SizedBox(height: 16.h),
            _employmentDetails(),
            SizedBox(height: 16.h),
            _specializations(),
            SizedBox(height: 16.h),
            _settingsItems(),
            SizedBox(height: 40.h),
            Signoutbutton(
              onTap: () {
                // TODO: auth logout logic
                context.push(RoleSelectionScreen.routeName);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out')),
                );
              },
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Header Section
  // ----------------------------------------------------
  Widget _headerSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: kTextMain,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22.r),
          bottomRight: Radius.circular(22.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "profile".tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "manage_account_info".tr(),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Profile Card
  // ----------------------------------------------------
  Widget _profileCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              _circleAvatar("LB"),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "lisa_brown".tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: kTextMain,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "internal_technician_label".tr(),
                      style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                    ),
                    Text(
                      "employee_id".tr(),
                      style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _simpleButton("edit_profile".tr()),
        ],
      ),
    );
  }

  Widget _circleAvatar(String txt) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Center(
        child: Text(
          txt,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
    );
  }

  Widget _simpleButton(String text) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: kBorderLight,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: kBorderLight),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Employment Details Card
  // ----------------------------------------------------
  Widget _employmentDetails() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "employment_details".tr(),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kTextMain,
            ),
          ),
          SizedBox(height: 14.h),
          _rowItem("department".tr(), "field_services".tr()),
          SizedBox(height: 10.h),
          _rowItem("join_date".tr(), "Jan 15, 2023"),
          SizedBox(height: 10.h),
          _rowItem("position".tr(), "Senior Technician"),
        ],
      ),
    );
  }

  Widget _rowItem(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: TextStyle(fontSize: 13.sp, color: kTextMuted)),
        Text(
          right,
          style: TextStyle(
            fontSize: 13.sp,
            color: kTextMain,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // Specializations
  // ----------------------------------------------------
  Widget _specializations() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "specializations".tr(),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: kTextMain,
            ),
          ),
          SizedBox(height: 14.h),

          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _chip("hvac_systems".tr(), Colors.blue.shade100, Colors.blue.shade900),
              _chip("electrical".tr(), Colors.yellow.shade100, Colors.orange.shade800),
              _chip("plumbing".tr(), Colors.green.shade100, Colors.green.shade700),
              _chip("maintenance".tr(), Colors.purple.shade100, Colors.purple.shade700),
              _chip("emergency_repair".tr(), Colors.red.shade100, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Updated Settings List (With Background Icons)
  // ----------------------------------------------------
  Widget _settingsItems() {
    return Column(
      children: [
        _listItem(
          Icons.calendar_month,
          "time_off_requests",
          "2 pending",
          const Color(0xFFE8F0FF),    // Light blue background
          const Color(0xFF2563EB),    // Blue icon
        ),
        _listItem(
          Icons.workspace_premium,
          "certifications".tr(),
          "8 active",
          const Color(0xFFFFF4D9),    // Soft yellow
          Colors.orange,              // Orange icon
        ),
        _listItem(
          Icons.work_history_rounded,
          "work_history".tr(),
          "view".tr(),
          const Color(0xFFF3E8FF),    // Purple background
          Colors.purple,
        ),
        _listItem(
          Icons.language,
          "language".tr(),
          "English",
          const Color(0xFFE8FFF4),    // Mint green
          Colors.green,
        ),
        _listItem(
          Icons.support_agent,
          "support".tr(),
          "",
          const Color(0xFFFFF0E0),    // Soft Orange
          Colors.deepOrange,
        ),
      ],
    );
  }

  Widget _listItem(IconData icon, String title, String subtitle, Color bgColor, Color iconColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 40.w,
            width: 40.w,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 22.sp, color: iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 14.sp, fontWeight: FontWeight.w600, color: kTextMain),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                  ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: kTextMuted),
        ],
      ),
    );
  }
  // ----------------------------------------------------
  // Card Decoration
  // ----------------------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(18.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
