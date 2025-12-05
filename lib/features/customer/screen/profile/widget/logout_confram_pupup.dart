// import 'package:flutter/material.dart';
//
// Future<void> _confirmAndLogout() async {
//   final isGuest = widget.isGuest;
//
//   final bool? confirm = await showDialog<bool>(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Confirm'),
//         content: Text(
//           isGuest
//               ? 'Do you want to exit guest mode?'
//               : 'Are you sure you want to sign out?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text(
//               'Yes',
//               style: TextStyle(color: Color(0xFFC20001)),
//             ),
//           ),
//         ],
//       );
//     },
//   );
//
//   if (confirm != true) return;
//
//   try {
//     if (!isGuest) {
//       // real user logout
//       await CustomerAuthApi.logout();
//       _showToast('Logout successful');
//     } else {
//       _showToast('Exited guest mode');
//     }
//
//     // local state / navigation parent ke handle korte dao
//     if (widget.onLogout != null) {
//       widget.onLogout!();
//     } else {
//       // fallback: go back to role selection / auth screen
//       Navigator.of(context).pop();
//     }
//   } catch (e) {
//     _showToast('Logout failed: $e', success: false);
//   }
// }
