// import 'package:flutter/material.dart';
//
// class GuestProfileScreen extends StatelessWidget {
//   const GuestProfileScreen({super.key});
//   static final routeName = '/guest-profile';
//
//   @override
//   Widget build(BuildContext context) {
//     const redTop = Color(0xFFD4161F);
//     const orangeCard = Color(0xFFF4A623);
//     const bgColor = Color(0xFFF4F5F9);
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.only(bottom: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // ---------- TOP RED HEADER ----------
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 18,
//                 ),
//                 decoration: const BoxDecoration(
//                   color: redTop,
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(0),
//                     bottomRight: Radius.circular(0),
//                   ),
//                 ),
//                 child: const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Profile',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       'Guest Account',
//                       style: TextStyle(color: Colors.white70, fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // ---------- GUEST USER CARD ----------
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 14,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 44,
//                         height: 44,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFE0E0E0),
//                           borderRadius: BorderRadius.circular(22),
//                         ),
//                         alignment: Alignment.center,
//                         child: const Text(
//                           'GU',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF757575),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Guest User',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF333333),
//                             ),
//                           ),
//                           SizedBox(height: 2),
//                           Text(
//                             'Limited access',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF9E9E9E),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // ---------- CREATE ACCOUNT BIG CARD ----------
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 22,
//                   ),
//                   decoration: BoxDecoration(
//                     color: orangeCard,
//                     borderRadius: BorderRadius.circular(22),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 52,
//                         height: 52,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white.withOpacity(0.2),
//                         ),
//                         alignment: Alignment.center,
//                         child: const Icon(
//                           Icons.person_outline,
//                           color: Colors.white,
//                           size: 32,
//                         ),
//                       ),
//                       const SizedBox(height: 14),
//                       const Text(
//                         'Create Account',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       const Text(
//                         'Sign up to unlock all features',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 12, color: Colors.white70),
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 44,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // TODO: navigate to sign up
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(24),
//                             ),
//                           ),
//                           child: const Text(
//                             'Sign Up Now',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: redTop,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // ---------- LANGUAGE CARD ----------
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: _SettingTile(
//                   icon: Icons.language,
//                   iconBg: const Color(0xFFF5F5F5),
//                   title: 'Language',
//                   subtitle: 'English',
//                   onTap: () {
//                     // TODO: language selection
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // ---------- SUPPORT TITLE ----------
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24),
//                 child: Text(
//                   'Support',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF757575),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//
//               // ---------- CALL US ----------
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: _SettingTile(
//                   icon: Icons.phone_in_talk_outlined,
//                   iconBg: const Color(0xFFF5F5F5),
//                   title: 'Call Us',
//                   subtitle: '+1 (800) 123-4567',
//                   onTap: () {
//                     // TODO: call
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//
//               // ---------- EMAIL SUPPORT ----------
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: _SettingTile(
//                   icon: Icons.email_outlined,
//                   iconBg: const Color(0xFFF5F5F5),
//                   title: 'Email Support',
//                   subtitle: 'support@ibacos.com',
//                   onTap: () {
//                     // TODO: email
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // ---------- BUSINESS HOURS CARD ----------
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     color: orangeCard,
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Business Hours',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       _HoursRow(
//                         day: 'Monday - Friday',
//                         time: '8:00 AM - 8:00 PM',
//                       ),
//                       SizedBox(height: 4),
//                       _HoursRow(day: 'Saturday', time: '9:00 AM - 6:00 PM'),
//                       SizedBox(height: 4),
//                       _HoursRow(day: 'Sunday', time: '10:00 AM - 4:00 PM'),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // ---------- EXIT GUEST MODE ----------
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: TextButton.icon(
//                   onPressed: () {
//                     // TODO: exit guest mode
//                   },
//                   style: TextButton.styleFrom(
//                     foregroundColor: redTop,
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 10,
//                       horizontal: 8,
//                     ),
//                   ),
//                   icon: const Icon(Icons.logout, size: 18),
//                   label: const Text(
//                     'Exit Guest Mode',
//                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ---------- SMALL WIDGETS ----------
//
// class _SettingTile extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final String title;
//   final String? subtitle;
//   final VoidCallback? onTap;
//
//   const _SettingTile({
//     required this.icon,
//     required this.iconBg,
//     required this.title,
//     this.subtitle,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: onTap,
//         splashColor: Colors.black12,
//         borderRadius: BorderRadius.circular(18),
//         child: Row(
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: iconBg,
//                 borderRadius: BorderRadius.circular(17),
//               ),
//               child: Icon(icon, size: 20, color: const Color(0xFF757575)),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF333333),
//                     ),
//                   ),
//                   if (subtitle != null) ...[
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle!,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFF9E9E9E),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.arrow_forward_ios,
//               size: 14,
//               color: Color(0xFFB0B0B0),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _HoursRow extends StatelessWidget {
//   final String day;
//   final String time;
//
//   const _HoursRow({required this.day, required this.time});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             day,
//             style: const TextStyle(fontSize: 12, color: Colors.white),
//           ),
//         ),
//         Text(time, style: const TextStyle(fontSize: 12, color: Colors.white)),
//       ],
//     );
//   }
// }
