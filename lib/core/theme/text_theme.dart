import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/core/constants/color_control/all_color.dart';

TextTheme get textTheme {
  return TextTheme(
    titleLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: 12.sp,
      color: AllColor.grey,
      fontWeight: FontWeight.w400,
      // letterSpacing: 1
    ),
    titleSmall: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,

    ),
    headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AllColor.black),
    headlineMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400
    ),


  );
}
