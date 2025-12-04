import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Same roles as React: 'customer' | 'freelancer' | 'internal'
enum UserRole { customer, freelancer, internal }

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.onRoleSelect});
  static const String routeName = '/';

  final ValueChanged<UserRole> onRoleSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420.w,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Header(),
                        SizedBox(height: 16.h),
                        // Role cards
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, // Keep this for wider screens
                              vertical: 8, // Keep this for wider screens
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'select_your_role'.tr(),
                                  style: const TextStyle(
                                    fontSize: 16, // or 16.sp
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 16.h),

                                // CUSTOMER
                                _RoleCard(
                                  title: 'customer'.tr(),
                                  description:
                                  'book_and_manage_service_requests'.tr(),
                                  gradientColors: const [
                                    Color(0xFFC20001),
                                    Color(0xFF9A0001),
                                  ],
                                  icon: Icons.group,
                                  onTap: () => onRoleSelect(
                                    UserRole.customer,
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // FREELANCER TECHNICIAN
                                _RoleCard(
                                  title: 'freelancer_technician'.tr(),
                                  description:
                                  'accept_jobs_and_earn_commissions'.tr(),
                                  gradientColors: const [
                                    Color(0xFFFFB111),
                                    Color(0xFFE69F0F),
                                  ],
                                  icon: Icons.build_rounded,
                                  onTap: () =>
                                      onRoleSelect(UserRole.freelancer),
                                ),
                                SizedBox(height: 12.h),

                                // INTERNAL TECHNICIAN
                                _RoleCard(
                                  title: 'internal_technician'.tr(),
                                  // ei key ta na thakle, chaile
                                  // 'manage_assignments_performance'.tr() use korte paro
                                  description:
                                  'manage_assignments_performance'.tr(),
                                  gradientColors: const [
                                    Color(0xFF374151),
                                    Color(0xFF111827),
                                  ],
                                  icon: Icons.manage_accounts_rounded,
                                  onTap: () => onRoleSelect(UserRole.internal),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
      ).copyWith(top: 32.h, bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // TODO: change to your real asset path
          Image.asset(
            'assets/images/Logo.png',
            height: 80.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.h),
          Text(
            'field_service_management_platform'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13, // or 13.sp
              color: Color(0xFF6B7280),
            ),
          ),
          // language selector jodi chai pore ekhane add korte parba
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final List<Color> gradientColors;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.black.withOpacity(0.04),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, // already translated
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description, // already translated
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.3,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18.sp,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// /// Same roles as React: 'customer' | 'freelancer' | 'internal'
// enum UserRole { customer, freelancer, internal }
//
// class RoleSelectionScreen extends StatelessWidget {
//   const RoleSelectionScreen({super.key, required this.onRoleSelect});
//   static final String routeName = '/';
//
//   final ValueChanged<UserRole> onRoleSelect;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F8F8),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return Center(
//               child: SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxWidth: 420.w,
//                     minHeight: constraints.maxHeight,
//                   ),
//                   child: IntrinsicHeight(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         _Header(),
//                         SizedBox(height: 16.h),
//                         // Role cards
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24, // Keep this for wider screens
//                               vertical: 8, // Keep this for wider screens
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   // LKeys.hello.tr(),
//                                   // "hello".tr(),
//                                   'Select Your Role',
//                                   style: TextStyle(
//                                     fontSize:
//                                         16, // This can remain as is, or use .sp
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF111827),
//                                   ),
//                                 ),
//                                 SizedBox(height: 16.h),
//                                 _RoleCard(
//                                   title: 'Customer',
//                                   description:
//                                       'Book and manage service requests',
//                                   gradientColors: const [
//                                     Color(0xFFC20001),
//                                     Color(0xFF9A0001),
//                                   ],
//                                   icon: Icons.group,
//                                   onTap: () => onRoleSelect(
//                                     UserRole.customer,
//                                   ), // customer
//                                 ),
//                                 SizedBox(height: 12.h),
//                                 _RoleCard(
//                                   title: 'Freelancer Technician',
//                                   description:
//                                       'Accept jobs and earn commissions',
//                                   gradientColors: const [
//                                     Color(0xFFFFB111),
//                                     Color(0xFFE69F0F),
//                                   ],
//                                   icon: Icons.build_rounded,
//                                   onTap: () =>
//                                       onRoleSelect(UserRole.freelancer),
//                                 ),
//                                 SizedBox(height: 12.h),
//                                 _RoleCard(
//                                   title: 'Internal Technician',
//                                   description:
//                                       'Manage assigned jobs and schedule',
//                                   gradientColors: const [
//                                     Color(0xFF374151),
//                                     Color(0xFF111827),
//                                   ],
//                                   icon: Icons.manage_accounts_rounded,
//                                   onTap: () => onRoleSelect(UserRole.internal),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         // Footer
//                         const Padding(
//                           padding: EdgeInsets.fromLTRB(
//                             24, // Keep this for wider screens
//                             8, // Keep this for wider screens
//                             24, // Keep this for wider screens
//                             24, // Keep this for wider screens
//                           ),
//                           child: Column(
//                             children: [
//                               Text(
//                                 'Version 1.0.0',
//                                 style: TextStyle(
//                                   fontSize:
//                                       11, // This can remain as is, or use .sp
//                                   color: Color(0xFF9CA3AF),
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 '© 2025 IBACOS Services',
//                                 style: TextStyle(
//                                   fontSize:
//                                       11, // This can remain as is, or use .sp
//                                   color: Color(0xFF9CA3AF),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class _Header extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: 24.w,
//       ).copyWith(top: 32.h, bottom: 24.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(24.r),
//           bottomRight: Radius.circular(24.r),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 16.r,
//             offset: Offset(0, 6.h),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // TODO: change to your real asset path
//           Image.asset(
//             'assets/images/Logo.png',
//             height: 80.h,
//             fit: BoxFit.contain,
//           ),
//           SizedBox(height: 12.h),
//           const Text(
//             'Field Service Management Platform',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13,
//               color: Color(0xFF6B7280),
//             ), // or 13.sp
//           ),
//           // language selector jodi chai pore ekhane add korte parba
//         ],
//       ),
//     );
//   }
// }
//
// class _RoleCard extends StatelessWidget {
//   const _RoleCard({
//     required this.title,
//     required this.description,
//     required this.gradientColors,
//     required this.icon,
//     required this.onTap,
//   });
//
//   final String title;
//   final String description;
//   final List<Color> gradientColors;
//   final IconData icon;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         splashColor: Colors.black.withOpacity(0.04),
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Row(
//             children: [
//               Container(
//                 width: 56.w,
//                 height: 56.w,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(18.r),
//                   gradient: LinearGradient(
//                     colors: gradientColors,
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.18),
//                       blurRadius: 10.r,
//                       offset: Offset(0, 5.h),
//                     ),
//                   ],
//                 ),
//                 child: Icon(icon, color: Colors.white, size: 28.sp),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w600,
//                         color: const Color(0xFF111827),
//                       ),
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       description,
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         height: 1.3,
//                         color: const Color(0xFF6B7280),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 18.sp,
//                 color: const Color(0xFF9CA3AF),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
