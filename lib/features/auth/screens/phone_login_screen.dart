// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:workpleis/features/auth/screens/otp_verify_screen.dart';
// import 'package:workpleis/features/auth/widgets/Customer_portal_top_section.dart';
//
// class PhoneLoginScreen extends StatelessWidget {
//   const PhoneLoginScreen({super.key});
//   static final String routeName = '/customer-phone-login';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F5F9),
//       body: Column(
//         children: [
//           // ---------- TOP LOGO CARD ----------
//           RoleSelectionCard(),
//
//           SizedBox(height: 24.h),
//
//           // ---------- CENTER CARD ----------
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: Column(
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(24.r),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 16.r,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Center(
//                           child: Text(
//                             'Welcome Back',
//                             style: TextStyle(
//                               fontSize: 20.sp,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFF333333),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Center(
//                           child: Text(
//                             'Enter your phone number to login',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               color: Color(0xFF757575),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 24.h),
//
//                         Text(
//                           'Phone Number',
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             fontWeight: FontWeight.w500,
//                             color: Color(0xFF555555),
//                           ),
//                         ),
//                         SizedBox(height: 8.h),
//
//                         // ---- PHONE TEXT FIELD ----
//                         SizedBox(
//                           height: 48.h,
//                           child: TextField(
//                             keyboardType: TextInputType.phone,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: const Color(0xFFF7F7F7),
//                               hintText: 'Enter your phone number',
//                               hintStyle: TextStyle(
//                                 fontSize: 13.sp,
//                                 color: Color(0xFFB0B0B0),
//                               ),
//                               prefixIcon: Icon(
//                                 Icons.phone_outlined,
//                                 size: 20.sp,
//                                 color: Color(0xFFB0B0B0),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 0,
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xFFE0E0E0),
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xFFCF2626),
//                                   width: 1.4,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: 24.h),
//
//                         // ---- SEND OTP BUTTON ----
//                         SizedBox(
//                           width: double.infinity,
//                           height: 55.h,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               context.push(OtpVerifyScreen.routeName);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               elevation: 0,
//                               backgroundColor: const Color(0xFFCF2626),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                             ),
//                             child: Text(
//                               'Send OTP',
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: 16.h),
//
//                         // ---- SIGNUP TEXT ----
//                         Center(
//                           child: RichText(
//                             text: TextSpan(
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 color: Color(0xFF757575),
//                               ),
//                               children: [
//                                 TextSpan(text: "Don't have an account? "),
//                                 TextSpan(
//                                   text: 'Sign up',
//                                   style: TextStyle(
//                                     color: Color(0xFFCF2626),
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // ---------- BOTTOM BACK BUTTON ----------
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//             child: SizedBox(
//               width: double.infinity,
//               height: 48.h,
//               child: TextButton(
//                 onPressed: () {
//                   // TODO: Navigator.pop(context);
//                 },
//                 style: TextButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30.r),
//                   ),
//                   foregroundColor: const Color(0xFF333333),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.arrow_back, size: 18),
//                     SizedBox(width: 8.w),
//                     Text(
//                       'Back',
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
