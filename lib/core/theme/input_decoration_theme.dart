import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/core/constants/color_control/all_color.dart';

InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: AllColor.grey200,
  contentPadding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 20.w),
  // prefixIconColor: Colors.grey,
  hintStyle: TextStyle(color: AllColor.grey, fontSize: 14.sp,fontWeight: FontWeight.w400,),
  suffixIconColor: Colors.grey,
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(color: AllColor.lightBlue, width: 0.5.sp),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(color: AllColor.red200, width: 0.5.sp),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(color: AllColor.red200, width: 0.5.sp),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(color: AllColor.red200, width: 0.5.sp),
  ),
  errorStyle: TextStyle(fontSize: 12.sp, color: Colors.red),

);
